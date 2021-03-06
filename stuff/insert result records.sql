USE [EQuIS_Reporting]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--ALTER PROCEDURE [dbo].[sp_MakingGeoSpatialTables] (
declare
	 @facility_id int = 47
	,@SchemaName VARCHAR(20) ='s_36599_Test'
	,@coord_zone varchar (20) = 'N83SPCA III Ft'
	,@SRID int = N'2227'
	,@sample_table_name varchar (100) = 'tbl_36599_SamplingLocation'
--)
--AS
--BEGIN
--	--SET NOCOUNT ON added to prevent extra result sets from
--	-- interfering with SELECT statements.
	SET NOCOUNT ON;


DECLARE	
	@SQL varchar(max),
	@sqlRun AS NVARCHAR(4000),
	@return_value INT,
	@table_name varchar (200),
	@err_msg varchar (300),
	@schema_table_name varchar (100)

/*Create schema if it doesn't already exist*/
	IF NOT EXISTS (
		SELECT  schema_name
		FROM    information_schema.schemata
		WHERE   schema_name = @SchemaName ) 

	BEGIN
		SET @sqlRun = N'CREATE SCHEMA ' + @SchemaName + ' AUTHORIZATION [dbo]'
		PRINT @sqlRun
		EXEC sp_executesql @sqlRun
	END

