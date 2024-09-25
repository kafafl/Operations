SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MsfsStatusReportExecSummary](
	[iId]              BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
    [AsOfDate]         DATE NOT NULL,
    [iRecId]           BIGINT NOT NULL,
	[RecAction]        VARCHAR(500) NULL,
	[RecComment]       VARCHAR(500) NULL,
	[RecResponse]      VARCHAR(500) NULL,
    [FundName]         VARCHAR(500) NULL,
    [RecSection]       VARCHAR(500) NULL,
    [RecCustodian]     VARCHAR(500) NULL,
    [BreakSummary]     VARCHAR(500) NULL,
    [RecIdentifier]    VARCHAR(500) NULL,
    [MsSecDescription] VARCHAR(500) NULL,
    [RecTradeId]       VARCHAR(500) NULL,
    [RecTradeDate]     DATE NULL,
    [RecMsQuantity]    FLOAT NULL,
    [RecCuQuantity]    FLOAT NULL,
    [RecQuantDiff]     FLOAT NULL,
    [RecMsAmount]      FLOAT NULL,
    [RecCuAmount]      FLOAT NULL,
    [RecAmntDiff]      FLOAT NULL,
    [RecMsComm]        FLOAT NULL,
    [RecCuComm]        FLOAT NULL,
    [RecCommDiff]      FLOAT NULL,
    [RecSettleCcy]     VARCHAR(500) NULL,
    [RecStrategy]      VARCHAR(500) NULL,
    [RecBreakAge]      INT NULL,
    [RecPortfolio]     VARCHAR(500) NULL,
    [RecSource]        VARCHAR(500) NULL,
	[SysStartTime]     DATETIME2(7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime]       DATETIME2(7) GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[MsfsStatusReportExecSummary_history])
)
GO


/*

ALTER TABLE dbo.MsfsStatusReportExecSummary  SET ( SYSTEM_VERSIONING = Off )
GO
drop table dbo.MsfsStatusReportExecSummary;
drop table dbo.MsfsStatusReportExecSummary_history
GO

*/


SELECT TOP 100 * FROM dbo.MsfsStatusReportExecSummary
GO

SELECT TOP 100 * FROM dbo.MsfsStatusReportExecSummary_history
GO