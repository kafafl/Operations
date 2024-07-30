SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[p_GetBasketCompsOverN](
  @AsOfDate       DATE NULL = DEFAULT,
  @BasketName     VARCHAR(255) = 'MSA1BIOH',
  @OverWeight     FLOAT = 1.00)

   /*
  Author:   Lee Kafafian
  Crated:   05/28/2024
  Object:   p_GetBasketCompsOverN
  Example:  EXEC dbo.p_GetBasketCompsOverN @AsOfDate = '07/29/2024', @BasketName = 'MSA1BIOH', @OverWeight = 1.00 
            EXEC dbo.p_GetBasketCompsOverN @AsOfDate = '07/29/2024', @BasketName = 'MSA14568', @OverWeight = 4.00 
 */
  
 AS 

   BEGIN

   SET NOCOUNT ON

      IF @AsOfDate IS NULL
        BEGIN
          SELECT TOP 1 @AsOfDate = msb.AsOfDate FROM dbo.MspbBasketDetails msb ORDER BY msb.AsOfDate DESC
        END

    CREATE TABLE #tmpBasketLiquidity(
      AsOfDate               DATE,
      BasketName             VARCHAR(255),
      CompName               VARCHAR(255),
      Shares                 FLOAT,
      CompWeight             FLOAT,
      bUpdated               BIT NOT NULL DEFAULT 0)

    DECLARE @MktDate AS DATE

     INSERT INTO #tmpBasketLiquidity(
            AsOfDate,
            BasketName,
            CompName,
            Shares,
            CompWeight)
     SELECT msb.AsOfDate,
            msb.BasketTicker,
            msb.CompBbg,
            msb.CompExpShares,
            msb.PctWeight
       FROM dbo.MspbBasketDetails msb
      WHERE msb.AsOfDate = @AsOfDate
        AND CHARINDEX(@BasketName, msb.BasketTicker) != 0


/*   RETURN RESULTS WITH A BASKET WEIGHT ABOVE 1%    */

     SELECT TOP 100
            tbl.AsOfDate,
            tbl.BasketName AS Basket,
            tbl.CompName AS Ticker,
            tbl.Shares,
            tbl.CompWeight
       FROM #tmpBasketLiquidity tbl
      WHERE ABS(tbl.CompWeight) >= CAST(@OverWeight AS FLOAT)
      ORDER BY ABS(tbl.CompWeight) DESC


    SET NOCOUNT OFF

   END
GO


GRANT EXECUTE ON dbo.p_GetBasketCompsOverN TO PUBLIC
GO