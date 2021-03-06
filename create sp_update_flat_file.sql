USE [EQuIS_Reporting]
GO
/****** Object:  StoredProcedure [dbo].[sp_update_flat_file]    Script Date: 9/22/2017 6:56:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[sp_update_flat_file]
as
begin
	if object_id('s_36599E00.tbl_results_flat_file') is not null drop table s_36599E00.tbl_results_flat_file

	declare @datetimestamp as datetime 
	set @datetimestamp = (select getdate())

	select
	@datetimestamp as [DateTimeStamp]
	,sample_id
	,sys_sample_code
	,sample_name
	,lab_sample_id
	,subfacility_name
	,sys_loc_code
	,loc_name
	,loc_type
	,sample_date
	,duration
	,duration_unit
	,matrix_code
	,sample_type
	,sample_source
	,task_code
	,start_depth
	,end_depth
	,reference_elevation
	,reference_elevation_point
	,start_elevation
	,ws_start_depth
	,v_elev
	,end_elevation
	,elev_reference_type_code
	,l_loc_type
	,depth_unit
	,compound_group
	,analytic_method
	,prep_method
	,dilution_factor
	,total_or_dissolved
	,lab_sdg
	,lab_name
	,analysis_date
	,chemical_name
	,cas_rn
	,lab_reported_result
	,lab_reported_result_unit
	,detect_flag
	,reportable_result
	,result_type_code
	,lab_qualifiers
	,validated_yn
	,validation_reason_code
	,qualifier
	,result_label
	,result_value
	,method_detection_limit
	,reporting_detection_limit
	,reporting_qualifier
	,result_unit
	,detection_limit_type
	,coord_type_code
	,x_coord
	,y_coord
	,SRID
	,APN
	,permission_type_code

	into equis_reporting.s_36599E00.tbl_results_flat_file
	from equis_reporting.s_36599E00.tbl_results
	where permission_type_code = '0'

	select * from equis_reporting.s_36599E00.tbl_results_flat_file

end
