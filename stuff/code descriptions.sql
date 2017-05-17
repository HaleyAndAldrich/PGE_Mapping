use equis 
go


select
t.facility_id
,t.task_code
,t.task_desc
--,tp.permission_type_code
from dt_task t
left join dt_hai_task_permissions tp
on t.task_code = tp.task_code
where t.facility_id = 47

UNION

select distinct
 s.facility_id
,s.matrix_code
,r.matrix_desc
--,tp.permission_type_code
from dt_sample s
inner join rt_matrix r on s.matrix_code = r.matrix_code
left join dt_task t on s.task_code = t.task_code
left join dt_hai_task_permissions tp
on s.facility_id = tp.facility_id and s.task_code = tp.task_code
where s.facility_id = 47



union

select distinct
 47
,g.group_code
,group_desc
--,null
from rt_group g
inner join rt_group_member gm on g.group_code = gm.group_code
inner join dt_test t on gm.member_code = t.analytic_method
where t.facility_id = 47 and group_type = 'compound_group'

union

select distinct
l.facility_id
,l.loc_type
,rl.location_type_desc
--,null as permission_type_code
from dt_location l
inner join rt_location_type rl on l.loc_type = rl.location_type_code
--left join (select permission_type_code, sys_loc_code from dt_hai_location_details ld inner join rt_hai_APN apn on ld.apn = apn.apn)ld
--on l.sys_loc_code = ld.sys_loc_code
where l.facility_id = 47
