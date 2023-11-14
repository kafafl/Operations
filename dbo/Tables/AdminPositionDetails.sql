CREATE TABLE dbo.AdminPositionDetails(
  iId                      BIGINT IDENTITY (1, 1) NOT NULL,
  SecName                  VARCHAR(255),
  AsOfDate                 DATE,
  Account                  VARCHAR(255),
  TopLevelTag              VARCHAR(255),
  Strategy                 VARCHAR(255),
  BbgShortCode             VARCHAR(255),
  CcyCode                  VARCHAR(255),
  Sector                   VARCHAR(255),
  AssetClass               VARCHAR(255),
  HedgeCore                VARCHAR(255),
  PositionType             VARCHAR(255),
  Custodian                VARCHAR(255),
  LS_Exposure              FLOAT,
  Quantity                 FLOAT,
  QuantityStart            FLOAT,
  QuantChange              FLOAT,
  Cost                     FLOAT,
  Price                    FLOAT,
  PriceNat                 FLOAT,
  AvgUnitCostNat           FLOAT,
  PriceUnderly             FLOAT,
  MktValueGross            FLOAT,
  EquityDeltaExpGross      FLOAT,
  DeltaExpGross            FLOAT,
  Delta                    FLOAT,
  DtdPnlUsd                FLOAT,
  MtdPnlUsd                FLOAT,
  YtdPnlUsd                FLOAT,
  IssuerCode               VARCHAR(255),
  IssuerName               VARCHAR(255),
  IssuerSymbol             VARCHAR(255),
  SEDOL                    VARCHAR(255),
  ISIN                     VARCHAR(255),
  CUSIP                    VARCHAR(255),
  BbgCode                  VARCHAR(255),
  SectorGICs               VARCHAR(255),
  Ticker                   VARCHAR(255),
  UnderlyCUSIP             VARCHAR(255),
  UnderlySYMBOL            VARCHAR(255),
  ThesisType               VARCHAR(255),
  CountryCode              VARCHAR(255),
  IndustryGICs             VARCHAR(255),
  SecDescShort             VARCHAR(255),
  CreatedBy                VARCHAR(50) 
        CONSTRAINT DF_AdminPosistionDetails_CreatedBy DEFAULT(SUSER_NAME()),
  CreatedOn                DATETIME
        CONSTRAINT DF_AdminPositionsDetails_CreatedOn DEFAULT(GETDATE()),
  UpdatedBy                VARCHAR(50) NULL,
  UpdatedOn                DATETIME NULL)

GO

CREATE TRIGGER [dbo].[admPosDetail] 
  ON [dbo].[AdminPositionDetails] 
  AFTER UPDATE
  AS 
    BEGIN
    
      SET NOCOUNT ON

      DECLARE @ts DATETIME
      DECLARE @user AS VARCHAR(255)

      SET @ts = CURRENT_TIMESTAMP
      SET @user = SUSER_NAME()

      UPDATE epd 
         SET UpdatedOn = @ts,
             UpdatedBy = @user
        FROM [dbo].[AdminPositionDetails] AS epd
       INNER JOIN inserted AS i 
          ON epd.iId = i.iId;
    END
GO


GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.AdminPositionDetails TO PUBLIC
GO