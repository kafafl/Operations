SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[p_GetLongPortfolio](
    @AsOfDate          DATE = NULL)
 

 /*
  Author:   Lee Kafafian
  Crated:   05/08/2024
  Object:   p_GetLongPortfolio
  Example:  EXEC dbo.p_GetLongPortfolio @AsOfDate = '04/25/2024', 
 */
  
 AS 
  BEGIN
    SET NOCOUNT ON

  CREATE TABLE #tmpPortOutput(
    AsOfDate           DATE,
    Strategy           VARCHAR(255),
    BBYellowkey        VARCHAR(255),
    PosLong            FLOAT,
    PosNet             FLOAT,
    PosShort           FLOAT)


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
               PosLong)
        SELECT epd.AsOfDate,
               epd.StratName,
               epd.BBYellowKey,
               SUM(epd.Quantity) AS Quantity
          FROM dbo.EnfPositionDetails epd
         WHERE epd.AsOfDate = @AsOfDate
           AND epd.InstrType = 'Equity'
           AND CHARINDEX('Long', epd.StratName) != 0
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
           AND CHARINDEX('Short', epd.StratName) != 0
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
           SET tpo.PosShort = tpq.Quantity,
               tpo.PosNet = tpo.PosLong - tpq.Quantity
          FROM #tmpPortOutput tpo
          JOIN #tmpPortQuants tpq
            ON tpo.BBYellowkey = tpq.BBYellowkey
           AND tpo.AsOfDate = tpq.AsOfDate

        UPDATE tpo
           SET tpo.PosLong = COALESCE(tpo.PosLong, 0),
               tpo.PosShort = COALESCE(tpo.PosShort, 0),
               tpo.PosNet = COALESCE(tpo.PosLong, 0) + COALESCE(tpo.PosShort, 0)
          FROM #tmpPortOutput tpo
    

           SELECT * FROM #tmpPortOutput



    SET NOCOUNT OFF
  END
GO
