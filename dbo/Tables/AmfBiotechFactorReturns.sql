SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AmfBiotechFactorReturns](
	[IdxRow] [bigint] IDENTITY(1,1) NOT NULL,
	[AsOfDate] [date] NULL,
	[AssetId] [varchar](max) NULL,
	[AssetName] [varchar](max) NULL,
	[FactorName] [varchar](max) NULL,
	[RetValue] [float] NULL,
	[JobReference] [varchar](255) NULL,
	[CreatedBy] [varchar](50) NULL,
	[CreatedOn] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AmfBiotechFactorReturns] ADD  CONSTRAINT [DF_AmfBiotechFactorReturns_CreatedBy]  DEFAULT (suser_name()) FOR [CreatedBy]
GO
ALTER TABLE [dbo].[AmfBiotechFactorReturns] ADD  CONSTRAINT [DF_AmfBiotechFactorReturns_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO

GRANT SELECT, UPDATE, INSERT, DELETE TO PUBLIC
GO
