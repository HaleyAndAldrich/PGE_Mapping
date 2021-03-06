USE [equis]
GO
/****** Object:  StoredProcedure [HAI].[sp_HAI_webmap_move_etl_log_recs_to_equis]    Script Date: 5/15/2017 11:52:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*moves web data ETL log from equis_reporting to equis for use in status notifications and reporting*/
ALTER PROCEDURE [HAI].[sp_HAI_webmap_move_etl_log_recs_to_equis]
AS
BEGIN

	SET NOCOUNT ON;
	insert into dt_hai_webmap_etl_log
		 select 
			 ER.ETL_ID
			,ER.run_date
			,ER.[schema_name]
			,ER.table_name
			,ER.permission_code_1_row_count
			,ER.permission_code_0_row_count
			,ER.total_row_count
			,ER.status
			,null as euid
			
		 from equis_reporting.dbo.etl_log ER
		 left join equis.dbo.dt_hai_webmap_etl_log EQ on ER.etl_id = EQ.etl_id
		 where EQ.etl_id is null
END
