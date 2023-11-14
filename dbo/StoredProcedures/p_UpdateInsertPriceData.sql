CREATE PROCEDURE dbo.p_UpdateInsertPriceData(
    @AsOfDate          DATE NULL = DEFAULT,
    @PositionId        VARCHAR(255),
    @PositionIdType    VARCHAR(255),
    @PriceSource       VARCHAR(255),
    @PriceValue        FLOAT,
    @TagMnemonic       VARCHAR(255))
 
 
 /*
  Author: Lee Kafafian
  Crated: 10/19/2023
  Object: p_UpdateInsertPriceData
  Example:  EXEC dbo.p_UpdateInsertPriceData @AsOfDate = '01/02/2023', @PositionId = 'FDMT US Equity', @PositionIdType = 'BloombergTicker', @PriceSource = 'Bloomberg', @PriceValue = 0.01, @TagMnemonic = 'LAST_PRICE'

 */
  
 AS 

  BEGIN

    SET NOCOUNT ON 
     
    IF EXISTS(SELECT TOP 1 * FROM dbo.PriceHistory phx WHERE phx.AsOfDate = @AsOfDate AND phx.PositionId = @PositionId AND phx.PositionIdType = @PositionIdType AND phx.PriceSource = @PriceSource AND phx.TagMnemonic = @TagMnemonic)
      BEGIN
        UPDATE phx
           SET phx.Price = @PriceValue
          FROM dbo.PriceHistory phx
         WHERE phx.AsOfDate = @AsOfDate
           AND phx.PositionId = @PositionId 
           AND phx.PositionIdType = @PositionIdType 
           AND phx.PriceSource = @PriceSource 
           AND phx.TagMnemonic = @TagMnemonic  
      END
    ELSE
      BEGIN
        INSERT INTO dbo.PriceHistory(
               AsOfDate,
               PositionId,
               PositionIdType,
               PriceSource,
               Price,
               TagMnemonic) 
        SELECT @AsOfDate,
               @PositionId,
               @PositionIdType,
               @PriceSource,
               @PriceValue,
               @TagMnemonic
      END
 
    SET NOCOUNT OFF
  
  END

GO

GRANT EXECUTE ON dbo.p_UpdateInsertPriceData TO PUBLIC
GO
