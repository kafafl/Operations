CREATE PROCEDURE dbo.p_UpdateInsertRawBbgValues(
    @strBbgTicker          VARCHAR(255),
    @SecName               VARCHAR(255),
    @MktCap                FLOAT,
    @Price                 FLOAT,
    @PEValue               FLOAT,
    @TotRetYtd             FLOAT,
    @RevenueT12M           FLOAT,
    @EPS                   FLOAT)
 
 
 /*
  Author:   Lee Kafafian
  Crated:   05/16/2024
  Object:   p_UpdateInsertRawBbgValues
  Example:  EXEC dbo.p_UpdateInsertRawBbgValues @strBbgTicker = '02/19/2024', @SecName = 'ABCD US Equity', @MktCap = 1.00, @Price = 1, @TotRetYtd = 1, @RevenueT12M = 1, @EPS = 1
 */
  
 AS 
  BEGIN
    SET NOCOUNT ON

        INSERT INTO dbo.BasketShortUniverse(
               BbgTicker,
               SecName,
               MarketCap,
               Price,
               PEVal,
               TotalReturnYTD,
               RevenueT12M,
               EPS12M) 
        SELECT @strBbgTicker,
               @SecName,
               @MktCap,
               @Price,
               @PEValue,
               @TotRetYtd,
               @RevenueT12M,
               @EPS

    SET NOCOUNT OFF
  END
GO

GRANT EXECUTE ON dbo.p_UpdateInsertRawBbgValues TO PUBLIC
GO
