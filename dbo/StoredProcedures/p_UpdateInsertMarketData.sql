ALTER PROCEDURE dbo.p_UpdateInsertMarketData(
    @AsOfDate          DATE NULL = DEFAULT,
    @PositionId        VARCHAR(255),
    @PositionIdType    VARCHAR(255),
    @MdSource          VARCHAR(255),
    @MdValue           FLOAT,
    @TagMnemonic       VARCHAR(255))
 
 
 /*
  Author:   Lee Kafafian
  Crated:   06/12/2024
  Object:   p_UpdateInsertMarketData
  Example:  EXEC dbo.p_UpdateInsertMarketData @AsOfDate = '01/02/2023', @PositionId = 'FDMT US Equity', @PositionIdType = 'BloombergTicker', @PriceSource = 'Bloomberg', @PriceValue = 0.01, @TagMnemonic = 'LAST_PRICE'

 */
  
 AS 

  BEGIN

    SET NOCOUNT ON 


    DECLARE @EventDate AS DATETIME = GETDATE()
    DECLARE @EventBy AS VARCHAR(255) = SUSER_NAME()
     
    IF EXISTS(SELECT TOP 1 * FROM dbo.AmfMarketData mdx WHERE mdx.AsOfDate = @AsOfDate AND mdx.PositionId = @PositionId AND mdx.PositionIdType = @PositionIdType AND mdx.DataSource = @MdSource AND mdx.TagMnemonic = @TagMnemonic)
      BEGIN
        UPDATE mdx
           SET mdx.MdValue = @MdValue,
               mdx.UpdatedOn = @EventDate,
               mdx.UpdatedBy = @EventBy
          FROM dbo.AmfMarketData mdx
         WHERE mdx.AsOfDate = @AsOfDate
           AND mdx.PositionId = @PositionId 
           AND mdx.PositionIdType = @PositionIdType 
           AND mdx.DataSource = @MdSource 
           AND mdx.TagMnemonic = @TagMnemonic  
      END
    ELSE
      BEGIN
        INSERT INTO dbo.AmfMarketData(
               AsOfDate,
               PositionId,
               PositionIdType,
               DataSource,
               MdValue,
               TagMnemonic,
               CreatedOn,
               CreatedBy) 
        SELECT @AsOfDate,
               @PositionId,
               @PositionIdType,
               @MdSource,
               @MdValue,
               @TagMnemonic,
               @EventDate,
               @EventBy
      END
 
    SET NOCOUNT OFF
  
  END

GO

GRANT EXECUTE ON dbo.p_UpdateInsertMarketData TO PUBLIC
GO
