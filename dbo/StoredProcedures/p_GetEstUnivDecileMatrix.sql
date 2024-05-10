CREATE PROCEDURE dbo.p_GetEstUnivDecileMatrix(
    @AsOfDate          DATE = NULL)

 /*
  Author:   Lee Kafafian
  Crated:   05/08/2024
  Object:   p_GetEstUniverseData
  Example:  EXEC p_GetEstUnivDecileMatrix @AsOfDate = '05/08/2024'
 */
  
 AS 
  BEGIN
    SET NOCOUNT ON

    CREATE TABLE #tmpEstUnivMatrix(
      AsOfDate          DATE,
      FactorName        VARCHAR(255),
      [90th Percentile] FLOAT,
      [80th Percentile] FLOAT,
      [70th Percentile] FLOAT,
      [60th Percentile] FLOAT,
      [50th Percentile] FLOAT,
      [40th Percentile] FLOAT,
      [30th Percentile] FLOAT,
      [20th Percentile] FLOAT,
      [10th Percentile] FLOAT)

      CREATE TABLE #tmpFactorList(
        FactorName     VARCHAR(255),
        bProcessed     BIT DEFAULT 0)


      DECLARE @JobRef AS VARCHAR(255)
      DECLARE @FactorName AS VARCHAR(5000)

      IF @AsOfDate IS NULL
        BEGIN
          SELECT TOP 1 @AsOfDate = reu.AsOfDate FROM dbo.RiskEstUniverse reu ORDER BY reu.AsOfDate DESC
        END
        SELECT TOP 1 @JobRef = reu.JobReference FROM dbo.RiskEstUniverse reu WHERE @AsOfDate = @AsOfDate ORDER BY reu.CreatedOn DESC

        INSERT INTO #tmpFactorList(
               FactorName)
        SELECT reu.FactorName 
          FROM dbo.RiskEstUniverse reu
         WHERE reu.AsOfDate = @AsOfDate
           AND reu.JobReference = @JobRef
         GROUP BY reu.AsOfDate, reu.FactorName, reu.JobReference

        WHILE EXISTS(SELECT TOP 1 reu.FactorName FROM #tmpFactorList reu WHERE reu.bProcessed = 0 ORDER BY reu.FactorName)
          BEGIN
            SELECT TOP 1 @FactorName = reu.FactorName FROM #tmpFactorList reu WHERE reu.bProcessed = 0 ORDER BY reu.FactorName

            PRINT(@FactorName)

            INSERT #tmpEstUnivMatrix(
                   AsOfDate,
                   FactorName,
                   [90th Percentile],
                   [80th Percentile],
                   [70th Percentile],
                   [60th Percentile],
                   [50th Percentile],
                   [40th Percentile],
                   [30th Percentile],
                   [20th Percentile],
                   [10th Percentile])
            SELECT DISTINCT @AsOfDate,
                   reu.FactorName,
                   percentile_cont(0.9) within group (order by [RetValue]) over () AS [90%],
                   percentile_cont(0.8) within group (order by [RetValue]) over () AS [80%],
                   percentile_cont(0.7) within group (order by [RetValue]) over () AS [70%],
                   percentile_cont(0.6) within group (order by [RetValue]) over () AS [60%],
                   percentile_cont(0.5) within group (order by [RetValue]) over () AS [50%],
                   percentile_cont(0.4) within group (order by [RetValue]) over () AS [40%],
                   percentile_cont(0.3) within group (order by [RetValue]) over () AS [30%],
                   percentile_cont(0.2) within group (order by [RetValue]) over () AS [20%],
                   percentile_cont(0.1) within group (order by [RetValue]) over () AS [10%]
              FROM dbo.RiskEstUniverse reu
             WHERE reu.FactorName = @FactorName
               AND reu.AsOfDate = @AsOfDate
               AND reu.JobReference = @JobRef

             UPDATE reu
                SET reu.bProcessed = 1
               FROM #tmpFactorList reu
              WHERE reu.FactorName = @FactorName

          END

            SELECT AsOfDate,
                   FactorName,
                   [90th Percentile],
                   [80th Percentile],
                   [70th Percentile],
                   [60th Percentile],
                   [50th Percentile],
                   [40th Percentile],
                   [30th Percentile],
                   [20th Percentile],
                   [10th Percentile]
              FROM #tmpEstUnivMatrix


    SET NOCOUNT OFF
  END
GO

GRANT EXECUTE ON dbo.p_GetEstUnivDecileMatrix TO PUBLIC
GO 