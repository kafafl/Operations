SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE [dbo].[p_GetAlphaShortBasketOverlapData]( 
    @AsOfDate   DATE NULL = DEFAULT ) 
  
 /* 
  Author:   Lee Kafafian 
  Crated:   06/02/2024 
  Object:   p_GetAlphaShortBasketOverlapData 
  Example:  EXEC dbo.p_GetAlphaShortBasketOverlapData @AsOfDate = '07/09/2024' 
 */ 
   
AS  
 
   BEGIN 
 
    SET NOCOUNT ON 
 
        IF @AsOfDate IS NULL 
          BEGIN 
            SELECT TOP 1 @AsOfDate = CAST(bsk.AsOfDate AS DATE) FROM dbo.MspbBasketDetails bsk ORDER BY bsk.AsOfDate DESC 
          END 
 
            SELECT epd.AsOfDate, 
                   epd.BBYellowKey, 
                   epd.StratName, 
                   COALESCE(epd.Quantity, 0) AS AlphShortShares, 
                   COALESCE(mbd.CompExpShares, 0) AS BasketShares, 
                   COALESCE(mbd.CompExpShares, 0) + COALESCE(epd.Quantity, 0) AS TotalShares 
              FROM dbo.EnfPositionDetails epd 
              JOIN dbo.MspbBasketDetails mbd 
                ON mbd.AsOfDate = epd.AsOfDate 
               AND LTRIM(RTRIM(LEFT(mbd.CompTicker, CHARINDEX(' ', mbd.CompTicker)))) = LTRIM(RTRIM(LEFT(epd.BBYellowKey, CHARINDEX(' ', epd.BBYellowKey))))
             WHERE mbd.AsOfDate = @AsOfDate
               AND epd.StratName IN ('Alpha Short') 
               AND epd.InstrType = 'Equity' 
               AND COALESCE(epd.Quantity, 0) != 0 
             ORDER BY epd.AsOfDate, 
                   epd.BBYellowKey, 
                   epd.StratName 
     
    SET NOCOUNT OFF 
 
   END 

GRANT EXECUTE ON dbo.p_GetAlphaShortBasketOverlapData TO PUBLIC
GO
