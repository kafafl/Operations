USE Operations
GO

ALTER PROCEDURE dbo.p_GetBasketDetails(
    @BasketName VARCHAR(255) ,
    @AsOfDate   DATE NULL = DEFAULT )
 
 /*
  Author: Lee Kafafian
  Crated: 09/25/2023
  Object: p_GetBasketDetails
  Example:  EXEC dbo.p_GetBasketDetails @BasketName = 'MSA1BIO Index'
 */
  
 AS 

   BEGIN

   SET NOCOUNT ON

     IF @AsOfDate IS NULL
       BEGIN
         SELECT TOP 1 @AsOfDate = CAST(bsk.UpdateDate AS DATE) FROM dbo.BasketConstituents bsk WHERE bsk.BasketName = @BasketName  ORDER BY bsk.UpdateDate DESC
       END
/**/
    CREATE TABLE #tmpBasket(
      BasketName      VARCHAR(500),
      ConstName       VARCHAR(500),
      Weights         FLOAT,        /* <-- NEED TO ADD TO DATABASE TABLE  */
      UpdateDate      DATETIME)


     INSERT INTO #tmpBasket(
            BasketName,
            ConstName,
            UpdateDate)
     SELECT bsk.BasketName,
            bsk.ConstName,
            bsk.UpdateDate
       FROM dbo.BasketConstituents bsk
      WHERE bsk.UpdateDate >= @AsOfDate 
        AND bsk.BasketName = @BasketName


     SELECT tbk.BasketName,
            tbk.ConstName,
            MAX(tbk.UpdateDate) AS UpdateDate
       FROM #tmpBasket tbk
     HAVING MAX(tbk.UpdateDate) = MAX(tbk.UpdateDate)
      GROUP BY tbk.BasketName,
            tbk.ConstName

   SET NOCOUNT OFF

   END
   GO

   GRANT EXECUTE ON dbo.p_GetBasketDetails TO PUBLIC
   GO