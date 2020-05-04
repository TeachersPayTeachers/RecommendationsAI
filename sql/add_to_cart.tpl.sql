with
atc as (
  select *
  from `tpt_raw.web_traffic_hit_level` 
  where hit_type = 'EVENT'
  and user_id is not null
  and event_action = 'Add To Cart'
  and event_category in ('Wishlist', 'Item Actions', 'Store', 'Search Results Actions', 'Description Item Actions')
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
  'add-to-cart' as eventType
  , format_timestamp('%FT%H:%M:%E9SZ', hit_started_at) as eventTime
  , struct(user_id as visitorId) as userInfo
  , struct(
    array((select struct<id string, quantity int64>(cast(item_id as string), 1))) as productDetails
  ) as productEventDetail
from atc
