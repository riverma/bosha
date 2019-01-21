# BOSHA: Business OwnerSHip Analyser

<em>Creates an database & dashboard for analysing business ownership in your city</em>

## Introduction

This codebase builds an Elasticsearch database and visualization dashboard
populated with business ownership information derived from Reference USA.

## Requirements

The following third-party tools / platforms are a requirement to run BOSHA:
- Unix-based operating system (e.g. Linux, MacOSX, etc.)
- cURL: https://curl.haxx.se/
- jq: https://stedolan.github.io/jq/
- csvkit: https://csvkit.readthedocs.io/en/1.0.3/
- Ruby: https://www.ruby-lang.org/en/downloads/
- pup: https://github.com/EricChiang/pup
- parallel (GNU Parallels): https://www.gnu.org/software/parallel/
- docker: https://www.docker.com/products/docker-desktop

## Configuration

The following steps will need to be performed before executing any code in this
repository.

1. Obtain access to [Reference USA](www.referenceusa.com) and have in mind a
city or geographic area you'd like to collect business ownership information
about.
2. Create a directory where you will store CSV record data for all businesses
within your chosen geographic area.
3. Navigate to [Reference USA](www.referenceusa.com), and download CSV files
representing ALL metadata fields for all businesses within your chosen
geographic area. Download these CSV files to your chosen directory from step 2.
Follow tutorials at Reference USA's website for how to export CSV data.
  - Note: you may be limited to up to 250 record downloads per search. Thus it
  could take a long time to download all CSV records for all businesses in a
  large city.
4. Choose a name without punctuation or spaces, for the database where your
business record data will be stored. Typically this would be your city name.
  - open line 22 of ``kibana-dashboard.json`` and change ``pasadena`` to the
  name of the database you'd like to use.
5. Decrypt ``biz_id_num_to_details.sh`` and modify the script as detailed in the
``refusa_howto_mov`` movie (which also needs to be decrypted). Consult Rishi for
specifics.

## Running

<em>ONLY AFTER THE ABOVE CONFIGURATION STEPS ARE COMPLETE</em>

Follow the below steps to load the database with relevant business details.
1. Run the ``steps.sh`` script to load
business data, that is correlated with geo-point location data, into a custom
Elasticsearch datastore. This script can take hours or days to complete,
depending on how many businesses you need to load. Note, ``CITY_NAME`` refers to
step 4 in configuration. ``REFERENCE_USA_CSV_FILES_DIRECTORY`` refers to step
2 in configuration above.
  - $ ./steps.sh <CITY_NAME> <REFERENCE_USA_CSV_FILES_DIRECTORY>
7. Load ``kibana-dashboard.json``
  - Navigate to ``http://localhost:5601`` after step 5 completes successfully.
  - Follow Kibana steps to load the new index name (identified by name in step
    4) into Kibana. i.e. Management -> Index Patterns -> Create Index Pattern
  - View the just created index and note in the URL the ID of the index,
  appearing after the ``kibana/indices/`` prefix. You'll need this ID
  - Take the ID just obtained above, and replace the existing value ``_id`` with
  the ID collected above    
  - Navigate to ``http://localhost:5601/app/kibana#/management/kibana/objects``
  and click "import". Select the file ``kibana-dashboard.json`` and import it.

## Viewing Dashboard

Navigate to: http://localhost:5601/app/kibana#/dashboards and select the
dashboard titled: ``Business Info Dashboard``. Explore this dashboard and use
the search box to find out information about a specific business.
