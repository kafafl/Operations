
CREATE VIEW dbo.vw_Biotech400FactorReturns

  AS

     SELECT bfx.AsOfDate,
            bfx.AsssetId,
            bfx.AssetName,
            MAX(bfx.[Beta Exp]) AS [Beta Exp],
            MAX(bfx.[Carbon Efficiency Exp]) AS [Carbon Efficiency Exp],
            MAX(bfx.[Dividend Yield Exp]) AS [Dividend Yield Exp],
            MAX(bfx.[Earnings Quality Exp]) AS [Earnings Quality Exp],
            MAX(bfx.[Earnings Variability Exp]) AS [Earnings Variability Exp],
            MAX(bfx.[Earnings Yield Exp]) AS [Earnings Yield Exp],
            MAX(bfx.[ESG Exp]) AS [ESG Exp],
            MAX(bfx.[Growth Exp]) AS [Growth Exp],
            MAX(bfx.[Investment Quality Exp]) AS [Investment Quality Exp],
            MAX(bfx.[Leverage Exp]) AS [Leverage Exp],
            MAX(bfx.[Liquidity Exp]) AS [Liquidity Exp],
            MAX(bfx.[Long-Term Reversal Exp]) AS [Long-Term Reversal Exp],
            MAX(bfx.[Mid Capitalization Exp]) AS [Mid Capitalization Exp],
            MAX(bfx.[Momentum Exp]) AS [Momentum Exp],
            MAX(bfx.[Profitability Exp]) AS [Profitability Exp],
            MAX(bfx.[Residual Volatility Exp]) AS [Residual Volatility Exp],
            MAX(bfx.[Short Interest Exp]) AS [Short Interest Exp],
            MAX(bfx.[Size Exp]) AS [Size Exp],
            MAX(bfx.[Value Exp]) AS [Value Exp],
            bfx.JobReference
       FROM (SELECT bfr.AsOfDate,
                    bfr.AssetId AS AsssetId,
                    bfr.AssetName,
                    bfr.JobReference,            
                    CASE WHEN bfr.FactorName = 'Beta Exp' THEN bfr.RetValue END AS [Beta Exp],
                    CASE WHEN bfr.FactorName = 'Carbon Efficiency Exp' THEN bfr.RetValue END AS [Carbon Efficiency Exp],
                    CASE WHEN bfr.FactorName = 'Dividend Yield Exp' THEN bfr.RetValue END AS [Dividend Yield Exp],
                    CASE WHEN bfr.FactorName = 'Earnings Quality Exp' THEN bfr.RetValue END AS [Earnings Quality Exp],
                    CASE WHEN bfr.FactorName = 'Earnings Variability Exp' THEN bfr.RetValue END AS [Earnings Variability Exp],
                    CASE WHEN bfr.FactorName = 'Earnings Yield Exp' THEN bfr.RetValue END AS [Earnings Yield Exp],
                    CASE WHEN bfr.FactorName = 'ESG Exp' THEN bfr.RetValue END AS [ESG Exp],
                    CASE WHEN bfr.FactorName = 'Growth Exp' THEN bfr.RetValue END AS [Growth Exp],
                    CASE WHEN bfr.FactorName = 'Investment Quality Exp' THEN bfr.RetValue END AS [Investment Quality Exp],
                    CASE WHEN bfr.FactorName = 'Leverage Exp' THEN bfr.RetValue END AS [Leverage Exp],
                    CASE WHEN bfr.FactorName = 'Liquidity Exp' THEN bfr.RetValue END AS [Liquidity Exp],
                    CASE WHEN bfr.FactorName = 'Long-Term Reversal Exp' THEN bfr.RetValue END AS [Long-Term Reversal Exp],
                    CASE WHEN bfr.FactorName = 'Mid Capitalization Exp' THEN bfr.RetValue END AS [Mid Capitalization Exp],
                    CASE WHEN bfr.FactorName = 'Momentum Exp' THEN bfr.RetValue END AS [Momentum Exp],
                    CASE WHEN bfr.FactorName = 'Profitability Exp' THEN bfr.RetValue END AS [Profitability Exp],
                    CASE WHEN bfr.FactorName = 'Residual Volatility Exp' THEN bfr.RetValue END AS [Residual Volatility Exp],
                    CASE WHEN bfr.FactorName = 'Short Interest Exp' THEN bfr.RetValue END AS [Short Interest Exp],
                    CASE WHEN bfr.FactorName = 'Size Exp' THEN bfr.RetValue END AS [Size Exp],
                    CASE WHEN bfr.FactorName = 'Value Exp' THEN bfr.RetValue END AS [Value Exp]            
              FROM dbo.AmfBiotechFactorReturns bfr)bfx
      GROUP BY bfx.AsOfDate,
            bfx.AsssetId,
            bfx.AssetName,
            bfx.JobReference


/*

GRANT SELECT ON dbo.vw_Biotech400FactorReturns TO PUBLIC
GO

*/