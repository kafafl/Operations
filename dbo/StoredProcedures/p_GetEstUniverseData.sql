CREATE PROCEDURE dbo.p_GetEstUniverseData(
    @AsOfDate          DATE = NULL)

 /*
  Author:   Lee Kafafian
  Crated:   05/08/2024
  Object:   p_GetEstUniverseData
  Example:  EXEC dbo.p_GetEstUniverseData @AsOfDate = '04/25/2024', 
 */
  
 AS 
  BEGIN
    SET NOCOUNT ON

    DECLARE @JobRef AS VARCHAR(255)

    IF @AsOfDate IS NULL
      BEGIN
          SELECT TOP 1 @AsOfDate = reu.AsOfDate FROM dbo.RiskEstUniverse reu ORDER BY reu.AsOfDate DESC
      END
      SELECT TOP 1 @JobRef = reu.JobReference FROM dbo.RiskEstUniverse reu ORDER BY reu.AsOfDate DESC, reu.CreatedOn DESC

    SELECT reu.IdxRow, 
           reu.AsOfDate,
           reu.AssetId,
           reu.AssetName,
           reu.FactorName,
           reu.RetValue,
           reu.JobReference
      FROM dbo.RiskEstUniverse reu
     WHERE reu.AsOfDate = @AsOfDate 
       AND reu.JobReference = @JobRef  
     ORDER BY reu.IdxRow, 
           reu.AsOfDate,
           reu.AssetId,
           reu.AssetName,
           reu.FactorName,
           reu.RetValue


    SET NOCOUNT OFF
  END
GO

GRANT EXECUTE ON dbo.p_GetEstUniverseData TO PUBLIC
GO      