IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AmfSecurityDetails]') AND type in (N'U'))
    EXEC dbo.DropTemporalTable @table = 'AmfSecurityDetails'
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE dbo.AmfSecurityDetails(
	[iId] [bigint]                   IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[SecNameDescr]                   VARCHAR(255) NULL,
	[SecBbgYelowKey]                 VARCHAR(255) NULL,
	[SecSedol]                       VARCHAR(24) NULL,
	[SecCusip]                       VARCHAR(24) NULL,
	[SecIsin]                        VARCHAR(24) NULL,
	[SecCurrency]                    VARCHAR(12) NULL,
	[SecType]                        VARCHAR(255) NULL,
	[SecTypeSort]                    BIGINT NULL,
	[SecUnderBbgId]                  VARCHAR(255) NULL,
	[SecUnderlying]                  BIGINT NULL,
    [SysStartTime]                   DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
    [SysEndTime]                     DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])) ON [PRIMARY] WITH(SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.AmfSecurityDetails_history))
GO


GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.AmfSecurityDetails TO PUBLIC
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO