#!/bin/bash

if [ $# -ne 1 ];then
  echo "Usage: $0 <ADDRESS>"
  echo "     e.g. $0 \"120 S Lake Ave,Pasadena,CA\""
  exit 1
fi

# remove unit numbers, as nominatim doesn't like that
ADDRESS=$(echo "$1" | sed -E 's/ # [0-9]+//g')

curl "https://nominatim.openstreetmap.org/?format=json&addressdetails=1&q=$ADDRESS&format=json&limit=1" | jq '.[0] | [{ "lat": .lat, "lon": .lon }]' | in2csv -f json | tail +2
