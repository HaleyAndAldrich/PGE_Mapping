USE [EQuIS_Reporting]
GO

/****** Object:  Table [dbo].[ETL_Log_test]    Script Date: 5/15/2017 11:04:11 AM ******/
DROP TABLE [dbo].[ETL_Log]
GO

/****** Object:  Table [dbo].[ETL_Log_test]    Script Date: 5/15/2017 11:04:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO


CREATE TABLE [dbo].[ETL_Log](
	[ETL_ID] [int] NOT NULL,
	[run_date] [datetime] NOT NULL,
	[schema_name] [varchar](255) NULL,
	[table_name] [varchar](255) NULL,
	[permission_code_1_row_count] [int] NULL,
	[permission_code_0_row_count] [int] NULL,
	[total_row_count] [int] NULL,
	[status] [varchar](10) NULL,
 CONSTRAINT [PK__ETL_Log] PRIMARY KEY CLUSTERED 
(
	[ETL_ID] ASC,
	[run_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


