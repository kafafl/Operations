CREATE PROCEDURE dbo.p_GetMSCiBetas(
    @AsOfDate             DATE NULL = DEFAULT)
 
 /*
  Author: Lee Kafafian
  Crated: 01/29/2024
  Object: p_GetMSCiBetas
  Example:  EXEC dbo.p_GetMSCiBetas @AsOfDate = '01/26/2024'
            EXEC dbo.p_GetMSCiBetas
 */
  
 AS 

  BEGIN

    SET NOCOUNT ON

    IF @AsOfDate IS NULL
      BEGIN
        SELECT TOP 1 @AsOfDate = msx.AsOfDate FROM dbo.MSCiCorrelations msx (NOLOCK) ORDER BY msx.AsOfDate DESC
      END

     
    SELECT msci.AsOfDate,
           msci.PortfolioName,
           msci.Ticker,
           msci.BbgYellowKey,
           msci.SecName,
           msci.Quantity,
           msci.Price,
           msci.MktVal,
           msci.WeightMod,
           msci.MktCorr,
           msci.BmkCorr
      FROM dbo.MSCiCorrelations msci (NOLOCK)
     WHERE msci.AsOfDate = @AsOfDate
     ORDER BY msci.AsOfDate,
           msci.PortfolioName,
           msci.Ticker,
           msci.BbgYellowKey,
           msci.SecName


    SET NOCOUNT OFF

  END

GO

GRANT EXECUTE ON dbo.p_GetMSCiBetas TO PUBLIC
GO