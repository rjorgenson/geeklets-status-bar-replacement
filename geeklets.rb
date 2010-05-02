#!/usr/bin/env ruby
#############################################################
# Author: Robert Jorgenson <rjorgenson@gmail.com>
#
# Usage: Please see README for usage details
#
# License: Free! Do whatever you want with it =]
#############################################################

#############################################################
# Returns the date and or time
#############################################################
class Datetime
  def long # Tuesday, September 23 11:11 PM
    return Time.now.strftime("%A, %B %d %I:%M %p")
  end # def long
  
  def short # Tue, Sep 23 11:11 PM
    return Time.now.strftime("%a, %b %d %I:%M %p")
  end # def short
  
  def time # 11:11 PM
    return Time.now.strftime("%I:%M %p")
  end # def time
  
  def longDate # Tuesday, September 23
    return Time.now.strftime("%A, %B %d")
  end # def longDate
  
  def shortDate # Tue, Sep 23
    return Time.now.strftime("%a, %b %d")
  end # def shortDate
  
  def string(string)# Returns the interpereted value of string
    return Time.now.strftime(string) 
  end # def string
end # class DateTime

#############################################################
# Returns battery status/info
#############################################################
class Battery
  def initialize() # gather relevant info
    @conn = `ioreg -n AppleSmartBattery | grep ExternalConnected | awk '{ print $5 }'` # is power connected
    @chrg = `ioreg -n AppleSmartBattery | grep IsCharging | awk '{ print $5 }'` # is battery chargin
    @time = `ioreg -n AppleSmartBattery | grep TimeRemaining | awk '{ print $5 }'` # time remaining on battery
    @max = `ioreg -n AppleSmartBattery | grep MaxCapacity | awk '{ print $5 }'` # maximum capacity
    @cur = `ioreg -n AppleSmartBattery | grep CurrentCapacity | awk '{ print $5 }'` # current capacity
  end # def initialize

  def build_meter(color="yes") # built battery meter
    percent = self.build_percent # get capacity percentage
    if color == "yes" then
      red = "\e[31m"
      yellow = "\e[33m"
      green = "\e[32m"
      clear = "\e[0m"
    else
      red = ""
      yellow = ""
      green = ""
      clear = ""
    end
    meter = ""
    
    for i in (1..10) # one bar per 10% battery, dashes for each empty 10%
      if percent >= 10 then
        i <= 2 ? meter << red : nil # first 2 bars red
        i <= 5 && i > 2 ? meter << yellow : nil # next 3 bars yellow
        i <= 10 && i > 5 ? meter << green : nil # remaining 5 green
        meter << "|" + clear # clear color
      else
        meter << "-" # empty
      end # if percent >= 10
      percent -= 10 # decrement percentage for next loop
    end # for i in (1..10)
    return meter + clear
  end # def build_meter
  
  def build_time # determines time remaining on battery
    hour = @time.strip.to_i / 60 # hours left
    min = @time.strip.to_i - (hour * 60) # minutes left
    min < 10 ? min = "0#{min}" : nil # make sure minutes is two digits long

    if @conn.strip == "Yes" then # power cable connected
      if @chrg.strip == "Yes" then # is plugged in and charging
        batTime = "Charging: #{hour}:#{min}"
      else # is plugged in but not charging
        self.build_percent == 100 ? batTime = "Charged" : batTime = "Not Charging"
      end # if @chrg.strip == "Yes"
    else # power is not connected
      if @time.to_i < 1 || @time.to_i > 2000 then
        batTime = "Calculating"
      else
        batTime = "#{hour}:#{min}"
      end # if @time < 1 || @ time > 2000 
    end # if @conn.strip == "Yes"
    
    return batTime
  end # def build_time
  
  def build_percent # returns percentage of battery remaining
    return (@cur.to_f / @max.to_f * 100).round.to_i
  end # def build_percent
end # Class Battery

#############################################################
# Script execution
#############################################################
case ARGV[0] # geeklet specified on command line
when "battery"
  batt = Battery.new
  if ARGV[1] == nil then
    puts batt.build_meter.to_s + " " + batt.build_percent.to_s + "% (" + batt.build_time.to_s + ")"
  else
    case ARGV[1]
    when "meter"
      if ARGV[2] == nil then
        puts batt.build_meter.to_s
      else
        puts batt.build_meter(ARGV[2]).to_s
      end
    when "percent"
      puts batt.build_percent.to_s
    when "time"
      puts batt.build_time.to_s
    else
      if ARGV[1] == nil then
        puts batt.build_meter.to_s + " " + batt.build_percent.to_s + "% (" + batt.build_time.to_s + ")"
      else
        puts batt.build_meter(ARGV[1]).to_s + " " + batt.build_percent.to_s + "% (" + batt.build_time.to_s + ")"
      end
    end # case ARGV[1]
  end # if ARGV[1] == nil
when "time"
  time = Datetime.new
  if ARGV[1] == nil then
    puts time.long
  else
    case ARGV[1]
    when "long"
      puts time.long
    when "short"
      puts time.short
    when "time"
      puts time.time
    when "longDate"
      puts time.longDate
    when "shortDate"
      puts time.shortDate
    when "string"
      if ARGV[2] == nil then
        puts "Please enter a date format string"
      else
        puts time.string(ARGV[2])
      end # if ARGV[2] == nil
    else
      puts time.long
    end # case ARGV[1]
  end # if ARGV[1] == nil
else
  puts "geeklet #{ARGV[0]} does not exist"
end # case ARGV[0]