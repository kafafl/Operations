SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[p_ClearMsgQueBasketRecords](
    @AsOfDate             DATE)
 
 /*
  Author: Lee Kafafian
  Crated: 01/25/2024
  Object: p_ClearMsgQueBasketRecords
  Example:  EXEC dbo.p_ClearMsgQueBasketRecords @AsOfDate = '05/12/2024'
 */
  
 AS 

  BEGIN

    SET NOCOUNT ON
     
    DELETE msg
      FROM dbo.MsgQueue msg
     WHERE CAST(msg.MsgInTs AS DATE) = @AsOfDate
       AND CHARINDEX('Basket Monitor', msg.MsgCatagory) != 0

    SET NOCOUNT OFF

  END

GO

GRANT EXECUTE ON dbo.p_ClearMsgQueBasketRecords TO PUBLIC
GO