SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[p_GetAmfBiotechUniverse]( 
    @AsOfDate          DATE = NULL,
    @LowQualityFilter  BIT =  0) 
 
 /* 
  Author:   Lee Kafafian 
  Crated:   05/08/2024 
  Object:   p_GetShortBasketComplete 
  Example:  EXEC p_GetAmfBiotechUniverse @AsOfDate = '06/12/2024'
            EXEC p_GetAmfBiotechUniverse @LowQualityFilter = 1
            EXEC p_GetAmfBiotechUniverse @AsOfDate = '07/08/2024', @LowQualityFilter = 1
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
        EntVal                  FLOAT NULL,
        Price                   FLOAT NULL,
        PrevPrice               FLOAT NULL,
        SLDate                  DATE NULL,
        SLAvail                 FLOAT NULL, 
        SLRate                  FLOAT NULL, 
        SLType                  VARCHAR(15) NULL,
        AvgVolDate              DATE NULL,
        AvgVol30d               FLOAT NULL,
        AvgVol90d               FLOAT NULL,
        AvgVol180d              FLOAT NULL,
        TheraAreaTag            VARCHAR(255),
        TheraAreaDate           DATE,
        bNoMktCap               BIT DEFAULT 0, 
        bNoPrice                BIT DEFAULT 0,
        bNoEntValue             BIT DEFAULT 0, 
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

      CREATE TABLE #tmpPortTagging(
        AsOfDate                DATE,
        PositionId              VARCHAR(255),
        TagReference            VARCHAR(255),
        TagValue                VARCHAR(255),
        TagTsUpdate             DATETIME)
 
      DECLARE @PortDate AS DATE
      DECLARE @MktDataDate AS DATE      
      DECLARE @TagDate AS DATE
 

 
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
             EntVal,
             Price) 
      SELECT @AsOfDate, 
             bmu.BbgTicker, 
             bmu.SecName,
             RTRIM(LTRIM(SUBSTRING(bmu.BbgTicker, CHARINDEX(' ', bmu.BbgTicker), CHARINDEX(' ', bmu.BbgTicker, CHARINDEX(' ', bmu.BbgTicker)) - 1))), 
             bmu.Crncy,
             bmu.MarketCap,
             bmu.EnterpriseValue, 
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
 

       SELECT TOP 1 @MktDataDate = amd.AsOfDate 
         FROM dbo.AmfMarketData amd
        WHERE amd.AsOfDate IS NOT NULL 
          AND amd.AsOfDate <= @AsOfDate 
        ORDER BY amd.AsOfDate DESC 

       UPDATE rdc
          SET rdc.AvgVolDate = @MktDataDate
         FROM #tmpRawDataCombined rdc

       UPDATE rdc
          SET rdc.AvgVol30d = amd.MdValue
         FROM #tmpRawDataCombined rdc 
         JOIN dbo.AmfMarketData amd
           ON rdc.AvgVolDate = amd.AsOfDate
          AND rdc.BbgTicker = amd.PositionId
        WHERE amd.DataSource = 'Bloomberg' 
          AND amd.TagMnemonic = 'VOLUME_AVG_30D'

       UPDATE rdc
          SET rdc.AvgVol90d = amd.MdValue
         FROM #tmpRawDataCombined rdc 
         JOIN dbo.AmfMarketData amd
           ON rdc.AvgVolDate = amd.AsOfDate
          AND rdc.BbgTicker = amd.PositionId
        WHERE amd.DataSource = 'Bloomberg' 
          AND amd.TagMnemonic = 'VOLUME_AVG_3M'

       UPDATE rdc
          SET rdc.AvgVol180d = amd.MdValue
         FROM #tmpRawDataCombined rdc 
         JOIN dbo.AmfMarketData amd
           ON rdc.AvgVolDate = amd.AsOfDate
          AND rdc.BbgTicker = amd.PositionId
        WHERE amd.DataSource = 'Bloomberg' 
          AND amd.TagMnemonic = 'VOLUME_AVG_6M'

      UPDATE rdc 
         SET rdc.bNoMktCap = 1 
        FROM #tmpRawDataCombined rdc 
       WHERE NOT ABS(COALESCE(rdc.MrktCap, 0))  > 20000000      /*   20,000,000 20 Million               */

      UPDATE rdc 
         SET rdc.bNoEntValue = 1 
        FROM #tmpRawDataCombined rdc 
       WHERE COALESCE(rdc.EntVal, 0) <= 0                       /*   ZERO OR LESS ENTERPRISE VALUE       */

      UPDATE rdc 
         SET rdc.bNoPrice = 1 
        FROM #tmpRawDataCombined rdc 
       WHERE COALESCE(rdc.Price, 0) <= .1                       /*   $0.10 /  10 cents or more in price  */


    /*  ADDD TAGS  */
        INSERT INTO #tmpPortTagging(
               AsOfDate,
               PositionId,
               TagReference,
               TagValue,
               TagTsUpdate)
        SELECT tat.AsOfDate,
               tat.PositionId,
               tat.TagReference,
               tat.TagValue,
               tat.CreatedOn 
          FROM dbo.vw_TherapeuticAreaTags tat
         WHERE tat.AsOfDate <= @AsOfDate

        UPDATE tbm
           SET tbm.TheraAreaTag = apt.TagValue,
               tbm.TheraAreaDate = apt.AsOfDate
          FROM #tmpRawDataCombined tbm
          JOIN #tmpPortTagging apt
            ON CHARINDEX(tbm.BbgTicker, apt.PositionId) != 0
 
      IF @LowQualityFilter = 1
        BEGIN
            SELECT rdc.AsOfDate, 
                   rdc.BbgTicker, 
                   COALESCE(rdc.Ticker, RTRIM(LEFT(rdc.BbgTicker, CHARINDEX(' ', rdc.BbgTicker)))) AS Ticker, 
                   rdc.SecName, 
                   rdc.Crncy, 
                   rdc.CntryCode, 
                   rdc.MrktCap,
                   rdc.EntVal, 
                   rdc.Price,
                   rdc.SLDate,                   
                   rdc.SLAvail, 
                   rdc.SLRate, 
                   rdc.SLType,
                   rdc.AvgVolDate,
                   rdc.AvgVol30d,
                   rdc.AvgVol90d,
                   rdc.AvgVol180d,
                   rdc.TheraAreaTag,
                   rdc.TheraAreaDate,
                   rdc.bNoMktCap,
                   rdc.bNoPrice,
                   rdc.bNoEntValue
              FROM #tmpRawDataCombined rdc 
             WHERE rdc.bNoPrice = 0
               AND rdc.bNoMktCap = 0
               AND rdc.bNoEntValue = 0
               AND rdc.CntryCode IN ('US', 'CN') 
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
                   rdc.EntVal, 
                   rdc.Price,
                   rdc.SLDate,                   
                   rdc.SLAvail, 
                   rdc.SLRate, 
                   rdc.SLType, 
                   rdc.AvgVolDate,
                   rdc.AvgVol30d,
                   rdc.AvgVol90d,
                   rdc.AvgVol180d,
                   rdc.TheraAreaTag,
                   rdc.TheraAreaDate,
                   rdc.bNoMktCap,
                   rdc.bNoPrice,
                   rdc.bNoEntValue
              FROM #tmpRawDataCombined rdc 
             WHERE rdc.CntryCode IN ('US', 'CN') 
               AND 1 = 1  /*  rdc.bMappedAvail = 1  */
             ORDER BY COALESCE(rdc.SecName, 'zzz' + rdc.BbgTicker)
        END  
 
    SET NOCOUNT OFF 
  END 


GRANT EXECUTE ON dbo.p_GetAmfBiotechUniverse TO PUBLIC
GO
