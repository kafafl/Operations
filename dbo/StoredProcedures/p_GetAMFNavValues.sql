USE Operations
GO

ALTER PROCEDURE dbo.p_GetAMFNavValues(
    @EntityName VARCHAR(255) NULL = DEFAULT ,
    @AsOfDate   DATE NULL = DEFAULT,
    @BegDate    DATE NULL = DEFAULT )
 
 /*
   Author:  Lee Kafafian
  Created:  11/27/2023
  Updated:  12/12/2023 by LK
   Object:  p_GetAMFNavValues
  Example:  EXEC dbo.p_GetAMFNavValues @AsOfDate = '01/10/2024'
            EXEC dbo.p_GetAMFNavValues @AsOfDate = '11/22/2023', @EntityName = 'AMF NAV'
            EXEC dbo.p_GetAMFNavValues @BegDate = '11/20/2023', @AsOfDate = '01/08/2024', @EntityName = 'AMF NAV'

 */
  
 AS 

   BEGIN

   SET NOCOUNT ON

    IF @EntityName IS NULL
      BEGIN
        SELECT @EntityName = 'AMF NAV'
      END

    IF @AsOfDate IS NULL
      BEGIN
        SELECT TOP 1 @AsOfDate = CAST(fad.AsOfDate AS DATE) FROM dbo.FundAssetsDetails fad WHERE fad.Entity = @EntityName  ORDER BY fad.AsOfDate DESC, COALESCE(fad.UpdatedOn, fad.CreatedOn) DESC
      END

    IF @BegDate IS NULL
      BEGIN
        SELECT @BegDate = @AsOfDate
      END

/*  FUND ASSETS TEMP TABLE   */
    CREATE TABLE #tmpFundAssets(
      AsOfDate        DATE,
      EntityName      VARCHAR(500),
      ConstName       VARCHAR(500),
      NavValue        FLOAT,
      UpdatedOn       DATETIME)

     INSERT INTO #tmpFundAssets(
            AsOfDate,
            EntityName,
            NavValue,
            UpdatedOn)
     SELECT fad.AsOfDate,
            fad.Entity,
            fad.AssetValue,
            COALESCE(fad.UpdatedOn, fad.CreatedOn)
       FROM dbo.FundAssetsDetails fad 
      WHERE fad.AsOfDate BETWEEN @BegDate AND @AsOfDate 
        AND fad.Entity = @EntityName
      ORDER BY fad.AsOfDate DESC,
            COALESCE(fad.UpdatedOn, fad.CreatedOn) DESC


     SELECT tfa.AsOfDate,
            tfa.EntityName,
            tfa.NavValue,
            tfa.UpdatedOn
       FROM #tmpFundAssets tfa 
      ORDER BY tfa.AsOfDate,
            tfa.EntityName

   SET NOCOUNT OFF

   END
   GO

   GRANT EXECUTE ON dbo.p_GetAMFNavValues TO PUBLIC
   GO