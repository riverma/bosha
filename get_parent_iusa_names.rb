#!/usr/local/bin/ruby

if ARGV.length != 1
  puts "Usage: script <BIZ_IDS_FILE>"
  exit 1
end

puts "\"BIZ_ID Number\",\"Owner\",\"Owner Address\",\"Owner City\",\"Owner State\",\"Owner Lat\",\"Owner Lon\""
File.open(ARGV[0]).each_with_index do |line,index|
  if index == 0
    next
  end

  line.strip!
  tokens = line.split(",")
  biz_id = tokens[0]
  parent_biz_id = tokens[-1,1].join(",")
  if parent_biz_id == "000000000"
    puts "\"#{biz_id}\",,,,,,"
  else
    parent_details = %x[./biz_id_num_to_details.sh #{parent_biz_id}]
    parent_details.strip!

    puts "\"#{biz_id}\",#{parent_details}"
    sleep(Random.rand(8))
  end
end
