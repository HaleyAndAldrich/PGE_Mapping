/****** Script for SelectTopNRows command from SSMS  ******/
select *
 into s_36599E00.tbl_location_only
from
(
SELECT distinct
      [subfacility_name],[sys_loc_code],[loc_name],[loc_type],[task_code],[reference_elevation]
      ,[reference_elevation_point],[coord_type_code],[x_coord],[y_coord],[SRID],[APN]
  FROM [EQuIS_Reporting].[s_36599E00].[tbl_Results] where (permission_type_code = 0 and permission_type_code is not null) or task_code = 'none') 
  as tbl_loc

  USE [EQuIS_Reporting]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[Sp_AddSpatialElements]
		@tableInName = N's_36599E00.tbl_location_only',
		@ProjSRID = N'2227'

SELECT	'Return Value' = @return_value

GO


