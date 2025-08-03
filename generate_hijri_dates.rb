#!/usr/bin/env ruby

# Helper script to generate Hijri date mappings for 2025
# This is a simplified mapping - for accurate dates, you should use a proper Hijri calendar library

require 'date'

# Islamic calendar month names
ISLAMIC_MONTHS = [
  'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
  'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Sha\'ban',
  'Ramadan', 'Shawwal', 'Dhu al-Qadah', 'Dhu al-Hijjah'
]

# Simplified mapping for 2025 (this is approximate - for accurate dates use a proper library)
# Key dates in 2025:
# - January 1, 2025 ≈ Rajab 1, 1446
# - August 1, 2025 ≈ Safar 7, 1447
# - December 31, 2025 ≈ Jumada al-Awwal 10, 1447

def generate_hijri_mapping_2025
  puts "// Generated Hijri date mapping for 2025"
  puts "const hijriDates2025 = {"
  
  # Generate mappings for the entire year
  (1..12).each do |month|
    days_in_month = Date.new(2025, month, 1).next_month.prev_day.day
    
    (1..days_in_month).each do |day|
      gregorian_date = Date.new(2025, month, day)
      
      # Simplified calculation (this is approximate)
      hijri_date = calculate_approximate_hijri(gregorian_date)
      
      date_key = gregorian_date.strftime("%Y-%m-%d")
      puts "  '#{date_key}': { day: #{hijri_date[:day]}, month: '#{hijri_date[:month]}', year: #{hijri_date[:year]} },"
    end
  end
  
  puts "};"
end

def calculate_approximate_hijri(gregorian_date)
  # This is a simplified calculation - for accurate dates, use a proper library
  # Approximate conversion based on known key dates
  
  case gregorian_date.month
  when 1..7
    # January to July 2025 ≈ Rajab to Muharram 1446-1447
    if gregorian_date.month == 1
      { day: gregorian_date.day, month: 'Rajab', year: 1446 }
    elsif gregorian_date.month == 2
      { day: gregorian_date.day, month: 'Sha\'ban', year: 1446 }
    elsif gregorian_date.month == 3
      { day: gregorian_date.day, month: 'Ramadan', year: 1446 }
    elsif gregorian_date.month == 4
      { day: gregorian_date.day, month: 'Shawwal', year: 1446 }
    elsif gregorian_date.month == 5
      { day: gregorian_date.day, month: 'Dhu al-Qadah', year: 1446 }
    elsif gregorian_date.month == 6
      { day: gregorian_date.day, month: 'Dhu al-Hijjah', year: 1446 }
    elsif gregorian_date.month == 7
      { day: gregorian_date.day, month: 'Muharram', year: 1447 }
    end
  when 8..12
    # August to December 2025 ≈ Safar to Jumada al-Awwal 1447
    if gregorian_date.month == 8
      { day: gregorian_date.day + 6, month: 'Safar', year: 1447 }
    elsif gregorian_date.month == 9
      { day: gregorian_date.day + 5, month: 'Rabi al-Awwal', year: 1447 }
    elsif gregorian_date.month == 10
      { day: gregorian_date.day + 5, month: 'Rabi al-Thani', year: 1447 }
    elsif gregorian_date.month == 11
      { day: gregorian_date.day + 4, month: 'Jumada al-Awwal', year: 1447 }
    elsif gregorian_date.month == 12
      { day: gregorian_date.day + 4, month: 'Jumada al-Thani', year: 1447 }
    end
  end
end

if __FILE__ == $0
  generate_hijri_mapping_2025
end 