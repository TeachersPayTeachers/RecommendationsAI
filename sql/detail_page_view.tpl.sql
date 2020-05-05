with
pv as (
  select *
  from `tpt_raw.web_traffic_hit_level` 
  where hit_type = 'PAGE'
  and user_id is not null
  and item_id is not null
  and page_path_level1 = 'Product'
  and session_date >= date_sub(current_date('America/New_York'), interval 13 month)
  {%- if dt %}
  and session_date >= '{{ dt }}' -- provided date is utc, session_date is ny, but >= will be fine
    {%- if backfill == 'yes' %}
    and date(hit_started_at) >= '{{ dt }}'
    {%- else %}
    and date(hit_started_at) = '{{ dt }}'
    {%- endif %}
  {%- endif %}
)
select
  'detail-page-view' as eventType
  , format_timestamp('%FT%H:%M:%E9SZ', hit_started_at) as eventTime
  , struct(user_id as visitorId) as userInfo
  , struct(
    struct<id string>(cast(item_id as string)) as productDetails
  ) as productEventDetail
from pv