#!/usr/bin/env ruby

#
# uses the ioreg command on Mac laptops to get battery charge information
#

maxBatt = `ioreg -l | grep MaxCapacity | awk '{ print $5 }'`

curBatt = `ioreg -l | grep CurrentCapacity | awk '{ print $5 }'`

batt = curBatt.to_f / maxBatt.to_f * 100
puts "#{batt.to_i}%"
