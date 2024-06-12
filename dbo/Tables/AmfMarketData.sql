SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AmfMarketData](
	[iId]               IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[AsOfDate]          [DATE] NULL,
	[PositionId]        [VARCHAR](255) NULL,
	[PositionIdType]    [VARCHAR](255) NULL,
	[DataSource]        [VARCHAR](255) NULL,
	[MdValue]           [FLOAT] NULL,
	[TagMnemonic]       [VARCHAR](255) NULL,
	[CreatedBy]         [VARCHAR](50) NULL,
	[CreatedOn]         [DATETIME] NULL,
	[UpdatedBy]         [VARCHAR](50) NULL,
	[UpdatedOn]         [DATETIME] NULL,
	[SysStartTime]      [DATETIME2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime]        [DATETIME2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime]))
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[AmfMarketData_history])
)
GO
