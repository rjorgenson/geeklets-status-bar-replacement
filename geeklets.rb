#!/usr/bin/env ruby
#
# Author: Robert (rjorgenson@gmail.com)
#
# Usage: geeklets.sh <arg1> <arg2> <arg3>
#
# arg1 can be any supprted geeklet, currently time & battery
# arg2 can be options for those geeklets as documented below
#
# geeklet options:
#
# => time:
# =>  long: time & date in long format (Saturday, September 14 11:59 PM)
# =>  short: time & date in short format (Sat, Sep 14 11:59 PM)
# =>  time: reports just the time (11:59 PM)
# =>  longdate: reports just the date in long format (see above)
# =>  shortdate: reports just the date in short format (see above)
# =>  string: takes a ruby strftime formatted date string
# =>  see http://ruby-doc.org/core/classes/Time.html#M000298
# =>  example: geeklets.rb time string "%A, %B %d %I:%M %p" would yeild the same
# =>  results as geeklets.sh time long, strings with spaces must be contained
# =>  with quotation marks.
#
# =>  default behavior of time is to report long time format when there are
# =>  no arguments given

def get_time_date # gets the current time and formats it as specified
  case ARGV[1]
  when "long" # long date format
    puts Time.now.strftime("%A, %B %d %I:%M %p")
  when "short" # short time format
    puts Time.now.strftime("%a, %b %d %I:%M %p")
  when "time" # Just the time
    puts Time.now.strftime("%I:%M %p")
  when "longdate" # just the date in long format
    puts Time.now.strftime("%A, %B %d")
  when "shortdate" # just the date in short format
    puts Time.now.strftime("%a, %b %d")
  when "string"
    puts Time.now.strftime("#{ARGV[2]}")
  else
    puts Time.now.strftime("%A, %B %d %I:%M %p")
  end
end

def get_battery_info # gets the battery info on macbooks/pros
  
  case ARGV[1] # determine what to process
  when "percent"
    mb = `ioreg -n AppleSmartBattery | grep MaxCapacity | awk '{ print $5 }'` # maximum capacity
    cb = `ioreg -n AppleSmartBattery | grep CurrentCapacity | awk '{ print $5 }'` # current capacity
    puts "#{(cb.to_f / mb.to_f * 100).round}%"
  when "time"
    chrg = `ioreg -n AppleSmartBattery | grep ExternalConnected | awk '{ print $5 }'` # is battery charged
    timel = `ioreg -n AppleSmartBattery | grep TimeRemaining | awk '{ print $5 }'` # time remaining on battery
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
    puts "#{time}"
  else
    chrg = `ioreg -n AppleSmartBattery | grep ExternalConnected | awk '{ print $5 }'` # is battery charged
    timel = `ioreg -n AppleSmartBattery | grep TimeRemaining | awk '{ print $5 }'` # time remaining on battery
    mb = `ioreg -n AppleSmartBattery | grep MaxCapacity | awk '{ print $5 }'` # maximum capacity
    cb = `ioreg -n AppleSmartBattery | grep CurrentCapacity | awk '{ print $5 }'` # current capacity
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
    puts "#{(cb.to_f / mb.to_f * 100).round}% (#{time})"
  end
end

# determine which script to execute
case ARGV[0]
when "time" # report date & time
  get_time_date()
when "battery" # report battery %
  get_battery_info()
else
  puts "geeklet #{a} does not exist"
end