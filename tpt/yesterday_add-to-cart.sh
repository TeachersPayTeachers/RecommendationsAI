#!/bin/bash
set -euxo pipefail
. gcp.sh
DT_CMD="date"
EXPIRE="86400"  # 1 day in seconds
LOOKBACK='-1 day'
YEAR="$($DT_CMD +'%Y' -d "$LOOKBACK")"
MONTH="$($DT_CMD +'%m' -d "$LOOKBACK")"
DAY="$($DT_CMD +'%d' -d "$LOOKBACK")"
RUN="$($DT_CMD +'%s' -d "$LOOKBACK")"
TABLE="tpt-data-warehouse-prod:dev_outbox.add_to_cart_$YEAR$MONTH$DAY"
GCS="gs://tpt_data_sci_dev/resources-recommendations/add-to-cart/$YEAR/$MONTH/$DAY/$RUN/*.json"
GCS_ERROR="gs://tpt_data_sci_dev/resources-recommendations-errors/"
SQL="$(jinja2 --strict -D dt=$YEAR-$MONTH-$DAY sql/add_to_cart.tpl.sql)"
PROJECT="tpt-data-warehouse-prod"

bq query --allow_large_results --nouse_legacy_sql \
  --replace=true --destination_table="$TABLE" \
  "$SQL"

bq extract --destination_format=NEWLINE_DELIMITED_JSON "$TABLE" "$GCS"

EVENT_IMPORT="
{
  \"errorsConfig\": {
    \"gcsPrefix\": \"$GCS_ERROR\"
  },
 \"inputConfig\": {
    \"gcsSource\": {
      \"inputUris\": [\"$GCS\"]
    }
  }
}
"

echo -n "$EVENT_IMPORT" | jq empty
echo "$GOOGLE_APPLICATION_CREDENTIALS"

curl -X POST \
  -H "Content-Type: application/json; charset=utf-8" -d "$EVENT_IMPORT" \
  -H "Authorization: Bearer "$(gcloud auth print-access-token)"" \
  "https://recommendationengine.googleapis.com/v1beta1/projects/$PROJECT/locations/global/catalogs/default_catalog/eventStores/default_event_store/userEvents:import"
