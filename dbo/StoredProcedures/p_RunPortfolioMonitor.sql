CREATE PROCEDURE dbo.p_RunPortfolioMonitor(
    @AsOfDate   DATE NULL = DEFAULT,
    @PrevDate   DATE NULL = DEFAULT,
    @rstOutput  INT = 1)
 
 /*
  Author:   Lee Kafafian
  Crated:   09/25/2023
  Object:   p_RunPortfolioMonitor
  Example:  EXEC dbo.p_RunPortfolioMonitor
            EXEC dbo.p_RunPortfolioMonitor @AsOfDate = '03/25/2024'
            EXEC dbo.p_RunPortfolioMonitor @AsOfDate = '03/25/2024', @PrevDate = '03/19/2024'
            EXEC dbo.p_RunPortfolioMonitor @rstOutput = 1
            EXEC dbo.p_RunPortfolioMonitor @rstOutput = 2
            EXEC dbo.p_RunPortfolioMonitor @rstOutput = 3
            
 */
  
 AS 

  BEGIN
  
    SET NOCOUNT ON

    CREATE TABLE #tmpPortfolio(  
      [AsOfDate]             DATE          NOT NULL,
      [Strategy]             VARCHAR (255) NULL,
      [Substrategy]          VARCHAR (255) NULL,
      [Ticker]               VARCHAR (255) NULL,
      [Shares]               FLOAT (53)    NULL,
      [FirstDate]            DATE          NULL,
      [ShareChange]          FLOAT (53)    NULL,
      [bProcessed]           BIT           DEFAULT 0,
      [sGUID]                VARCHAR(MAX)  NULL)

    DECLARE @AsOfUID UNIQUEIDENTIFIER = NEWID()
    DECLARE @PrevUID UNIQUEIDENTIFIER = NEWID()
    DECLARE @FirstDate AS DATE
    DECLARE @FirstShares AS FLOAT
    DECLARE @ShareChange AS FLOAT
    DECLARE @Ticker AS VARCHAR(255)


      IF @AsOfDate IS NULL
        BEGIN
          SELECT TOP 1 @AsOfDate = CAST(epd.AsOfDate AS DATE) FROM dbo.EnfPositionDetails epd WHERE 1 = 1 ORDER BY epd.AsOfDate DESC
        END

      IF @PrevDate IS NULL
        BEGIN
          SELECT TOP 1 @PrevDate = epd.AsOfDate FROM dbo.EnfPositionDetails epd WHERE 1 = 1 AND epd.AsOfDate < @AsOfDate ORDER BY epd.AsOfDate DESC
          SELECT @PrevDate = DATEADD(dd, -1, @AsOfDate)
        END


    /*    LOAD DATA FOR @AsOfDate   */
          INSERT INTO #tmpPortfolio(
                 AsOfDate,
                 Strategy,
                 Substrategy,
                 Ticker,
                 Shares,
                 sGUID)
          SELECT @AsOfDate,
                 epd.StratName AS Strategy,
                 epd.BookName AS Substrategy,
                 COALESCE(UnderlyBBYellowKey, BBYellowKey) AS Ticker,
                 SUM(epd.Quantity) AS Shares,
                 @AsOfUID
            FROM dbo.EnfPositionDetails epd
           WHERE epd.AsOfDate = @AsOfDate
             AND epd.StratName IN ('Alpha Long', 'Alpha Short')
             AND LTRIM(RTRIM(COALESCE(UnderlyBBYellowKey, BBYellowKey))) != ''
             AND epd.InstrType = 'Equity'
           GROUP BY epd.StratName,
                 epd.BookName,
                 COALESCE(UnderlyBBYellowKey, BBYellowKey)                 
          HAVING ROUND(SUM(epd.Quantity), 0) != 0
           ORDER BY epd.StratName,
                 epd.BookName,
                 COALESCE(UnderlyBBYellowKey, BBYellowKey)

    /*    LOAD DATA FOR @PrevDate   */
          INSERT INTO #tmpPortfolio(
                 AsOfDate,
                 Strategy,
                 Substrategy,
                 Ticker,
                 Shares,
                 sGUID)
          SELECT @PrevDate,
                 epd.StratName AS Strategy,
                 epd.BookName AS Substrategy,
                 COALESCE(UnderlyBBYellowKey, BBYellowKey) AS Ticker,
                 SUM(epd.Quantity) AS Shares,
                 @PrevUID
            FROM dbo.EnfPositionDetails epd
           WHERE epd.AsOfDate = @PrevDate
             AND epd.StratName IN ('Alpha Long', 'Alpha Short')
             AND LTRIM(RTRIM(COALESCE(UnderlyBBYellowKey, BBYellowKey))) != ''
             AND epd.InstrType = 'Equity'
           GROUP BY epd.StratName,
                 epd.BookName,
                 COALESCE(UnderlyBBYellowKey, BBYellowKey)
          HAVING ROUND(SUM(epd.Quantity), 0) != 0
           ORDER BY epd.StratName,
                 epd.BookName,
                 COALESCE(UnderlyBBYellowKey, BBYellowKey)


        WHILE EXISTS(SELECT 1 FROM #tmpPortfolio tpp WHERE tpp.bProcessed = 0)
          BEGIN

            SELECT TOP 1 @Ticker = tpp.Ticker FROM #tmpPortfolio tpp WHERE tpp.bProcessed = 0 ORDER BY tpp.Ticker, tpp.AsOfDate DESC
            
              SELECT TOP 1 
                     @FirstDate = epd.AsOfDate, 
                     @FirstShares = COALESCE(epd.Quantity, 0) 
                FROM dbo.EnfPositionDetails epd 
               WHERE COALESCE(ROUND(epd.Quantity, 0), 0) != 0
                 AND epd.InstrType = 'Equity'
                 AND epd.BBYellowKey = @Ticker 
                 AND epd.AsOfDate >= @PrevDate 
               ORDER BY epd.AsOfDate ASC
            
            IF EXISTS(SELECT 1 FROM #tmpPortfolio tpo WHERE tpo.Ticker = @Ticker AND tpo.sGUID = @AsOfUID AND tpo.Ticker NOT IN (SELECT tpx.Ticker FROM #tmpPortfolio tpx WHERE tpx.sGUID = @PrevUID))
              BEGIN
                SELECT TOP 1 @ShareChange = @FirstShares
                  FROM #tmpPortfolio tpp
                 WHERE tpp.Ticker = @Ticker
              END
            ELSE
              BEGIN
                SELECT TOP 1 @ShareChange = COALESCE(tpp.Shares, 0) - @FirstShares
                  FROM #tmpPortfolio tpp
                 WHERE tpp.Ticker = @Ticker
              END
            
            UPDATE tpp
               SET tpp.bProcessed = 1,
                   tpp.ShareChange = @ShareChange,
                   tpp.FirstDate = @FirstDate
             FROM  #tmpPortfolio tpp
            WHERE tpp.Ticker = @Ticker 
            
          END



    /*  SELECT OUT THE DATA FOR RESULTS  */
    IF @rstOutput = 1
      BEGIN
        SELECT tpo.AsOfDate,
               tpo.Strategy,
               tpo.Substrategy,
               tpo.Ticker,
               tpo.Shares,
               tpo.FirstDate,
               tpo.ShareChange,
               'New name in AMF Portfolio' AS [Status]
          FROM #tmpPortfolio tpo 
         WHERE tpo.sGUID = @AsOfUID
           AND tpo.Ticker NOT IN (SELECT tpx.Ticker FROM #tmpPortfolio tpx WHERE tpx.sGUID = @PrevUID)
         ORDER BY tpo.AsOfDate, tpo.Strategy, tpo.Substrategy
      END

    IF @rstOutput = 2
      BEGIN
        SELECT tpo.AsOfDate,
               tpo.Strategy,
               tpo.Substrategy,
               tpo.Ticker,
               tpo.Shares,
               tpo.FirstDate,
               tpo.ShareChange,
               'Unchanged names in AMF Portfolio' AS [Status]
          FROM #tmpPortfolio tpo 
         WHERE tpo.sGUID = @AsOfUID
           AND tpo.Ticker IN (SELECT tpx.Ticker FROM #tmpPortfolio tpx WHERE tpx.sGUID = @PrevUID)
         ORDER BY tpo.AsOfDate, tpo.Strategy, tpo.Substrategy
      END

    IF @rstOutput = 3
      BEGIN
        SELECT @AsOfDate AS AsOfDate,
               tpo.Strategy,
               tpo.Substrategy,
               tpo.Ticker,
               tpo.Shares,
               tpo.FirstDate,
               tpo.ShareChange,
               'Names out of the AMF Portfolio' AS [Status]
          FROM #tmpPortfolio tpo 
         WHERE tpo.sGUID = @PrevUID
           AND tpo.Ticker NOT IN (SELECT tpx.Ticker FROM #tmpPortfolio tpx WHERE tpx.sGUID = @AsOfUID)
         ORDER BY tpo.AsOfDate, tpo.Strategy, tpo.Substrategy
      END


    SET NOCOUNT OFF

  END
  GO

  GRANT EXECUTE ON dbo.p_RunPortfolioMonitor TO PUBLIC
  GO