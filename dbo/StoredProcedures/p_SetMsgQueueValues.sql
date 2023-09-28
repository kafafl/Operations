USE Operations
GO

ALTER PROCEDURE dbo.p_SetMsgQueueValues(
     @MsgValue        VARCHAR(5000),
     @MsgPriority     INT,
     @MsgCatagory     VARCHAR(500),
     @MsgInTs         DATETIME)
 
 /*
  Author: Lee Kafafian
  Crated: 09/25/2023
  Object: p_SetMsgQueueValues
  Example:  EXEC dbo.p_SetMsgQueueValues @MsgValue = 'Here is a message.', @MsgPriority = 1, @MsgCatagory = 'Basket Monitor', @MsgInTs = '09/24/2023 09:35:19' 
 */
  
 AS 
   BEGIN
   SET NOCOUNT ON


    INSERT INTO dbo.MsgQueue(
           MsgValue,
           MsgPriority,
           MsgCatagory,
           MsgInTs)
    SELECT @MsgValue,
           @MsgPriority,
           @MsgCatagory,
           @MsgInTs


   SET NOCOUNT OFF
   END
GO


GRANT EXECUTE ON dbo.p_SetMsgQueueValues TO PUBLIC
GO
