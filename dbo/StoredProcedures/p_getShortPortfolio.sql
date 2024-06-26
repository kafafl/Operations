CREATE PROCEDURE dbo.p_GetShortPortfolio(
    @AsOfDate          DATE = NULL)
 

 /*
  Author:   Lee Kafafian
  Crated:   05/08/2024
  Object:   p_GetShortPortfolio
  Example:  EXEC dbo.p_GetShortPortfolio @AsOfDate = '04/25/2024', 
 */
  
 AS 
  BEGIN
    SET NOCOUNT ON

  CREATE TABLE #tmpPortOutput(
    AsOfDate           DATE,
    Strategy           VARCHAR(255),
    BBYellowkey        VARCHAR(255),
    PosShort           FLOAT,
    PosNet             FLOAT,
    PosLong            FLOAT)


  CREATE TABLE #tmpPortQuants(
    AsOfDate           DATE,
    Strategy           VARCHAR(255),
    BBYellowkey        VARCHAR(255),
    Quantity            FLOAT)

    IF @AsOfDate IS NULL
      BEGIN
          SELECT TOP 1 @AsOfDate = enf.AsOfDate FROM dbo.EnfPositionDetails enf ORDER BY enf.AsOfDate DESC
      END


        INSERT INTO #tmpPortOutput(
               AsOfDate,
               Strategy,
               BBYellowkey,
               PosShort)
        SELECT epd.AsOfDate,
               epd.StratName,
               epd.BBYellowKey,
               SUM(epd.Quantity) AS Quantity
          FROM dbo.EnfPositionDetails epd
         WHERE epd.AsOfDate = @AsOfDate
           AND epd.InstrType = 'Equity'
           AND CHARINDEX('Alpha Short', epd.StratName) != 0
           AND ROUND(epd.Quantity, 0) != 0
           AND epd.Account IN ('MS Cash')
           AND COALESCE(epd.BBYellowKey, '') != ''
         GROUP BY epd.AsOfDate,
               epd.StratName,
               epd.BBYellowKey
         ORDER BY epd.AsOfDate,
               epd.StratName,
               epd.BBYellowKey


        INSERT INTO #tmpPortQuants(
               AsOfDate,
               Strategy,
               BBYellowkey,
               Quantity)
        SELECT epd.AsOfDate,
               epd.StratName,
               epd.BBYellowKey,
               SUM(epd.Quantity) AS Quantity
          FROM dbo.EnfPositionDetails epd
         WHERE epd.AsOfDate = @AsOfDate
           AND epd.InstrType = 'Equity'
           AND CHARINDEX('Alpha Long', epd.StratName) != 0
           AND ROUND(epd.Quantity, 0) != 0
           AND epd.Account IN ('MS Cash')
           AND COALESCE(epd.BBYellowKey, '') != ''
         GROUP BY epd.AsOfDate,
               epd.StratName,
               epd.BBYellowKey
         ORDER BY epd.AsOfDate,
               epd.StratName,
               epd.BBYellowKey


        UPDATE tpo
           SET tpo.PosLong = tpq.Quantity,
               tpo.PosNet = tpo.PosShort + tpq.Quantity
          FROM #tmpPortOutput tpo
          JOIN #tmpPortQuants tpq
            ON tpo.BBYellowkey = tpq.BBYellowkey
           AND tpo.AsOfDate = tpq.AsOfDate

        UPDATE tpo
           SET tpo.PosLong = COALESCE(tpo.PosLong, 0),
               tpo.PosShort = COALESCE(tpo.PosShort, 0),
               tpo.PosNet = COALESCE(tpo.PosLong, 0) - COALESCE(tpo.PosShort, 0)
          FROM #tmpPortOutput tpo
    

           SELECT PosLong,
                  PosShort,
                  PosNet 
             FROM #tmpPortOutput



    SET NOCOUNT OFF
  END
GO

GRANT EXECUTE ON dbo.p_GetShortPortfolio TO PUBLIC
GO