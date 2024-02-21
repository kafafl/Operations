CREATE PROCEDURE dbo.p_ClearStatisticalBetas(
    @AsOfDate             DATE)
 
 /*
  Author: Lee Kafafian
  Crated: 01/25/2024
  Object: p_ClearStatisticalBetas
  Example:  EXEC dbo.p_ClearStatisticalBetas @AsOfDate = '02/21/2024'
 */
  
 AS 

  BEGIN

    SET NOCOUNT ON
     
    DELETE stat
      FROM dbo.StatisicalBetaValues stat 
     WHERE stat.AsOfDate = @AsOfDate

    SET NOCOUNT OFF

  END

GO

GRANT EXECUTE ON dbo.p_ClearStatisticalBetas TO PUBLIC
GO