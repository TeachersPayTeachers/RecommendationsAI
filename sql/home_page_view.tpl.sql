with
hpv as (
  select *
  from `tpt_raw.web_traffic_hit_level` 
  where hit_type = 'PAGE'
  and user_id is not null
  and (page_path_level1 is null or page_path_level1 = '')
  and session_date >= date_sub(current_date('America/New_York'), interval 13 month)
  {%- if dt %}
  and session_date >= '{{ dt }}' -- provided date is utc, session_date is ny, but >= will be fine
  and date(hit_started_at) = '{{ dt }}'
  {%- endif %}
)
select
  'home-page-view' as eventType
  , format_timestamp('%FT%H:%M:%E9SZ', hit_started_at) as eventTime
  , struct(user_id as visitorId) as userInfo
from hpv
