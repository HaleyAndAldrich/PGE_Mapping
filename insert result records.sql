USE [EQuIS_Reporting]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--ALTER PROCEDURE [dbo].[sp_MakingGeoSpatialTables] (
declare
	 @facility_id int = 47
	,@SchemaName VARCHAR(20) ='s_36599test'
	,@coord_zone varchar (20) = 'N83SPCA III Ft'
	,@SRID int = N'2227'
	,@sample_table_name varchar (100) = 'tbl_36599_SamplingLocation'
--)
--AS
--BEGIN
--	--SET NOCOUNT ON added to prevent extra result sets from
--	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--    -- Insert statements for procedure here

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

		/*Create new tables */
				declare @new_tables table (table_name varchar(100),facility_id int, units varchar (10),matrix varchar(10),coord_zone varchar (20))
					insert into @new_tables
					select 'tbl_SO', @facility_id, 'mg/kg', 'SO',@coord_zone
					union
					select  'tbl_GW', @facility_id, 'ug/l', 'WG', @coord_zone
					union
					select  'tbl_SV', @facility_id, 'mg/m3', 'GS', @coord_zone
					union
					select  'tbl_IA', @facility_id, 'mg/m3', 'AA|IA', @coord_zone


					select * from @new_tables
					declare   @facility_id_text varchar (10), @units varchar (10), @matrix varchar (10)

				while (select count(*) from @new_tables) > 0
				Begin
					set @facility_id_text = cast(@facility_id as varchar (10))
					set @table_name = (select top 1 table_name from  @new_tables)
					set @units = (select units from @new_tables where table_name = @table_name)
					set @matrix = (select matrix from @new_tables where table_name = @table_name)

					set @SQL = 
						'SELECT * ' + char(10) +
						'INTO [EQuIS_Reporting].' + @SchemaName + '.'+ @table_name + char(10) +
						'FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v2](' + @facility_id_text + ', ' + '''' + @units + '''' + ',' +  ' NULL ' + ',' + '''' + @coord_zone + '''' +  '''' + @matrix + '''' +')' 
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



				--update/insert table spatial element
					begin try
						set @schema_table_name = @SchemaName + '.'+ @table_name
						exec [dbo].[Sp_AddSpatialElements]  @schema_table_name, @SRID
						set @err_msg  = (select @table_name + ' spatial elements updated.')
						RAISERROR (@err_msg, 0, 1) WITH NOWAIT	
					end try
					begin catch
						set @err_msg  = (select @table_name + ' spatial update failed.')
						RAISERROR (@err_msg, 0, 1) WITH NOWAIT	
					end catch

					delete @new_tables where table_name = @table_name

				end

		--create Results All table
				SELECT @SQL =  ISNULL(@SQL,'') +'Select * from '+ @SchemaName + '.' + table_name + ' union ' 
				FROM (SELECT DISTINCT  table_name FROM  @new_tables ) p

				set @SQL = left(@SQL,len(@SQL) -6) + char(10) + 
				'Into ' +  @SchemaName + '.' + 'tbl_All_Results'
			begin try
				exec (@SQL)
				set @err_msg  = (select @SchemaName + '.' + 'tbl_All_Results created.')
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT	
			end try
			begin catch
				set @err_msg  = (select @SchemaName + '.' + 'tbl_All_Results failed.')
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT					
			end catch


		--do the query and create the sample table
		SELECT tblSamples.* ,sl.[surveyed_surface_elev],sl.[Parcel_ID],sl.[site_name],sl.[location_source] ,sl.[SharePoint_Folder]
			  ,sl.[SharePoint_Folder_EDDs],sl.[sharepoint_link_text] ,sl.[boring_log_link],sl.[loc_id] ,sl.[mgp_area_type]
		INTO [EQuIS_Reporting].s_36599.tbl_location
		FROM(
		SELECT * FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Samples_v2](@facility_id, @coord_zone) 
		) as tblSamples left join dbo.tbl_36599_SamplingLocation sl on tblSamples.sys_loc_code = sl.sys_loc_code
		--WHERE matrix_code = 'SO'
		
		--set @err_msg  = (select 'Table ' + 'tbl_location ' + ' complete.')
		--RAISERROR (@err_msg, 0, 1) WITH NOWAIT
		
		set @schema_table_name = @SchemaName + '.'+ @table_name
		exec [dbo].[Sp_AddSpatialElements] 'tbl_location', @SRID
		set @err_msg  = (select 'Table ' + 'tbl_location' + ' spatial elements added. ')
		RAISERROR (@err_msg, 0, 1) WITH NOWAIT
		
		----do the query and create the BapEQ table
		--SELECT * 
		--INTO [EQuIS_Reporting].s_test.tbl_BaPEQ
		--FROM (
		--		SELECT s.[sys_loc_code],s.[loc_type],s.[sys_sample_code],s.[sample_date],s.[start_depth],s.[end_depth],s.[depth_unit],
		--			   s.[basis],s.[geological_unit_code], s.[sample_type_code],s.[sample_desc],s.[sample_class],s.[remediation_status],
		--			   s.[x_coord],s.[y_coord] ,N'BaP EQ' as [chemical_name], sl.mgp_area_type,
		--			   s.[converted_result] as [report_result_text_HA], s.[converted_result_numeric] as [result_numeric],
		--			   ((s.[converted_result] + ' '  +  s.[Qualifier])) as [report_result_text_HA_qual]
		--		FROM   s_36599E00.tbl_SO s
		--		left join dbo.tbl_36599_SamplingLocation sl on s.sys_loc_code = sl.sys_loc_code
		--		WHERE [cas_rn] = '50-32-8BAPEQ.RL' 
		--	 ) as soilBapTabel
		
		--set @err_msg  = (select 'Table ' + 'tbl_BaPEQ ' + ' complete.')
		--RAISERROR (@err_msg, 0, 1) WITH NOWAIT

		--exec [dbo].[Sp_AddSpatialElements] 'tbl_BaPEQ', @SRID
		--set @err_msg  = (select 'Table ' + 'tbl_BaPEQ ' + 'spatial elements added. ')
		--RAISERROR (@err_msg, 0, 1) WITH NOWAIT

	set @err_msg = @SchemaName + ' tables complete.'
	raiserror(@err_msg,0,1) with nowait
--SELECT	'Return Value' = @return_value
--END
