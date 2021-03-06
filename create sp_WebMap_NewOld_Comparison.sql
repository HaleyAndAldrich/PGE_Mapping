USE [EQuIS_Reporting]
GO
/****** Object:  StoredProcedure [dbo].[sp_WebMap_NewOld_Comparison]    Script Date: 10/19/2017 10:47:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*shows record differences betweeen flat file submittals*/
ALTER procedure [dbo].[sp_WebMap_NewOld_Comparison]

as
begin
		DECLARE @DATETIMESTAMP	AS VARCHAR (20)

		Set @datetimestamp =(Select cast(max(datetimestamp) as varchar(20)) from equis_reporting.s_36599E00.tbl_results_flat_file) 

		select 
			 @datetimestamp [Last FlatFile DateTime]
			,task_code_a  task_code
			,permission_type_code_a as permission_type_code
			,count(*) as record_count
		from (

			select
				 a.sys_sample_code as sys_sample_code_a
				,a.sys_loc_code as sys_loc_code_a
				,a.task_code as task_code_a
				,a.chemical_name as chemical_name_a
				,a.analytic_method as analytic_method_a
				,a.total_or_dissolved as total_or_dissolved_a
				,a.reportable_result as reportable_result_a
				,a.permission_type_code as permission_type_code_a
				,b.sys_sample_code
				,b.sys_loc_code
				,b.task_code
				,b.chemical_name
				,b.analytic_method
				,b.total_or_dissolved
				,b.reportable_result
				,b.permission_type_code
				from (


				select
					sys_sample_code
					,sys_loc_code
					,task_code
					,chemical_name
					,cas_rn
					,analytic_method
					,total_or_dissolved
					,reportable_result
					,permission_type_code

				from equis_reporting.s_36599E00.tbl_results
				where permission_type_code = '0' ) a
				left join
				(
				select
					 datetimestamp
					,sys_sample_code
					,sys_loc_code
					,task_code
					,chemical_name
					,cas_rn
					,analytic_method
					,total_or_dissolved
					,reportable_result
					,permission_type_code

				from equis_reporting.s_36599E00.tbl_results_flat_file
				where permission_type_code = '0' 
				)b

				on a.sys_sample_code = b.sys_sample_code
				and a.cas_Rn = replace(b.cas_rn,'"','')
				and a.analytic_method = b.analytic_method
				and a.total_or_dissolved = b.total_or_dissolved
				and a.reportable_result = b.reportable_result

				where b.sys_sample_code is null)z

		group by task_code_a, permission_type_code_a
end