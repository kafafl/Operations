CREATE PROCEDURE dbo.p_UpdateInsertFundAssetsData(
    @AsOfDate        DATE NULL = DEFAULT,
    @Entity          VARCHAR(255),
    @FundAssets      FLOAT )
 
 
 /*
  Author:   Lee Kafafian
  Crated:   11/14/2023
  Object:   p_UpdateInsertFundAssetsData
  Example:  EXEC dbo.p_UpdateInsertFundAssetsData @AsOfDate = '01/02/2023', @Entity = 'AMF', @FundAssets = 1010101

 */
  
 AS 

  BEGIN
     
    SET NOCOUNT ON

    IF EXISTS(SELECT TOP 1 * FROM dbo.FundAssetsDetails fax WHERE fax.AsOfDate = @AsOfDate AND fax.Entity = @Entity)
      BEGIN
        UPDATE fax
           SET fax.AssetValue = @FundAssets
          FROM dbo.FundAssetsDetails fax
         WHERE fax.AsOfDate = @AsOfDate
           AND fax.Entity = @Entity   
      END
    ELSE
      BEGIN
        INSERT INTO dbo.FundAssetsDetails(
               AsOfDate,
               Entity,
               AssetValue)
        SELECT @AsOfDate,
               @Entity,
               @FundAssets
      END

    SET NOCOUNT OFF
      
  END

GO

GRANT EXECUTE ON dbo.p_UpdateInsertFundAssetsData TO PUBLIC
GO