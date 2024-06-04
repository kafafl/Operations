CREATE PROCEDURE dbo.p_UpdateInsertMspbBasketDetails(
    @PortfolioId                 VARCHAR(255),
    @PortfolioName               VARCHAR(255),
    @BasketTicker                VARCHAR(255),
    @CompTicker                  VARCHAR(255),
    @CompName                    VARCHAR(255),
    @PctWeight                   FLOAT,
    @CompDefShares               FLOAT,
    @CompPrice                   FLOAT,
    @Divisor                     FLOAT,
    @CompRIC                     VARCHAR(255),
    @CompSEDOL                   VARCHAR(255),
    @CompCcy                     VARCHAR(255),
    @AsOfDate                    DATE,
    @CompISIN                    VARCHAR(255),
    @BasketRIC                   VARCHAR(255),
    @BasketId                    VARCHAR(255),
    @BasketCcy                   VARCHAR(255),
    @BasketQuantity              FLOAT,
    @BasketPrice                 FLOAT,
    @BasketMarkPrice             FLOAT,
    @FxRate                      FLOAT,
    @CompPriceBasketCcy          FLOAT,
    @BasketNotional              FLOAT,
    @ExpNotional                 FLOAT,
    @CompExpShares               FLOAT,
    @PairBasket                  FLOAT,
    @CompExpNotional             FLOAT,    
    @CompBbg                     VARCHAR(255))
 
 
 /*
  Author:   Lee Kafafian
  Crated:   05/30/2024
  Object:   p_UpdateInsertMspbBasketDetails
  Example:  EXEC dbo.p_UpdateInsertMspbBasketDetails ....
 */
  
 AS 
  BEGIN
    SET NOCOUNT ON

        INSERT INTO dbo.MspbBasketDetails(
               PortfolioID,
               PortfolioName,
               BasketTicker,
               CompTicker,
               CompName,
               PctWeight,
               CompDefShares,
               CompPrice,
               Divisor,
               CompRIC,
               CompSEDOL,
               CompCcy,
               AsOfDate,
               CompISIN,
               BasketRIC,
               BasketId,
               BasketCcy,
               BasketQuantity,
               BasketPrice,
               BasketMarkPrice,
               FxRate,
               CompPriceBskCcy,
               BasketNotional,
               ExpNotional,
               CompExpShares,
               PairBasket,
               CompExpNotional,
               CompBbg) 
        SELECT @PortfolioId,
               @PortfolioName,
               @BasketTicker,
               @CompTicker,
               @CompName,
               @PctWeight,
               @CompDefShares,
               @CompPrice,
               @Divisor,
               @CompRIC,
               @CompSEDOL,
               @CompCcy,
               @AsOfDate,
               @CompISIN,
               @BasketRIC,
               @BasketId,
               @BasketCcy,
               @BasketQuantity,
               @BasketPrice,
               @BasketMarkPrice,
               @FxRate,
               @CompPriceBasketCcy,
               @BasketNotional,
               @ExpNotional,
               @CompExpShares,
               @PairBasket,
               @CompExpNotional,    
               @CompBbg

    SET NOCOUNT OFF
  END
GO

GRANT EXECUTE ON dbo.p_UpdateInsertMspbBasketDetails TO PUBLIC
GO
