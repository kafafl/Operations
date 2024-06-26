SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[p_GetSimplePort]( 
    @PortDate   DATE NULL = DEFAULT,
    @iRst       INT  NULL = DEFAULT) 
  
 /* 
  Author: Lee Kafafian 
  Crated: 08/25/2023 
  Object: p_GetSimplePort 
  Example:  EXEC dbo.p_GetSimplePort @PortDate = '04/12/2024' 
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
      [BBYellowKey]	         VARCHAR(255)  NOT NULL, 
      [Quantity]             FLOAT (53)        NULL,
      [Strategy]             VARCHAR(255)      NULL) 
 
 
     INSERT INTO #tmpPositions( 
            AsOfDate, 
            BBYellowKey,
            Strategy,
            Quantity) 
     SELECT epd.AsOfDate, 
            epd.BBYellowKey,
            epd.StratName,
            SUM(epd.Quantity)             
       FROM dbo.EnfPositionDetails epd 
      WHERE epd.AsOfDate = @PortDate 
        AND CHARINDEX('US Equity', epd.UnderlyBBYellowKey) != 0	   
        AND COALESCE(epd.UnderlyBBYellowKey, '') != '' 
        AND epd.InstrType = 'Equity' 
        AND CHARINDEX('Private', epd.InstDescr) = 0 
		AND epd.Quantity != 0 
      GROUP BY epd.AsOfDate, 
            epd.BBYellowKey,
            epd.StratName 
 
     INSERT INTO #tmpPositions( 
            AsOfDate, 
            BBYellowKey,
            Strategy,
            Quantity) 
     SELECT epd.AsOfDate, 
            epd.UnderlyBBYellowKey,
            epd.StratName,
			      CEILING(SUM(COALESCE(epd.NetMarketValue, 0)/COALESCE(epd.FairValue, 1))) 
       FROM dbo.EnfPositionDetails epd 
      WHERE epd.AsOfDate = @PortDate 
        AND (CHARINDEX('US Equity', epd.UnderlyBBYellowKey) != 0 OR  CHARINDEX('Index', epd.UnderlyBBYellowKey) != 0) 
        AND COALESCE(epd.UnderlyBBYellowKey, '') != '' 
        AND epd.InstrType != 'Equity' 
		    AND CHARINDEX('FX ', epd.InstDescr) = 0  
		    AND epd.Quantity != 0 
        AND epd.UnderlyBBYellowKey NOT IN (SELECT DISTINCT BBYellowKey FROM #tmpPositions) 
        AND epd.FairValue != 0
      GROUP BY epd.AsOfDate, 
            epd.UnderlyBBYellowKey,
            epd.StratName
 
     UPDATE tsp 
        SET tsp.BBYellowKey = REPLACE(tsp.BBYellowKey, 'US Equity', '') 
       FROM #tmpPositions tsp 
 
     UPDATE tsp 
        SET tsp.BBYellowKey = REPLACE(tsp.BBYellowKey, 'Index', '') 
       FROM #tmpPositions tsp 
 
     DELETE tsp 
       FROM #tmpPositions tsp 
	    WHERE ABS(tsp.Quantity) = 0 
 
	   DELETE tsp 
       FROM #tmpPositions tsp 
	    WHERE CHARINDEX('MSA1BIO', tsp.BBYellowKey) != 0 
 
	   DELETE tsp 
       FROM #tmpPositions tsp 
	    WHERE CHARINDEX('MSA1BIO', tsp.BBYellowKey) != 0 
 
    IF @iRst = 1
      BEGIN
        DELETE tsp
          FROM #tmpPositions tsp 
	       WHERE tsp.Strategy NOT IN ('Alpha Long')
      END
        
/* 
 
*/ 
 
      SELECT tsp.AsOfDate AS PortDate, 
             tsp.BBYellowKey AS TickerName, 
             SUM(tsp.Quantity) AS Quantity
        FROM #tmpPositions tsp 
       GROUP BY tsp.AsOfDate, 
             tsp.BBYellowKey 
       ORDER BY tsp.BBYellowKey 
 
   SET NOCOUNT OFF 
 
   END 
GO
