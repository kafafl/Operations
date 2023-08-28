CREATE PROCEDURE dbo.p_TakeAction(
    @PortDate   DATE NULL = DEFAULT )
 
 
 /*
  Author: Lee Kafafian
  Crated: 08/25/2023
  Object: p_TakeAction (test power automate)
  Example:  EXEC dbo.p_TakeAction @PortDate = '08/25/2023'
 */
  
 AS 

   BEGIN

     INSERT INTO dbo.tExamples (MyNotes) VALUES ('PROC Connection request at ' + CAST(GETDATE() AS VARCHAR(255)))
  
   END

GO

