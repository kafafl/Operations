ALTER PROCEDURE dbo.p_UpdateInsertTagData(
    @AsOfDate          DATE NULL = DEFAULT,
    @EntityTag         VARCHAR(255),
    @PositionId        VARCHAR(255),
    @PositionName      VARCHAR(500),
    @PositionStrategy  VARCHAR(255),
    @TagReference      VARCHAR(255),
    @TagValue          VARCHAR(255))
 
 
 /*
  Author:   Lee Kafafian
  Crated:   07/09/2024
  Object:   p_UpdateInsertTagData
  Example:  EXEC dbo.p_UpdateInsertTagData @AsOfDate = '07/09/2024', @EntityTag = 'AMF', @PositionId = 'ABEO US Equity', @PositionName = 'ABEONA THERAPEUTICS INC', @PositionStrategy = 'MSA1BIO', @TagReference = 'Therapeutic Area', @TagValue = 'GENETIC MEDICINE'

 */
  
 AS 

  BEGIN

    SET NOCOUNT ON 

      IF EXISTS(SELECT TOP 1 * FROM dbo.AmfPortTagging apt WHERE apt.AsOfDate = @AsOfDate AND apt.EntityTag = @EntityTag AND apt.PositionId = @PositionId AND apt.TagReference = @TagReference)
        BEGIN
         UPDATE apt
            SET apt.TagValue = @TagValue,
                apt.PositionStrategy = @PositionStrategy
           FROM dbo.AmfPortTagging apt
          WHERE apt.AsOfDate = @AsOfDate
            AND apt.EntityTag = @EntityTag 
            AND apt.PositionId = @PositionId 
            AND apt.TagReference = @TagReference 
        END
      ELSE
        BEGIN
          INSERT INTO dbo.AmfPortTagging(
                 AsOfDate,
                 EntityTag,
                 PositionId,
                 PositionName,
                 PositionStrategy,
                 TagReference,
                 TagValue) 
          SELECT @AsOfDate,
                 @EntityTag,
                 @PositionId,
                 @PositionName,
                 @PositionStrategy,
                 @TagReference,
                 @TagValue
        END

    SET NOCOUNT OFF
  
  END

GO

GRANT EXECUTE ON dbo.p_UpdateInsertTagData TO PUBLIC
GO