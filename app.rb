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

def fetch_data_from_api
  today = Date.today.strftime("%Y-%m-%d")  
  filters = {"Date" => today} # you can set filter like {"date" => "2025-08-02"}
  encoded = URI.encode_www_form_component(filters.to_json)
  url = "https://data.gov.sg/api/action/datastore_search?resource_id=#{DATASET_ID}&filters=#{encoded}&limit=9999"

  begin
    res = Net::HTTP.get(URI(url))
    json = JSON.parse(res)
    
    # Ensure cache directory exists
    FileUtils.mkdir_p(File.dirname(CACHE_FILE))
    File.write(CACHE_FILE, JSON.pretty_generate(json))
    json
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
    modified_time = File.mtime(CACHE_FILE)
    if File.mtime(CACHE_FILE).to_date != Date.today
      fetch_data_from_api
    else
      JSON.parse(File.read(CACHE_FILE))
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
    cache_size: File.exist?(CACHE_FILE) ? File.size(CACHE_FILE) : 0
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

