USE Operations
GO

ALTER PROCEDURE dbo.p_GetBasketDetails(
    @BasketName VARCHAR(255),
    @AsOfDate   DATE NULL = DEFAULT )
 
 /*
  Author:   Lee Kafafian
  Crated:   09/25/2023
  Object:   p_GetBasketDetails
  Example:  EXEC dbo.p_GetBasketDetails @BasketName = 'MSA1BIOH'
 */
  
 AS 

   BEGIN

   SET NOCOUNT ON

     IF @AsOfDate IS NULL
       BEGIN
         SELECT TOP 1 @AsOfDate = bsk.AsOfDate FROM dbo.MspbBasketDetails bsk WHERE bsk.BasketTicker = @BasketName  ORDER BY bsk.AsOfDate DESC
       END
/**/
    CREATE TABLE #tmpBasket(
      AsOfDate        DATE,
      BasketName      VARCHAR(500),
      ConstName       VARCHAR(500),
      Weights         FLOAT,        /* <-- NEED TO ADD TO DATABASE TABLE  */
      UpdateDate      DATETIME)


     INSERT INTO #tmpBasket(
            AsOfDate,
            BasketName,
            ConstName,
            UpdateDate)
     SELECT bsk.AsOfDate,
            bsk.BasketTicker + ' Index',
            bsk.CompTicker + ' Equity',
            bsk.AsOfDate
       FROM dbo.MspbBasketDetails bsk
      WHERE bsk.AsOfDate = @AsOfDate 
        AND bsk.BasketTicker = @BasketName

     SELECT tbk.BasketName,
            tbk.ConstName,
            MAX(tbk.UpdateDate) AS UpdateDate
       FROM #tmpBasket tbk
      GROUP BY tbk.BasketName,
            tbk.ConstName
     HAVING MAX(tbk.UpdateDate) = MAX(tbk.UpdateDate)
     
   SET NOCOUNT OFF

   END
   GO

   GRANT EXECUTE ON dbo.p_GetBasketDetails TO PUBLIC
   GO

