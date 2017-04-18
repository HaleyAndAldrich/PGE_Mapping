
use equis_reporting
go

set nocount off
go


delete tbl_custom_tables
insert into tbl_custom_tables
		select 47,'generic','tbl_SE',  'mg/kg', 'SE','N83SPCA III Ft', 'Select * INTO [EQuIS_Reporting].','  FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v3]( @facility_id, @unit, null, @coord_type, @matrix)'
		union					
		select 47,'generic','tbl_SO',  'mg/kg', 'SO','N83SPCA III Ft', 'Select *  INTO [EQuIS_Reporting].',' FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v3]( @facility_id, @unit, null, @coord_type, @matrix)'
		union
		select  47,'generic','tbl_GW',  'ug/l', 'WG', 'N83SPCA III Ft', 'Select * INTO [EQuIS_Reporting].',' FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v3]( @facility_id, @unit, null, @coord_type, @matrix)'
		union
		select  47,'generic','tbl_SV',  'mg/m3', 'GS', 'N83SPCA III Ft', 'Select  *  INTO [EQuIS_Reporting].',' FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v3]( @facility_id, @unit, null, @coord_type, @matrix)'
		union
		select  47,'generic','tbl_IA',  'mg/m3', 'AA|IA', 'N83SPCA III Ft', 'Select  *  INTO [EQuIS_Reporting].',' FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v3]( @facility_id, @unit, null, @coord_type, @matrix)'
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
			,' FROM (SELECT s.[sys_loc_code],s.[loc_type],s.[sys_sample_code],s.[sample_date],s.[start_depth],s.[end_depth],s.[depth_unit], s.[basis],s.[geological_unit_code], s.[sample_type_code],s.[sample_desc],s.[sample_class],s.[remediation_status],
				   s.[x_coord],s.[y_coord] ,' + '''' + 'BaP EQ' + '''' + ' as [chemical_name], sl.mgp_area_type,
					   s.[converted_result] as [report_result_text_HA], s.[converted_result_numeric] as [result_numeric],
					   ((s.[converted_result] '+ '+ ' + '''' + ' ' + '''' + ' + '  + ' s.[Qualifier])) as [report_result_text_HA_qual]
						FROM  s_36599_test.tbl_SO s left join dbo.tbl_36599_SamplingLocation sl on s.sys_loc_code = sl.sys_loc_code WHERE [cas_rn] = ' + '''' + '50-32-8BAPEQ.RL' + '''' + ') as soilBapTable '


		declare @t table (table_name varchar (30))
		insert into @t select table_name from tbl_custom_tables

		select * from tbl_custom_tables



