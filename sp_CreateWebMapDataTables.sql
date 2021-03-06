USE [EQuIS_Reporting]
GO
/****** Object:  StoredProcedure [dbo].[sp_CreateWebMapDataTables]    Script Date: 9/21/2017 3:58:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_CreateWebMapDataTables] (

	 @facility_id nvarchar(10)
	,@SchemaName VARCHAR(20) 
	,@coord_zone nvarchar (20) 
	,@SRID varchar(10) 
	,@elev_datum varchar (20)
	,@sample_table_name varchar (100) 
	,@URL_yn varchar(2)
	,@permissions varchar (20)
)
AS
BEGIN
--SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


DECLARE	
	@SQL nvarchar(max),
	@return_value INT,
	@table_name varchar (200),
	@err_msg varchar (300),
	@schema_table_name varchar (100),
	@unit varchar (10),
	@matrix varchar (10),
	@table_list varchar (500),
	@parameters nvarchar(1000) ,
	@facility_id_text nvarchar (10) = cast(@facility_id as varchar (10)),
	@AllTablesSQL varchar (max),
	@row_id int


/*Create schema if it doesn't already exist*/
	IF NOT EXISTS (
		SELECT  schema_name
		FROM    information_schema.schemata
		WHERE   schema_name = @SchemaName ) 

	BEGIN
		SET @SQL = N'CREATE SCHEMA ' + @SchemaName + ' AUTHORIZATION [dbo]'
		PRINT @SQL
		EXEC sp_executesql @SQL
	END

