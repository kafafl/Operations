ALTER PROCEDURE dbo.p_ClearMarketMasterUniverse(
    @AsOfDate          DATE,
    @ParentEntity      VARCHAR(255))
 
 /*
  Author:   Lee Kafafian
  Crated:   08/01/2024
  Object:   p_ClearMarketMasterUniverse
  Example:  EXEC dbo.p_ClearMarketMasterUniverse @AsOfDate = '08/01/2024', @Crncy = 'RTY'
            EXEC dbo.p_ClearMarketMasterUniverse @AsOfDate = '06/03/2024', @Crncy = 'CAD'
 */
  
 AS 

  BEGIN

    SET NOCOUNT ON
     
    DELETE bmu
      FROM dbo.MarketMasterUniverse bmu
     WHERE bmu.AsOfDate = @AsOfDate
       AND bmu.ParentEntity = @ParentEntity


    SET NOCOUNT OFF

  END

GO

GRANT EXECUTE ON dbo.p_ClearMarketMasterUniverse TO PUBLIC
GO