SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  

ALTER PROCEDURE [dbo].[p_RunDailyPositionRecReports](
    @AsOfDate             DATE NULL = DEFAULT,
    @RstOutput            INT = 1,
    @Strategy             VARCHAR(255) = 'ALL')

 /*
  Author:   Lee Kafafian
  Crated:   07/17/2024
  Object:   p_RunDailyPositionRecReports
  Example:  EXEC dbo.p_RunDailyPositionRecReports @AsOfDate = '07/17/2024', @RstOutput = 1, @Strategy = 'Alpha Long'

            EXEC dbo.p_RunDailyPositionRecReports @AsOfDate = '07/17/2024', @RstOutput = 1, @Strategy = 'Alpha Short'

            EXEC dbo.p_RunDailyPositionRecReports @AsOfDate = '07/17/2024', @RstOutput = 1, @Strategy = 'All'
 
 */

 AS 
 
   BEGIN

   SET NOCOUNT ON

    DECLARE @AsOfDateCheck AS DATE
    DECLARE @AsOfDateEnfu AS DATE
    DECLARE @AsOfDateMsfs AS DATE

    SELECT TOP 1 @AsOfDateEnfu = epd.AsOfDate FROM dbo.EnfPositionDetails epd ORDER BY epd.AsOfDate DESC
    SELECT TOP 1 @AsOfDateMsfs = msf.AsOfDate FROM dbo.AdminPositionDetails msf ORDER BY msf.AsOfDate DESC
    SELECT @AsOfDateCheck =  IIf(@AsOfDateEnfu > @AsOfDateMsfs, @AsOfDateMsfs, @AsOfDateEnfu)
    
    IF @AsOfDate IS NULL OR @AsOfDate > @AsOfDateCheck
      BEGIN
        SELECT @AsOfDate = @AsOfDateCheck
      END

      CREATE TABLE #tmpRecResults(
        AsOfDate           DATE,
        Strategy           VARCHAR(255),
        Book               VARCHAR(255),
        Ticker             VARCHAR(255),
        SecName            VARCHAR(255),
        UnderlySymbol      VARCHAR(255),
        AdmTicker          VARCHAR(255),
        AdmSecName         VARCHAR(255),
        EnfQuantity        FLOAT,
        AdmQuantity        FLOAT,
        EnfDtdPnlUsd       FLOAT,
        AdmDtdPnlUsd       FLOAT,
        EnfMtdPnlUsd       FLOAT,
        AdmMtdPnlUsd       FLOAT,
        EnfYtdPnlUsd       FLOAT,
        AdmYtdPnlUsd       FLOAT,
        LongShort          VARCHAR(255),
        bUpdated           BIT DEFAULT 0,
        UpdateRule         VARCHAR(255),
        iSort              INTEGER DEFAULT 1)

      CREATE TABLE #tmpRecResultsNonSec(
        AsOfDate           DATE,
        Strategy           VARCHAR(255),
        Book               VARCHAR(255),
        Ticker             VARCHAR(255),
        SecName            VARCHAR(255),
        UnderlySymbol      VARCHAR(255),
        AdmTicker          VARCHAR(255),
        AdmSecName         VARCHAR(255),
        EnfQuantity        FLOAT,
        AdmQuantity        FLOAT,
        EnfDtdPnlUsd       FLOAT,
        AdmDtdPnlUsd       FLOAT,
        EnfMtdPnlUsd       FLOAT,
        AdmMtdPnlUsd       FLOAT,
        EnfYtdPnlUsd       FLOAT,
        AdmYtdPnlUsd       FLOAT,
        bUpdated           BIT DEFAULT 0,
        UpdateRule         VARCHAR(255),
        iSort              INTEGER DEFAULT 1)

      CREATE TABLE #tmpRecResultsClosed(
        AsOfDate           DATE,
        Strategy           VARCHAR(255),
        Book               VARCHAR(255),
        Ticker             VARCHAR(255),
        SecName            VARCHAR(255),
        UnderlySymbol      VARCHAR(255),
        AdmTicker          VARCHAR(255),
        AdmSecName         VARCHAR(255),
        EnfQuantity        FLOAT,
        AdmQuantity        FLOAT,
        EnfDtdPnlUsd       FLOAT,
        AdmDtdPnlUsd       FLOAT,
        EnfMtdPnlUsd       FLOAT,
        AdmMtdPnlUsd       FLOAT,
        EnfYtdPnlUsd       FLOAT,
        AdmYtdPnlUsd       FLOAT,
        bUpdated           BIT DEFAULT 0,
        UpdateRule         VARCHAR(255),
        iSort              INTEGER DEFAULT 1)        

      CREATE TABLE #tmpEnfPositionDetails(
        AsOfDate             DATE          NOT NULL,
        FundShortName        VARCHAR (255) NOT NULL,
        StratName            VARCHAR(255)  NOT NULL,
        BookName             VARCHAR (255) NOT NULL,
        InstDescr            VARCHAR (255) NOT NULL,
        BBYellowKey	         VARCHAR (255) NULL,
        UnderlyBBYellowKey   VARCHAR (255) NULL,
        Account	             VARCHAR (255) NOT NULL,
        CcyOne               VARCHAR (255) NULL,
        CcyTwo               VARCHAR (255) NULL,
        InstrType            VARCHAR (255) NULL,
        Quantity             FLOAT (53) NULL,
        NetAvgCost           FLOAT (53) NULL,
        OverallCost          FLOAT (53) NULL,
        FairValue	         FLOAT (53) NULL,
        NetMarketValue       FLOAT (53) NULL,
        DlyPnlUsd            FLOAT (53) NULL,
        DlyPnlOfNav          FLOAT (53) NULL,
        MtdPnlUsd	         FLOAT (53) NULL,
        MtdPnlOfNav          FLOAT (53) NULL,
        YtdPnlUsd            FLOAT (53) NULL,
        YtdPnlOfNav          FLOAT (53) NULL,
        ItdPnlUsd            FLOAT (53) NULL,
        GrExpOfGLNav         FLOAT (53) NULL,
        Delta                FLOAT (53) NULL,
        DeltaAdjMV           FLOAT (53) NULL,
        DeltaExp             FLOAT (53) NULL,
        GrossExp             FLOAT (53) NULL,
        LongMV               FLOAT (53) NULL,
        ShortMV              FLOAT (53) NULL,
        InstrTypeCode        VARCHAR (255) NULL,
        InstrTypeUnder       VARCHAR (255) NULL,
        bIsUsed              BIT DEFAULT 0,
        UsageNote            VARCHAR(255) NULL)

      CREATE TABLE #tmpAdminPositions(
        AsOfDate            DATE,
        SecName             VARCHAR(255),
        Account             VARCHAR(500),
        TopLevelTag         VARCHAR(500),
        Strategy            VARCHAR(500),
        BbgShortCode        VARCHAR(500),
        BbgCode             VARCHAR(500),
        CcyCode             VARCHAR(500),
        AssetClass          VARCHAR(500),
        HedgeCore           VARCHAR(500),
        PositionType        VARCHAR(500),
        Custodian           VARCHAR(500),
        UnderlySYMBOL       VARCHAR(500),
        Quantity            FLOAT,
        QuantityStart       FLOAT,
        QuantChange         FLOAT,
        MarketValue         FLOAT,
        Cost                FLOAT,
        Price               FLOAT,
        DtdPnlUsd	         FLOAT,
        MtdPnlUsd	         FLOAT,
        YtdPnlUsd           FLOAT,
        LongShort           VARCHAR (255) NULL,
        bIsUsed             BIT DEFAULT 0,
        UsageNote           VARCHAR(255) NULL)

      CREATE TABLE #tmpPortfolioRec(
        AsOfDate            DATE,
        Strategy            VARCHAR(255),
        BBYellowKey         VARCHAR(255),
        PortPosLong         FLOAT,
        PortPosShort        FLOAT,
        PortPosNet          FLOAT,

        MspbQuantity        FLOAT,
        EnfQuantity         FLOAT,

        MspbDtdPnlUsd       FLOAT,
        EnfDtdPnlUsd        FLOAT,

        MspbMtdPnlUsd       FLOAT,
        EnfMtdPnlUsd        FLOAT,
        
        MspbYtdPnlUsd       FLOAT,
        EnfYtdPnlUsd        FLOAT,

        iSort               INTEGER,
        bProcessed          BIT DEFAULT 0)

      CREATE TABLE #tmpPortfolioTmp(
        AsOfDate            DATE,
        Strategy            VARCHAR(255),
        BBYellowKey         VARCHAR(255),
        PortPosLong         FLOAT,
        PortPosShort        FLOAT,
        PortPosNet          FLOAT,
        MspbQuantity        FLOAT,
        EnfQuantity         FLOAT,
        MspbDtdPnlUsd       FLOAT,
        EnfDtdPnlUsd        FLOAT,
        MspbMtdPnlUsd       FLOAT,
        EnfMtdPnlUsd        FLOAT,        
        MspbYtdPnlUsd       FLOAT,
        EnfYtdPnlUsd        FLOAT,
        bProcessed          BIT DEFAULT 0)
    
      CREATE TABLE #tmpAdminRecDetails(
        AsOfDate            DATE,
        Strategy            VARCHAR(255),
        BbgCode             VARCHAR(255),
        BbgShortCode        VARCHAR(255),
        BBYellowKey         VARCHAR(255),
        AdminQuant          FLOAT,
        AdminDtdPnl         FLOAT,
        AdminMtdPnl         FLOAT,
        AdminYtdPnl         FLOAT,
        bProcessed          BIT DEFAULT 0)

      CREATE TABLE #tmpEnfusRecDetails(
        AsOfDate            DATE,
        Strategy            VARCHAR(255),
        BbgCode             VARCHAR(255),
        BbgShortCode        VARCHAR(255),
        BBYellowKey         VARCHAR(255),
        EnfusQuant          FLOAT,
        EnfusDtdPnl         FLOAT,
        EnfusMtdPnl         FLOAT,
        EnfusYtdPnl         FLOAT,
        bProcessed          BIT DEFAULT 0)


    /*  SETUP THE EXPLICIT POSITIONS TO REC  */
        IF @Strategy = 'All' OR @Strategy = 'Alpha Long'
          BEGIN
            INSERT INTO #tmpPortfolioTmp(
                   AsOfDate,
                   Strategy,
                   BBYellowKey,
                   PortPosLong,
                   PortPosNet,
                   PortPosShort)
              EXEC dbo.p_GetLongPortfolio @AsOfDate = @AsOfDate
          END

        IF @Strategy = 'All' OR @Strategy = 'Alpha Short'
          BEGIN
            INSERT INTO #tmpPortfolioTmp(
                   AsOfDate,
                   Strategy,
                   BBYellowKey,
                   PortPosLong,
                   PortPosShort,
                   PortPosNet)
              EXEC dbo.p_GetShortPortfolio @AsOfDate = @AsOfDate
          END

        IF @Strategy = 'All' OR @Strategy = ''
          BEGIN      /**/
            INSERT INTO #tmpPortfolioTmp(
                   AsOfDate,
                   Strategy,
                   BBYellowKey,
                   PortPosLong,
                   PortPosNet,
                   PortPosShort)
            SELECT epd.AsOfDate,
                   epd.StratName,
                   epd.BBYellowKey,
                   SUM(CASE WHEN epd.Quantity > 0 THEN epd.Quantity ELSE 0.0 END) AS PosLong,
                   SUM(epd.Quantity),
                   SUM(CASE WHEN epd.Quantity < 0 THEN epd.Quantity ELSE 0.0 END) AS PosShort           
              FROM dbo.EnfPositionDetails epd
             WHERE epd.AsOfDate  = @AsOfDate
               AND ROUND(epd.Quantity, 0) != 0
               AND epd.StratName IN ('Biotech Hedge', 'Equity Hedge')
               AND COALESCE(epd.BBYellowKey, '') != ''
             GROUP BY epd.AsOfDate,
                    epd.StratName,
                    epd.BBYellowKey
          END

    /*  FINAL TEMP PORTFOLIO TABLE  */
        INSERT INTO #tmpPortfolioRec(
               AsOfDate,
               Strategy,
               BBYellowKey,
               PortPosLong,
               PortPosNet,
               PortPosShort)
        SELECT AsOfDate,
               MIN(Strategy),
               BBYellowKey,
               MAX(PortPosLong),
               MAX(PortPosNet),
               MAX(PortPosShort)
          FROM #tmpPortfolioTmp
         GROUP BY AsOfDate,
               BBYellowKey


    /*  LOAD ENFUSION POSITION TEMP TABLE          */
        INSERT INTO #tmpEnfPositionDetails(
               AsOfDate,
               FundShortName,
               StratName,
               BookName,
               InstDescr,
               BBYellowKey,
               UnderlyBBYellowKey,
               Account,
               CcyOne ,
               CcyTwo,
               InstrType,
               Quantity,
               NetAvgCost,
               OverallCost,
               FairValue,
               NetMarketValue,
               DlyPnlUsd,
               DlyPnlOfNav,
               MtdPnlUsd,
               MtdPnlOfNav,
               YtdPnlUsd,
               YtdPnlOfNav,
               ItdPnlUsd,
               GrExpOfGLNav,
               Delta,
               DeltaAdjMV,
               DeltaExp,
               GrossExp,
               LongMV,
               ShortMV,
               InstrTypeCode,
               InstrTypeUnder) 
        SELECT AsOfDate,
               FundShortName,
               StratName,
               BookName,
               InstDescr,
               REPLACE(epd.BBYellowKey, ' ELEC ', ' '),
               UnderlyBBYellowKey,
               Account,
               CcyOne ,
               CcyTwo,
               InstrType,
               Quantity,
               NetAvgCost,
               OverallCost,
               FairValue,
               NetMarketValue,
               DlyPnlUsd,
               DlyPnlOfNav,
               MtdPnlUsd,
               MtdPnlOfNav,
               YtdPnlUsd,
               YtdPnlOfNav,
               ItdPnlUsd,
               GrExpOfGLNav,
               Delta,
               DeltaAdjMV,
               DeltaExp,
               GrossExp,
               LongMV,
               ShortMV,
               InstrTypeCode,
               InstrTypeUnder   
          FROM dbo.EnfPositionDetails epd 
         WHERE epd.AsOfDate = @AsOfDate



         /*  LOAD ADMIN POSITION TEMP TABLE          */
         INSERT INTO #tmpAdminPositions(
                AsOfDate,
                SecName,
                Account,
                TopLevelTag,
                Strategy,
                BbgShortCode,
                BbgCode,
                CcyCode,
                AssetClass,
                HedgeCore,
                PositionType,
                Custodian,
                UnderlySYMBOL,
                Quantity,
                QuantityStart,
                QuantChange,
                MarketValue,
                Cost,
                Price,
                DtdPnlUsd,
                MtdPnlUsd,
                YtdPnlUsd,
                LongShort)
         SELECT AsOfDate,
                apd.SecName,
                Account,
                TopLevelTag,
                Strategy,
                BbgShortCode,
                REPLACE(apd.BbgCode, ' ELEC ', ' '),
                CcyCode,
                apd.AssetClass,
                HedgeCore,
                PositionType,
                Custodian,
                COALESCE(MAX(UnderlySYMBOL), ''),
                SUM(Quantity),
                SUM(QuantityStart),
                SUM(QuantChange),
                SUM(MktValueGross),
                SUM(Cost),
                SUM(Price),
                SUM(DtdPnlUsd),
                SUM(MtdPnlUsd),
                SUM(YtdPnlUsd),
                LS_Exposure
           FROM dbo.AdminPositionDetails apd
          WHERE apd.AsOfDate = @AsOfDate
          GROUP BY AsOfDate,
                SecName,
                Account,
                TopLevelTag,
                Strategy,
                BbgShortCode,
                BbgCode,
                CcyCode,
                apd.AssetClass,
                HedgeCore,
                PositionType,
                Custodian,
                LS_Exposure


        UPDATE tap
           SET tap.BbgShortCode = 'GOSS US',
               tap.BbgCode = 'GOSS US'
          FROM #tmpAdminPositions tap
         WHERE tap.SecName = 'Gossamer Bio Inc'

        UPDATE tap
           SET tap.BbgShortCode = 'ZURA US',
               tap.BbgCode = 'ZURA US'
          FROM #tmpAdminPositions tap
         WHERE tap.SecName = 'Zura Private'

        UPDATE tap
           SET tap.BbgShortCode = 'MSA1BIO Index',
               tap.BbgCode = 'MSA1BIO Index'
          FROM #tmpAdminPositions tap
         WHERE tap.SecName = 'Msa1Bio'

        UPDATE tap
           SET tap.BbgShortCode = 'MSA1BIOH Index',
               tap.BbgCode = 'MSA1BIOH Index'
          FROM #tmpAdminPositions tap
         WHERE tap.SecName = 'Msa1Bioh'        
        
        UPDATE tap
           SET tap.BbgShortCode = tap.BbgCode
          FROM #tmpAdminPositions tap
         WHERE tap.BbgShortCode = 'XBI' 
           AND tap.AssetClass = 'OPTION ON ETFS/INDICES'

        UPDATE tap
           SET tap.BbgShortCode = 'XBI US Equity', 
               tap.BbgCode = 'XBI US Equity' 
          FROM #tmpAdminPositions tap
         WHERE tap.BbgShortCode = 'XBI US' 
           AND tap.AssetClass = 'ETFS/INDICES'


