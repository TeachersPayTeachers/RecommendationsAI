#!/bin/bash
set -euxo pipefail
. gcp.sh
TABLE="tpt-data-warehouse-prod:dev_outbox.backfill_purchase_complete"
GCS='gs://tpt_data_sci_dev/resources-recommendations/purchase-complete/backfill/*.json'
SQL="$(jinja2 sql/purchase_complete.tpl.sql)"

bq query --allow_large_results --nouse_legacy_sql \
  --replace=true --destination_table="$TABLE" \
  "$SQL" 1>/dev/null

bq extract --destination_format=NEWLINE_DELIMITED_JSON "$TABLE" "$GCS"
