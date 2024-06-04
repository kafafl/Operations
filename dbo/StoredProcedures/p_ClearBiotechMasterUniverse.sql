ALTER PROCEDURE dbo.p_ClearBiotechMasterUniverse(
    @AsOfDate   DATE,
    @Crncy      VARCHAR(255))
 
 /*
  Author:   Lee Kafafian
  Crated:   05/16/2024
  Object:   p_ClearBasketShortUniverse
  Example:  EXEC dbo.p_ClearBiotechMasterUniverse @AsOfDate = '06/04/2024', @Crncy = 'USD'
            EXEC dbo.p_ClearBiotechMasterUniverse @AsOfDate = '06/03/2024', @Crncy = 'CAD'
 */
  
 AS 

  BEGIN

    SET NOCOUNT ON
     
    DELETE bmu
      FROM dbo.BiotechMasterUniverse bmu
     WHERE bmu.AsOfDate = @AsOfDate
       AND bmu.Crncy = @Crncy


    SET NOCOUNT OFF

  END

GO

GRANT EXECUTE ON dbo.p_ClearBiotechMasterUniverse TO PUBLIC
GO
