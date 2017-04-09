use equis

go





insert into dt_hai_location_details (facility_id, sys_loc_code, gis_area_type)

select
47,sl.sys_loc_code,mgp_area_type

from [EQuIS_Reporting].[dbo].[tbl_36599_SamplingLocation] sl
left join dt_hai_location_details ld on sl.sys_loc_code = ld.sys_loc_code
where ld.sys_loc_code is null
and sl.sys_loc_code in (select sys_loc_code from dt_location where facility_id = 47)