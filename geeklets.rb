#!/usr/bin/env ruby

def get_time_date
  # gets the current time and formats it as specified
  puts Time.now.strftime("%A, %B %d %I:%M %p")
end

def get_battery_info
  # gets the battery info on macbooks/pros
end

ARGV.each do|a|
  case a
  when "time"
    get_time_date()
  when "battery"
    get_battery_info()
  else
    puts "Error in command"
  end
end