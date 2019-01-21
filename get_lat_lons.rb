#!/usr/local/bin/ruby

if ARGV.length != 1
  puts "Usage: script <ADDRESSES_FILE>"
  exit 1
end

puts "\"BIZ_ID Number\",\"Lat\",\"Lon\""
File.open(ARGV[0]).each_with_index do |line,index|
  if index == 0
    next
  end

  line.strip!
  line_tokens = line.split(",")
  biz_id = line_tokens[0]
  address = line_tokens[-4,4].join(",").gsub("\"","")
  lat_lon = %x[./addresses_to_lat_lon.sh "#{address}"]
  lat_lon.strip!

  puts "#{biz_id},#{lat_lon}"

  sleep(Random.rand(5))
end
