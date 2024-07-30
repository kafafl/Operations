SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[p_GetBasketLargestWeights](
  @AsOfDate       DATE NULL = DEFAULT,
  @BasketName     VARCHAR(255) = 'MSA1BIOH')

   /*
  Author:   Lee Kafafian
  Crated:   05/28/2024
  Object:   p_GetBasketLargestWeights
  Example:  EXEC dbo.p_GetBasketLargestWeights @AsOfDate = '07/29/2024', @BasketName = 'MSA1BIOH'
            EXEC dbo.p_GetBasketLargestWeights @AsOfDate = '07/29/2024', @BasketName = 'MSA14568'
 */
  
 AS 

   BEGIN

   SET NOCOUNT ON

      IF @AsOfDate IS NULL
        BEGIN
          SELECT TOP 1 @AsOfDate = msb.AsOfDate FROM dbo.MspbBasketDetails msb ORDER BY msb.AsOfDate DESC
        END

      DECLARE @Tomorrow AS DATE = DATEADD(d, 1, @AsOfDate)


        SELECT TOP 10 
               REPLACE(msb.BasketTicker, ' Index', '') AS BasketName,
               msb.CompName AS ConstituentName,
               SUBSTRING(msb.CompTicker, 1, CHARINDEX(' ', msb.CompTicker)) AS ConstTicker,
               msb.PctWeight AS BasketWght
          FROM dbo.MspbBasketDetails msb
         WHERE msb.AsOfDate = @AsOfDate
           AND REPLACE(msb.BasketTicker, ' Index', '') = @BasketName
         ORDER BY msb.PctWeight DESC

    SET NOCOUNT OFF

   END
GO

GRANT EXECUTE ON dbo.p_GetBasketLargestWeights TO PUBLIC
GO