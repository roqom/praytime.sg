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

# Set timezone to Singapore (UTC+8)
ENV['TZ'] = 'Asia/Singapore'

def get_singapore_date
  # Ensure we're using Singapore timezone
  Time.now.strftime("%Y-%m-%d")
end

def fetch_data_from_api(date = nil)
  # Use provided date or default to today in Singapore timezone
  target_date = date || get_singapore_date
  filters = {"Date" => target_date}
  encoded = URI.encode_www_form_component(filters.to_json)
  url = "https://data.gov.sg/api/action/datastore_search?resource_id=#{DATASET_ID}&filters=#{encoded}&limit=9999"

  puts "Fetching data for date: #{target_date}"
  puts "API URL: #{url}"

  begin
    res = Net::HTTP.get(URI(url))
    json = JSON.parse(res)
    
    puts "API Response: #{json.inspect}"
    
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
    existing_cache["last_fetched_date"] = target_date
    
    File.write(CACHE_FILE, JSON.pretty_generate(existing_cache))
    puts "Cache updated with #{new_records.length} new records"
    existing_cache
  rescue => e
    puts "Error fetching data: #{e.message}"
    puts "Error backtrace: #{e.backtrace.join("\n")}"
    # Return cached data if available, otherwise raise
    if File.exist?(CACHE_FILE)
      JSON.parse(File.read(CACHE_FILE))
    else
      raise e
    end
  end
end

def cached_data
  today = get_singapore_date
  puts "Checking cache for today: #{today}"
  
  if File.exist?(CACHE_FILE)
    cache_data = JSON.parse(File.read(CACHE_FILE))
    last_updated = cache_data["last_updated"]
    last_fetched_date = cache_data["last_fetched_date"]
    
    # Check if cache has data for today
    today_record = cache_data.dig("result", "records")&.find { |r| r["Date"] == today }
    
    puts "Last updated: #{last_updated}"
    puts "Last fetched date: #{last_fetched_date}"
    puts "Today's record found: #{!today_record.nil?}"
    
    # If cache is stale (not from today) or missing today's data, refresh
    if last_updated.nil? || 
       Date.parse(last_updated) != Date.today || 
       last_fetched_date != today ||
       today_record.nil?
      puts "Cache is stale or missing today's data, refreshing..."
      fetch_data_from_api
    else
      puts "Using cached data"
      cache_data
    end
  else
    puts "No cache file found, fetching fresh data"
    fetch_data_from_api
  end
end

get '/' do
  send_file 'public/index.html'
end

get '/health' do
  content_type :json
  today = get_singapore_date
  
  cache_info = if File.exist?(CACHE_FILE)
    cache_data = JSON.parse(File.read(CACHE_FILE))
    records = cache_data.dig("result", "records") || []
    today_record = records.find { |r| r["Date"] == today }
    
    {
      cache_exists: true,
      cache_size: File.size(CACHE_FILE),
      last_updated: cache_data["last_updated"],
      last_fetched_date: cache_data["last_fetched_date"],
      total_records: records.length,
      today_record_exists: !today_record.nil?,
      today_record: today_record
    }
  else
    {
      cache_exists: false,
      cache_size: 0,
      last_updated: nil,
      last_fetched_date: nil,
      total_records: 0,
      today_record_exists: false,
      today_record: nil
    }
  end
  
  {
    status: 'ok',
    timestamp: Time.now.iso8601,
    today: today,
    timezone: ENV['TZ'],
    **cache_info
  }.to_json
end

get '/api/prayer-times' do
  content_type :json
  
  begin
    data = cached_data
    records = data.dig("result", "records") || []

    today = get_singapore_date
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
      JSON.pretty_generate({ 
        error: "No data found for today (#{today})",
        available_dates: records.map { |r| r["Date"] },
        total_records: records.length,
        timezone: ENV['TZ']
      })
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

