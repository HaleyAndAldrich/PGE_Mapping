
use equis_reporting
go

set nocount off
go


delete tbl_custom_tables where facility_id =  5036806
insert into tbl_custom_tables
		select 5036806,'generic','tbl_All_Results',  null, 'SO','N83SP NJ Ft', 'Select * INTO [EQuIS_Reporting].','  FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v3]( @facility_id, @unit, null, @coord_type, @matrix)'
		union
		select   
			5036806
			,'location'
			,'tbl_location'
			, null
			, null
			, 'N83SPCA III Ft'
			, 'SELECT tblSamples.*  INTO [EQuIS_Reporting].'
			,' FROM(SELECT * FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Samples_v2]( @facility_id , @coord_zone) ) as tblSamples ' 


		declare @t table (table_name varchar (30))
		insert into @t select table_name from tbl_custom_tables

		select * from tbl_custom_tables



