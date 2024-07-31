SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[p_GetBiotechFactorReturns]( 
    @AsOfDate          DATE = NULL) 
 
 /* 
  Author:   Lee Kafafian 
  Crated:   06/10/2024 
  Object:   p_GetBiotechFactorReturns 
  Example:  EXEC p_GetBiotechFactorReturns @AsOfDate = '06/07/2024'
 */ 
   
 AS  
  BEGIN 
    SET NOCOUNT ON 

      DECLARE @JobRef           VARCHAR(255)

      CREATE TABLE #tmpFactorReturns(
          AsOfDate                   DATE NOT NULL,
          AssetId                    VARCHAR(255) NOT NULL,
          AssetName                  VARCHAR(255) NOT NULL,
          BetaExp                    FLOAT NOT NULL,
          CarbonEfficiencyExp        FLOAT NOT NULL,
          DividendYieldExp           FLOAT NOT NULL,
          EarningsQualityExp         FLOAT NOT NULL,
          EarningsVariabilityExp     FLOAT NOT NULL,
          EarningsYieldExp           FLOAT NOT NULL,
          EsgExp                     FLOAT NOT NULL,
          GrowthExp                  FLOAT NOT NULL,
          InvestmentQualityExp       FLOAT NOT NULL,
          LeverageExp                FLOAT NOT NULL,
          LiquidityExp               FLOAT NOT NULL,
          LongTermReversalExp        FLOAT NOT NULL,
          MidCapitalizationExp       FLOAT NOT NULL,
          MomentumExp                FLOAT NOT NULL,
          ProfitabilityExp           FLOAT NOT NULL,
          ResidualVolatilityExp      FLOAT NOT NULL,
          ShortInerestExp            FLOAT NOT NULL,
          SizeExp                    FLOAT NOT NULL,
          ValueExp                   FLOAT NOT NULL)

      CREATE TABLE #tmpBiotechMaster( 
          AsOfDate                DATE, 
          BbgTicker               VARCHAR(255) NOT NULL, 
          Ticker                  VARCHAR(255) NULL, 
          SecName                 VARCHAR(500) NOT NULL DEFAULT 'NA', 
          Crncy                   VARCHAR(12) NULL,
          CntryCode               VARCHAR(12) NULL,        
          MrktCap                 FLOAT NULL,
          EntVal                  FLOAT NULL, 
          Price                   FLOAT NULL,
          SLDate                  DATE NULL,
          SLAvail                 FLOAT NULL, 
          SLRate                  FLOAT NULL, 
          SLType                  VARCHAR(15) NULL,
          AvgVolDate              DATE NULL,
          AvgVol30d               FLOAT NULL,
          AvgVol90d               FLOAT NULL,
          AvgVol180d              FLOAT NULL, 
          TheraAreaTag            VARCHAR(255) NULL,
          TheraAreaDate           DATE,
          bNoMktCap               BIT DEFAULT 0,
          bNoEntVal               BIT DEFAULT 0, 
          bNoPrice                BIT DEFAULT 0, 
          bNoEntValue             BIT DEFAULT 0) 



        IF @AsOfDate IS NULL
          BEGIN
            SELECT TOP 1 @AsOfDatE = bfx.AsOfDate FROM dbo.AmfBiotechFactorReturns bfx ORDER BY bfx.AsOfDate DESC, bfx.CreatedOn DESC        
          END

          SELECT TOP 1 @JobRef = bfx.JobReference FROM dbo.AmfBiotechFactorReturns bfx  WHERE bfx.AsOfDate = @AsOfDate ORDER BY bfx.AsOfDate DESC, bfx.CreatedOn DESC  

             INSERT INTO #tmpFactorReturns(
                    AsOfDate,
                    AssetId,
                    AssetName,
                    BetaExp,
                    CarbonEfficiencyExp,
                    DividendYieldExp,
                    EarningsQualityExp,
                    EarningsVariabilityExp,
                    EarningsYieldExp,
                    EsgExp,
                    GrowthExp,
                    InvestmentQualityExp,
                    LeverageExp,
                    LiquidityExp,
                    LongTermReversalExp,
                    MidCapitalizationExp,
                    MomentumExp,
                    ProfitabilityExp,
                    ResidualVolatilityExp,
                    ShortInerestExp,
                    SizeExp,
                    ValueExp)
             SELECT bfr.AsOfDate,
                    bfr.AssetId,
                    bfr.AssetName,
                    bfr.BetaExp,
                    bfr.CarbonEfficiencyExp,
                    bfr.DividendYieldExp,
                    bfr.EarningsQualityExp,
                    bfr.EarningsVariabilityExp,
                    bfr.EarningsYieldExp,
                    bfr.EsgExp,
                    bfr.GrowthExp,
                    bfr.InvestmentQualityExp,
                    bfr.LeverageExp,
                    bfr.LiquidityExp,
                    bfr.LongTermReversalExp,
                    bfr.MidCapitalizationExp,
                    bfr.MomentumExp,
                    bfr.ProfitabilityExp,
                    bfr.ResidualVolatilityExp,
                    bfr.ShortInterestExp,
                    bfr.SizeExp,
                    bfr.ValueExp
               FROM dbo.vw_Biotech400FactorReturns bfr
              WHERE bfr.AsOfDate = @AsOfDate
                AND bfr.JobReference = @JobRef

/**/

             INSERT INTO #tmpBiotechMaster( 
                    AsOfDate,
                    BbgTicker,
                    Ticker,
                    SecName,
                    Crncy,
                    CntryCode,
                    MrktCap,
                    EntVal, 
                    Price,
                    SLDate,
                    SLAvail,
                    SLRate,
                    SLType,
                    AvgVolDate,
                    AvgVol30d,
                    AvgVol90d,
                    AvgVol180d,
                    TheraAreaTag,
                    TheraAreaDate,
                    bNoMktCap,
                    bNoPrice,
                    bNoEntValue)  
               EXEC dbo.p_GetAmfBiotechUniverse @AsOfDate = @AsOfDate, @LowQualityFilter = 1


    /*  RETURN THESE RESULTS  */
         SELECT bmu.AsOfDate,
                bmu.BbgTicker,
                bmu.Ticker,
                bmu.SecName,
                tfr.BetaExp, 
                tfr.CarbonEfficiencyExp, 
                tfr.DividendYieldExp, 
                tfr.EarningsQualityExp, 
                tfr.EarningsVariabilityExp, 
                tfr.EarningsYieldExp, 
                tfr.EsgExp, 
                tfr.GrowthExp, 
                tfr.InvestmentQualityExp, 
                tfr.LeverageExp, 
                tfr.LiquidityExp, 
                tfr.LongTermReversalExp, 
                tfr.MidCapitalizationExp, 
                tfr.MomentumExp, 
                tfr.ProfitabilityExp, 
                tfr.ResidualVolatilityExp, 
                tfr.ShortInerestExp, 
                tfr.SizeExp, 
                tfr.ValueExp
           FROM #tmpBiotechMaster bmu
           LEFT JOIN #tmpFactorReturns tfr
             ON bmu.AsOfDate = tfr.AsOfDate
            AND bmu.Ticker = tfr.AssetId


    SET NOCOUNT OFF 
  END 
GO




GRANT EXECUTE ON dbo.p_GetBiotechFactorReturns TO PUBLIC
GO
