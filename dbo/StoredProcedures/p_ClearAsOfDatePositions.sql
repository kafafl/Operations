CREATE PROCEDURE dbo.p_ClearAsOfPositions(
    @AsOfDate             DATE NULL = DEFAULT)
 
 /*
  Author: Lee Kafafian
  Crated: 09/20/2023
  Object: p_ClearAsOfPositions
  Example:  EXEC dbo.p_ClearAsOfPositions @AsOfDate = '09/20/2023'
 */
  
 AS 

  BEGIN
     
    DELETE epd
      FROM dbo.EnfPositionDetails epd 
     WHERE epd.AsOfDate = @AsOfDate

  END

GO

GRANT EXECUTE ON dbo.p_ClearAsOfPositions TO PUBLIC
GO