/*Clear old tables	*/
	print '1. Clear old tables' + char(10)
	declare @tables table (schema_name varchar (100),table_name varchar (200))
	insert into @tables
		select
			s.name as schema_name
			,t.name as table_name
		from sys.objects o
			inner join sys.schemas s on o.schema_id = s.schema_id
			inner join sys.tables t on o.object_id = t.object_id
		where s.name = @SchemaName and t.name not like '%tbl_results_flat_file'

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

			set @err_msg  = (select '  Table ' + @table_name + ' dropped.')
			RAISERROR (@err_msg, 0, 1) WITH NOWAIT
		end

	/******Begin Create new generic matrix tables **************************/
	Print char(10) + '2. Create new generic [Matrix] tables.' 
		declare @t table (table_name varchar (30))
		insert into @t select table_name from tbl_custom_tables where table_type = 'generic' and facility_id = @facility_id
		print char(10) + 'Begin generic tables...'


		SET @parameters = N'@facility_id int, @unit varchar (10), @coord_type varchar (20), @elev_datum varchar (20), @matrix varchar (10), @permissions varchar (20)';


		set @row_id = coalesce((select max(etl_id) from dbo.etl_log),0) + 1
		while (select count(*) from @t)> 0
		begin
			set @table_name = (select top 1 table_name from @t)
			set @unit = (select unit_code from tbl_custom_tables where facility_id = @facility_id and table_name = @table_name)
			set @coord_zone = (select coord_zone from tbl_custom_tables where facility_id = @facility_id and table_name = @table_name)
			set @matrix = (select matrix_code from tbl_custom_tables where facility_id = @facility_id and table_name = @table_name)

			
			set @sql = (select SelectSQL from tbl_custom_tables where table_name = @table_name) + @SchemaName + '.'+ @table_name +(select FromSQL from tbl_custom_tables where table_name = @table_name)
			

			execute sp_executesql @SQL, @parameters, @facility_id , @unit , @coord_zone, @elev_datum , @matrix,@permissions ;

			if @URL_yn = 'Y'
			begin
				set @sql = 'update ' +@SchemaName + '.'+ @table_name  + char(10)+
					'Set Sharepoint_URL = equis_reporting.dbo.fn_PGE_sharepoint_address (subfacility_name, task_code, apn) '
				begin try
					execute sp_executesql @sql
					set @err_msg = @SchemaName + '.'+ @table_name + ' Sharepoint URL updated.'
					raiserror(@err_msg, 0,1) with nowait
				end try
				begin catch
					set @err_msg = @SchemaName + '.'+ @table_name + ' Sharepoint URL failed.'
					raiserror(@err_msg, 0,1) with nowait
					set @err_msg = error_message()
					raiserror(@err_msg, 0,1) with nowait
				end catch
			end

			set @SQL = 'Set @rec_cnt = (select count(*) from ' + @table_name + ')'
			set @err_msg  = (select '  Table ' + @table_name + ' complete.')
			RAISERROR (@err_msg, 0,1) with nowait

			delete @t where table_name = @table_name

			/*log query results*/
			
			set @SQL = 'insert into dbo.etl_log' + char(10) +
			 ' select ' + cast( @row_id as varchar (10)) + ', getdate(), ' + '''' +  @SchemaName + '''' + ',' + char(10) +
			  '''' + @table_name + '''' + ',' + char(10) + 
			  '(select count(*) from ' + @SchemaName + '.' + @table_name +  ' where permission_type_code = 1),' + char(10) +
			  '(select count(*) from ' + @SchemaName + '.' + @table_name +  ' where permission_type_code = 0),' + char(10) +
			  '(select count(*) from ' + @SchemaName + '.' + @table_name +   '),' + char(10) +
			   +  '''' + 'complete' + ''''
		begin try
			execute sp_executesql @SQL
		end try
		begin catch
			set @err_msg = 'Insert ETL Log Failed.'
			raiserror (@err_msg, 0,1)
			print @SQL
		end catch
			
		end

	/************End make Generic matrix tables***************/


	/***get SQL for All Results table here where table has its values****/
		print 'Create [All Results] table.' + char(10)

			SELECT @AllTablesSQL =  ISNULL(@AllTablesSQL,'') +'Select * from '+ @SchemaName + '.' + table_name + ' union ' 
			FROM (SELECT DISTINCT  table_name FROM  tbl_custom_tables where table_type = 'generic' and facility_id = @facility_id ) p
			set @AllTablesSQL = 'Select * Into '+ @SchemaName + '.' + 'tbl_Results from ('+ left(@AllTablesSQL,len(@AllTablesSQL) -6) + char(10) + ')z'
			print  char(10) + 'All results: ' + char(10 ) + replace( replace(@AllTablesSQL,'union','union' + char(10)),'from','from' + char(10) +  '(') + char(10)


		--create Results_All table
			begin try
				exec (@AllTablesSQL)

			/*log insert*/
			set @table_name = 'tbl_Results'
			set @SQL = 'insert into dbo.etl_log' + char(10) +
			 ' select ' + cast( @row_id as varchar (10)) + ', getdate(), ' + '''' +  @SchemaName + '''' + ',' + char(10) +
			  '''' + @table_name + '''' + ',' + char(10) + 
			  '(select count(*) from ' + @SchemaName + '.' + @table_name +  ' where permission_type_code = 1),' + char(10) +
			  '(select count(*) from ' + @SchemaName + '.' + @table_name +  ' where permission_type_code = 0),' + char(10) +
			  '(select count(*) from ' + @SchemaName + '.' + @table_name +   '),' + char(10) +
			   +  '''' + 'complete' + ''''				
				execute sp_executesql @SQL			

				set @err_msg  = (select @SchemaName + '.' + '  tbl_All_Results created.')
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT	
			end try
			begin catch
			/*log failure*/
			set @SQL = 'insert into dbo.etl_log' + char(10) +
				 ' select ' + cast( @row_id as varchar (10)) + ', getdate(), ' + '''' +  @SchemaName + '''' + ',' + '''' + @table_name + '''' + ',' + '''' + '0' + '''' + ', '+ '''' + '0' + '''' + ', '+ '''' + '0' + '''' + ', ' + ''''+ 'failed' + ''''
				execute sp_executesql @SQL						

				set @err_msg  = (select @SchemaName + '.' + '  tbl_All_Results failed.')
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT					
			end catch

	/*****Create the Location table*****/
	/***Depends on tbl_results ***/
	Print char(10) + '3. Create Special tables' 
		print 'Create location table.' + char(10)

		set @table_name = 'tbl_location'

		SET @parameters = N'@facility_id int , @coord_zone  varchar (20)'
			set @sql = (select SelectSQL from tbl_custom_tables where facility_id = @facility_id and table_name = @table_name) + @SchemaName + '.'+ @table_name +(select FromSQL from tbl_custom_tables where facility_id = @facility_id and table_name = @table_name)
		begin try			
			execute sp_executesql @SQL, @parameters, @facility_id , @coord_zone  ;
			/*log insert*/
			set @SQL = 'insert into dbo.etl_log' + char(10) +
			 ' select ' + cast( @row_id as varchar (10)) + ', getdate(), ' + '''' +  @SchemaName + '''' + ',' + char(10) +
			  '''' + @table_name + '''' + ',' + char(10) + 
			  '(select count(*) from ' + @SchemaName + '.' + @table_name +  ' where permission_type_code = 1),' + char(10) +
			  '(select count(*) from ' + @SchemaName + '.' + @table_name +  ' where permission_type_code = 0),' + char(10) +
			  '(select count(*) from ' + @SchemaName + '.' + @table_name +   '),' + char(10) +
			   +  '''' + 'complete' + ''''					
			set @err_msg  = (select '  Table ' + 'tbl_location' + ' complete.')
			RAISERROR (@err_msg, 0, 1) WITH NOWAIT
		end try
		begin catch
			/*log failure*/
			set @SQL = 'insert into dbo.etl_log' + char(10) +
				 ' select ' + cast( @row_id as varchar (10)) + ', getdate(), ' + '''' +  @SchemaName + '''' + ',' + '''' + @table_name + '''' + ',' + '''' + '0' + '''' + ', '+ '''' + '0' + '''' + ', '+ '''' + '0' + '''' + ', ' + ''''+ 'failed' + ''''
				execute sp_executesql @SQL						
			
			set @err_msg  = (select '  Create Table ' + 'tbl_location' + ' failed.')
			RAISERROR (@err_msg, 0, 1) WITH NOWAIT
			print @SQL + char(10)
		end catch

	--Run Custom Queries
		declare @custom_tables table(table_name varchar (100))
		insert into @custom_tables  select table_name from tbl_custom_tables where facility_id = @facility_id and table_type in('special', 'custom')
		
		while (select count(*) from  @custom_tables ) > 0
		begin
			Set @table_name = (select top 1 table_name from @custom_tables)

			print 'Run Query ' + @table_name  + char(10)

			set @sql = (select SelectSQL from tbl_custom_tables where facility_id = @facility_id and table_name = @table_name ) + (select isnull(FromSQL,'') from tbl_custom_tables where facility_id = @facility_id and  table_name = @table_name )
			begin try			
				execute sp_executesql @SQL;


				set @err_msg  = (select '  Query ' + @table_name + ' complete.')
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT
			end try
			begin catch
					
				set @err_msg  = (select '  Query ' + @table_name + ' failed.')
			
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT
				set @err_msg =  error_message()
				raiserror(@err_msg,0,1) with nowait
				print @SQL + char(10)

			end catch

			delete @custom_tables where table_name = @table_name
		end
