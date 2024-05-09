CREATE PROCEDURE dbo.p_ClearRawEstUnivTable
 
 /*
  Author:   Lee Kafafian
  Crated:   05/09/2024
  Object:   p_ClearRawEstUnivTable
  Example:  EXEC dbo.p_ClearRawEstUnivTable 
 */
  
 AS 
  BEGIN
    SET NOCOUNT ON

      TRUNCATE TABLE [dbo].[zRaw_RiskEstUniverse]

    SET NOCOUNT OFF
  END
GO

GRANT EXECUTE ON dbo.p_ClearRawEstUnivTable TO PUBLIC
GO

