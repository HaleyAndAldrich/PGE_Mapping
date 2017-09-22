USE [EQuIS_Reporting]
GO
/****** Object:  StoredProcedure [dbo].[sp_WebMap_NewOld_Comparison]    Script Date: 9/21/2017 3:32:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*shows record differences betweeen flat file submittals*/
ALTER procedure [dbo].[sp_WebMap_NewOld_Comparison]

as
begin


			select
				 a.sys_sample_code
				,a.sys_loc_code
				,a.task_code
				,a.chemical_name
				,a.analytic_method
				,a.total_or_dissolved
				,a.reportable_result
				,a.permission_type_code
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

				where b.sys_sample_code is null
end