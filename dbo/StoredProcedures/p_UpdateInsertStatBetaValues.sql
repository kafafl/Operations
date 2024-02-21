CREATE PROCEDURE dbo.p_UpdateInsertStatBetaValues(
    @AsOfDate          DATE,
    @BBYellowKey        VARCHAR(255),
    @BetaValue         NUMERIC(10, 2),
    @PortfolioName     VARCHAR(500) = 'AMF',
    @Ticker             VARCHAR(500) = '')
 
 
 /*
  Author:   Lee Kafafian
  Crated:   10/20/2023
  Object:   p_UpdateInsertStatBetaValues
  Example:  EXEC dbo.p_UpdateInsertStatBetaValues @AsOfDate = '02/19/2024', @BBYellowKey = 'ABCD US Equity', @BetaValue = 1.00
 */
  
 AS 
  BEGIN
    SET NOCOUNT ON
    
    IF @Ticker = ''
      BEGIN
        SELECT @Ticker = SUBSTRING(@BBYellowKey, 1, CHARINDEX(' ', @BBYellowKey))
      END


    IF EXISTS(SELECT TOP 1 * FROM dbo.StatisticalBetaValues sbv WHERE sbv.AsOfDate = @AsOfDate AND sbv.BbgYellowKey = @BBYellowKey)
      BEGIN
        UPDATE sbv
           SET sbv.BmkBeta = @BetaValue,
               sbv.Ticker = @Ticker
          FROM dbo.StatisticalBetaValues sbv
         WHERE sbv.AsOfDate = @AsOfDate
           AND sbv.BbgYellowKey = @BBYellowKey  
      END
    ELSE
      BEGIN
        INSERT INTO dbo.StatisticalBetaValues(
               AsOfDate,
               PortfolioName,
               Ticker,
               BbgYellowKey,
               BmkBeta) 
        SELECT @AsOfDate,
               @PortfolioName,
               @Ticker,
               @BBYellowKey,
               @BetaValue
      END
   
    SET NOCOUNT OFF
  END
GO

GRANT EXECUTE ON dbo.p_UpdateInsertFactorReturns TO PUBLIC
GO
