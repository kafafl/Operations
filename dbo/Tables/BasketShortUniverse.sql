IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BasketShortUniverse]') AND type in (N'U'))
  EXEC dbo.DropTemporalTable @table = 'BasketShortUniverse'
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE TABLE dbo.BasketShortUniverse(
  [iId] [bigint]                   IDENTITY(1,1) NOT NULL PRIMARY KEY,
  [BbgTicker]                      VARCHAR(255) NOT NULL,	
  [SecName]                        VARCHAR(255) NOT NULL,
  [MarketCap]                      FLOAT NULL,
  [Price]                          FLOAT NULL,
  [PEValue]                        FLOAT NULL,	
  [TotalReturnYTD]                 FLOAT NULL,
  [RevenueT12M]                    FLOAT NULL,	
  [EPST12M]                        FLOAT NULL,
  [SysStartTime]                   DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
  [SysEndTime]                     DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])) ON [PRIMARY] WITH(SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.BasketShortUniverse_history))
GO


GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.BasketShortUniverse TO PUBLIC
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

