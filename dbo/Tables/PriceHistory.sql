CREATE TABLE dbo.PriceHistory(
  iId                      BIGINT IDENTITY (1, 1) NOT NULL,
  AsOfDate                 DATE,
  PositionId               VARCHAR(255),
  PositionIdType           VARCHAR(255),
  PriceSource              VARCHAR(255),
  Price                    FLOAT,
  TagMnemonic              VARCHAR(255),
  CreatedBy                VARCHAR(50)    CONSTRAINT DF_PriceHistory_CreatedBy DEFAULT(SUSER_NAME()),
  CreatedOn                DATETIME       CONSTRAINT DF_PriceHistory_CreatedOn DEFAULT(GETDATE()))
  UpdatedBy                VARCHAR(50) NULL,
  UpdatedOn                DATETIME NULL)

GO

CREATE TRIGGER [dbo].[trgUpdPriceHistory] 
  ON [dbo].[PriceHistory] 
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
        FROM [dbo].[PriceHistory] AS epd
       INNER JOIN inserted AS i 
          ON epd.iId = i.iId;
    END
GO
GO


GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.PriceHistory TO PUBLIC
GO