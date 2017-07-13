
use equis_reporting
go

set nocount off
go


delete tbl_custom_tables where facility_id = 47
insert into tbl_custom_tables
		select 47,'generic','tbl_SE',  'mg/kg', 'SE','N83SPCA III Ft', 'Select * INTO [EQuIS_Reporting].','  FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v3]( @facility_id, @unit, null, @coord_type, @elev_datum, @matrix) where loc_type not like ' + '''' + 'idw%' + ''''
		union					
		select 47,'generic','tbl_SO',  'mg/kg', 'SO','N83SPCA III Ft', 'Select *  INTO [EQuIS_Reporting].',' FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v3]( @facility_id, @unit, null, @coord_type , @elev_datum, @matrix) where loc_type not like ' + '''' + 'idw%' + ''''
		union
		select 47,'generic','tbl_PORE',  'mg/l', 'PORE','N83SPCA III Ft', 'Select *  INTO [EQuIS_Reporting].',' FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v3]( @facility_id, @unit, null, @coord_type , @elev_datum, @matrix) where loc_type not like ' + '''' + 'idw%' + ''''
		union
		select  47,'generic','tbl_GW',  'ug/l', 'WG', 'N83SPCA III Ft', 'Select * INTO [EQuIS_Reporting].',' FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v3]( @facility_id, @unit, null, @coord_type, @elev_datum, @matrix) where loc_type not like ' + '''' + 'idw%' + ''''
		union
		select  47,'generic','tbl_SV',  'mg/m3', 'GS', 'N83SPCA III Ft', 'Select  *  INTO [EQuIS_Reporting].',' FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v3]( @facility_id, @unit, null, @coord_type, @elev_datum, @matrix) where loc_type not like ' + '''' + 'idw%' + ''''
		union
		select  47,'generic','tbl_IA',  'mg/m3', 'AA|IA', 'N83SPCA III Ft', 'Select  *  INTO [EQuIS_Reporting].',' FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v3]( @facility_id, @unit, null, @coord_type, @elev_datum, @matrix) where loc_type not like ' + '''' + 'idw%' + ''''
		union
		select   
			47
			,'location'
			,'tbl_location'
			, null
			, null
			, 'N83SPCA III Ft'
			, 'SELECT distinct[subfacility_name],[sys_loc_code],[loc_name],[loc_type],[task_code],[reference_elevation],[reference_elevation_point],[coord_type_code],[x_coord],[y_coord],[SRID],[APN],Sharepoint_URL into '
			,' FROM [EQuIS_Reporting].[s_36599E00_test].[tbl_Results] where (permission_type_code = 0 )'
union

		select   
			47
			,'custom'
			,'tbl_BaPEQ'
			, null
			, null
			, 'N83SPCA III Ft'
			, 'SELECT * INTO [EQuIS_Reporting].[s_36599E00_test].tbl_BaPEQ'
			,' FROM (SELECT s.[sys_loc_code],s.[loc_type],s.[sys_sample_code],s.[sample_date],s.[start_depth],s.[end_depth],s.[depth_unit], null as [basis], null as [geological_unit_code], s.[sample_type_code],null as [sample_desc],null as [sample_class],null as [remediation_status],
				   s.[x_coord],s.[y_coord] ,' + '''' + 'BaP EQ' + '''' + ' as [chemical_name], sl.mgp_area_type,
					   s.[result_value],
					   s.[result_label]
						FROM  s_36599E00_test.tbl_SO s left join dbo.tbl_36599_SamplingLocation sl on s.sys_loc_code = sl.sys_loc_code WHERE [cas_rn] = ' + '''' + '50-32-8BAPEQ.RL' + '''' + ') as soilBapTable '
union

		select   
			47
			,'special'
			,'tbl_IDW'
			, null
			, null
			, 'N83SPCA III Ft'
			,'select  * into s_36599E00_test.tbl_IDW '
			,'FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v3]( 47, null, null, ' + '''' + 'N83SPCA III Ft' + '''' + ', null,' + '''' +  'SO|SQ|W|WG|WQ' + '''' + ')'
				 + ' where loc_Type  like ' + '''' + 'idw%' + '''' +  ' And subfacility_NAME in (' + '''' + 'Beach Street' + '''' + ',' + '''' + 'Former Fillmore MGP' + '''' + ',' + '''' + 'Former North Beach MGP' + '''' + ') AND PERMISSION_type_CODE = ' + '''' + '0' + '''' + ' and x_coord is not null'

--union
--	select
--	 47
--	,'custom'
--	,'update SO lead permissions'
--	,null
--	,null 
--	,null
--	,'update [EQuIS_Reporting].s_36599E00_test.[tbl_SO] set [permission_type_code] = 1 where [chemical_name] like ' + ''''+ '%lead%' + '''' + 
--			' and sys_loc_code in (select member_code from equis.dbo.rt_group_member where group_code = ' + '''' + 'PGE_SO_Lead_exclude' + '''' + ' and facility_id = 47)'
--	,null
--union
--	select
--	 47
--	,'custom'
--	,'update Results lead permissions'
--	,null
--	,null 
--	,null
--	,'update [EQuIS_Reporting].s_36599E00_test.[tbl_Results] set [permission_type_code] = 1 where [chemical_name] like ' + ''''+ '%lead%' + '''' + 
--			' and sys_loc_code in (select member_code from equis.dbo.rt_group_member where group_code = ' + '''' + 'PGE_SO_Lead_exclude' + '''' + ' and facility_id = 47)'
--	,null		
		
		
--declare @t table (table_name varchar (30))
--insert into @t select table_name from tbl_custom_tables

select * from tbl_custom_tables



