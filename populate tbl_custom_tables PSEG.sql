
use equis_reporting
go

set nocount off
go


delete tbl_custom_tables where facility_id =  5036806

insert into tbl_custom_tables
select 5036806,'generic','tbl_All_Results',  null, 'SO','N83SP NJ Ft', 'Select * INTO [EQuIS_Reporting].','  FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v4]( @facility_id, @unit, null, @coord_type, null,  @matrix, @permission_code)'
	union
select   
	5036806
	,'location'
	,'tbl_location'
	, null
	, null
	, 'N83SP NJ Ft'
	, 'SELECT distinct[subfacility_name],[sys_loc_code],[loc_name],[loc_type],[task_code],[reference_elevation],[reference_elevation_point],[coord_type_code],[x_coord],[y_coord],[SRID],[APN],Sharepoint_URL into '
	,' FROM [EQuIS_Reporting].[s_129402E002].[tbl_Results] where (permission_type_code = 0 and permission_type_code is not null) or task_code = ' + '''' + 'none' + '''' 



select * from tbl_custom_tables



