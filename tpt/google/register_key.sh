#!/bin/bash
set -exuo pipefail

# Register a key for use with predict API
# usage: ./register_key.sh <key>

KEY="$1"
GOOGLE_APPLICATION_CREDENTIALS="$GOOGLE_APPLICATION_CREDENTIALS"
export PROJECTID=495428317352

curl -X POST \
     -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
     -H "Content-Type: application/json; charset=utf-8" \
     --data '{ 
           "predictionApiKeyRegistration": { 
                "apiKey": "'"$KEY"'"
            } 
        }'\
        "https://recommendationengine.googleapis.com/v1beta1/projects/$PROJECTID/locations/global/catalogs/default_catalog/eventStores/default_event_store/predictionApiKeyRegistrations"