/*Clear old tables	*/
	declare @tables table (schema_name varchar (100),table_name varchar (200))
	insert into @tables
		select
			s.name as schema_name
			,t.name as table_name
		from sys.objects o
			inner join sys.schemas s on o.schema_id = s.schema_id
			inner join sys.tables t on o.object_id = t.object_id
		where s.name = @SchemaName

	while (select count(*) from @tables) > 0
		begin
			set @table_name = (select top 1 table_name from @tables)



				Set @SQL = 
					'IF OBJECT_ID(' + '''' + '[EQuIS_Reporting].' + @SchemaName + '.' + @table_name + '''' + ', ' + '''' + 'U' + '''' + ') IS NOT NULL ' + char(10) +
					'BEGIN ' + char(10) +
						'DROP TABLE [EQuIS_Reporting].' + @SchemaName + '.' + @table_name +char(10) +
					'END'
				
				exec(@SQL)

			delete @tables where table_name = @table_name

			set @err_msg  = (select 'Table ' + @table_name + ' dropped.')
			RAISERROR (@err_msg, 0, 1) WITH NOWAIT
		end

	/******Begin Create new generic matrix tables **************************/
				declare @new_tables table (table_name varchar(100),facility_id int, units varchar (10),matrix varchar(10),coord_zone varchar (20))
					insert into @new_tables
					select 'tbl_SO', @facility_id, 'mg/kg', 'SO',@coord_zone
					union
					select  'tbl_GW', @facility_id, 'ug/l', 'WG', @coord_zone
					union
					select  'tbl_SV', @facility_id, 'mg/m3', 'GS', @coord_zone
					union
					select  'tbl_IA', @facility_id, 'mg/m3', 'AA|IA', @coord_zone
					union
					select  'tbl_SE', @facility_id, 'ug/kg', 'SE', @coord_zone
				/***get SQL for All Results table here where table has its values****/
					declare @AllTablesSQL varchar (max)
					SELECT @AllTablesSQL =  ISNULL(@AllTablesSQL,'') +'Select * from '+ @SchemaName + '.' + table_name + ' union ' 
					FROM (SELECT DISTINCT  table_name FROM  @new_tables ) p
					set @AllTablesSQL = 'Select * Into '+ @SchemaName + '.' + 'tbl_All_Results from ('+ left(@AllTablesSQL,len(@AllTablesSQL) -6) + char(10) + ')z'
					--print @AllTablesSQL
			/******************************************************************/
		
				declare  @facility_id_text varchar (10), @units varchar (10), @matrix varchar (10)

				while (select count(*) from @new_tables) > 0
				Begin
					set @facility_id_text = cast(@facility_id as varchar (10))
					set @table_name = (select top 1 table_name from  @new_tables)
					set @units = (select units from @new_tables where table_name = @table_name)
					set @matrix = (select matrix from @new_tables where table_name = @table_name)

					set @SQL = 
						'SELECT top 100 * ' + char(10) +
						'INTO [EQuIS_Reporting].' + @SchemaName + '.'+ @table_name + char(10) +
						'FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v2](' + @facility_id_text + ', ' + '''' + @units + '''' + ',' +  ' NULL ' + ',' + '''' + @coord_zone + ''''+ ',' +  '''' + @matrix + '''' +')' 
				--create tables
					begin try
						exec (@sql)
						set @err_msg  = (select 'Table ' + @table_name + ' complete.')
						RAISERROR (@err_msg, 0, 1) WITH NOWAIT
					end try
					begin catch
						set @err_msg  = (select 'Table ' + @table_name + ' not created.')
						RAISERROR (@err_msg, 0, 1) WITH NOWAIT
					end catch

					delete @new_tables where table_name = @table_name
				end 
	/************End make Generic matrix tables***************/


		--create Results All table
			begin try
				exec (@AllTablesSQL)
				set @err_msg  = (select @SchemaName + '.' + 'tbl_All_Results created.')
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT	
			end try
			begin catch
				set @err_msg  = (select @SchemaName + '.' + 'tbl_All_Results failed.')
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT					
			end catch

		--update/insert table spatial element
			insert into @new_tables
			select 'tbl_SE', @facility_id, 'mg/kg', 'SE',@coord_zone
			union
			select 'tbl_SO', @facility_id, 'mg/kg', 'SO',@coord_zone
			union
			select  'tbl_GW', @facility_id, 'ug/l', 'WG', @coord_zone
			union
			select  'tbl_SV', @facility_id, 'mg/m3', 'GS', @coord_zone
			union
			select  'tbl_IA', @facility_id, 'mg/m3', 'AA|IA', @coord_zone
			union
			select  'tbl_SE', @facility_id, 'ug/kg', 'SE', @coord_zone
			union
			select  'tbl_All_Results', @facility_id, null, null, @coord_zone
		while (select count(*) from @new_tables) > 0
		Begin
			set @table_name = (select top 1 table_name from  @new_tables)
			begin try
				set @schema_table_name = @SchemaName + '.'+ @table_name
				--exec [dbo].[Sp_AddSpatialElements]  @schema_table_name, @SRID
				set @err_msg  = (select @table_name + ' spatial elements updated.')
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT	
			end try
			begin catch
				set @err_msg  = (select @table_name + ' spatial update failed.')
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT	
			end catch

			delete @new_tables where table_name = @table_name
		end
			

	--Create the sample table
		set @SQL = char(10) +
		'SELECT tblSamples.* ,sl.[surveyed_surface_elev],sl.[Parcel_ID],sl.[site_name],sl.[location_source] ,sl.[SharePoint_Folder]' + char(10) +
			  ',sl.[SharePoint_Folder_EDDs],sl.[sharepoint_link_text] ,sl.[boring_log_link],sl.[loc_id] ,sl.[mgp_area_type]' + char(10) +
		'INTO [EQuIS_Reporting].' + @SchemaName + '.tbl_location ' + char(10)+
		'FROM(' + char(10) +
		'SELECT * FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Samples_v2](' + @facility_id_text + ',' + '''' +  @coord_zone + '''' + ') ' + char(10) +
		') as tblSamples left join dbo.tbl_36599_SamplingLocation sl on tblSamples.sys_loc_code = sl.sys_loc_code' + char(10) 
		
		begin try
			print (@SQL)
			exec (@SQL)
			set @err_msg  = (select 'Table ' + 'tbl_location' + ' complete.')
			RAISERROR (@err_msg, 0, 1) WITH NOWAIT
		end try
		begin catch
			set @err_msg  = (select 'Create Table ' + 'tbl_location' + ' failed.')
			RAISERROR (@err_msg, 0, 1) WITH NOWAIT
		end catch
	--Add spatial elements to Sample Table
		begin try
			exec [dbo].[Sp_AddSpatialElements] 's_36599_test.tbl_location', @SRID
			set @err_msg  = (select 'Table ' + 's_36599_test.tbl_location' + ' spatial elements added. ')
			RAISERROR (@err_msg, 0, 1) WITH NOWAIT
		end try
		begin catch
			set @err_msg  = (select 'Add Table ' + 's_36599test.tbl_location' + ' spatial elements failed. ')
			RAISERROR (@err_msg, 0, 1) WITH NOWAIT
		end catch

	--Create the BapEQ table
		set @SQL = 'SELECT * ' + char(10) +
		'INTO [EQuIS_Reporting].' + @SchemaName + '.tbl_BaPEQ' + char(10) +
		'FROM (' + char(10) +
				'SELECT s.[sys_loc_code],s.[loc_type],s.[sys_sample_code],s.[sample_date],s.[start_depth],s.[end_depth],s.[depth_unit],' + char(10) +
					   's.[basis],s.[geological_unit_code], s.[sample_type_code],s.[sample_desc],s.[sample_class],s.[remediation_status],' + char(10) +
					   's.[x_coord],s.[y_coord] ,' + '''' + 'BaP EQ' + '''' + ' as [chemical_name], sl.mgp_area_type,' + char(10) +
					   's.[converted_result] as [report_result_text_HA], s.[converted_result_numeric] as [result_numeric],' + char(10) +
					   '((s.[converted_result] ' + '+' + '''' + char(32) + '''' + '+ '  +  ' s.[Qualifier])) as [report_result_text_HA_qual]' + char(10) +
				'FROM  ' + @SchemaName + '.tbl_SO s' + char(10) +
				'left join dbo.tbl_36599_SamplingLocation sl on s.sys_loc_code = sl.sys_loc_code' + char(10) +
				'WHERE [cas_rn] = ' + '''' + '50-32-8BAPEQ.RL' + ''''  + char(10) +
			 ') as soilBapTable ' + char(10) 
		
		begin try
		exec(@SQL)
			set @err_msg  = (select 'Table ' + 'tbl_BaPEQ ' + ' complete.')
			RAISERROR (@err_msg, 0, 1) WITH NOWAIT
		end try
		begin catch
			set @err_msg  = (select 'Create Table ' + 'tbl_BaPEQ ' + ' Failed.')
			RAISERROR (@err_msg, 0, 1) WITH NOWAIT
		end catch

		begin try
			exec [dbo].[Sp_AddSpatialElements] 's_36599_test.tbl_BaPEQ', @SRID
			set @err_msg  = (select 'Table ' + 'tbl_BaPEQ ' + 'spatial elements added. ')
			RAISERROR (@err_msg, 0, 1) WITH NOWAIT
		end try
		begin catch
			set @err_msg  = (select 'Add Table ' + 'tbl_BaPEQ ' + 'spatial elements Failed. ')
			RAISERROR (@err_msg, 0, 1) WITH NOWAIT
		end catch


	set @err_msg = @SchemaName + ' tables complete.'
	raiserror(@err_msg,0,1) with nowait
--SELECT	'Return Value' = @return_value
--END
