CREATE PROCEDURE dbo.p_ProcessRawEstUnivData(
    @AsOfDate             DATE NULL,
    @JobReference         VARCHAR(255) NULL)
 
 /*
  Author: Lee Kafafian
  Crated: 01/25/2024
  Object: p_ProcessRawEstUnivData
  Example:  EXEC dbo.p_ProcessRawEstUnivData @AsOfDate = '05/08/2024', @JobReference = 'LKJOIONLKoijlkniudfh*9987gkj'
 */
  
 AS 

  BEGIN

    SET NOCOUNT ON
    
         DELETE reux FROM dbo.RiskEstUniverse reux WHERE reux.AsOfDate = @AsOfDate AND reux.JobReference = @JobReference

         INSERT INTO dbo.RiskEstUniverse(
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

GO

GRANT EXECUTE ON dbo.p_ProcessRawEstUnivData TO PUBLIC
GO    