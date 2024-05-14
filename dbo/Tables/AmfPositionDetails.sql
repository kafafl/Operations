IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AmfPositionDetails]') AND type in (N'U'))
    EXEC dbo.DropTemporalTable @table = 'AmfPositionDetails'
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE dbo.AmfPositionDetails(
	  [iId]                           BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	  [AsOfDate]                      DATE NULL,
    [Fund]                          VARCHAR(500) NULL,
	  [PortStrat]                     VARCHAR(500) NULL,
	  [PortBook]                      VARCHAR(500) NULL,
    [PosQuant]                      FLOAT,
    [PosLastPxUsd]                  FLOAT,
    [PosNetMktValUsd]               FLOAT,
    [PosDeltAdjMktValUsd]           FLOAT,
    [BetaStat]                      FLOAT,
    [BetaModel]                     FLOAT,
    [DtdPnlUsd]                     FLOAT,
    [MtdPnlUsd]                     FLOAT,
    [YtdPnlUsd]                     FLOAT,
    [ItdPnlUsd]                     FLOAT,
    [PosFxRate]                     FLOAT,
	  [PosSecIdRef]                   BIGINT,
    [SysStartTime]                  DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
    [SysEndTime]                    DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])) ON [PRIMARY] WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.AmfPositionDetails_history))
GO


GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.AmfPositionDetails TO PUBLIC
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
