select
  cast(item_id as string) as item_id
  , price
  , (select string_agg(gl, '|') from unnest(grade_levels) as gl) as grade_levels
  , (select string_agg(sa, '|') from unnest(subject_areas) as sa) as subject_areas
  , (select string_agg(rt, '|') from unnest(resource_types) as rt) as resource_types
  , is_free 
from `tpt_core.dim_cur_item`