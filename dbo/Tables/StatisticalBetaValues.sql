CREATE TABLE [dbo].[StatisticalBetaValues]( 
   [Iid]             BIGINT IDENTITY (1, 1) NOT NULL,
   [AsOfDate]        DATE,
   [PortfolioName]   VARCHAR(500),
   [Ticker]          VARCHAR(500),
   [BbgYellowKey]    VARCHAR(500),
   [BmkBeta]         FLOAT,
   [CreatedBy]       VARCHAR(50)    CONSTRAINT DF_StatBetaValues_CreatedBy DEFAULT(SUSER_NAME()),
   [CreatedOn]       DATETIME       CONSTRAINT DF_StatBetaValues_CreatedOn DEFAULT(GETDATE()),
   [UpdatedBy]       VARCHAR(50) NULL,
   [UpdatedOn]       DATETIME NULL)
GO

CREATE TRIGGER [dbo].[trgUpdStatBeta] 
  ON [dbo].[StatisticalBetaValues] 
  AFTER UPDATE
  AS 
    BEGIN
    
      SET NOCOUNT ON

      DECLARE @ts DATETIME
      DECLARE @user AS VARCHAR(255)

      SET @ts = CURRENT_TIMESTAMP
      SET @user = SUSER_NAME()

      UPDATE sbv 
         SET sbv.UpdatedOn = @ts,
             sbv.UpdatedBy = @user
        FROM [dbo].[StatisticalBetaValues] AS sbv
       INNER JOIN inserted AS i 
          ON sbv.iId = i.iId;
    END
GO



GRANT SELECT, UPDATE, INSERT, DELETE ON [dbo].[StatisticalBetaValues] TO PUBLIC
GO