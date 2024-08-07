CREATE PROCEDURE dbo.p_ClearMspbAvailability(
    @AsOfDate             DATE)
 
 /*
  Author:   Lee Kafafian
  Crated:   08/06/2024
  Object:   p_ClearMspbAvailability
  Example:  EXEC dbo.p_ClearMspbAvailability @AsOfDate = '05/24/2024'
 */
  
 AS 

  BEGIN

    SET NOCOUNT ON
     
    DELETE mbd
      FROM dbo.MspbSLAvailability mbd 
     WHERE mbd.AsOfDate = @AsOfDate

    SET NOCOUNT OFF

  END

GO

GRANT EXECUTE ON dbo.p_ClearMspbAvailability TO PUBLIC
GO
