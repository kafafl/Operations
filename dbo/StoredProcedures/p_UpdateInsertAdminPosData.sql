CREATE PROCEDURE dbo.p_UpdateInsertAdminPosData(
  @SecName                  VARCHAR(255),
  @AsOfDate                 DATE,
  @Account                  VARCHAR(255),
  @TopLevelTag              VARCHAR(255),
  @Strategy                 VARCHAR(255),
  @BbgShortCode             VARCHAR(255),
  @CcyCode                  VARCHAR(255),
  @Sector                   VARCHAR(255),
  @AssetClass               VARCHAR(255),
  @HedgeCore                VARCHAR(255),
  @PositionType             VARCHAR(255),
  @Custodian                VARCHAR(255),
  @LS_Exposure              VARCHAR(255),
  @Quantity                 FLOAT,
  @QuantityStart            FLOAT,
  @QuantChange              FLOAT,
  @Cost                     FLOAT,
  @Price                    FLOAT,
  @PriceNat                 FLOAT,
  @AvgUnitCostNat           FLOAT,
  @PriceUnderly             FLOAT,
  @MktValueGross            FLOAT,
  @EquityDeltaExpGross      FLOAT,
  @DeltaExpGross            FLOAT,
  @Delta                    FLOAT,
  @DtdPnlUsd                FLOAT,
  @MtdPnlUsd                FLOAT,
  @YtdPnlUsd                FLOAT,
  @IssuerCode               VARCHAR(255),
  @IssuerName               VARCHAR(255),
  @IssuerSymbol             VARCHAR(255),
  @SEDOL                    VARCHAR(255),
  @ISIN                     VARCHAR(255),
  @CUSIP                    VARCHAR(255),
  @BbgCode                  VARCHAR(255),
  @SectorGICs               VARCHAR(255),
  @Ticker                   VARCHAR(255),
  @UnderlyCUSIP             VARCHAR(255),
  @UnderlySYMBOL            VARCHAR(255),
  @ThesisType               VARCHAR(255),
  @CountryCode              VARCHAR(255),
  @IndustryGICs             VARCHAR(255),
  @SecDescShort             VARCHAR(255))
 
 /*
  Author: Lee Kafafian
  Crated: 10/12/2023
  Object: p_UpdateInsertAdminPosData
  Example:  EXEC dbo.p_UpdateInsertAdminPosData ...

 */
  
 AS 

  BEGIN

    SET NOCOUNT ON
     
    IF EXISTS(SELECT TOP 1 * FROM dbo.AdminPositionDetails epd WHERE epd.AsOfDate = @AsOfDate AND 1 = 0)
      BEGIN
        /* ADD AT SOME POINT  */
        UPDATE epd
           SET apd.SecName = ''             
          FROM dbo.AdminPositionDetails apd
         WHERE apd.AsOfDate = @AsOfDate          

      END
    ELSE
      BEGIN
        INSERT INTO dbo.AdminPositionDetails(
               SecName,
               AsOfDate,
               Account,
               TopLevelTag,
               Strategy,
               BbgShortCode,
               CcyCode,
               Sector,
               AssetClass,
               HedgeCore,
               PositionType,
               Custodian,
               LS_Exposure,
               Quantity,
               QuantityStart,
               QuantChange,
               Cost,
               Price,
               PriceNat,
               AvgUnitCostNat,
               PriceUnderly,
               MktValueGross,
               EquityDeltaExpGross,
               DeltaExpGross,
               Delta,
               DtdPnlUsd,
               MtdPnlUsd,
               YtdPnlUsd,
               IssuerCode,
               IssuerName,
               IssuerSymbol,
               SEDOL,
               ISIN,
               CUSIP,
               BbgCode,
               SectorGICs,
               Ticker,
               UnderlyCUSIP,
               UnderlySYMBOL,
               ThesisType,
               CountryCode,
               IndustryGICs,
               SecDescShort)
        SELECT @SecName,
               @AsOfDate,
               @Account,
               @TopLevelTag,
               @Strategy,
               @BbgShortCode,
               @CcyCode,
               @Sector,
               @AssetClass,
               @HedgeCore,
               @PositionType,
               @Custodian,
               @LS_Exposure,
               @Quantity,
               @QuantityStart,
               @QuantChange,
               @Cost,
               @Price,
               @PriceNat,
               @AvgUnitCostNat,
               @PriceUnderly,
               @MktValueGross,
               @EquityDeltaExpGross,
               @DeltaExpGross,
               @Delta,
               @DtdPnlUsd,
               @MtdPnlUsd,
               @YtdPnlUsd,
               @IssuerCode,
               @IssuerName,
               @IssuerSymbol,
               @SEDOL,
               @ISIN,
               @CUSIP,
               @BbgCode,
               @SectorGICs,
               @Ticker,
               @UnderlyCUSIP,
               @UnderlySYMBOL,
               @ThesisType,
               @CountryCode,
               @IndustryGICs,
               @SecDescShort

      END

     SET NOCOUNT OFF

  END

GO

GRANT EXECUTE ON dbo.p_UpdateInsertAdminPosData TO PUBLIC
GO