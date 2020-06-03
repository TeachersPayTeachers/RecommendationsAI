{%- set start_date = '2019-01-01' %}
{%- set fua_only_use = '_add_to_cart' %}
with fua as (
  select
    coalesce(_download_item.item_id, _view_item.item_id, _add_to_cart.item_id) as item_id
    , coalesce(_download_item.hit_id, _view_item.hit_id, _add_to_cart.hit_id) as hit_id
    , *
  from `tpt_core.fact_user_actions` 
  where 1=1
  and ((_download_item.date_ny is not null and _download_item.date_ny >= '{{ start_date }}')
    or (_view_item.date_ny is not null and _view_item.date_ny >= '{{ start_date }}')
    or (_add_to_cart.date_ny is not null and _add_to_cart.date_ny >= '{{ start_date }}')
  )
  union all
  select
    null as item_id
    , _view_page.hit_id as hit_id
    , *
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
  where {{ fua_only_use }}.hit_id is not null
)
select
  event_id
  , cast(user_id as string) as user_id
  , cast(item_id as string) as item_id
  , action as event_type
  , unix_seconds(ts) as timestamp
  , to_json_string(properties)
from t