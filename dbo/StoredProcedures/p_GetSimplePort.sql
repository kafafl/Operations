USE Operations
GO

USE Operations
GO

ALTER PROCEDURE dbo.p_GetSimplePort(
    @PortDate   DATE NULL = DEFAULT )
 
 /*
  Author: Lee Kafafian
  Crated: 08/25/2023
  Object: p_GetSimplePort
  Example:  EXEC dbo.p_GetSimplePort @PortDate = '08/25/2023'
 */
  
 AS 

   BEGIN

   SET NOCOUNT ON

     IF @PortDate IS NULL
       BEGIN
         SELECT TOP 1 @PortDate = epd.AsOfDate FROM dbo.EnfPositionDetails epd ORDER BY epd.AsOfDate DESC
       END


    CREATE TABLE #tmpPositions(  
      [AsOfDate]             DATE          NOT NULL,
      [BBYellowKey]	         VARCHAR (255) NOT NULL,
      [Quantity]             FLOAT (53) NULL)


     INSERT INTO #tmpPositions(
            AsOfDate,
            BBYellowKey,
            Quantity)
     SELECT epd.AsOfDate,
            epd.BBYellowKey,
            SUM(epd.Quantity)            
       FROM dbo.EnfPositionDetails epd
      WHERE epd.AsOfDate = @PortDate
        AND CHARINDEX('US Equity', epd.UnderlyBBYellowKey) != 0	  
        AND COALESCE(epd.UnderlyBBYellowKey, '') != ''
        AND epd.InstrType = 'Equity'
		AND epd.Quantity != 0
      GROUP BY epd.AsOfDate,
            epd.BBYellowKey

     INSERT INTO #tmpPositions(
            AsOfDate,
            BBYellowKey,
            Quantity)
     SELECT epd.AsOfDate,
            epd.UnderlyBBYellowKey,
			CEILING(SUM(COALESCE(epd.NetMarketValue, 0)/COALESCE(epd.NetAvgCost, 1)))
       FROM dbo.EnfPositionDetails epd
      WHERE epd.AsOfDate = @PortDate
        AND (CHARINDEX('US Equity', epd.UnderlyBBYellowKey) != 0 OR  CHARINDEX('Index', epd.UnderlyBBYellowKey) != 0)
        AND COALESCE(epd.UnderlyBBYellowKey, '') != ''
        AND epd.InstrType != 'Equity'
		AND CHARINDEX('FX ', epd.InstDescr) = 0 
		AND epd.Quantity != 0
        AND epd.UnderlyBBYellowKey NOT IN (SELECT DISTINCT BBYellowKey FROM #tmpPositions)
      GROUP BY epd.AsOfDate,
            epd.UnderlyBBYellowKey

     UPDATE tsp
        SET tsp.BBYellowKey = REPLACE(tsp.BBYellowKey, 'US Equity', '')
       FROM #tmpPositions tsp

     UPDATE tsp
        SET tsp.BBYellowKey = REPLACE(tsp.BBYellowKey, 'Index', '')
       FROM #tmpPositions tsp

     DELETE tsp
       FROM #tmpPositions tsp
	  WHERE ABS(tsp.Quantity) = 0

       
/*

*/

     SELECT tsp.AsOfDate AS PortDate,
            tsp.BBYellowKey AS TickerName,
            tsp.Quantity
       FROM #tmpPositions tsp 
      ORDER BY tsp.BBYellowKey

   SET NOCOUNT OFF

   END
   GO

   GRANT EXECUTE ON dbo.p_GetSimplePort TO PUBLIC
   GO

