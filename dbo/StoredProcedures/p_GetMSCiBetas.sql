CREATE PROCEDURE dbo.p_GetMSCiBetas( 
    @AsOfDate             DATE NULL = DEFAULT) 
  
 /* 
  Author: Lee Kafafian 
  Crated: 01/29/2024 
  Object: p_GetMSCiBetas 
  Example:  EXEC dbo.p_GetMSCiBetas @AsOfDate = '01/24/2024' 
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
           MAX(msci.Quantity) AS Quantity, 
           MAX(msci.Price) AS Price, 
           MAX(msci.MktVal) AS MktVal, 
           MAX(msci.WeightMod) AS WeightMod, 
           MAX(msci.MktCorr) AS MktCorr, 
           MAX(msci.BmkCorr) AS BmkCorr
      FROM dbo.MSCiCorrelations msci (NOLOCK) 
     WHERE msci.AsOfDate = @AsOfDate
     GROUP BY msci.AsOfDate, 
           msci.PortfolioName, 
           msci.Ticker, 
           msci.BbgYellowKey, 
           msci.SecName 
     ORDER BY msci.AsOfDate, 
           msci.PortfolioName, 
           msci.Ticker, 
           msci.BbgYellowKey, 
           msci.SecName 
 
 
    SET NOCOUNT OFF 
 
  END 
 