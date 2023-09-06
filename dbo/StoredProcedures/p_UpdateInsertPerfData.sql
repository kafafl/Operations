CREATE PROCEDURE dbo.p_UpdateInsertPerfData(
    @AsOfDate       DATE NULL = DEFAULT,
    @Entity          VARCHAR(255),
    @DailyReturn     FLOAT )
 
 
 /*
  Author: Lee Kafafian
  Crated: 09/05/2023
  Object: p_UpdateInsertPerfData
  Example:  EXEC dbo.p_UpdateInsertPerfData @AsOfDate = '01/02/2023', @Entity = 'AMF', @DailyReturn = 0.01

 */
  
 AS 

  BEGIN
     
    IF EXISTS(SELECT TOP 1 * FROM dbo.PerformanceDetails pdx WHERE pdx.AsOfDate = @AsOfDate AND pdx.Entity = @Entity)
      BEGIN
        UPDATE pdx
           SET pdx.DailyReturn = @DailyReturn
          FROM dbo.PerformanceDetails pdx
         WHERE pdx.AsOfDate = @AsOfDate
           AND pdx.Entity = @Entity   
      END
    ELSE
      BEGIN
        INSERT INTO dbo.PerformanceDetails(
               AsOfDate,
               Entity,
               DailyReturn)
        SELECT @AsOfDate,
               @Entity,
               @DailyReturn
      END

  
  END

GO

GRANT EXECUTE ON dbo.p_UpdateInsertPerfData TO PUBLIC
GO