SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BasketShortBorrowData](
	[iId] [bigint] IDENTITY(1,1) NOT NULL,
	[MspbTicker] [varchar](255) NOT NULL,
	[SecName] [varchar](255) NOT NULL,
	[Country] [varchar](255) NOT NULL,
	[vAvailability] [varchar](255) NULL,
	[Rate] [float] NULL,
	[RateType] [varchar](255) NULL,
	[ClsPrice] [float] NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[BasketShortBorrowData_history])
)
GO
ALTER TABLE [dbo].[BasketShortBorrowData] ADD PRIMARY KEY CLUSTERED 
(
	[iId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO