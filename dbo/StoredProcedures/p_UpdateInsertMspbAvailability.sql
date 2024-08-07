CREATE PROCEDURE dbo.p_UpdateInsertMspbAvailability(
    @AsOfDate                    DATE,
    @Identifier                  VARCHAR(255),
    @Source                      VARCHAR(255),
    @SourceFile                  VARCHAR(255),
    @AvailAmount                 FLOAT,
    @SLRate                      FLOAT,
    @SLRateType                  VARCHAR(255))
 
 
 /*
  Author:   Lee Kafafian
  Crated:   05/30/2024
  Object:   p_UpdateInsertMspbAvailability
  Example:  EXEC dbo.p_UpdateInsertMspbAvailability ....
 */
  
 AS 
  BEGIN
    SET NOCOUNT ON

        INSERT INTO dbo.MspbSLAvailability(
               AsOfDate,
               Identifier,
               DataSource,
               SourceFile,
               AvailAmount,
               SLRate,
               SLRateType) 
        SELECT @AsOfDate,
               @Identifier,
               @Source,
               @SourceFile,
               @AvailAmount,
               @SLRate,
               @SLRateType

    SET NOCOUNT OFF
  END
GO

GRANT EXECUTE ON dbo.p_UpdateInsertMspbAvailability TO PUBLIC
GO
