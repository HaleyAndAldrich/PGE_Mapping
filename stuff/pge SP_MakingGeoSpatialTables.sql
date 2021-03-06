USE [EQuIS_Reporting]
GO
/****** Object:  StoredProcedure [s_36599E00].[SP_MakingGeoSpatialTables]    Script Date: 4/6/2017 5:56:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Dariush Mobini>
-- Create date: <2017-04-05>
-- Description:	<Create spatial tables that will be used for Geocortex and ArcGIS>
-- Project : PG&E
-- =============================================
ALTER PROCEDURE [s_36599E00].[SP_MakingGeoSpatialTables] 


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

--making the SO table and sample location from EQuIS 
DECLARE	

	@sqlRun AS NVARCHAR(4000),
	@return_value INT,
	@SchemaName VARCHAR(10)


SET @SchemaName = 's_36599E00'

IF NOT EXISTS (
SELECT  schema_name
FROM    information_schema.schemata
WHERE   schema_name = @SchemaName ) 

BEGIN
SET @sqlRun = N'CREATE SCHEMA ' + @SchemaName + ' AUTHORIZATION [dbo]'
PRINT @sqlRun
EXEC sp_executesql @sqlRun
END
			

IF OBJECT_ID('[EQuIS_Reporting].s_36599E00.tbl_SO', 'U') IS NOT NULL
BEGIN
	DROP TABLE [EQuIS_Reporting].s_36599E00.tbl_SO
END

IF OBJECT_ID('[EQuIS_Reporting].s_36599E00.tbl_GW', 'U') IS NOT NULL
BEGIN
	DROP TABLE [EQuIS_Reporting].s_36599E00.tbl_GW
END

IF OBJECT_ID('[EQuIS_Reporting].s_36599E00.tbl_SV', 'U') IS NOT NULL
BEGIN
	DROP TABLE [EQuIS_Reporting].s_36599E00.tbl_SV
END

IF OBJECT_ID('[EQuIS_Reporting].s_36599E00.tbl_BaPEQ', 'U') IS NOT NULL
BEGIN
	DROP TABLE [EQuIS_Reporting].s_36599E00.tbl_BaPEQ
END

IF OBJECT_ID('[EQuIS_Reporting].s_36599E00.tbl_location', 'U') IS NOT NULL
BEGIN
	DROP TABLE [EQuIS_Reporting].s_36599E00.tbl_location
END

SELECT * 
INTO [EQuIS_Reporting].s_36599E00.tbl_SO
FROM 
( 
SELECT * FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v2]('47', 'mg/kg', NULL, 'N83SPCA III Ft') WHERE matrix_code = 'SO'
) as tblSoil


SELECT * 
INTO [EQuIS_Reporting].s_36599E00.tbl_GW
FROM 
( 
SELECT * FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v2]('47', 'ug/L', NULL, 'N83SPCA III Ft') WHERE matrix_code = 'WG'
) as tblGroundwater


SELECT * 
INTO [EQuIS_Reporting].s_36599E00.tbl_SV
FROM 
( 
SELECT * FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v2]('47', 'ug/L', NULL, 'N83SPCA III Ft') WHERE matrix_code = 'GS'
) as tblSoilVapor

--do the query and create the sample table
SELECT tblSamples.* ,sl.[surveyed_surface_elev],sl.[Parcel_ID],sl.[site_name],sl.[location_source] ,sl.[SharePoint_Folder]
      ,sl.[SharePoint_Folder_EDDs],sl.[sharepoint_link_text] ,sl.[boring_log_link],sl.[loc_id] ,sl.[mgp_area_type]
INTO [EQuIS_Reporting].s_36599E00.tbl_location
FROM(
SELECT * FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Samples_v2]('47', 'N83SPCA III Ft') 
) as tblSamples left join dbo.tbl_36599_SamplingLocation sl on tblSamples.sys_loc_code = sl.sys_loc_code
--WHERE matrix_code = 'SO'

SELECT	'Return Value' = @return_value
EXEC	@return_value = [dbo].[Sp_AddSpatialElements]
		@tableInName = N's_36599E00.tbl_location',
		@ProjSRID = N'2227'

--do the query and create the BapEQ table
SELECT * 
INTO [EQuIS_Reporting].s_36599E00.tbl_BaPEQ
FROM (
		SELECT s.[sys_loc_code],s.[loc_type],s.[sys_sample_code],s.[sample_date],s.[start_depth],s.[end_depth],s.[depth_unit],
			   s.[basis],s.[geological_unit_code], s.[sample_type_code],s.[sample_desc],s.[sample_class],s.[remediation_status],
			   s.[x_coord],s.[y_coord] ,N'BaP EQ' as [chemical_name], sl.mgp_area_type,
			   s.[converted_result] as [report_result_text_HA], s.[converted_result_numeric] as [result_numeric],
			   ((s.[converted_result] + ' '  +  s.[Qualifier])) as [report_result_text_HA_qual]
		FROM   s_36599E00.tbl_SO s
		left join dbo.tbl_36599_SamplingLocation sl on s.sys_loc_code = sl.sys_loc_code
		WHERE [cas_rn] = '50-32-8BAPEQ.RL' 
	 ) as soilBapTabel

--create spatial info

EXEC	@return_value = [dbo].[Sp_AddSpatialElements]
		@tableInName = N's_36599E00.tbl_BaPEQ',
		@ProjSRID = N'2227'

SELECT	'Return Value' = @return_value
END
