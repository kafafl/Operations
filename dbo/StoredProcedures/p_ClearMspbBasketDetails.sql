CREATE PROCEDURE dbo.p_ClearMspbBasketDetails(
    @AsOfDate             DATE)
 
 /*
  Author:   Lee Kafafian
  Crated:   05/30/2024
  Object:   p_ClearMspbBasketDetails
  Example:  EXEC dbo.p_ClearMspbBasketDetails @AsOfDate = '05/24/2024'
 */
  
 AS 

  BEGIN

    SET NOCOUNT ON
     
    DELETE mbd
      FROM dbo.MspbBasketDetails mbd 
     WHERE mbd.AsOfDate = @AsOfDate

    SET NOCOUNT OFF

  END

GO

GRANT EXECUTE ON dbo.p_ClearMspbBasketDetails TO PUBLIC
GO
