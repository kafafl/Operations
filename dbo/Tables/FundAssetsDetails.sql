IF OBJECT_ID('dbo.FundAssetsDetails', 'U') IS NOT NULL
  BEGIN 
    DROP TABLE dbo.FundAssetsDetails
  END


CREATE TABLE dbo.FundAssetsDetails(
  FastId        BIGINT IDENTITY,
  AsOfDate      DATE,
  Entity        VARCHAR(255),
  AssetValue    FLOAT,
  PerfNote      VARCHAR(1000),
  CreatedBy     VARCHAR(50)    CONSTRAINT DF_FundAssets_CreatedBy DEFAULT(SUSER_NAME()),
  CreatedOn     DATETIME       CONSTRAINT DF_FundAssets_CreatedOn DEFAULT(GETDATE()),
  UpdatedBy     VARCHAR(50) NULL,
  UpdatedOn     DATETIME NULL)
GO

CREATE TRIGGER [dbo].[trgUpdateOneFundAssetsDetails] 
  ON dbo.FundAssetsDetails
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
        FROM [dbo].[FundAssetsDetails] AS epd
       INNER JOIN inserted AS i 
          ON epd.FastId = i.FastId;
    END
GO


GRANT SELECT, INSERT, UPDATE ON dbo.FundAssetsDetails TO PUBLIC
GO