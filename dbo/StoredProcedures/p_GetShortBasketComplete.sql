CREATE PROCEDURE dbo.p_GetShortBasketComplete(
    @AsOfDate          DATE = NULL)

 /*
  Author:   Lee Kafafian
  Crated:   05/08/2024
  Object:   p_GetShortBasketComplete
  Example:  EXEC p_GetShortBasketComplete @AsOfDate = '05/21/2024'
 */
  
 AS 
  BEGIN
    SET NOCOUNT ON

      CREATE TABLE #tmpRawDataCombined(
        AsOfDate                DATE,
        BbgTicker               VARCHAR(255) NOT NULL,
        MsTicker                VARCHAR(255) NULL,
        SecName                 VARCHAR(500) NOT NULL DEFAULT 'NA',
        SecNameMs               VARCHAR(500) NULL,
        MsCountry               VARCHAR(12) NULL,    
        MrktCap                 FLOAT NULL,
        BbgPrice                FLOAT NULL,
        MsPrice                 FLOAT NULL,
        PxDiff                  FLOAT NULL,
        MsAvail                 VARCHAR(255),
        SLRate                  FLOAT,
        SLType                  VARCHAR(15) NULL,
        bUnmapped               BIT DEFAULT 1,
        bNoMktCap               BIT DEFAULT 0,
        bNoPrice                BIT DEFAULT 0,
        bNonRebate              BIT DEFAULT 0,
        bNoAvgVol               BIT DEFAULT 0,
        bInLongPort             BIT DEFAULT 0,
        bInShortPort            BIT DEFAULT 0)

      CREATE TABLE #tmpPortfolio(
        AsOfDate                DATE,
        Strategy                VARCHAR(500),
        Substrategy             VARCHAR(500),
        Ticker                  VARCHAR(500),
        Shares                  FLOAT,
        FirstDate               DATE,
        ShareChange             FLOAT,
        StatusDet               VARCHAR(500))

      DECLARE @PortDate AS DATE

      IF @AsOfDate IS NULL
        BEGIN
          SELECT @AsOfDate = CAST(GETDATE() AS DATE)
        END


      SELECT TOP 1 @PortDate = epd.AsOfDate FROM dbo.EnfPositionDetails epd WHERE epd.AsOfDate < @AsOfDate ORDER BY epd.AsOfDate DESC

      INSERT INTO #tmpRawDataCombined(
             AsOfDate,
             BbgTicker,
             SecName,
             MrktCap,
             BbgPrice)
      SELECT @AsOfDate,
             bsu.BbgTicker,
             bsu.SecName,
             bsu.MarketCap,
             bsu.Price
        FROM dbo.BasketShortUniverse bsu

      INSERT INTO #tmpPortfolio(
             AsOfDate,
             Strategy,
             Substrategy,
             Ticker,
             Shares,
             FirstDate,
             ShareChange,
             StatusDet)
        EXEC dbo.p_RunPortfolioMonitor @AsOfDate = @PortDate


      UPDATE rdc
         SET rdc.MsTicker = sbd.MspbTicker,
             rdc.SecNameMs = sbd.SecName,
             rdc.MsCountry = sbd.Country,
             rdc.SLRate = sbd.Rate,
             rdc.SLType = sbd.RateType,
             rdc.MsPrice = sbd.ClsPrice,
             rdc.PxDiff = ROUND(rdc.BbgPrice - sbd.ClsPrice, 2),
             rdc.MsAvail = CASE WHEN sbd.vAvailability = 'LIMITED' THEN NULL ELSE sbd.vAvailability END,
             rdc.bUnmapped = 0
        FROM #tmpRawDataCombined rdc
        JOIN dbo.BasketShortBorrowData sbd 
          ON sbd.MspbTicker = LEFT(rdc.BBgTicker, CHARINDEX(' ', rdc.BbgTicker))
         AND CASE WHEN sbd.Country = 'USA' THEN 'US' WHEN sbd.Country = 'CAN' THEN 'CN' ELSE 'N/A' END = RTRIM(LTRIM(SUBSTRING(rdc.BbgTicker, CHARINDEX(' ', rdc.BbgTicker), CHARINDEX(' ', rdc.BbgTicker, CHARINDEX(' ', rdc.BbgTicker)) - 1)))

      UPDATE rdc
         SET rdc.bNoMktCap = 1
        FROM #tmpRawDataCombined rdc
       WHERE COALESCE(rdc.MrktCap, 0) <= 0

      UPDATE rdc
         SET rdc.bNoPrice = 1
        FROM #tmpRawDataCombined rdc
       WHERE COALESCE(rdc.BbgPrice, 0) <= 0

      UPDATE rdc
         SET rdc.bNonRebate = 1
        FROM #tmpRawDataCombined rdc
       WHERE rdc.SLRate < 0.00
          --OR rdc.MsAvail IS NULL

      UPDATE rdc
         SET rdc.bInLongPort = 1
        FROM #tmpRawDataCombined rdc
        JOIN #tmpPortfolio tpp
          ON rdc.BbgTicker = tpp.Ticker
       WHERE CHARINDEX('Alpha Long', tpp.Strategy) != 0

      UPDATE rdc
         SET rdc.bInShortPort = 1
        FROM #tmpRawDataCombined rdc
        JOIN #tmpPortfolio tpp
          ON rdc.BbgTicker = tpp.Ticker
       WHERE CHARINDEX('Alpha Short', tpp.Strategy) != 0

      SELECT rdc.AsOfDate,
             rdc.BbgTicker,
             rdc.MsTicker,
             rdc.SecName,
             rdc.SecNameMs,
             rdc.MsCountry,
             rdc.MrktCap,
             rdc.BbgPrice,
             rdc.MsPrice,
             rdc.PxDiff,
             ROUND(CASE WHEN rdc.MsPrice = 0 AND rdc.BbgPrice != 0 
                        THEN rdc.BbgPrice 
                        WHEN rdc.BbgPrice = 0 AND rdc.MsPrice != 0 
                        THEN rdc.MsPrice 
                        ELSE COALESCE(rdc.BbgPrice, rdc.MsPrice)
                   END, 4) AS AnyPrice,
             COALESCE(rdc.MsAvail, 'LIMITED') AS MsAvail,
             rdc.SLRate,
             rdc.SLType,
             '' AS AvgVolume,
             rdc.bUnmapped,
             rdc.bNoMktCap,
             rdc.bNonRebate,
             rdc.bNoPrice,
             rdc.bNoAvgVol,
             rdc.bInLongPort,
             rdc.bInShortPort
        FROM #tmpRawDataCombined rdc
       ORDER BY rdc.AsOfDate,
             rdc.BbgTicker,
             rdc.MsTicker,
             rdc.SecName

    SET NOCOUNT OFF
  END
GO

GRANT EXECUTE ON dbo.p_GetShortBasketComplete TO PUBLIC
GO 


