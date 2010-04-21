#!/usr/bin/env ruby
#
# Author: Robert (rjorgenson@gmail.com)
#
# Usage: geeklets.rb <arg1> <arg2> <arg3>
#
# arg1 can be any supprted geeklet, currently time & battery
# arg2 & arg3 can be options for those geeklets as documented below
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
# =>    see http://ruby-doc.org/core/classes/Time.html#M000298
# =>    example: geeklets.rb time string "%A, %B %d %I:%M %p" would yeild the same
# =>    results as geeklets.rb time long, strings with spaces must be contained
# =>    with quotation marks.
#
# =>  default behavior of time is to report long time format when there are
# =>  no arguments given
#
# => battery:
# =>  time: reports just the ramining time until battery is charged/full
# =>    depending on if it is plugged in or not
# =>  percent: reports only the % of charge in the battery
# =>  meter: displays a text based battery meter in increments of 10
# =>    ex: ||||||---- charge is more than 60% but less than 70%
# =>    not very granular
#
# =>  default behavior of battery is to output all 3 in the following order
# =>    meter -> percent -> time

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

def build_battery_meter(mb,cb)
  percent = (cb.to_f / mb.to_f * 100).round.to_i
  meter = ""
  for i in (1..10)
    if percent >= 10
      meter << "|"
    else
      meter << "-"
    end
    percent = percent - 10
  end
  return meter
end

def build_battery_time(conn,chrg,timeR)
  hour = timeR.strip.to_i / 60 # hours left
  min = timeR.strip.to_i - (hour * 60) # minutes left
  min < 10 ? min = "0#{min}" :  # make sure minutes is two digits long
  
  if conn.strip == "Yes" then # power cable connected
    if chrg.strip == "Yes" then # is plugged in and charging
      time = "Charging: #{hour}:#{min}"
    else # is plugged in but not charging
      time = "Charged: #{hour}:#{min}"
    end
  else # power is not connected
    time = "#{hour}:#{min}"
  end
  return time
end

def get_battery_info # gets the battery info on macbooks/pros
  
  case ARGV[1] # determine what to process
  when "meter"
    mb = `ioreg -n AppleSmartBattery | grep MaxCapacity | awk '{ print $5 }'` # maximum capacity
    cb = `ioreg -n AppleSmartBattery | grep CurrentCapacity | awk '{ print $5 }'` # current capacity
    puts build_battery_meter(mb,cb)
  when "percent"
    mb = `ioreg -n AppleSmartBattery | grep MaxCapacity | awk '{ print $5 }'` # maximum capacity
    cb = `ioreg -n AppleSmartBattery | grep CurrentCapacity | awk '{ print $5 }'` # current capacity
    puts "#{(cb.to_f / mb.to_f * 100).round}%"
  when "time"
    conn = `ioreg -n AppleSmartBattery | grep ExternalConnected | awk '{ print $5 }'` # is power connected
    chrg = `ioreg -n AppleSmartBattery | grep IsCharging | awk '{ print $5 }'` # is battery charging
    timeR = `ioreg -n AppleSmartBattery | grep TimeRemaining | awk '{ print $5 }'` # time remaining on battery
    puts build_battery_time(conn,chrg,timeR)
  else
    conn = `ioreg -n AppleSmartBattery | grep ExternalConnected | awk '{ print $5 }'` # is power connected
    chrg = `ioreg -n AppleSmartBattery | grep IsCharging | awk '{ print $5 }'` # is battery chargin
    timeR = `ioreg -n AppleSmartBattery | grep TimeRemaining | awk '{ print $5 }'` # time remaining on battery
    mb = `ioreg -n AppleSmartBattery | grep MaxCapacity | awk '{ print $5 }'` # maximum capacity
    cb = `ioreg -n AppleSmartBattery | grep CurrentCapacity | awk '{ print $5 }'` # current capacity
    meter = build_battery_meter(mb,cb)
    time = build_battery_time(conn,chrg,timeR)
    puts "#{meter} #{(cb.to_f / mb.to_f * 100).round}% (#{time})"
  end
end

# determine which script to execute
case ARGV[0]
when "time" # report date & time
  get_time_date()
when "battery" # report battery %
  get_battery_info()
else
  puts "geeklet #{ARGV[0]} does not exist"
end