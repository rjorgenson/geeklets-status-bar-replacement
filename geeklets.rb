#!/usr/bin/env ruby

def get_time_date # gets the current time and formats it as specified
  puts Time.now.strftime("%A, %B %d %I:%M %p")
end

def get_battery_info # gets the battery info on macbooks/pros
  chg = `ioreg -l | grep ExternalConnected | awk '{ print $5 }'` # is battery charged
  mb = `ioreg -l | grep MaxCapacity | awk '{ print $5 }'` # maximum capacity
  cb = `ioreg -l | grep CurrentCapacity | awk '{ print $5 }'` # current capacity
  # determine battery % and round off to match system battery %
  puts "#{(chg.strip == "Yes" ? "Charging: " : "Battery: ")}#{(cb.to_f / mb.to_f * 100).round}%"
end

# determine which script to execute
ARGV.each do|a|
  case a
  when "time" # report date & time
    get_time_date()
  when "battery" # report battery %
    get_battery_info()
  else
    puts "geeklet #{a} does not exist"
  end
end