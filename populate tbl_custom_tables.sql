
use equis_reporting
go

set nocount off
go

declare @SchemaName varchar (100) = 's_36599_test'

delete tbl_custom_tables
insert into tbl_custom_tables
		select 47,'generic','tbl_SE',  'mg/kg', 'SE','N83SPCA III Ft', 'Select * INTO [EQuIS_Reporting].','  FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v2]( @facility_id, @unit, null, @coord_type, @matrix)'
		union					
		select 47,'generic','tbl_SO',  'mg/kg', 'SO','N83SPCA III Ft', 'Select *  INTO [EQuIS_Reporting].',' FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v2]( @facility_id, @unit, null, @coord_type, @matrix)'
		union
		select  47,'generic','tbl_GW',  'ug/l', 'WG', 'N83SPCA III Ft', 'Select * INTO [EQuIS_Reporting].',' FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v2]( @facility_id, @unit, null, @coord_type, @matrix)'
		union
		select  47,'generic','tbl_SV',  'mg/m3', 'GS', 'N83SPCA III Ft', 'Select  *  INTO [EQuIS_Reporting].',' FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v2]( @facility_id, @unit, null, @coord_type, @matrix)'
		union
		select  47,'generic','tbl_IA',  'mg/m3', 'AA|IA', 'N83SPCA III Ft', 'Select  *  INTO [EQuIS_Reporting].',' FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v2]( @facility_id, @unit, null, @coord_type, @matrix)'
		union
		select   
			47
			,'location'
			,'tbl_location'
			, null
			, null
			, 'N83SPCA III Ft'
			, 'SELECT tblSamples.* ,sl.[surveyed_surface_elev],sl.[Parcel_ID],sl.[site_name],sl.[location_source] ,sl.[SharePoint_Folder],sl.[SharePoint_Folder_EDDs],sl.[sharepoint_link_text] ,sl.[boring_log_link],sl.[loc_id] ,sl.[mgp_area_type] INTO [EQuIS_Reporting].'
			,' FROM(SELECT * FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Samples_v2]( @facility_id , @coord_zone) ) as tblSamples left join dbo.tbl_36599_SamplingLocation sl on tblSamples.sys_loc_code = sl.sys_loc_code' 
union

		select   
			47
			,'BaP'
			,'tbl_BaPEQ'
			, null
			, null
			, 'N83SPCA III Ft'
			, 'SELECT * INTO [EQuIS_Reporting].'
			,'FROM (' + char(10) +
	--			'SELECT s.[sys_loc_code],s.[loc_type],s.[sys_sample_code],s.[sample_date],s.[start_depth],s.[end_depth],s.[depth_unit],' + char(10) +
	--				   's.[basis],s.[geological_unit_code], s.[sample_type_code],s.[sample_desc],s.[sample_class],s.[remediation_status],' + char(10) +
	--				   's.[x_coord],s.[y_coord] ,' + '''' + 'BaP EQ' + '''' + ' as [chemical_name], sl.mgp_area_type,' + char(10) +
	--				   's.[converted_result] as [report_result_text_HA], s.[converted_result_numeric] as [result_numeric],' + char(10) +
	--				   '((s.[converted_result] '+ ' '  + ' s.[Qualifier])) as [report_result_text_HA_qual]' + char(10) +
	--			'FROM  ' + @SchemaName + '.tbl_SO s' + char(10) +
	--			'left join dbo.tbl_36599_SamplingLocation sl on s.sys_loc_code = sl.sys_loc_code' + char(10) +
	--			'WHERE [cas_rn] = ' + '''' + '50-32-8BAPEQ.RL' + ''''  + char(10) +
	--		 ') as soilBapTable '


		declare @t table (table_name varchar (30))
		insert into @t select table_name from tbl_custom_tables

		select * from tbl_custom_tables



