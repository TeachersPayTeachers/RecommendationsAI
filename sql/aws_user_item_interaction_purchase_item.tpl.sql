{%- set start_date = '2019-01-01' %}
with t as (
  select
    concat('purchase-', cast(order_item_id as string)) as event_id
    , user_id
    , item_id
    , 'purchase' as action
    , created_at as ts
    , (select as struct
      gmv
    ) as properties
  from `tpt_core.fact_order_items` 
  where created_at_month_ny >= '{{ start_date }}'
)
select
  event_id
  , cast(user_id as string) as user_id
  , cast(item_id as string) as item_id
  , action as event_type
  , unix_seconds(ts) as timestamp
  , to_json_string(properties)
from t

