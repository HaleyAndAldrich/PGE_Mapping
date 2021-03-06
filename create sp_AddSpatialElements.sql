USE [EQuIS_Reporting]
GO
/****** Object:  StoredProcedure [dbo].[Sp_AddSpatialElements]    Script Date: 7/12/2017 2:33:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Dariush Mobini>
-- Create date: <2016-08-12>
-- Last Update: <2017-03-20>
-- Description:	<This SP adds geoshape field and compute it, then adds two indexes>
-- It Works With: Query for any site ned to be automated              
-- =============================================
ALTER PROCEDURE [dbo].[Sp_AddSpatialElements]
	-- Add the parameters for the stored procedure here
(
@tableInName AS NVARCHAR(50),
@ProjSRID NVARCHAR(10)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE
	@sqlRun AS NVARCHAR(4000),
	@ProjXmin NVARCHAR(20),
	@ProjYmin NVARCHAR(20),
	@ProjXmax NVARCHAR(20),
	@ProjYmax NVARCHAR(20),
	@XMin_env decimal(10,2),
	@YMin_env decimal(10,2),
	@XMax_env decimal(10,2),
	@YMax_env decimal(10,2)

    -- Insert statements for procedure here
	
			--calculate the envelope
	
			SET @sqlRun = N'SELECT @MinX = MIN(x_coord) FROM ' + @tableInName + ' WHERE x_coord IS NOT NULL'
			EXEC sp_executesql @sqlRun, N'@MinX REAL OUTPUT',@XMin_env OUTPUT

			SET @sqlRun = N'SELECT @MinY = MIN(y_coord) FROM ' + @tableInName + ' WHERE y_coord IS NOT NULL'
			EXEC sp_executesql @sqlRun, N'@MinY REAL OUTPUT',@YMin_env OUTPUT

			SET @sqlRun = N'SELECT @MaxX = MAX(x_coord) FROM ' + @tableInName + ' WHERE x_coord IS NOT NULL'
			EXEC sp_executesql @sqlRun, N'@MaxX REAL OUTPUT',@XMax_env OUTPUT
	
			SET @sqlRun = N'SELECT @MaxY = MAX(y_coord) FROM ' + @tableInName + ' WHERE y_coord IS NOT NULL'
			EXEC sp_executesql @sqlRun, N'@MaxY REAL OUTPUT',@YMax_env OUTPUT

			SET @ProjXmin = @XMin_env - ((@XMax_env - @XMin_env )/20)
			SET @ProjXmax = @XMax_env + ((@XMax_env - @XMin_env )/20)
			SET @ProjYmin = @YMin_env - ((@YMax_env - @YMin_env )/20)
			SET @ProjYmax = @YMax_env + ((@YMax_env - @YMin_env )/20) 

			PRINT @ProjXmin
			PRINT @ProjXmax
			PRINT @ProjYmin
			PRINT @ProjYmax 
			
			--adding the columns

	IF COL_LENGTH(@tableInName,'GeoShape') IS NULL
		BEGIN
			SET @sqlRun = N'
			ALTER TABLE ' + @tableInName + ' ADD [GeoShape] GEOMETRY '

			EXEC sp_executesql @stmt = @sqlRun;
		END


	IF COL_LENGTH(@tableInName,'indexID') IS NOT NULL
		BEGIN
			PRINT 'indexID does Exist'
		END
			
		ELSE
		BEGIN
			PRINT 'indexID does not not Exist - creating new spatial index on ' + @tableInName + '..'
			
			SET @sqlRun = N'
			ALTER TABLE ' + @tableInName + ' ADD [indexID] int NOT NULL IDENTITY (1,1)'

			EXEC sp_executesql @stmt = @sqlRun;	
			
			--Making Table Index

			SET @sqlRun =  N' ALTER TABLE '+ @tableInName + '
			ADD CONSTRAINT [PK_SMAPLE_'+ @tableInName + '] PRIMARY KEY CLUSTERED
			([indexID] ASC)';		
			
			--PRINT @sqlRun	
			EXEC sp_executesql @stmt = @sqlRun;

		END

		--pupluate GeoShape spatial column from x,y

		SET @sqlRun = N'
		UPDATE ' + @tableInName + '
		SET GeoShape = (CONVERT(GEOMETRY, GEOMETRY::STPointFromText(''POINT(''
																  + CONVERT(VARCHAR, x_coord)
																  + '' ''
																  + CONVERT(VARCHAR, y_coord)
																  + '')'', '+ @ProjSRID +')))'
		--print @sqlRun
		EXEC sp_executesql @stmt = @sqlRun;

		--Making Spatial Index

		SET @sqlRun = N'
		CREATE SPATIAL INDEX [SPI_'+ @tableInName + '] ON '+ @tableInName + '
		(
			[GeoShape]
		)USING  GEOMETRY_GRID 
		WITH (
		BOUNDING_BOX =('+ @ProjXmin + ', '+ @ProjYmin + ', '+ @ProjXmax + ', '+ @ProjYmax + '), 
		GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), 
		CELLS_PER_OBJECT = 16, PAD_INDEX  = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, 
		ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]'

		--PRINT @sqlRun	
		EXEC sp_executesql @stmt = @sqlRun;

END
