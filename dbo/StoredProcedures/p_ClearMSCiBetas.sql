CREATE PROCEDURE dbo.p_ClearMSCiBetas(
    @AsOfDate             DATE)
 
 /*
  Author: Lee Kafafian
  Crated: 01/25/2024
  Object: p_ClearMSCiBetas
  Example:  EXEC dbo.p_ClearMSCiBetas @AsOfDate = '01/24/2024'
 */
  
 AS 

  BEGIN

    SET NOCOUNT ON
     
    DELETE msci
      FROM dbo.MSCiCorrelations msci 
     WHERE msci.AsOfDate = @AsOfDate

    SET NOCOUNT OFF

  END

GO

GRANT EXECUTE ON dbo.p_ClearMSCiBetas TO PUBLIC
GO