/*
    SELECT * FROM #tmpAdminPositions WHERE secname LIKE '%Goss%'
 
    SELECT * FROM #tmpEnfPositionDetails WHERE InstDescr LIKE '%Goss%'
    RETURN
*/

/*

SELECT * FROM #tmpAdminPositions
SELECT * FROM #tmpEnfPositionDetails
RETURN

*/

    UPDATE tpr
       SET tpr.iSort = 1
      FROM #tmpPortfolioRec tpr
     WHERE tpr.Strategy = 'Alpha Long'

    UPDATE tpr
       SET tpr.iSort = 2
      FROM #tmpPortfolioRec tpr
     WHERE tpr.Strategy = 'Alpha Short'

    UPDATE tpr
       SET tpr.iSort = 3
      FROM #tmpPortfolioRec tpr
     WHERE tpr.Strategy IN ('Biotech Hedge')

    UPDATE tpr
       SET tpr.iSort = 4
      FROM #tmpPortfolioRec tpr
     WHERE tpr.Strategy IN ('Equity Hedge')


/*
SELECT * FROM #tmpPortfolioRec ORDER BY iSort 

SELECT * FROM #tmpAdminRecDetails

RETURN
*/

    INSERT INTO #tmpAdminRecDetails(
           AsOfDate,
           Strategy,
           BbgCode,
           BbgShortCode,
           BBYellowKey,
           AdminQuant,
           AdminDtdPnl,
           AdminMtdPnl,
           AdminYtdPnl)
    SELECT apd.AsOfDate,
           tpr.Strategy,
           apd.BbgCode,
           apd.BbgShortCode,
           tpr.BBYellowKey,
           SUM(apd.Quantity) AS Quantity,
           SUM(apd.DtdPnlUsd) AS DtdPnlUsd,
           SUM(apd.MtdPnlUsd) AS MtdPnlUsd,
           SUM(apd.YtdPnlUsd) AS YtdPnlUsd
      FROM #tmpAdminPositions apd
      JOIN #tmpPortfolioRec tpr
        ON CHARINDEX(apd.BbgCode, tpr.BBYellowKey) != 0
     WHERE apd.AsOfDate = @AsOfDate
       AND apd.AssetClass != 'OPTION ON ETFS/INDICES'
     GROUP BY apd.AsOfDate,
           tpr.Strategy,
           apd.BbgCode,
           apd.BbgShortCode,
           tpr.BBYellowKey
     ORDER BY apd.AsOfDate,
           tpr.Strategy,
           apd.BbgCode,
           apd.BbgShortCode,
           tpr.BBYellowKey

    INSERT INTO #tmpAdminRecDetails(
           AsOfDate,
           Strategy,
           BbgCode,
           BbgShortCode,
           BBYellowKey,
           AdminQuant,
           AdminDtdPnl,
           AdminMtdPnl,
           AdminYtdPnl)
    SELECT apd.AsOfDate,
           tpr.Strategy,
           apd.BbgCode,
           apd.BbgShortCode,
           tpr.BBYellowKey,
           SUM(apd.Quantity) AS Quantity,
           SUM(apd.DtdPnlUsd) AS DtdPnlUsd,
           SUM(apd.MtdPnlUsd) AS MtdPnlUsd,
           SUM(apd.YtdPnlUsd) AS YtdPnlUsd
      FROM #tmpAdminPositions apd
      JOIN #tmpPortfolioRec tpr
        ON apd.BbgCode = tpr.BBYellowKey
     WHERE apd.AsOfDate = @AsOfDate
       AND apd.AssetClass = 'OPTION ON ETFS/INDICES'
     GROUP BY apd.AsOfDate,
           tpr.Strategy,
           apd.BbgCode,
           apd.BbgShortCode,
           tpr.BBYellowKey
     ORDER BY apd.AsOfDate,
           tpr.Strategy,
           apd.BbgCode,
           apd.BbgShortCode,
           tpr.BBYellowKey

    UPDATE tpr
       SET tpr.MspbQuantity = trd.AdminQuant,
           tpr.MspbDtdPnlUsd = trd.AdminDtdPnl,
           tpr.MspbMtdPnlUsd = trd.AdminMtdPnl,
           tpr.MspbYtdPnlUsd = trd.AdminYtdPnl           
      FROM #tmpPortfolioRec tpr
      JOIN #tmpAdminRecDetails trd
        ON tpr.AsOfDate = trd.AsOfDate
       AND tpr.Strategy = trd.Strategy
       AND tpr.BBYellowKey = trd.BBYellowKey



