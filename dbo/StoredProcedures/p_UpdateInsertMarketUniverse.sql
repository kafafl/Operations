ALTER PROCEDURE dbo.p_UpdateInsertMarketUniverse(
    @AsOfDate              DATE,
    @ParentEntity          VARCHAR(255),
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
    @EPS                   FLOAT)
 
 
 /*
  Author:   Lee Kafafian
  Crated:   08/01/2024
  Object:   p_UpdateInsertMarketUniverse
  Example:  EXEC dbo.p_UpdateInsertMarketUniverse @AsOfDate...
            EXEC dbo.p_UpdateInsertMarketUniverse @AsOfDate = '08/01/2024', @ParentEntity = 'RTY', @strBbgTicker = 'CCOI UW Equity', @SecName = 'Cogent Communications Holdings', @GICS_sector = 'Communication Services', @GICS_industry = 'Diversified Telecommunication Services', @Crncy = 'USD', @MktCap = 3380725820.23678, @EntVal = 5113188820.23678, @Price = 68.9599990844727, @PrevPrice = 70.1100006103516, @PEValue = 28.0389711960039, @TotRetYtd = 0.210277764207863, @RevenueT12M = 1053502000, @EPS = 11486.3636363636

 */
  
 AS 
  BEGIN
    SET NOCOUNT ON

    DECLARE @NullCheck AS BIGINT = -99999

        INSERT INTO dbo.MarketMasterUniverse(
               AsOfDate,
               ParentEntity,
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
               EPST12M) 
        SELECT @AsOfDate,
               @ParentEntity,
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
               CASE WHEN @EPS = @NullCheck THEN NULL ELSE @EPS END

    SET NOCOUNT OFF
  END
GO

GRANT EXECUTE ON dbo.p_UpdateInsertMarketUniverse TO PUBLIC
GO
