{%- set start_date = '2019-01-01' %}
with fua as (
  select
    null as item_id
    , _view_page.hit_id as hit_id
    , 'home-page-view' as action
    , * except (action)
  from `tpt_core.fact_user_actions` 
  where 1=1
  and _view_page.date_ny is not null
  and _view_page.date_ny >= '{{ start_date }}'
  and _view_page.path_base = '' or _view_page.path_base = '/'
  )
, t as (
  select
    concat(action, '-', hit_id) as event_id
    , user_id
    , item_id
    , action
    , ts
    , (select as struct
      null as gmv
    ) as properties
  from fua
)
select
  event_id
  , cast(user_id as string) as user_id
  , cast(item_id as string) as item_id
  , action as event_type
  , unix_seconds(ts) as timestamp
  , to_json_string(properties)
from t