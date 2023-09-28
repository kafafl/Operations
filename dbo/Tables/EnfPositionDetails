USE Operations
GO

CREATE TABLE [dbo].[EnfPositionDetails] (
    [iId]                  BIGINT IDENTITY (1, 1) NOT NULL,
    [AsOfDate]             DATE          NOT NULL,
    [FundShortName]        VARCHAR (255) NOT NULL,
    [StratName]            VARCHAR(255)  NOT NULL,
    [BookName]             VARCHAR (255) NOT NULL,
    [InstDescr]            VARCHAR (255) NOT NULL,
    [BBYellowKey]	       VARCHAR (255) NULL,
    [UnderlyBBYellowKey]   VARCHAR (255) NULL,
    [Account]	           VARCHAR (255) NOT NULL,
    [CcyOne]               VARCHAR (255) NULL,
    [CcyTwo]               VARCHAR (255) NULL,
    [InstrType]            VARCHAR (255) NULL,
    [Quantity]             FLOAT (53) NULL,
    [NetAvgCost]           FLOAT (53) NULL,
    [OverallCost]          FLOAT (53) NULL,
    [FairValue]	           FLOAT (53) NULL,
    [NetMarketValue]       FLOAT (53) NULL,
    [DlyPnlUsd]            FLOAT (53) NULL,
    [DlyPnlOfNav]          FLOAT (53) NULL,
    [MtdPnlUsd]	           FLOAT (53) NULL,
    [MtdPnlOfNav]          FLOAT (53) NULL,
    [YtdPnlUsd]            FLOAT (53) NULL,
    [YtdPnlOfNav]          FLOAT (53) NULL,
    [ItdPnlUsd]            FLOAT (53) NULL,
    [GrExpOfGLNav]         FLOAT (53) NULL,
    [Delta]                FLOAT (53) NULL,
    [DeltaAdjMV]           FLOAT (53) NULL,
    [DeltaExp]             FLOAT (53) NULL,
    [LongShort]            VARCHAR (255) NULL,
    [GrossExp]             FLOAT (53) NULL,
    [LongMV]               FLOAT (53) NULL,
    [ShortMV]              FLOAT (53) NULL,
    [InstrTypeCode]        VARCHAR (255) NULL,
    [InstrTypeUnder]       VARCHAR (255) NULL,
    [CreatedBy]            VARCHAR(50) 
        CONSTRAINT DF_EnfPosistionDetails_CreatedBy DEFAULT(SUSER_NAME()),
    [CreatedOn]            DATETIME
        CONSTRAINT DF_EnfPositionsDetails_CreatedOn DEFAULT(GETDATE()),
    [UpdatedBy]            VARCHAR(50) NULL,
    [UpdatedOn]            DATETIME NULL
);

GO


CREATE TRIGGER [dbo].[enfPosDetail] 
  ON [dbo].[EnfPositionDetails] 
  AFTER UPDATE
  AS 
    BEGIN
    
      SET NOCOUNT ON

      DECLARE @ts DATETIME
      DECLARE @user AS VARCHAR(255)

      SET @ts = CURRENT_TIMESTAMP
      SET @user = SUSER_NAME()

      UPDATE epd 
         SET UpdatedOn = @ts,
             UpdatedBy = @user
        FROM [dbo].[EnfPositionDetails] AS epd
       INNER JOIN inserted AS i 
          ON epd.iId = i.iId;
    END
GO

/*
SELECT TOP 1 * FROM [dbo].[EnfPositionDetails]
*/



