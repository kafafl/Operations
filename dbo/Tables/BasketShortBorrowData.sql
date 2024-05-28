CREATE PROCEDURE dbo.p_UpdateInsertMspbBorrowData(
    @strTicker             VARCHAR(255),
    @SecName               VARCHAR(255),
    @Country               VARCHAR(255),
    @Availability          FLOAT,
    @Rate                  FLOAT,
    @RateType              VARCHAR(255),
    @Price                 FLOAT)
 
 
 /*
  Author:   Lee Kafafian
  Crated:   05/16/2024
  Object:   p_UpdateInsertMspbBorrowData
  Example:  EXEC dbo.p_UpdateInsertMspbBorrowData @strBbgTicker = '02/19/2024', @SecName = 'ABCD US Equity', @MktCap = 1.00, @Price = 1, @TotRetYtd = 1, @RevenueT12M = 1, @EPS = 1
 */
  
 AS 
  BEGIN
    SET NOCOUNT ON

        INSERT INTO dbo.BasketShortBorrowData(
               MspbTicker,
               SecName,
               Country,
               vAvailability,
               Rate,
               RateType,
               ClsPrice) 
        SELECT @strTicker,
               @SecName,
               @Country,
               @Availability,
               @Rate,
               @RateType,
               @Price

    SET NOCOUNT OFF
  END
GO

GRANT EXECUTE ON dbo.p_UpdateInsertMspbBorrowData TO PUBLIC
GO
