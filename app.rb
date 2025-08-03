# app.rb
require 'sinatra'
require 'json'
require 'net/http'
require 'uri'
require 'time'
require 'fileutils' # Added for FileUtils

# Remove hardcoded bind/port for deployment compatibility
# set :bind, '0.0.0.0'
# set :port, 4567

CACHE_FILE = "cache/prayer_times.json"
DATASET_ID = "d_e81ea2337599b674c4f645c1af93e0dc" # placeholder, update to correct one

def fetch_data_from_api(date = nil)
  # Use provided date or default to today
  target_date = date || Date.today.strftime("%Y-%m-%d")
  filters = {"Date" => target_date}
  encoded = URI.encode_www_form_component(filters.to_json)
  url = "https://data.gov.sg/api/action/datastore_search?resource_id=#{DATASET_ID}&filters=#{encoded}&limit=9999"

  begin
    res = Net::HTTP.get(URI(url))
    json = JSON.parse(res)
    
    # Ensure cache directory exists
    FileUtils.mkdir_p(File.dirname(CACHE_FILE))
    
    # Read existing cache or create new structure
    existing_cache = if File.exist?(CACHE_FILE)
      JSON.parse(File.read(CACHE_FILE))
    else
      { "result" => { "records" => [] } }
    end
    
    # Merge new data with existing cache
    new_records = json.dig("result", "records") || []
    existing_records = existing_cache.dig("result", "records") || []
    
    # Remove any existing record for the same date to avoid duplicates
    existing_records.reject! { |record| record["Date"] == target_date }
    
    # Add new records
    existing_records.concat(new_records)
    
    # Update the cache structure
    existing_cache["result"]["records"] = existing_records
    existing_cache["last_updated"] = Time.now.iso8601
    
    File.write(CACHE_FILE, JSON.pretty_generate(existing_cache))
    existing_cache
  rescue => e
    puts "Error fetching data: #{e.message}"
    # Return cached data if available, otherwise raise
    if File.exist?(CACHE_FILE)
      JSON.parse(File.read(CACHE_FILE))
    else
      raise e
    end
  end
end

def cached_data
  if File.exist?(CACHE_FILE)
    cache_data = JSON.parse(File.read(CACHE_FILE))
    last_updated = cache_data["last_updated"]
    
    # Check if cache is from today and has data for today
    today = Date.today.strftime("%Y-%m-%d")
    today_record = cache_data.dig("result", "records")&.find { |r| r["Date"] == today }
    
    # If cache is stale (not from today) or missing today's data, refresh
    if last_updated.nil? || 
       Date.parse(last_updated) != Date.today || 
       today_record.nil?
      puts "Cache is stale or missing today's data, refreshing..."
      fetch_data_from_api
    else
      cache_data
    end
  else
    fetch_data_from_api
  end
end

get '/' do
  send_file 'public/index.html'
end

get '/health' do
  content_type :json
  {
    status: 'ok',
    timestamp: Time.now.iso8601,
    cache_exists: File.exist?(CACHE_FILE),
    cache_size: File.exist?(CACHE_FILE) ? File.size(CACHE_FILE) : 0,
    today: Date.today.strftime("%Y-%m-%d")
  }.to_json
end

get '/api/prayer-times' do
  content_type :json
  
  begin
    data = cached_data
    records = data.dig("result", "records") || []

    today = Date.today.strftime("%Y-%m-%d")
    today_record = records.find { |r| r["Date"] == today }

    if today_record
      formatted = {
        date: today_record["Date"],
        subuh: today_record["Subuh"],
        syuruk: today_record["Syuruk"],
        zuhur: today_record["Zohor"],
        asar: today_record["Asar"],
        maghrib: today_record["Maghrib"],
        isyak: today_record["Isyak"]
      }

      JSON.pretty_generate([formatted])  # frontend expects array
    else
      status 404
      JSON.pretty_generate({ error: "No data found for today (#{today})" })
    end
  rescue => e
    status 500
    JSON.pretty_generate({ error: "Failed to load prayer times: #{e.message}" })
  end
end

# Add endpoint to force refresh cache
get '/api/refresh' do
  content_type :json
  begin
    fetch_data_from_api
    { status: 'success', message: 'Cache refreshed successfully' }.to_json
  rescue => e
    status 500
    { error: "Failed to refresh cache: #{e.message}" }.to_json
  end
end

