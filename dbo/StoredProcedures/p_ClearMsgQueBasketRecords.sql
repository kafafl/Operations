CREATE PROCEDURE dbo.p_ClearMsgQueBasketRecords(
    @AsOfDate             DATE)
 
 /*
  Author: Lee Kafafian
  Crated: 01/25/2024
  Object: p_ClearMsgQueBasketRecords
  Example:  EXEC dbo.p_ClearMsgQueBasketRecords @AsOfDate = '01/24/2024'
 */
  
 AS 

  BEGIN

    SET NOCOUNT ON
     
    DELETE msg
      FROM dbo.MsgQueue msg
     WHERE CAST(msg.UpdateDate AS DATE) = @AsOfDate
     AND msg.

    SET NOCOUNT OFF

  END

GO

GRANT EXECUTE ON dbo.p_ClearMsgQueBasketRecords TO PUBLIC
GO