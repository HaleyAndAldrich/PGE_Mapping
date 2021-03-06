USE [equis]
GO
/****** Object:  StoredProcedure [HAI].[sp_hai_get_webmap_etl_log]    Script Date: 5/15/2017 11:01:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*report ID = 4935392*/
ALTER procedure [HAI].[sp_hai_get_webmap_etl_log]
(
 @facility_id int
,@start_date date
,@end_date date
)

as
begin
	select 
	etl_id
	,run_date
	,schema_name
	,table_name
	,permission_code_1_row_count
	,permission_code_0_row_count
	,total_row_count
	,status 

	from dt_hai_webmap_etl_log
	where (cast(run_date as date) > = @start_date and cast(run_date as date) < = @end_date)
	order by etl_id desc, table_name

end


