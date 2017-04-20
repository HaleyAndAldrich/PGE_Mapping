USE [EQuIS_Reporting]
GO

/****** Object:  Table [dbo].[rt_hai_APN]    Script Date: 4/20/2017 10:50:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
if object_id('dbo.etl_log') is not null drop table dbo.etl_log

CREATE TABLE [dbo].[ETL_Log](
	[ETL_ID] int  not null ,
	[run_date] datetime not null,
	[schema_name] [varchar](255) NULL,
	[table_name] [varchar](255) NULL,
	[row_count] int NULL,
 CONSTRAINT PK__ETL_Log PRIMARY KEY CLUSTERED 
(
	ETL_ID, run_date ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


