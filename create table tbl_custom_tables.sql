USE [EQuIS_Reporting]
GO

/****** Object:  Table [dbo].[tbl_custom_tables]    Script Date: 4/13/2017 3:28:57 PM ******/
DROP TABLE [dbo].[tbl_custom_tables]
GO

/****** Object:  Table [dbo].[tbl_custom_tables]    Script Date: 4/13/2017 3:28:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_custom_tables](
	[facility_id] [int] NOT NULL,
	[table_type] varchar (30) not null,
	[table_name] [varchar](100) NOT NULL,
	[unit_code] [varchar](10) NULL,
	[matrix_code] [varchar](10) NULL,
	[coord_zone] [varchar](20) NULL,
	[SelectSQL] [varchar](max) NULL,
	[FromSQL] [varchar] (max) Null,
 CONSTRAINT [PK__custom_table] PRIMARY KEY CLUSTERED 
(
	[facility_id] ASC,
	[table_type] ASC,
	[table_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


