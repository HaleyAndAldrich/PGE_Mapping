use equis
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	alter procedure hai.sp_hai_pge_web_map_changes
		(
		 @start_date date 
		,@end_date date 
		,@schema_name varchar (30)
		)

	as 
	begin 
		select
			start_data.schema_name
			,cast(datename(month,@start_date) as varchar) + ' ' + cast(datepart(day, @start_date) as varchar ) + '-' + cast(datepart(day, @end_date) as varchar) + ', ' + cast(datepart(year,@end_date) as varchar) as date_range
			,end_data.permission_code_1_row_count - start_data.permission_code_1_row_count as permission_1_change
			,end_data.permission_code_0_row_count - start_data.permission_code_0_row_count  as permission_0_change
			from (
				select 
				etl_id
				,run_date
				,schema_name
				,table_name
				,permission_code_1_row_count
				,permission_code_0_row_count
				,total_row_count
				,status 
				from dt_hai_webmap_etl_log el
				where cast(run_date as date)  = @start_date 
				and schema_name = @schema_name
				)start_data

			inner join (

				select 
				etl_id
				,run_date
				,schema_name
				,table_name
				,permission_code_1_row_count
				,permission_code_0_row_count
				,total_row_count
				,status 
				from dt_hai_webmap_etl_log el
				where cast(run_date as date)  = @end_date 
				and schema_name = @schema_name
				) end_data
				on start_data.schema_name = end_data.schema_name and start_data.table_name = end_data.table_name

		end