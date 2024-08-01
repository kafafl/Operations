IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MarketMasterUniverse]') AND type in (N'U'))
  EXEC dbo.DropTemporalTable @table = 'MarketMasterUniverse'
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE TABLE dbo.MarketMasterUniverse(
  [iId] [bigint]                   IDENTITY(1,1) NOT NULL PRIMARY KEY,
  [AsOfDate]                       DATE,
  [ParentEntity]                   VARCHAR(255) NOT NULL,
  [BbgTicker]                      VARCHAR(255) NOT NULL,	
  [SecName]                        VARCHAR(255) NOT NULL,
  [GICS_sector]                    VARCHAR(255) NOT NULL,
  [GICS_industry]                  VARCHAR(255) NOT NULL,
  [Crncy]                          VARCHAR(255) NOT NULL,
  [MarketCap]                      FLOAT NULL,
  [EnterpriseValue]                FLOAT NULL,
  [Price]                          FLOAT NULL,
  [PrevPrice]                      FLOAT NULL,
  [PEValue]                        FLOAT NULL,
  [TotalReturnDtd]                 FLOAT NULL,  	
  [TotalReturnYTD]                 FLOAT NULL,
  [RevenueT12M]                    FLOAT NULL,	
  [EPST12M]                        FLOAT NULL,
  [SysStartTime]                   DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
  [SysEndTime]                     DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])) ON [PRIMARY] WITH(SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.MarketMasterUniverse_history))
GO


GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.MarketMasterUniverse TO PUBLIC
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO