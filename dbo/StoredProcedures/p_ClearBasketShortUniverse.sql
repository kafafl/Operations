CREATE PROCEDURE dbo.p_ClearBasketShortUniverse
 
 /*
  Author:   Lee Kafafian
  Crated:   05/16/2024
  Object:   p_ClearBasketShortUniverse
  Example:  EXEC dbo.p_ClearBasketShortUniverse 
 */
  
 AS 

  BEGIN

    SET NOCOUNT ON
     
    DELETE bsu
      FROM dbo.BasketShortUniverse bsu

    SET NOCOUNT OFF

  END

GO

GRANT EXECUTE ON dbo.p_ClearBasketShortUniverse TO PUBLIC
GO