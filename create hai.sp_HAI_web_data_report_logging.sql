use equis
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*Report used to write out Web Data ETL logging to Enterprise Notifications*/
	alter PROCEDURE hai.sp_HAI_web_data_report_logging
	(@facility_Id int
	,@start_date datetime
	,@end_date datetime)
	AS
		BEGIN

			SET NOCOUNT ON;
			set @start_date = cast(convert(varchar,@start_date,101) as datetime)  -- round down to midnight
			set @end_date = dateadd(day,1,cast(convert(varchar,@end_date,101) as datetime))

		 select 
			 ETL_ID
			,run_date
			,schema_name
			,table_name
			,row_count
			,status
		 from equis_reporting.dbo.etl_log
		 where run_date > = @start_date
			and run_date <= @end_date
		END
	GO
