SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE dbo.p_GetBasketMostIlliquid(
  @AsOfDate       DATE NULL = DEFAULT,
  @TopN           INT NULL = DEFAULT)

   /*
  Author:   Lee Kafafian
  Crated:   05/28/2024
  Object:   p_GetBasketMostIlliquid
  Example:  EXEC dbo.p_GetBasketMostIlliquid @AsOfDate = '06/26/2024', @TopN = 5 
 */
  
 AS 

   BEGIN

   SET NOCOUNT ON

      IF @AsOfDate IS NULL
        BEGIN
          SELECT TOP 1 @AsOfDate = msb.AsOfDate FROM dbo.MspbBasketDetails msb ORDER BY msb.AsOfDate DESC
        END
      
      IF @TopN IS NULL
        BEGIN
          SELECT @TopN = 5
        END

    CREATE TABLE #tmpBasketLiquidity(
      AsOfDate               DATE,
      BasketName             VARCHAR(255),
      CompName               VARCHAR(255),
      Shares                 FLOAT,
      AvgVolume30d           FLOAT,
      ADV30Day               FLOAT,
      bUpdated               BIT NOT NULL DEFAULT 0)

    DECLARE @MktDate AS DATE

     INSERT INTO #tmpBasketLiquidity(
            AsOfDate,
            BasketName,
            CompName,
            Shares)
     SELECT msb.AsOfDate,
            msb.BasketTicker,
            msb.CompBbg,
            msb.CompExpShares 
       FROM dbo.MspbBasketDetails msb
      WHERE msb.AsOfDate = @AsOfDate


/*   ADD LIQUIDITY MARKET DATA    */
     SELECT TOP 1 @MktDate =  mkd.AsOfDate
       FROM dbo.AmfMarketData mkd
      WHERE mkd.DataSource = 'Bloomberg'
        AND mkd.PositionIdType  = 'BloombergTicker'
        AND mkd.TagMnemonic = 'VOLUME_AVG_10D'
      ORDER BY mkd.AsOfDate DESC


     UPDATE tbl
        SET tbl.CompName = REPLACE(tbl.CompName,' UN',' US')
       FROM #tmpBasketLiquidity tbl 
      WHERE CHARINDEX(' UN', tbl.CompName) != 0

     UPDATE tbl
        SET tbl.CompName = REPLACE(tbl.CompName,' UA',' US')
       FROM #tmpBasketLiquidity tbl 
      WHERE CHARINDEX(' UA', tbl.CompName) != 0


     UPDATE tbl
        SET tbl.AvgVolume30d = mkd.MdValue,
            tbl.ADV30Day = CASE WHEN mkd.MdValue IS NOT NULL AND mkd.MdValue != 0 THEN tbl.Shares / mkd.MdValue ELSE NULL END,
            tbl.bUpdated = 1
       FROM #tmpBasketLiquidity tbl
       JOIN dbo.AmfMarketData mkd
         ON CHARINDEX(tbl.CompName, mkd.PositionId) != 0
      WHERE mkd.AsOfDate = @MktDate
        AND mkd.DataSource = 'Bloomberg'
        AND mkd.PositionIdType  = 'BloombergTicker'
        AND mkd.TagMnemonic = 'VOLUME_AVG_10D'

     SELECT TOP 5
            tbl.AsOfDate,
            tbl.BasketName AS Basket,
            tbl.CompName AS Ticker,
            tbl.Shares,
            tbl.AvgVolume30d,
            tbl.ADV30Day,
            @MktDate AS VolumeDate 
       FROM #tmpBasketLiquidity tbl
      WHERE tbl.ADV30Day IS NOT NULL
      ORDER BY tbl.ADV30Day ASC


    SET NOCOUNT OFF

   END
GO

GRANT EXECUTE ON dbo.p_GetBasketMostIlliquid TO PUBLIC
GO



/*
    SELECT tbl.AsOfDate,
           tbl.BasketName AS Basket,
           tbl.CompName AS Ticker,
           tbl.Shares,
           tbl.AvgVolume30d,
           tbl.ADV30Day 
      FROM #tmpBasketLiquidity tbl
     WHERE tbl.ADV30Day IS NULL
     ORDER BY tbl.ADV30Day ASC
*/

