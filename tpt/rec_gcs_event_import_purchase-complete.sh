#!/bin/bash
set -euxo pipefail

# Import events from GCS bucket, as specified in event_import.json

export GOOGLE_APPLICATION_CREDENTIALS="$PWD/gcr-poc.json"
export PROJECT=tpt-data-warehouse-prod

EVENT_IMPORT='
{
  "errorsConfig": {
    "gcsPrefix": "gs://tpt_data_sci_dev/resources-recommendations/errors/"
  },
 "inputConfig": {
    "gcsSource": {
      "inputUris": ["gs://tpt_data_sci_dev/resources-recommendations/purchase-complete/*.json"]
    }
  }
}

'

echo -n "$EVENT_IMPORT" | jq empty

curl -X POST \
  -H "Content-Type: application/json; charset=utf-8" -d "$EVENT_IMPORT" \
  -H "Authorization: Bearer "$(gcloud auth application-default print-access-token)"" \
  "https://recommendationengine.googleapis.com/v1beta1/projects/$PROJECT/locations/global/catalogs/default_catalog/eventStores/default_event_store/userEvents:import"
