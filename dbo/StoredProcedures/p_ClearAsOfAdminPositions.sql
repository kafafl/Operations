CREATE PROCEDURE dbo.p_ClearAsOfAdminPositions(
    @AsOfDate             DATE NULL = DEFAULT)
 
 /*
  Author: Lee Kafafian
  Crated: 09/20/2023
  Object: p_ClearAsOfAdminPositions
  Example:  EXEC dbo.p_ClearAsOfAdminPositions @AsOfDate = '10/12/2023'
 */
  
 AS 

  BEGIN

    SET NOCOUNT ON
     
    DELETE apd
      FROM dbo.AdminPositionDetails apd 
     WHERE apd.AsOfDate = @AsOfDate


    SET NOCOUNT OFF

  END

GO

GRANT EXECUTE ON dbo.p_ClearAsOfAdminPositions TO PUBLIC
GO