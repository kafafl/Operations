ALTER PROCEDURE dbo.p_UpdateInsertBiotechMasterUniveres(
    @AsOfDate              DATE,
    @strBbgTicker          VARCHAR(255),
    @SecName               VARCHAR(255),
    @MktCap                FLOAT,
    @EntVal                FLOAT,
    @Price                 FLOAT,
    @PrevPrice             FLOAT,
    @PEValue               FLOAT,
    @TotRetYtd             FLOAT,
    @RevenueT12M           FLOAT,
    @EPS                   FLOAT)
 
 
 /*
  Author:   Lee Kafafian
  Crated:   05/16/2024
  Object:   p_UpdateInsertBiotechMasterUniveres
  Example:  EXEC dbo.p_UpdateInsertBiotechMasterUniveres @AsOfDate...
 */
  
 AS 
  BEGIN
    SET NOCOUNT ON

    DECLARE @NullCheck AS BIGINT = -99999

        INSERT INTO dbo.BiotechMasterUniverse(
               AsOfDate,
               BbgTicker,
               SecName,
               MarketCap,
               EnterpriseValue,
               Price,
               PrevPrice,
               PEValue,
               TotalReturnYTD,
               RevenueT12M,
               EPST12M) 
        SELECT @AsOfDate,
               @strBbgTicker,
               @SecName,
               CASE WHEN @MktCap = @NullCheck THEN NULL ELSE @MktCap END,
               CASE WHEN @EntVal = @NullCheck THEN NULL ELSE @EntVal END,
               CASE WHEN @Price = @NullCheck THEN NULL ELSE @Price END,
               CASE WHEN @PrevPrice = @NullCheck THEN NULL ELSE @PrevPrice END,
               CASE WHEN @PEValue = @NullCheck THEN NULL ELSE @PEValue END,
               CASE WHEN @TotRetYtd = @NullCheck THEN NULL ELSE @TotRetYtd END,
               CASE WHEN @RevenueT12M = @NullCheck THEN NULL ELSE @RevenueT12M END,
               CASE WHEN @EPS = @NullCheck THEN NULL ELSE @EPS END

    SET NOCOUNT OFF
  END
GO

GRANT EXECUTE ON dbo.p_UpdateInsertBiotechMasterUniveres TO PUBLIC
GO
