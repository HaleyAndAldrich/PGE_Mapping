
use equis_reporting
go

set nocount off
go


delete tbl_custom_tables where facility_id =  2172688

insert into tbl_custom_tables
select 2172688,'generic','tbl_All_Results',  null, 'SO|WG','N83SP OH North', 'Select * INTO [EQuIS_Reporting].','  FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v4]( @facility_id, @unit, null, @coord_type, null,  @matrix, @permission_code)'
	union
select   
	2172688
	,'location'
	,'tbl_location'
	, null
	, null
	, 'N83SP OH North'
	, 'SELECT distinct[subfacility_name],[sys_loc_code],[loc_name],[loc_type],[task_code],[reference_elevation],[reference_elevation_point],[coord_type_code],[x_coord],[y_coord],[SRID],[APN],Sharepoint_URL into '
	,' FROM [EQuIS_Reporting].[s_42916E00].[tbl_Results] where (permission_type_code = 0 and permission_type_code is not null) or task_code = ' + '''' + 'none' + '''' 



select * from tbl_custom_tables



