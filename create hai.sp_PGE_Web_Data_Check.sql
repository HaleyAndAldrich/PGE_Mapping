
use equis
go

set nocount on
go

/*Compares EQuIS Data to EQuIS_Reporting Data available on PGE Web Map*/

alter procedure hai.sp_PGE_Web_Data_Check 
	(@facility_id int)
	as
	begin
		select distinct
			 z.apn as [APN]
			,z.task_code as [APN/Event]
			,case when cast(z.permission_type_code as varchar (10))= '0' then 'Shared'
				when cast(z.permission_type_code as varchar (10)) = '1' then 'Not Shared'
				when cast(z.permission_type_code as varchar (10)) = '999' then 'Other'
				else cast(z.permission_type_code as varchar (10)) end  'Share Status'
			,case when y.task_code is not null then 'On GIS Server' else '--' end as 'Status'
		from (
			select distinct
			ld.apn
			,ld.address
			,s.task_code
			,tp.permission_type_code
			from dt_hai_location_details ld
			inner join dt_sample s on ld.facility_id = s.facility_id and ld.sys_loc_code = s.sys_loc_code
			left join dt_hai_task_permissions tp on s.facility_id = tp.facility_id and s.task_code = tp.task_code
			where s.facility_id = @facility_id and s.task_code not like '%idw%'
			)z

		left join 

			(select distinct
				task_code
				,[APN]
				,[permission_type_code]

			  FROM [EQuIS_Reporting].[s_36599E00].[tbl_Results]
			 )y
			  on z.task_code = y.task_code
			  order by z.task_code
		end
