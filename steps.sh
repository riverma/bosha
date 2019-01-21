#!/bin/bash

if [ $# -ne 1 ];then
  echo "Usage: $0 <CITY_NAME> <REFERENCE_USA_CSV_FILES_DIRECTORY>"
  echo "TIP: ensure you've modified the get_parent_biz_ids_details.sh script with information from refusa_howto.mov"

  exit 1
fi

CITY_NAME=$1
DATA_DIR=$2

echo "Merge separate metadata files..."
find $DATA_DIR -name "*.csv" | head -1 | xargs -I{} head -1 {} > $DATA_DIR/merged; find $DATA_DIR -name "*.csv" | xargs -I{} tail +2 {} >> $DATA_DIR/merged;
mv $DATA_DIR/merged $DATA_DIR/merged.csv
echo "Done."

echo "Extract out the parent BIZ_ID references..."
cat $DATA_DIR/merged.csv | csvcut -c 105,106 > $DATA_DIR/parent_biz_ids.csv
echo "Done."

echo "Query for additional metadata on parent BIZ_IDs..."
./get_parent_biz_id_names.rb $DATA_DIR/parent_biz_ids.csv > $DATA_DIR/parent_biz_ids_details.csv
echo "Done."

echo "Add in lat/lon coordinates for company address and parent BIZ_ID address..."
echo "   collect all BIZ_IDs and associated addresses from merged.csv..."
cat $DATA_DIR/merged.csv | csvcut -c 105,7,8,9,10 | csvformat -U 2 > $DATA_DIR/addresses.csv
echo "   query each address from 5.a. print the lat/lon along with BIZ_ID..."
./get_lat_lons.rb $DATA_DIR/addresses.csv > $DATA_DIR/addresses_lat_lons.csv
echo "Done."

echo "Join parent BIZ_IDs details with merged.csv..."
csvjoin -c 105,1 $DATA_DIR/merged.csv $DATA_DIR/parent_biz_ids_details.csv | csvformat -U 2 > $DATA_DIR/merged_parent_biz_id_details.csv
echo "Done."

echo "Join address info with merged.csv..."
csvjoin -c 105,1 $DATA_DIR/merged_parent_biz_id_details.csv $DATA_DIR/addresses_lat_lons.csv | csvformat -U 2 > $DATA_DIR/merged_addresses_lat_lons.csv
echo "Done."

echo "Make final CSV..."
mv $DATA_DIR/merged_addresses_lat_lons.csv $DATA_DIR/final.csv
echo "Done."

echo "Convert CSV to JSON (for Elasticsearch)..."
csvjson --blanks $DATA_DIR/final.csv > $DATA_DIR/final.json
cat $DATA_DIR/final.json | jq -c '.[] | . + { GeoCoords: (if ."Lat" == "" and ."Lon" == "" then null else { "lat": ."Lat", "lon": ."Lon" } end ) } + { OwnerGeoCoords: (if ."Owner Lat" == "" and ."Owner Lon" == "" then null else { "lat": ."Owner Lat", "lon": ."Owner Lon" } end ) }' > $DATA_DIR/final-es.jsonl
echo "Done."

echo "Start up Elasticsearch / Kibana..."
cd elk; docker-compose up -d
cd ..
sleep 300
echo "Done."

echo "Push final.csv to Elasticsearch..."
./put_es_mappings.sh $CITY_NAME elasticsearch-index-mapping.json
cat $DATA_DIR/final-es.jsonl | parallel "echo {} | curl -XPOST 'http://localhost:9200/$CITY_NAME/businesses' -H 'Content-Type: application/json' -d @-"
echo "Done."

echo "-- THE END --"
echo "TIP: navigate to http://localhost:5601/ to visualize your results. Make sure to load the kibana.json visualizations"
