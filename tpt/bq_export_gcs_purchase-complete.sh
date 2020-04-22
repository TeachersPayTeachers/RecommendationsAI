#!/bin/bash
set -exuo pipefail
SQL='
-- https://cloud.google.com/recommendations-ai/docs/user-events

SELECT
  "purchase-complete" AS eventType,
  FORMAT_TIMESTAMP("%FT%H:%M:%E9SZ", MIN(created_at)) AS eventTime,
  STRUCT(MIN(user_id) AS visitorId) as userInfo,
  STRUCT(
    ARRAY_AGG(STRUCT<id STRING, quantity INT64>(CAST(item_id AS STRING), 1)) AS productDetails,
    STRUCT<revenue FLOAT64, currencyCode STRING>(SUM(gmv), "USD") AS purchaseTransaction
  ) AS productEventDetail
FROM `tpt_core.fact_order_items` 
WHERE DATE(created_at, "America/New_York") < CURRENT_DATE("America/New_York")
AND DATE(created_at, "America/New_York") >= DATE_SUB(CURRENT_DATE("America/New_York"), INTERVAL 1 YEAR)
GROUP BY order_id

'

TABLE="tpt-data-warehouse-prod:dev_brian_kleszyk.rec_purchase_complete"
bq query --allow_large_results --nouse_legacy_sql \
  --replace=true --destination_table="$TABLE" \
  "$SQL" 1>/dev/null

bq extract --destination_format=NEWLINE_DELIMITED_JSON "$TABLE" 'gs://tpt_data_sci_dev/resources-recommendations/purchase-complete/*.json'