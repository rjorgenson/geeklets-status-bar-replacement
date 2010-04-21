#!/usr/bin/env ruby

def get_time_date # gets the current time and formats it as specified
  puts Time.now.strftime("%A, %B %d %I:%M %p")
end

def get_battery_info # gets the battery info on macbooks/pros
  chrg = `ioreg -l | grep ExternalConnected | awk '{ print $5 }'` # is battery charged
  timel = `ioreg -l | grep TimeRemaining | awk '{ print $5 }'` # time remaining on battery
  # display time remaining on battery or charging if plugged in
  if chrg.strip == "Yes" then
    time = "Charging"
  else
    if timel.strip == "0" then
      time = "Calculating..."
    else
      hour = timel.strip.to_i / 60
      min = timel.strip.to_i - (hour * 60)
      # fix minutes to be 2 digits long always
      if min < 10 then
        min = "0#{min}"
      end
      time = "#{hour}:#{min}"
    end
  end
  mb = `ioreg -l | grep MaxCapacity | awk '{ print $5 }'` # maximum capacity
  cb = `ioreg -l | grep CurrentCapacity | awk '{ print $5 }'` # current capacity
  # determine battery % and round off to match system battery %
  puts "Battery: #{(cb.to_f / mb.to_f * 100).round}% (#{time})"
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