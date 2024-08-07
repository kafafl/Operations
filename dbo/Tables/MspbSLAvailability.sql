/*
ALTER TABLE [dbo].[MspbSLAvailability] SET ( SYSTEM_VERSIONING = OFF  )
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MspbSLAvailability]') AND type in (N'U'))
DROP TABLE [dbo].[MspbSLAvailability]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MspbSLAvailability_history]') AND type in (N'U'))
DROP TABLE [dbo].[MspbSLAvailability_history]
GO
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MspbSLAvailability](
	[iId]                            BIGINT IDENTITY(1, 1) NOT NULL,
    CONSTRAINT [PK_SLAvailability] PRIMARY KEY CLUSTERED (iId),
    [AsOfDate]                     DATE,
    [Identifier]                   VARCHAR(255) NOT NULL,
    [DataSource]                   VARCHAR(255) NOT NULL,
    [SourceFile]                   VARCHAR(255) NOT NULL,
    [AvailAmount]                  FLOAT NULL,
    [SLRate]                       FLOAT NULL,
    [SLRateType]                   VARCHAR(255),
	  [SysStartTime]                 DATETIME2(7)  GENERATED ALWAYS AS ROW START NOT NULL,
	  [SysEndTime]                   DATETIME2(7)  GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[MspbSLAvailability_history])
)
GO