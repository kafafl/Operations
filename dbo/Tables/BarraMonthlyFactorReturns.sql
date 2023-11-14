CREATE TABLE dbo.BarraMonthlyFactorReturns(
  iId                      BIGINT IDENTITY (1, 1) NOT NULL,
  AsOfDate                 DATE,
  NumDate                  BIGINT,
  FactorName               VARCHAR(255),
  FactorValue              FLOAT,
  CreatedBy                VARCHAR(50)    CONSTRAINT DF_FactorReturns_CreatedBy DEFAULT(SUSER_NAME()),
  CreatedOn                DATETIME       CONSTRAINT DF_FactorReturns_CreatedOn DEFAULT(GETDATE()),
  UpdatedBy                VARCHAR(50) NULL,
  UpdatedOn                DATETIME NULL)

GO

CREATE TRIGGER [dbo].[trgUpdMonthlyFactorReturns] 
  ON [dbo].[BarraMonthlyFactorReturns] 
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
        FROM [dbo].[BarraMonthlyFactorReturns] AS epd
       INNER JOIN inserted AS i 
          ON epd.iId = i.iId;
    END
GO
GO


GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.BarraMonthlyFactorReturns TO PUBLIC
GO