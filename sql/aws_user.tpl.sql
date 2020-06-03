select
  cast(user_id as string) as user_id
  , user_group
  , (select string_agg(gl, '|') from unnest(grade_levels) as gl) as grade_levels
  , (select string_agg(sa, '|') from unnest(subject_areas) as sa) as subject_area
from `tpt_core.dim_cur_user` 