#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <index_name> <mapping_file>"
  echo "   e.g. $0 pasadena elasticsearch-index-mapping.json"
  exit 1
fi

curl -XPUT "http://localhost:9200/$1" -H 'Content-Type: application/json' -d @$2