/*******Add Spatial Elements***********************************/
		print char(10) + ' 4. Add Spatial Elements: ' 

		--update/insert spatial element

			--update tbl_results separately from other tables because its dynmaically created from whatever generic tables exist
			set @table_name =  @SchemaName + '.' + 'tbl_Results'
			set @SQL = 'exec [dbo].[Sp_AddSpatialElements] '+ '''' + @table_name + '''' + ', '  + @SRID + '; '
			begin try
				exec(@SQL)
				set @err_msg  = 'tbl_Results Spatial elements updated.'
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT	
			end try
			begin catch
				set @err_msg  =  'tbl_Results Spatial update failed.'
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT	
			end catch

			--update all other table spatial elements
			set @SQL = ''
			SELECT @SQL =  ISNULL(@SQL,'') + 'begin try exec [dbo].[Sp_AddSpatialElements] [' + tbl +  '], '  + @SRID + + ' end try begin catch print error_message() end catch;' +  char(10)
				FROM (SELECT DISTINCT  @SchemaName + '.' + table_name  as tbl FROM  tbl_custom_tables where facility_id = @facility_id and table_type in ('location','special','generic')) p		

			begin try
				exec(@SQL)
				set @err_msg  = ' Spatial elements updated.'
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT	
			end try
			begin catch
				set @err_msg  =  ' Spatial update failed.'
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT	
			end catch

	/*Run report log*/
		--moves etl log recs from equis_reporting to equis
		exec  equis.[HAI].[sp_HAI_webmap_move_etl_log_recs_to_equis]

	set @err_msg = char(10) + @SchemaName + ' Tables Complete.'
	raiserror(@err_msg,0,1) with nowait

END
