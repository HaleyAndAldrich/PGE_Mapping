


select distinct

case when len(APN) = 0 then sys_loc_code else replace(APN,'-','') end as APN

from (
select
sys_loc_code
,left(sys_loc_code,charindex('-',sys_loc_code)) as APN
from
dt_location
where facility_id = 47
and left(sys_loc_code, 1) = '0')x