/* 
      
SELECT * FROM #tmpAdminRecDetails trd WHERE trd.BBYellowKey LIKE 'XBI%'

SELECT * FROM #tmpPortfolioRec tpr WHERE tpr.BBYellowKey LIKE 'XBI%'

RETURN

SELECT * FROM #tmpPortfolioRec ORDER BY iSort 
SELECT * FROM #tmpAdminRecDetails
RETURN

SELECT * FROM #tmpPortfolioRec
SELECT * FROM #tmpAdminRecDetails
RETURN

*/


    INSERT INTO #tmpEnfusRecDetails(
           AsOfDate,
           Strategy,
           BBYellowKey,
           EnfusQuant,
           EnfusDtdPnl,
           EnfusMtdPnl,
           EnfusYtdPnl)
    SELECT epd.AsOfDate,
           tpr.Strategy,
           tpr.BBYellowKey,
           SUM(epd.Quantity) AS Quantity,
           SUM(epd.DlyPnlUsd) AS DtdPnlUsd,
           SUM(epd.MtdPnlUsd) AS MtdPnlUsd,
           SUM(epd.YtdPnlUsd) AS YtdPnlUsd
      FROM #tmpEnfPositionDetails epd
      JOIN #tmpPortfolioRec tpr
        ON epd.BBYellowKey = tpr.BBYellowKey
     WHERE epd.AsOfDate = @AsOfDate
     GROUP BY epd.AsOfDate,
           tpr.Strategy,
           tpr.BBYellowKey
     ORDER BY epd.AsOfDate,
           tpr.Strategy,
           tpr.BBYellowKey

    UPDATE tpr
       SET tpr.EnfQuantity = erd.EnfusQuant,
           tpr.EnfDtdPnlUsd = erd.EnfusDtdPnl,
           tpr.EnfMtdPnlUsd = erd.EnfusMtdPnl,
           tpr.EnfYtdPnlUsd = erd.EnfusYtdPnl           
      FROM #tmpPortfolioRec tpr
      JOIN #tmpEnfusRecDetails erd
        ON tpr.AsOfDate = erd.AsOfDate
       AND tpr.Strategy = erd.Strategy
       AND tpr.BBYellowKey = erd.BBYellowKey
       



    INSERT INTO #tmpPortfolioRec(
           AsOfDate,
           Strategy,
           BBYellowKey,
           iSort)
    SELECT @AsOfDate,
           'Total' AS Strategy,
           'Total' AS BBYellowKey,
           -1


    UPDATE tpr
       SET tpr.EnfDtdPnlUsd = erx.EnfusDtdPnl,
           tpr.EnfMtdPnlUsd = erx.EnfusMtdPnl,
           tpr.EnfYtdPnlUsd = erx.EnfusYtdPnl           
      FROM #tmpPortfolioRec tpr
      JOIN (SELECT @AsOfDate AS AsOfDate,
                   SUM(erd.Quantity) AS EnfusQuant,
                   SUM(erd.DlyPnlUsd) AS EnfusDtdPnl,
                   SUM(erd.MtdPnlUsd) AS EnfusMtdPnl,
                   SUM(erd.YtdPnlUsd) AS EnfusYtdPnl      
             FROM #tmpEnfPositionDetails erd) erx
        ON tpr.AsOfDate = erx.AsOfDate
     WHERE tpr.Strategy = 'Total'
       AND tpr.BBYellowKey = 'Total' 

    UPDATE tpr
       SET tpr.MspbDtdPnlUsd = erx.AdminDtdPnl,
           tpr.MspbMtdPnlUsd = erx.AdminMtdPnl,
           tpr.MspbYtdPnlUsd = erx.AdminYtdPnl           
      FROM #tmpPortfolioRec tpr
      JOIN (SELECT @AsOfDate AS AsOfDate,
                   SUM(erd.Quantity) AS AdminQuant,
                   SUM(erd.DtdPnlUsd) AS AdminDtdPnl,
                   SUM(erd.MtdPnlUsd) AS AdminMtdPnl,
                   SUM(erd.YtdPnlUsd) AS AdminYtdPnl      
             FROM #tmpAdminPositions erd) erx
        ON tpr.AsOfDate = erx.AsOfDate
     WHERE tpr.Strategy = 'Total'
       AND tpr.BBYellowKey = 'Total' 


    INSERT INTO #tmpPortfolioRec(
           AsOfDate,
           Strategy,
           BBYellowKey,
           iSort,
           MspbQuantity,
           EnfQuantity,
           MspbDtdPnlUsd,
           EnfDtdPnlUsd,
           MspbMtdPnlUsd,
           EnfMtdPnlUsd,
           MspbYtdPnlUsd,
           EnfYtdPnlUsd)
    SELECT @AsOfDate,
          'ROW TOTALS' AS Strategy,
          'ROW TOTALS' AS BBYellowKey,
          100,
          SUM(MspbQuantity),
          SUM(EnfQuantity),
          SUM(MspbDtdPnlUsd),
          SUM(EnfDtdPnlUsd),
          SUM(MspbMtdPnlUsd),
          SUM(EnfMtdPnlUsd),
          SUM(MspbYtdPnlUsd),
          SUM(EnfYtdPnlUsd)
     FROM #tmpPortfolioRec tpr
    WHERE tpr.iSort IN (1, 2, 3, 4)

    INSERT INTO #tmpPortfolioRec(
           AsOfDate,
           Strategy,
           BBYellowKey,
           iSort,
           MspbQuantity,
           EnfQuantity,
           MspbDtdPnlUsd,
           EnfDtdPnlUsd,
           MspbMtdPnlUsd,
           EnfMtdPnlUsd,
           MspbYtdPnlUsd,
           EnfYtdPnlUsd)
    SELECT @AsOfDate,
          'Other' AS Strategy,
          'Other' AS BBYellowKey,
          99,
          SUM(tp1.MspbQuantity) - SUM(tp2.MspbQuantity),
          SUM(tp1.EnfQuantity) - SUM(tp2.EnfQuantity),
          SUM(tp1.MspbDtdPnlUsd) - SUM(tp2.MspbDtdPnlUsd),
          SUM(tp1.EnfDtdPnlUsd) - SUM(tp2.EnfDtdPnlUsd),
          SUM(tp1.MspbMtdPnlUsd) - SUM(tp2.MspbMtdPnlUsd),
          SUM(tp1.EnfMtdPnlUsd) - SUM(tp2.EnfMtdPnlUsd),
          SUM(tp1.MspbYtdPnlUsd) - SUM(tp2.MspbYtdPnlUsd),
          SUM(tp1.EnfYtdPnlUsd) - SUM(tp2.EnfYtdPnlUsd)
     FROM #tmpPortfolioRec tp1
     JOIN #tmpPortfolioRec tp2
       ON tp1.AsOfDate = tp2.AsOfDate
    WHERE tp1.iSort = -1
      AND tp2.iSort = 100


    DELETE tpr FROM #tmpPortfolioRec tpr WHERE tpr.iSort = 100


    SELECT tpr.AsOfDate,
           tpr.Strategy,
           tpr.BBYellowKey,
           tpr.PortPosLong,
           tpr.PortPosShort,
           tpr.PortPosNet,
           tpr.MspbQuantity,
           tpr.EnfQuantity,
           COALESCE(tpr.MSPBQuantity, 0) - COALESCE(tpr.EnfQuantity, 0) AS QuantityDiff,           
           tpr.MspbDtdPnlUsd,
           tpr.EnfDtdPnlUsd,
           COALESCE(tpr.MspbDtdPnlUsd, 0) - COALESCE(tpr.EnfDtdPnlUsd, 0) AS DtdPnlDiff,           
           tpr.MspbMtdPnlUsd,
           tpr.EnfMtdPnlUsd,
           COALESCE(tpr.MspbMtdPnlUsd, 0) - COALESCE(tpr.EnfMtdPnlUsd, 0) AS MtdPnlDiff,            
           tpr.MspbYtdPnlUsd,
           tpr.EnfYtdPnlUsd,
           COALESCE(tpr.MspbYtdPnlUsd, 0) - COALESCE(tpr.EnfYtdPnlUsd, 0) AS YtdPnlDiff,
           iSort
      FROM #tmpPortfolioRec tpr
     ORDER BY tpr.iSort,
           tpr.AsOfDate,
           tpr.Strategy,
           tpr.BBYellowKey



    SET NOCOUNT OFF

  END

GO


GRANT EXECUTE ON [dbo].[p_RunDailyPositionRecReports] TO PUBLIC
GO
