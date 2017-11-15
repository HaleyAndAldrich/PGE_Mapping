
use equis
go

set nocount on
go

/*Compares EQuIS Data to EQuIS_Reporting Data available on PGE Web Map*/

declare @facility_id int = 47

		select distinct
			 z.apn as [APN]
			,z.task_code as [APN/Event]
			,z.sys_sample_code
			,case when cast(z.permission_type_code as varchar (10))= '0' then 'Shared'
				when cast(z.permission_type_code as varchar (10)) = '1' then 'Not Shared'
				when cast(z.permission_type_code as varchar (10)) = '999' then 'Other'
				else cast(z.permission_type_code as varchar (10)) end  'Share Status'
			,case when y.task_code is not null then 'On GIS Server' else '--' end as 'Status'?.xcv
		left join 

			(select distinct
				 sys_sample_code
				,task_code
				,[APN]
				,[permission_type_code]

			  FROM [EQuIS_Reporting].[s_36599E00].[tbl_Results]
			 )y
			  on z.sys_sample_code = y.sys_sample_code and z.task_code = y.task_code
			  order by z.task_code
	
