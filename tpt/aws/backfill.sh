#!/bin/bash
set -euxo pipefail
. gcp.sh

TABLE="${1}"
PROJECT="tpt-data-warehouse-prod"
FORMAT=CSV
GCS_NAMES="*.csv"

DT_CMD="gdate"
EXPIRE="600"  # 10 minutes in seconds
YEAR="$($DT_CMD +'%Y')"
MONTH="$($DT_CMD +'%m')"
DAY="$($DT_CMD +'%d')"
TIME="$($DT_CMD +'%H%M%Sn%N')"
TABLE_FOLDER="${TABLE}/$YEAR/$MONTH/$DAY/$TIME"
TABLE_NAME="${TABLE}_$YEAR$MONTH${DAY}T$TIME"

FULL_BQ_TABLE_NAME="tpt-data-warehouse-prod:dev_outbox.$TABLE_NAME"
FULL_GCS_TABLE_FOLDER="gs://tpt_data_sci_dev/$TABLE_FOLDER"
FULL_GCS_TABLE_IDS="$FULL_GCS_TABLE_FOLDER/$GCS_NAMES"
FULL_S3_TABLE_FOLDER="s3://tpt-datascience-dev/rec-poc/$TABLE_FOLDER"

SQL="$(jinja2 --strict -D dt=$YEAR-$MONTH-$DAY -D backfill=yes ./sql/$TABLE.tpl.sql)"

echo "$SQL" | bq query --allow_large_results --nouse_legacy_sql \
  --replace=false --destination_table="$FULL_BQ_TABLE_NAME"

bq extract --destination_format="$FORMAT" "$FULL_BQ_TABLE_NAME" "$FULL_GCS_TABLE_IDS"

gsutil -m rsync -rd "$FULL_GCS_TABLE_FOLDER" "$FULL_S3_TABLE_FOLDER"
