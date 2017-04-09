USE [EQuIS]
GO

/****** Object:  Table [dbo].[rt_hai_APN]    Script Date: 4/6/2017 12:54:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[rt_hai_permissions](
	[permission_type_code] [int] not NULL,
	[permission_type_desc] [varchar](200) NULL,
 CONSTRAINT [PK__rt_hai_permissions] PRIMARY KEY CLUSTERED 
(
	[permission_type_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO



SET ANSI_PADDING OFF
GO


