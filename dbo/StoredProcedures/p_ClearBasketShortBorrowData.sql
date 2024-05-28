CREATE PROCEDURE dbo.p_ClearBasketShortBorrowData
 
 /*
  Author:   Lee Kafafian
  Crated:   05/16/2024
  Object:   p_ClearBasketShortUniverse
  Example:  EXEC dbo.p_ClearBasketShortBorrowData 
 */
  
 AS 

  BEGIN

    SET NOCOUNT ON
     
    DELETE sbd
      FROM dbo.BasketShortBorrowData sbd

    SET NOCOUNT OFF

  END

GO

GRANT EXECUTE ON dbo.p_ClearBasketShortBorrowData TO PUBLIC
GO