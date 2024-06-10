ALTER PROCEDURE [dbo].[p_GetAmfBiotechUniverse]( 
    @AsOfDate          DATE = NULL,
    @LowQualityFilter  BIT =  0) 
 
 /* 
  Author:   Lee Kafafian 
  Crated:   05/08/2024 
  Object:   p_GetShortBasketComplete 
  Example:  EXEC p_GetAmfBiotechUniverse @AsOfDate = '06/03/2024'
            EXEC p_GetAmfBiotechUniverse @LowQualityFilter = 1
            EXEC p_GetAmfBiotechUniverse @AsOfDate = '06/03/2024', @LowQualityFilter = 1
 */ 
   
 AS  
  BEGIN 
    SET NOCOUNT ON 
 
      CREATE TABLE #tmpRawDataCombined( 
        AsOfDate                DATE, 
        BbgTicker               VARCHAR(255) NOT NULL, 
        Ticker                  VARCHAR(255) NULL, 
        SecName                 VARCHAR(500) NOT NULL DEFAULT 'NA', 
        SecNameMs               VARCHAR(500) NULL, 
        Country                 VARCHAR(12) NULL,
        CntryCode               VARCHAR(12) NULL,
        Crncy                   VARCHAR(12) NULL,
        MrktCap                 FLOAT NULL, 
        Price                   FLOAT NULL,
        PrevPrice               FLOAT NULL,
        SLDate                  DATE NULL,
        SLAvail                   FLOAT NULL, 
        SLRate                  FLOAT NULL, 
        SLType                  VARCHAR(15) NULL,
        AvgVolDate              DATE NULL,
        AvgVol30d               FLOAT NULL,
        AvgVol90d               FLOAT NULL,
        AvgVol180d              FLOAT NULL, 
        bNoMktCap               BIT DEFAULT 0, 
        bNoPrice                BIT DEFAULT 0, 
        bMappedAvail            BIT DEFAULT 0) 
 
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
 
      IF @AsOfDate IS NULL
        BEGIN
          SELECT TOP 1 @AsOfDate = epd.AsOfDate FROM dbo.BiotechMasterUniverse epd WHERE epd.AsOfDate < @AsOfDate ORDER BY epd.AsOfDate DESC 
        END

      INSERT INTO #tmpRawDataCombined( 
             AsOfDate, 
             BbgTicker, 
             SecName,
             CntryCode,
             Crncy,
             MrktCap, 
             Price) 
      SELECT @AsOfDate, 
             bmu.BbgTicker, 
             bmu.SecName,
             RTRIM(LTRIM(SUBSTRING(bmu.BbgTicker, CHARINDEX(' ', bmu.BbgTicker), CHARINDEX(' ', bmu.BbgTicker, CHARINDEX(' ', bmu.BbgTicker)) - 1))), 
             bmu.Crncy,
             bmu.MarketCap, 
             bmu.Price 
        FROM dbo.BiotechMasterUniverse bmu
        WHERE bmu.AsOfDate = @AsOfDate
  
      UPDATE rdc 
         SET rdc.Ticker = sbd.MspbTicker, 
             rdc.SecNameMs = sbd.SecName, 
             rdc.Country = sbd.Country, 
             rdc.SLRate = sbd.Rate, 
             rdc.SLType = sbd.RateType, 
             rdc.Price = sbd.ClsPrice, 
             rdc.SLAvail = CASE WHEN sbd.vAvailability = 'LIMITED' THEN NULL ELSE sbd.vAvailability END,
             rdc.SLDate = CAST(sbd.SysStartTime AS DATE),
             rdc.bMappedAvail = 1
        FROM #tmpRawDataCombined rdc 
        JOIN dbo.BasketShortBorrowData sbd  
          ON sbd.MspbTicker = LEFT(rdc.BBgTicker, CHARINDEX(' ', rdc.BbgTicker)) 
         AND CASE WHEN sbd.Country = 'USA' THEN 'US' WHEN sbd.Country = 'CAN' THEN 'CN' ELSE 'N/A' END = RTRIM(LTRIM(SUBSTRING(rdc.BbgTicker, CHARINDEX(' ', rdc.BbgTicker), CHARINDEX(' ', rdc.BbgTicker, CHARINDEX(' ', rdc.BbgTicker)) - 1))) 
 
      UPDATE rdc 
         SET rdc.bNoMktCap = 1 
        FROM #tmpRawDataCombined rdc 
       WHERE NOT ABS(COALESCE(rdc.MrktCap, 0))  > 20000000 -- 20,000,000 20 Million
        
      UPDATE rdc 
         SET rdc.bNoPrice = 1 
        FROM #tmpRawDataCombined rdc 
       WHERE COALESCE(rdc.Price, 0) <= .1   -- $0.10 /  10 cents or more in price
 

      IF @LowQualityFilter = 1
        BEGIN
            SELECT rdc.AsOfDate, 
                   rdc.BbgTicker, 
                   COALESCE(rdc.Ticker, RTRIM(LEFT(rdc.BbgTicker, CHARINDEX(' ', rdc.BbgTicker)))) AS Ticker, 
                   rdc.SecName, 
                   rdc.Crncy, 
                   rdc.CntryCode, 
                   rdc.MrktCap, 
                   rdc.Price,
                   rdc.SLDate,                   
                   rdc.SLAvail, 
                   rdc.SLRate, 
                   rdc.SLType,
                   rdc.AvgVolDate,
                   rdc.AvgVol30d,
                   rdc.AvgVol90d,
                   rdc.AvgVol180d,
                   rdc.bNoMktCap,
                   rdc.bNoPrice
              FROM #tmpRawDataCombined rdc 
             WHERE rdc.bNoPrice = 0
               AND rdc.bNoMktCap = 0
               AND rdc.CntryCode IN ('US', 'CN') 
               --AND rdc.bMappedAvail = 1
             ORDER BY COALESCE(rdc.SecName, 'zzz' + rdc.BbgTicker)
        END
      ELSE
        BEGIN
            SELECT rdc.AsOfDate, 
                   rdc.BbgTicker, 
                   COALESCE(rdc.Ticker, RTRIM(LEFT(rdc.BbgTicker, CHARINDEX(' ', rdc.BbgTicker)))) AS Ticker, 
                   rdc.SecName, 
                   rdc.Crncy, 
                   rdc.CntryCode, 
                   rdc.MrktCap, 
                   rdc.Price,
                   rdc.SLDate,                   
                   rdc.SLAvail, 
                   rdc.SLRate, 
                   rdc.SLType, 
                   rdc.AvgVolDate,
                   rdc.AvgVol30d,
                   rdc.AvgVol90d,
                   rdc.AvgVol180d,
                   rdc.bNoMktCap,
                   rdc.bNoPrice 
              FROM #tmpRawDataCombined rdc 
             WHERE rdc.CntryCode IN ('US', 'CN') 
               AND 1 = 1  --rdc.bMappedAvail = 1
             ORDER BY COALESCE(rdc.SecName, 'zzz' + rdc.BbgTicker)
        END  
 
    SET NOCOUNT OFF 
  END 




  GRANT EXECUTE ON dbo.p_GetAmfBiotechUniverse TO PUBLIC
  GO