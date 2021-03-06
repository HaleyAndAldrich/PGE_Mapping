USE [EQuIS_Reporting]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Alter PROCEDURE [dbo].[sp_CreateWebMapDataTables] (

	 @facility_id nvarchar(10)= 47
	,@SchemaName VARCHAR(20) ='s_36599_test'
	,@coord_zone nvarchar (20) = 'N83SPCA III Ft'
	,@SRID varchar(10) = N'2227'
	,@sample_table_name varchar (100) = 'tbl_36599_SamplingLocation'
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
	@AllTablesSQL varchar (max)

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

			set @err_msg  = (select '  Table ' + @table_name + ' dropped.')
			RAISERROR (@err_msg, 0, 1) WITH NOWAIT
		end

	/******Begin Create new generic matrix tables **************************/
	Print char(10) + '2. Create new generic [Matrix] tables.' 
		declare @t table (table_name varchar (30))
		insert into @t select table_name from tbl_custom_tables where table_type = 'generic'
		print char(10) + 'Begin generic tables...'


		SET @parameters = N'@facility_id int, @unit varchar (10), @coord_type varchar (20), @matrix varchar (10)';



		while (select count(*) from @t)> 0
		begin
			set @table_name = (select top 1 table_name from @t)
			set @unit = (select unit_code from tbl_custom_tables where facility_id = @facility_id and table_name = @table_name)
			set @coord_zone = (select coord_zone from tbl_custom_tables where facility_id = @facility_id and table_name = @table_name)
			set @matrix = (select matrix_code from tbl_custom_tables where facility_id = @facility_id and table_name = @table_name)


			set @sql = (select SelectSQL from tbl_custom_tables where table_name = @table_name) + @SchemaName + '.'+ @table_name +(select FromSQL from tbl_custom_tables where table_name = @table_name)
			
			execute sp_executesql @SQL, @parameters, @facility_id , @unit , @coord_zone ,@matrix ;
			set @err_msg  = (select '  Table ' + @table_name + ' complete.')
			RAISERROR (@err_msg, 0,1) with nowait

			delete @t where table_name = @table_name
			
		end
			--set @SQL = ''
			
			--SELECT @SQL =  ISNULL(@SQL,'') + [SQL] + ';'
			--FROM (SELECT DISTINCT  SQL FROM  tbl_custom_tables ) p

			--print ' 1. Single table: ' + char(10) +  @SQL
			--exec (@sql)
	/************End make Generic matrix tables***************/

	/*****Create the Location table*****/
	Print char(10) + '3. Create Special tables' 
		print 'Create location table.' + char(10)

		set @table_name = 'tbl_location'

		SET @parameters = N'@facility_id int , @coord_zone  varchar (20)'
			set @sql = (select SelectSQL from tbl_custom_tables where table_name = @table_name) + @SchemaName + '.'+ @table_name +(select FromSQL from tbl_custom_tables where table_name = @table_name)
		begin try			
			execute sp_executesql @SQL, @parameters, @facility_id , @coord_zone  ;
			set @err_msg  = (select '  Table ' + 'tbl_location' + ' complete.')
			RAISERROR (@err_msg, 0, 1) WITH NOWAIT
		end try
		begin catch
			set @err_msg  = (select '  Create Table ' + 'tbl_location' + ' failed.')
			RAISERROR (@err_msg, 0, 1) WITH NOWAIT
			print @SQL + char(10)
		end catch

	/***get SQL for All Results table here where table has its values****/
		print 'Create [All Results] table.' + char(10)

			SELECT @AllTablesSQL =  ISNULL(@AllTablesSQL,'') +'Select * from '+ @SchemaName + '.' + table_name + ' union ' 
			FROM (SELECT DISTINCT  table_name FROM  tbl_custom_tables where table_type = 'generic' ) p
			set @AllTablesSQL = 'Select * Into '+ @SchemaName + '.' + 'tbl_All_Results from ('+ left(@AllTablesSQL,len(@AllTablesSQL) -6) + char(10) + ')z'
			print  char(10) + 'All results: ' + char(10 ) + replace( replace(@AllTablesSQL,'union','union' + char(10)),'from','from' + char(10) +  '(') + char(10)

		--create Results_All table
			begin try
				exec (@AllTablesSQL)
				set @err_msg  = (select @SchemaName + '.' + '  tbl_All_Results created.')
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT	
			end try
			begin catch
				set @err_msg  = (select @SchemaName + '.' + '  tbl_All_Results failed.')
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT					
			end catch

		--Create the BapEQ table
			print 'Create BaP table.' + char(10)
			Set @table_name = 'tbl_BaPEQ'
			SET @parameters = N'@SchemaName varchar (100) , @table_name  varchar (100)'
				set @sql = (select SelectSQL from tbl_custom_tables where table_name = @table_name) + @SchemaName + '.'+ @table_name +(select FromSQL from tbl_custom_tables where table_name = @table_name)
			begin try			
				execute sp_executesql @SQL, @parameters, @schemaname , @table_name  ;
				set @err_msg  = (select '  Table ' + 'tbl_BaPEQ' + ' complete.')
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT
			end try
			begin catch
				set @err_msg  = (select '  Create Table ' + 'tbl_BaPEQ' + ' failed.')
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT
				print @SQL + char(10)

			end catch

/*******Add Spatial Elements***********************************/
		print char(10) + ' 4. Add Spatial Elements: ' 

		--update/insert spatial element
			set @SQL = ''
			SELECT @SQL =  ISNULL(@SQL,'') +'exec [dbo].[Sp_AddSpatialElements] '+ '''' + tbl + '''' + ', '  + @SRID + '; '
				FROM (SELECT DISTINCT  @SchemaName + '.' + table_name  as tbl FROM  tbl_custom_tables  ) p


			begin try
				exec(@SQL)
				set @err_msg  = ' Spatial elements updated.'
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT	
			end try
			begin catch
				set @err_msg  =  ' Spatial update failed.'
				RAISERROR (@err_msg, 0, 1) WITH NOWAIT	
			end catch



	set @err_msg = char(10) + @SchemaName + ' Tables Complete.'
	raiserror(@err_msg,0,1) with nowait

END
