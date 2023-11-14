CREATE PROCEDURE dbo.p_UpdateInsertFactorReturns(
    @dtNumDate         VARCHAR(50),
    @FactorName        VARCHAR(255),
    @FactorValue       FLOAT)
 
 
 /*
  Author:   Lee Kafafian
  Crated:   10/20/2023
  Object:   p_UpdateInsertFactorReturns
  Example:  EXEC dbo.p_UpdateInsertFactorReturns @dtNumDate = '201311', @FactorName = 'EFMUSATRD_GROWTH', @FactorValue = -.001019703
 */
  
 AS 

  BEGIN

    SET NOCOUNT ON


/*  MANAGE NUMDATE  */
    DECLARE @CalDate AS DATE
    DECLARE @iYear AS VARCHAR(15) = LEFT(@dtNumDate, 4)
    DECLARE @iMonth AS VARCHAR(15)
     
    IF LEN(@dtNumDate) = 6
      BEGIN
        SELECT @iMonth = RIGHT(@dtNumDate, 2)
      END 
    
    IF LEN(@dtNumDate) = 5
      BEGIN
        SELECT @iMonth = '0' + RIGHT(@dtNumDate, 1)
      END 
    
    SELECT @CalDate = EOMONTH(CAST(@iYear + '-' + @iMonth + '-' + '1' AS DATE))
    
    IF EXISTS(SELECT TOP 1 * FROM dbo.BarraMonthlyFactorReturns bmf WHERE bmf.NumDate = @dtNumDate AND FactorName = @FactorName)
      BEGIN
        UPDATE bmf
           SET bmf.FactorValue = @FactorValue
          FROM dbo.BarraMonthlyFactorReturns bmf
         WHERE bmf.NumDate = @dtNumDate
           AND bmf.FactorName = @FactorName  
      END
    ELSE
      BEGIN
        INSERT INTO dbo.BarraMonthlyFactorReturns(
               NumDate,
               FactorName,
               FactorValue) 
        SELECT @dtNumDate,
               @FactorName,
               @FactorValue
      END
 

    /* ADD POST RECORD MANAGEMENT END OF MONTH UPDATE STATEMENET  */
       UPDATE bmf
          SET bmf.AsOfDate = @CalDate
         FROM dbo.BarraMonthlyFactorReturns bmf
        WHERE bmf.NumDate = @dtNumDate
          AND bmf.FactorName = @FactorName     

    SET NOCOUNT OFF
  
  END

GO

GRANT EXECUTE ON dbo.p_UpdateInsertFactorReturns TO PUBLIC
GO

