CREATE PROCEDURE dbo.p_ProcessAmfBiotechFactorReturns( 
    @AsOfDate             DATE, 
    @JobReference         VARCHAR(255)) 
  
 /* 
  Author:   Lee Kafafian 
  Crated:   01/25/2024 
  Object:   p_ProcessRawEstUnivData 
  Example:  EXEC dbo.p_ProcessAmfBiotechFactorReturns @AsOfDate = '02/21/2024' 
 */ 
   
 AS  
 
  BEGIN 
 
    SET NOCOUNT ON

         DELETE reux FROM dbo.AmfBiotechFactorReturns reux WHERE reux.AsOfDate = @AsOfDate AND reux.JobReference = @JobReference 
 
         INSERT INTO dbo.AmfBiotechFactorReturns( 
                AsOfDate, 
                AssetId, 
                AssetName, 
                FactorName, 
                RetValue, 
                JobReference) 
         SELECT @AsOfDate, 
                [Asset ID], 
                [Asset Name], 
                [factor], 
                CAST([value] AS FLOAT), 
                @JobReference 
           FROM [dbo].[zRaw_RiskEstUniverse] reu 
          WHERE [Indent] = 1 
 
    SET NOCOUNT OFF 
 
  END 
 
 GRANT EXECUTE ON dbo.p_ProcessAmfBiotechFactorReturns TO PUBLIC
GO    