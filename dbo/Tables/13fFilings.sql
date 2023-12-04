IF OBJECT_ID('dbo.13fFilings', 'U') IS NOT NULL
  BEGIN 
    DROP TABLE dbo.13fFilings
  END


CREATE TABLE [dbo].[13fFilings](
  iId             BIGINT IDENTITY (1, 1) NOT NULL,
  CurrEndDate     DATE NOT NULL,
  PrevEndDate     DATE NOT NULL,
  FundName        VARCHAR(255) NULL,
  PosName         VARCHAR (255) NULL,
  PosTicker       VARCHAR (255) NULL,
  PosSector       VARCHAR (255) NULL,
  CurrQuantity    FLOAT NULL,
  PrevQuantity    FLOAT NULL,
  CurrPosChng     FLOAT NULL,
  CurrMktValue    FLOAT NULL,
  CurrMktValChng  FLOAT NULL,
  CreatedBy       VARCHAR(50)    CONSTRAINT DF_13fFilings_CreatedBy DEFAULT(SUSER_NAME()),
  CreatedOn       DATETIME       CONSTRAINT DF_13fFilings_CreatedOn DEFAULT(GETDATE()),
  UpdatedBy       VARCHAR(50) NULL,
  UpdatedOn       DATETIME NULL)
GO

CREATE TRIGGER [dbo].[trgUpdateOne13fFilings] 
  ON dbo.13fFilings
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
        FROM [dbo].[13fFilings] AS epd
       INNER JOIN inserted AS i 
          ON epd.iId = i.iId;
    END
GO

GRANT SELECT, INSERT, UPDATE ON dbo.FundAssetsDetails TO PUBLIC
GO

