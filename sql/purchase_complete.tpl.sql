with
oi as (
  select * except (_is_latest)
  from (
    select *
    , ROW_NUMBER() OVER (PARTITION BY id ORDER BY _sdc_sequence DESC, _sdc_batched_at DESC , _sdc_extracted_at DESC , _sdc_received_at DESC , _sdc_table_version DESC) = 1 AS _is_latest
    from `tpt-data-warehouse-staging.tpt_mysql_live_v3.order_items` oi
  )
  where _is_latest
)
, o as (
  select * except (_is_latest, created)
  , CASE WHEN id = 947977
        THEN TIMESTAMP('2012-08-03 03:43:29 UTC') -- one missing value in years we care about!
        ELSE PARSE_TIMESTAMP('%F %X', format_timestamp('%F %X', created, 'Etc/UTC'), 'America/New_York')  
    END AS created_at
  from (
    select *
    , ROW_NUMBER() OVER (PARTITION BY id ORDER BY _sdc_sequence DESC, _sdc_batched_at DESC , _sdc_extracted_at DESC , _sdc_received_at DESC , _sdc_table_version DESC) = 1 AS _is_latest
    from `tpt-data-warehouse-staging.tpt_mysql_live_v3.orders` o
  )
  where _is_latest
)

, foi as (
  select
    oi.*
    , IF(oi.item_type != 3, oi.license_count*oi.license_price + oi.quantity*oi.price, 0) AS gmv
    , o.created_at
    , o.user_id
  from oi
  join o on oi.order_id = o.id
)

, fo as (
select
  order_id
  , min(created_at) as min_created_at
  , min(user_id) as min_user_id
  , array_agg(item_id) as item_ids
  , sum(gmv) as gmv
from foi
{%- if dt %}
where date(created_at) = '{{ dt }}'
{%- endif %}
group by order_id
)
select
  'purchase-complete' as eventType
  , format_timestamp('%FT%H:%M:%E9SZ', min_created_at) as eventTime
  , struct(min_user_id as visitorId) as userInfo
  , struct(
    array((select struct<id string, quantity int64>(cast(item_id as string), 1) from unnest(item_ids) as item_id)) as productDetails
    , struct<revenue float64, currencyCode string>(gmv, 'USD') as purchaseTransaction
  ) as productEventDetail
from fo
