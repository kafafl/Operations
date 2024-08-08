ALTER PROCEDURE dbo.p_UpdateInsertBiotechMasterUniverse(
    @AsOfDate              DATE,
    @strBbgTicker          VARCHAR(255),
    @SecName               VARCHAR(255),
    @GICS_sector           VARCHAR(255),
    @GICS_industry         VARCHAR(255),
    @Crncy                 VARCHAR(255),
    @MktCap                FLOAT,
    @EntVal                FLOAT,
    @Price                 FLOAT,
    @PrevPrice             FLOAT,
    @PEValue               FLOAT,
    @TotRetYtd             FLOAT,
    @RevenueT12M           FLOAT,
    @EPS                   FLOAT,
    @CUSIP                 VARCHAR(255),
    @SEDOL                 VARCHAR(255))
 
 
 /*
  Author:   Lee Kafafian
  Crated:   05/16/2024
  Object:   p_UpdateInsertBiotechMasterUniverse
  Example:  EXEC dbo.p_UpdateInsertBiotechMasterUniverse @AsOfDate...
 */
  
 AS 
  BEGIN
    SET NOCOUNT ON

    DECLARE @NullCheck AS BIGINT = -99999

        INSERT INTO dbo.BiotechMasterUniverse(
               AsOfDate,
               BbgTicker,
               SecName,
               GICS_sector,
               GICS_industry,
               Crncy,
               MarketCap,
               EnterpriseValue,
               Price,
               PrevPrice,
               PEValue,
               TotalReturnYTD,
               RevenueT12M,
               EPST12M,
               IdCUSIP,
               IdSEDOL) 
        SELECT @AsOfDate,
               @strBbgTicker,
               @SecName,
               @GICS_sector,
               @GICS_industry,
               @Crncy,
               CASE WHEN @MktCap = @NullCheck THEN NULL ELSE @MktCap END,
               CASE WHEN @EntVal = @NullCheck THEN NULL ELSE @EntVal END,
               CASE WHEN @Price = @NullCheck THEN NULL ELSE @Price END,
               CASE WHEN @PrevPrice = @NullCheck THEN NULL ELSE @PrevPrice END,
               CASE WHEN @PEValue = @NullCheck THEN NULL ELSE @PEValue END,
               CASE WHEN @TotRetYtd = @NullCheck THEN NULL ELSE @TotRetYtd END,
               CASE WHEN @RevenueT12M = @NullCheck THEN NULL ELSE @RevenueT12M END,
               CASE WHEN @EPS = @NullCheck THEN NULL ELSE @EPS END,
               @CUSIP,
               @SEDOL

    SET NOCOUNT OFF
  END
GO

GRANT EXECUTE ON dbo.p_UpdateInsertBiotechMasterUniverse TO PUBLIC
GO
