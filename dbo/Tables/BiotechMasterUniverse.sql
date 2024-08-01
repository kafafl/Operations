IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BiotechMasterUniverse]') AND type in (N'U'))
  EXEC dbo.DropTemporalTable @table = 'BiotechMasterUniverse'
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE TABLE dbo.BiotechMasterUniverse(
  [iId] [bigint]                   IDENTITY(1,1) NOT NULL PRIMARY KEY,
  [AsOfDate]                       DATE,
  [BbgTicker]                      VARCHAR(255) NOT NULL,	
  [SecName]                        VARCHAR(255) NOT NULL,
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
    PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])) ON [PRIMARY] WITH(SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.BiotechMasterUniverse_history))
GO


GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.BiotechMasterUniverse TO PUBLIC
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO



ALTER TABLE dbo.BiotechMasterUniverse ADD   [GICS_sector]                    VARCHAR(255) NOT NULL
GO

ALTER TABLE dbo.BiotechMasterUniverse ADD     [GICS_industry]                  VARCHAR(255) NOT NULL
GO

