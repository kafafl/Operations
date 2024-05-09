CREATE PROCEDURE dbo.p_UpdateInsertFacExpRets(
    @AsOfDate          DATE,
    @AssetIdBarra      VARCHAR(255),
    @AssetNameBarra    VARCHAR(255),
    @FactorNameBarra   VARCHAR(255),
    @RetVal            FLOAT,
    @JobReference      VARCHAR(255))
 

 /*
  Author:   Lee Kafafian
  Crated:   04/26/2024
  Object:   p_UpdateInsertFacExpRets
  Example:  EXEC dbo.p_UpdateInsertFacExpRets @AsOfDate = '04/25/2024', 
 */
  
 AS 
  BEGIN
    SET NOCOUNT ON


    IF EXISTS(SELECT TOP 1 * FROM dbo.RiskEstUnivFactExpRetDetail eur WHERE eur.AsOfDate = @AsOfDate AND eur.AssetIdBarra = @AssetIdBarra AND eur.FactorNameBarra = @FactorNameBarra)
      BEGIN
        UPDATE eur
           SET eur.RetVal = @RetVal,
               eur.JobReference = @JobReference
          FROM dbo.RiskEstUnivFactExpRetDetail eur
         WHERE eur.AsOfDate = @AsOfDate
           AND eur.AssetIdBarra = @AssetIdBarra
           AND eur.FactorNameBarra = @FactorNameBarra 
      END
    ELSE
      BEGIN
        INSERT INTO dbo.RiskEstUnivFactExpRetDetail(
               AsOfDate,
               AssetIdBarra,
               AssetNameBarra,
               FactorNameBarra,
               RetVal,
               JobReference) 
        SELECT @AsOfDate,
               @AssetIdBarra,
               @AssetNameBarra,
               @FactorNameBarra,
               @RetVal,
               @JobReference
      END
   
    SET NOCOUNT OFF
  END
GO

GRANT EXECUTE ON dbo.p_UpdateInsertFacExpRets TO PUBLIC
GO
