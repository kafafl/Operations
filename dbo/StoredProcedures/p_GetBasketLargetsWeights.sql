SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[p_GetBasketLargestWeights](
  @AsOfDate       DATE NULL = DEFAULT)

   /*
  Author:   Lee Kafafian
  Crated:   05/28/2024
  Object:   p_GetBasketLargestWeights
  Example:  EXEC dbo.p_GetBasketLargestWeights @AsOfDate = '06/12/2024' 
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
               SUBSTRING(msb.CompTicker, 1, CHARINDEX(' ', msb.CompTicker)) AS ConstName,
               msb.PctWeight
          FROM dbo.MspbBasketDetails msb
         WHERE msb.AsOfDate = @AsOfDate
         ORDER BY msb.PctWeight DESC

    SET NOCOUNT OFF

   END
GO
