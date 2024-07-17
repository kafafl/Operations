SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[p_GetShortBasketComplete]( 
    @AsOfDate          DATE = NULL,
    @rstOutput         INT = 1) 
 
 /* 
  Author:   Lee Kafafian 
  Crated:   05/08/2024 
  Object:   p_GetShortBasketComplete 
  Example:  EXEC dbo.p_GetShortBasketComplete @AsOfDate = '06/03/2024'
            EXEC dbo.p_GetShortBasketComplete
            EXEC dbo.p_GetShortBasketComplete @AsOfDate = '07/08/2024', @rstOutput = 2
 */ 
   
 AS  
  BEGIN 
    SET NOCOUNT ON 
 
      CREATE TABLE #tmpPortfolio( 
        AsOfDate                DATE, 
        Strategy                VARCHAR(500), 
        Substrategy             VARCHAR(500), 
        Ticker                  VARCHAR(500), 
        Shares                  FLOAT, 
        FirstDate               DATE, 
        ShareChange             FLOAT, 
        StatusDet               VARCHAR(500)) 

     CREATE TABLE #tmpBiotechMaster( 
        AsOfDate                DATE, 
        BbgTicker               VARCHAR(255) NOT NULL, 
        Ticker                  VARCHAR(255) NULL, 
        SecName                 VARCHAR(500) NOT NULL DEFAULT 'NA', 
        Crncy                   VARCHAR(12) NULL,
        CntryCode               VARCHAR(12) NULL,        
        MrktCap                 FLOAT NULL,
        EntVal                  FLOAT NULL, 
        Price                   FLOAT NULL,
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
        bNoEntVal               BIT DEFAULT 0, 
        bNoPrice                BIT DEFAULT 0,
        bNoRebate               BIT DEFAULT 0,
        bInLongPort             BIT DEFAULT 0,
        bInShortPort            BIT DEFAULT 0)

      CREATE TABLE #tmpPortTagging(
        AsOfDate                DATE,
        PositionId              VARCHAR(255),
        TagReference            VARCHAR(255),
        TagValue                VARCHAR(255),
        TagTsUpdate             DATETIME)         
 
      DECLARE @PortDate AS DATE
      DECLARE @TagDate AS DATE
 
      IF @AsOfDate IS NULL 
        BEGIN 
          SELECT @AsOfDate = CAST(GETDATE() AS DATE) 
        END 
 
 
    SELECT TOP 1 @PortDate = epd.AsOfDate FROM dbo.EnfPositionDetails epd WHERE epd.AsOfDate < @AsOfDate ORDER BY epd.AsOfDate DESC 
 
  /* FETCH BIOTECH HIG QUALITY UNIVERESE  */
     INSERT INTO #tmpBiotechMaster( 
             AsOfDate,
             BbgTicker,
             Ticker,
             SecName,
             Crncy,
             CntryCode,
             MrktCap,
             EntVal, 
             Price,
             SLDate,
             SLAvail,
             SLRate,
             SLType,
             AvgVolDate,
             AvgVol30d,
             AvgVol90d,
             AvgVol180d,
             TheraAreaTag,
             TheraAreaDate,
             bNoMktCap,
             bNoEntVal,
             bNoPrice)  
        EXEC dbo.p_GetAmfBiotechUniverse @AsOfDate = @AsOfDate, @LowQualityFilter = 1

  /*  LOAD PORTFOLIO DETAILS      */
      INSERT INTO #tmpPortfolio( 
             AsOfDate, 
             Strategy, 
             Substrategy, 
             Ticker, 
             Shares, 
             FirstDate, 
             ShareChange, 
             StatusDet) 
        EXEC dbo.p_RunPortfolioMonitor @AsOfDate = @PortDate, @rstOutput = 4 


  /*  BORROW DATA   */
      UPDATE rdc 
         SET rdc.Ticker = sbd.MspbTicker, 
             rdc.SecName = sbd.SecName, 
             rdc.SLRate = sbd.Rate, 
             rdc.SLType = sbd.RateType, 
             rdc.SLAvail = CASE WHEN sbd.vAvailability = 'LIMITED' THEN NULL ELSE sbd.vAvailability END,
             rdc.SLDate = CAST(sbd.SysStartTime AS DATE)
        FROM #tmpBiotechMaster rdc 
        JOIN dbo.BasketShortBorrowData sbd  
          ON sbd.MspbTicker = rdc.Ticker
         AND CASE WHEN sbd.Country = 'USA' THEN 'US' WHEN sbd.Country = 'CAN' THEN 'CN' ELSE 'N/A' END = RTRIM(LTRIM(SUBSTRING(rdc.BbgTicker, CHARINDEX(' ', rdc.BbgTicker), CHARINDEX(' ', rdc.BbgTicker, CHARINDEX(' ', rdc.BbgTicker)) - 1))) 


        /*  MARKET CAP FILTER          */
            UPDATE rdc 
               SET rdc.bNoMktCap = 1 
              FROM #tmpBiotechMaster rdc 
             WHERE NOT ABS(COALESCE(rdc.MrktCap, 0))  BETWEEN 25000000 AND 25000000000000      /*   BETWEEN 25M and 25B       */

        /*   ENTERPRISE VALUE FILTER   */
            UPDATE rdc 
               SET rdc.bNoEntVal = 1 
              FROM #tmpBiotechMaster rdc 
             WHERE NOT ABS(COALESCE(rdc.EntVal, 0))  BETWEEN 1 AND 25000000000000              /*   BETWEEN 1 and 25B         */

        /*   PRICE FILTER              */
            UPDATE rdc 
               SET rdc.bNoPrice = 1 
              FROM #tmpBiotechMaster rdc 
             WHERE COALESCE(rdc.Price, 0) <= .5                                             /*   GREATER THAN 50 cents     */
        
        /*   REBATE FILTER              */
            UPDATE rdc 
               SET rdc.bNoRebate = 1 
              FROM #tmpBiotechMaster rdc 
             WHERE rdc.SLRate < 0.00                                                           /*   GREATER THAN ZERO REBATE  */
                OR rdc.SLAvail IS NULL 
        
        /*  IN LONG PORTFOLIO     */ 
            UPDATE rdc 
               SET rdc.bInLongPort = 1 
              FROM #tmpBiotechMaster rdc 
              JOIN #tmpPortfolio tpp 
                ON rdc.BbgTicker = tpp.Ticker 
             WHERE CHARINDEX('Alpha Long', tpp.Strategy) != 0 
        
        /*  IN SHORT PORTFOLIO     */
            UPDATE rdc 
               SET rdc.bInShortPort = 1 
              FROM #tmpBiotechMaster rdc 
              JOIN #tmpPortfolio tpp 
                ON rdc.BbgTicker = tpp.Ticker 
             WHERE CHARINDEX('Alpha Short', tpp.Strategy) != 0 
 


    IF @rstOutput = 1
      BEGIN
    /*  OUTPUT OF STORED PROCEDURE   */
         SELECT tbm.AsOfDate, 
                tbm.BbgTicker, 
                COALESCE(tbm.Ticker, RTRIM(LEFT(tbm.BbgTicker, CHARINDEX(' ', tbm.BbgTicker)))) AS Ticker, 
                tbm.SecName,
                tbm.Crncy,
                tbm.CntryCode,
                tbm.MrktCap,
                tbm.EntVal, 
                tbm.Price,
                tbm.SLAvail, 
                tbm.SLRate, 
                tbm.SLType,
                tbm.SLDate, 
                tbm.AvgVol30d,
                tbm.AvgVol90d,
                tbm.AvgVol180d, 
                tbm.bNoMktCap, 
                tbm.bNoRebate, 
                tbm.bNoPrice, 
                tbm.bInLongPort, 
                tbm.bInShortPort 
           FROM #tmpBiotechMaster tbm 
          WHERE tbm.bNoMktCap = 0 
            AND tbm.bNoEntVal = 0 
            AND tbm.bNoPrice = 0
            AND tbm.bNoRebate = 0
            AND tbm.bInLongPort = 0 
          ORDER BY tbm.AsOfDate, 
                tbm.BbgTicker, 
                tbm.SecName
      END

    IF @rstOutput = 2
      BEGIN

    /*  ADDD TAGS  */
        INSERT INTO #tmpPortTagging(
               AsOfDate,
               PositionId,
               TagReference,
               TagValue,
               TagTsUpdate)
        SELECT tag.AsOfDate,
               tag.PositionId,
               tag.TagReference,
               tag.TagValue,
               tag.CreatedOn
          FROM dbo.vw_TherapeuticAreaTags tag
          JOIN (SELECT MAX(tat.AsOfDate) AS AsOfDate,
                       tat.PositionId,
                       MAX(tat.CreatedOn) AS CreatedOn,
                       COUNT(tat.PositionId) AS xCount
                  FROM dbo.vw_TherapeuticAreaTags tat
                 WHERE tat.AsOfDate <= @AsOfDate 
                 GROUP BY tat.PositionId
                HAVING MAX(tat.CreatedOn) = MAX(tat.CreatedOn)) tax
                    ON tag.AsOfDate = tax.AsOfDate
                   AND tag.PositionId = tax.PositionId
                   AND tag.CreatedOn = tax.CreatedOn
         ORDER BY tag.PositionId  

        UPDATE tbm
           SET tbm.TheraAreaTag = apt.TagValue,
               tbm.TheraAreaDate = apt.AsOfDate
          FROM #tmpBiotechMaster tbm
          JOIN #tmpPortTagging apt
            ON CHARINDEX(tbm.BbgTicker, apt.PositionId) != 0
        

    /*  OUTPUT OF STORED PROCEDURE   */
         SELECT tbm.AsOfDate, 
                tbm.BbgTicker, 
                COALESCE(tbm.Ticker, RTRIM(LEFT(tbm.BbgTicker, CHARINDEX(' ', tbm.BbgTicker)))) AS Ticker, 
                tbm.SecName,
                tbm.Crncy,
                tbm.CntryCode,
                tbm.MrktCap,
                tbm.EntVal, 
                tbm.Price,
                tbm.SLAvail, 
                tbm.SLRate, 
                tbm.SLType,
                tbm.SLDate, 
                tbm.AvgVol30d,
                tbm.AvgVol90d,
                tbm.AvgVol180d,
                tbm.TheraAreaTag,
                tbm.TheraAreaDate, 
                tbm.bNoMktCap, 
                tbm.bNoRebate, 
                tbm.bNoPrice, 
                tbm.bInLongPort, 
                tbm.bInShortPort 
           FROM #tmpBiotechMaster tbm 
          WHERE tbm.bNoMktCap = 0 
            AND tbm.bNoEntVal = 0 
            AND tbm.bNoPrice = 0
            AND tbm.bNoRebate = 0
            AND tbm.bInLongPort = 0 
          ORDER BY tbm.AsOfDate, 
                tbm.BbgTicker, 
                tbm.SecName
      END

 
    SET NOCOUNT OFF 
  END 
GO


GRANT EXECUTE ON [dbo].[p_GetShortBasketComplete] TO PUBLIC
GO