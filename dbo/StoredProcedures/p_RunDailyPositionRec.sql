SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  

ALTER PROCEDURE [dbo].[p_RunDailyPositionRec](
    @AsOfDate             DATE NULL = DEFAULT,
    @RstOutput            INT = 1)
 
 /*
  Author:   Lee Kafafian
  Crated:   09/21/2023
  Object:   p_RunDailyPositionRec
  Example:  EXEC dbo.p_RunDailyPositionRec @AsOfDate = '03/01/2024', @RstOutput = 2
            EXEC dbo.p_RunDailyPositionRec @AsOfDate = '11/30/2023', @RstOutput = 2
            EXEC dbo.p_RunDailyPositionRec @AsOfDate = '07/17/2024', @RstOutput = 1
 
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
        LongShort            VARCHAR (255) NULL,
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
           LongShort,
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
           LongShort,
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
           CASE WHEN apd.Custodian = 'PRIV' THEN apd.SecName + ' - Private' ELSE apd.SecName END,
           Account,
           TopLevelTag,
           Strategy,
           BbgShortCode,
           REPLACE(apd.BbgCode, ' ELEC ', ' '),
           CcyCode,
           CASE WHEN apd.BbgCode = 'AMAM US' THEN 'EQUITY' ELSE apd.AssetClass END,
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
           CASE WHEN apd.BbgCode = 'AMAM US' THEN 'EQUITY' ELSE apd.AssetClass END,
           HedgeCore,
           PositionType,
           Custodian,
           LS_Exposure


/*  UPDATE MAPPING NAMES MANUALLY TO GET RID OF THE OTHER MAPPINGS  */
    UPDATE adm
       SET adm.SecName = 'MOLECULAR TEMPLATES - Private (override)'
      FROM #tmpAdminPositions adm
     WHERE CHARINDEX('Mtem', adm.SecName) != 0

/*
    SELECT SUM(tap.DtdPnlUsd) AS DtdPnlUsdAdmin
      FROM #tmpAdminPositions tap
     WHERE (COALESCE(tap.Quantity, 0) = 0 
       AND COALESCE(tap.MarketValue, 0) = 0
       AND COALESCE(tap.YtdPnlUsd, 0) = 0 
       AND COALESCE(tap.MtdPnlUsd, 0) = 0 
       AND COALESCE(tap.DtdPnlUsd, 0) = 0 )


    SELECT SUM(tep.DlyPnlUsd) AS DtdPnlUsdEnf
      FROM #tmpEnfPositionDetails tep
     WHERE (COALESCE(tep.Quantity, 0) = 0 
       AND COALESCE(tep.NetMarketValue, 0) = 0
       AND COALESCE(tep.YtdPnlUsd, 0) = 0 
       AND COALESCE(tep.MtdPnlUsd, 0) = 0 
       AND COALESCE(tep.DlyPnlUsd, 0) = 0 )       
*/


/*  CLEAN DATASETS OF ANYTHING UNRELATED TO THE CURRENT REC PERIOD (YTD)  */
    DELETE tap
      FROM #tmpAdminPositions tap
     WHERE (COALESCE(tap.Quantity, 0) = 0 
       AND COALESCE(tap.MarketValue, 0) = 0
       AND COALESCE(tap.YtdPnlUsd, 0) = 0 
       AND COALESCE(tap.MtdPnlUsd, 0) = 0 
       AND COALESCE(tap.DtdPnlUsd, 0) = 0 )

    DELETE tep
      FROM #tmpEnfPositionDetails tep
     WHERE (COALESCE(tep.Quantity, 0) = 0 
       AND COALESCE(tep.NetMarketValue, 0) = 0
       AND COALESCE(tep.YtdPnlUsd, 0) = 0 
       AND COALESCE(tep.MtdPnlUsd, 0) = 0 
       AND COALESCE(tep.DlyPnlUsd, 0) = 0 )


/* REMOVE ANYTHING THAT WE DON'T WANT TO REC  */
/* FOR NOT LIMITED TO CAPITAL MOVES*/           
    DELETE tap 
      FROM #tmpAdminPositions tap
     WHERE CHARINDEX('Accrued Capital Contribution', tap.SecName ) != 0 

/**/
    DELETE tep 
      FROM #tmpEnfPositionDetails tep
     WHERE CHARINDEX('settled cash', tep.InstDescr) = 0 


/*  START WITH ALL POSITIONS IN ENFUSION  */
    INSERT INTO #tmpRecResults(
           AsOfDate,
           Strategy,
           Book,
           Ticker,
           SecName,
           UnderlySymbol,
           LongShort,
           EnfQuantity,
           EnfDtdPnlUsd,
           EnfMtdPnlUsd,
           EnfYtdPnlUsd)
    SELECT epd.AsOfDate,
           epd.StratName,
           epd.BookName,
           epd.BBYellowKey,
           epd.InstDescr,
           epd.UnderlyBBYellowKey,
           LongShort,
           SUM(epd.Quantity),
           SUM(epd.DlyPnlUsd),
           SUM(epd.MtdPnlUsd),
           SUM(epd.YtdPnlUsd)
      FROM #tmpEnfPositionDetails epd 
     WHERE epd.AsOfDate = @AsOfDate
       AND COALESCE(epd.Quantity, 0) != 0
       AND epd.StratName != ''
       AND epd.BookName != ''
       AND CHARINDEX('settled cash', epd.InstDescr) = 0
       AND epd.bIsUsed = 0
     GROUP BY epd.AsOfDate,
           epd.StratName,
           epd.BookName,
           epd.BBYellowKey,
           epd.InstDescr,
           epd.UnderlyBBYellowKey,
           epd.LongShort

/*  SET USAGE  */
    UPDATE epd
       SET epd.bIsUsed = 1,
           epd.UsageNote = 'Open portfolio positions'
      FROM #tmpEnfPositionDetails epd
     WHERE epd.AsOfDate = @AsOfDate
       AND COALESCE(epd.Quantity, 0) != 0
       AND epd.StratName != ''
       AND epd.BookName != ''
       AND CHARINDEX('Settled Cash', epd.InstDescr) = 0
       AND epd.bIsUsed = 0

/*  UPDATE CLOSED POSITION P&L FROM ENFUSION  */
    UPDATE trr
       SET trr.EnfQuantity = trr.EnfQuantity + epd.Quantity,
           trr.EnfDtdPnlUsd = trr.EnfDtdPnlUsd + epd.DlyPnlUsd,
           trr.EnfMtdPnlUsd = trr.EnfMtdPnlUsd + epd.MtdPnlUsd,
           trr.EnfYtdPnlUsd = trr.EnfYtdPnlUsd + epd.YtdPnlUsd
      FROM #tmpRecResults trr
      JOIN #tmpEnfPositionDetails epd 
        ON trr.AsOfDate = epd.AsOfDate
       AND trr.Ticker = epd.BBYellowKey
       AND trr.SecName = epd.InstDescr
     WHERE ROUND(epd.Quantity, 0) = 0
       --AND ROUND(epd.DlyPnlUsd, 0) != 0
       AND epd.bIsUsed = 0

/*  SET USAGE  */
    UPDATE epd
       SET epd.bIsUsed = 1,
           epd.UsageNote = 'Closed legs of open portfolio positions'
      FROM #tmpEnfPositionDetails epd
      JOIN #tmpRecResults trr
        ON trr.AsOfDate = epd.AsOfDate
       AND trr.Ticker = epd.BBYellowKey
       AND trr.SecName = epd.InstDescr
     WHERE ROUND(epd.Quantity, 0) = 0
       AND epd.bIsUsed = 0


/*  REMOVE "Equity" TAG ON TICKER NAMES  (EQUITIES) */
    UPDATE trr
       SET trr.AdmQuantity = apd.Quantity,
           trr.AdmTicker = apd.BbgCode,
           trr.AdmDtdPnlUsd = apd.DtdPnlUsd,
           trr.AdmMtdPnlUsd = apd.MtdPnlUsd,
           trr.AdmYtdPnlUsd = apd.YtdPnlUsd,
           trr.AdmSecName = apd.SecName,
           trr.bUpdated = 1,
           trr.UpdateRule = 'Equity Ticker Mapping'
      FROM #tmpRecResults trr
      JOIN #tmpAdminPositions apd
        ON trr.AsOfDate = apd.AsOfDate
       AND LTRIM(RTRIM(REPLACE(trr.Ticker, 'Equity', ''))) = LTRIM(RTRIM(REPLACE(apd.BbgCode, 'Equity', '')))
       AND trr.LongShort = apd.LongShort
     WHERE trr.bUpdated = 0
       AND apd.bIsUsed = 0

/*  SET USAGE  */
    UPDATE apd
       SET apd.bIsUsed = 1,
           apd.UsageNote = 'Admin match portfolio postions (omit Equity yellow key)'
      FROM #tmpAdminPositions apd
      JOIN #tmpRecResults trr
        ON trr.AsOfDate = apd.AsOfDate
       AND LTRIM(RTRIM(REPLACE(trr.Ticker, 'Equity', ''))) = LTRIM(RTRIM(REPLACE(apd.BbgCode, 'Equity', '')))
       AND trr.LongShort = apd.LongShort
     WHERE trr.bUpdated = 1
       AND apd.bIsUsed = 0


/*  REMOVE "Equity" TAG ON TICKER NAMES  (EQUITIES) AND REMOVE L/S mapping REQUIREMENT  */
    UPDATE trr
       SET trr.AdmQuantity = apd.Quantity,
           trr.AdmTicker = apd.BbgCode,
           trr.AdmDtdPnlUsd = apd.DtdPnlUsd,
           trr.AdmMtdPnlUsd = apd.MtdPnlUsd,
           trr.AdmYtdPnlUsd = apd.YtdPnlUsd,
           trr.AdmSecName = apd.SecName,
           trr.bUpdated = 1,
           trr.UpdateRule = 'Equity Ticker Mapping - w/o L/S map'
      FROM #tmpRecResults trr
      JOIN #tmpAdminPositions apd
        ON trr.AsOfDate = apd.AsOfDate
       AND LTRIM(RTRIM(REPLACE(trr.Ticker, 'Equity', ''))) = LTRIM(RTRIM(REPLACE(apd.BbgCode, 'Equity', '')))
     WHERE trr.bUpdated = 0
       AND apd.bIsUsed = 0


/*  SET USAGE  */
    UPDATE apd
       SET apd.bIsUsed = 1,
           apd.UsageNote = 'Admin match portfolio postions (omit Equity yellow key)'
      FROM #tmpAdminPositions apd
      JOIN #tmpRecResults trr
        ON trr.AsOfDate = apd.AsOfDate
       AND LTRIM(RTRIM(REPLACE(trr.Ticker, 'Equity', ''))) = LTRIM(RTRIM(REPLACE(apd.BbgCode, 'Equity', '')))
     WHERE trr.bUpdated = 1
       AND apd.bIsUsed = 0

/*  REMOVE "Index" TAG ON TICKER NAMES  */
    UPDATE trr
       SET trr.AdmQuantity = apd.Quantity,
           trr.AdmTicker = apd.BbgCode,
           trr.AdmDtdPnlUsd = apd.DtdPnlUsd,
           trr.AdmMtdPnlUsd = apd.MtdPnlUsd,
           trr.AdmYtdPnlUsd = apd.YtdPnlUsd,
           trr.AdmSecName = apd.SecName,
           trr.bUpdated = 1,
           trr.UpdateRule = 'Index Ticker Mapping'
      FROM #tmpRecResults trr
      JOIN #tmpAdminPositions apd
        ON trr.AsOfDate = apd.AsOfDate
       AND LTRIM(RTRIM(REPLACE(trr.Ticker, 'Index', ''))) = LTRIM(RTRIM(REPLACE(apd.BbgCode, 'Index', '')))
       AND trr.LongShort = apd.LongShort
     WHERE trr.bUpdated = 0
       AND apd.bIsUsed = 0

/*  SET USAGE  */
    UPDATE apd
       SET apd.bIsUsed = 1,
           apd.UsageNote = 'Admin match portfolio postions (omit Index yellow key)'
      FROM #tmpAdminPositions apd
      JOIN #tmpRecResults trr
        ON trr.AsOfDate = apd.AsOfDate
       AND LTRIM(RTRIM(REPLACE(trr.Ticker, 'Index', ''))) = LTRIM(RTRIM(REPLACE(apd.BbgCode, 'Index', '')))
       AND trr.LongShort = apd.LongShort
     WHERE trr.bUpdated = 1
       AND apd.bIsUsed = 0

/*  REMOVE "Index" TAG ON TICKER NAMES AND REMOVE L/S mapping criteria */
    UPDATE trr
       SET trr.AdmQuantity = apd.Quantity,
           trr.AdmTicker = apd.BbgCode,
           trr.AdmDtdPnlUsd = apd.DtdPnlUsd,
           trr.AdmMtdPnlUsd = apd.MtdPnlUsd,
           trr.AdmYtdPnlUsd = apd.YtdPnlUsd,
           trr.AdmSecName = apd.SecName,
           trr.bUpdated = 1,
           trr.UpdateRule = 'Index Ticker Mapping'
      FROM #tmpRecResults trr
      JOIN #tmpAdminPositions apd
        ON trr.AsOfDate = apd.AsOfDate
       AND LTRIM(RTRIM(REPLACE(trr.Ticker, 'Index', ''))) = LTRIM(RTRIM(REPLACE(apd.BbgCode, 'Index', '')))
     WHERE trr.bUpdated = 0
       AND apd.bIsUsed = 0

/*  SET USAGE  */
    UPDATE apd
       SET apd.bIsUsed = 1,
           apd.UsageNote = 'Admin match portfolio postions (omit Index yellow key)'
      FROM #tmpAdminPositions apd
      JOIN #tmpRecResults trr
        ON trr.AsOfDate = apd.AsOfDate
       AND LTRIM(RTRIM(REPLACE(trr.Ticker, 'Index', ''))) = LTRIM(RTRIM(REPLACE(apd.BbgCode, 'Index', '')))
     WHERE trr.bUpdated = 1
       AND apd.bIsUsed = 0


/*  Bloomberg code ON TICKER NAMES  */
    UPDATE trr
       SET trr.AdmQuantity = apd.Quantity,
           trr.AdmTicker = apd.BbgCode,
           trr.AdmDtdPnlUsd = apd.DtdPnlUsd,
           trr.AdmMtdPnlUsd = apd.MtdPnlUsd,
           trr.AdmYtdPnlUsd = apd.YtdPnlUsd,
           trr.AdmSecName = apd.SecName,
           trr.bUpdated = 1,
           trr.UpdateRule = 'Ticker to BbgCode'
      FROM #tmpRecResults trr
      JOIN #tmpAdminPositions apd
        ON trr.AsOfDate = apd.AsOfDate
       AND trr.Ticker = apd.BbgCode
       AND trr.LongShort = apd.LongShort
     WHERE trr.bUpdated = 0
       AND apd.bIsUsed = 0

/*  SET USAGE  */
    UPDATE apd
       SET apd.bIsUsed = 1,
           apd.UsageNote = 'Admin match portfolio postions on BBG Code'
      FROM #tmpAdminPositions apd
      JOIN #tmpRecResults trr
        ON trr.AsOfDate = apd.AsOfDate
       AND trr.Ticker = apd.BbgCode
       AND trr.LongShort = apd.LongShort
     WHERE trr.bUpdated = 1
       AND apd.bIsUsed = 0


/*  PRIVATE SECURITY MAPPING   */    
    UPDATE trr
       SET trr.AdmQuantity = apd.Quantity,
           trr.AdmTicker = apd.BbgCode,
           trr.AdmDtdPnlUsd = apd.DtdPnlUsd,
           trr.AdmMtdPnlUsd = apd.MtdPnlUsd,
           trr.AdmYtdPnlUsd = apd.YtdPnlUsd,
           trr.AdmSecName = apd.SecName,
           trr.bUpdated = 1,
           trr.UpdateRule = 'Private Mapping'
      FROM #tmpRecResults trr
      JOIN #tmpAdminPositions apd
        ON trr.AsOfDate = apd.AsOfDate
       AND LEFT(trr.SecName, CHARINDEX(' ', trr.SecName)) = LEFT(apd.SecName, CHARINDEX(' ', apd.SecName))
     WHERE trr.bUpdated = 0
       AND apd.bIsUsed = 0
       AND CHARINDEX('Private', trr.SecName) ! = 0
       AND CHARINDEX('Private', apd.SecName) != 0

/*  SET USAGE  */
    UPDATE apd
       SET apd.bIsUsed = 1,
           apd.UsageNote = 'Admin match portfolio PRIVATE positions'
      FROM #tmpAdminPositions apd
      JOIN #tmpRecResults trr
        ON trr.AsOfDate = apd.AsOfDate
       AND LEFT(trr.SecName, CHARINDEX(' ', trr.SecName)) = LEFT(apd.SecName, CHARINDEX(' ', apd.SecName))
     WHERE trr.bUpdated = 1
       AND apd.bIsUsed = 0
       AND CHARINDEX('Private', trr.SecName) ! = 0
       AND CHARINDEX('Private', apd.SecName) != 0


/*  WARRANT SECURITY MAPPING   */    
    UPDATE trr
       SET trr.AdmQuantity = apd.Quantity,
           trr.AdmTicker = apd.BbgCode,
           trr.AdmDtdPnlUsd = apd.DtdPnlUsd,
           trr.AdmMtdPnlUsd = apd.MtdPnlUsd,
           trr.AdmYtdPnlUsd = apd.YtdPnlUsd,
           trr.AdmSecName = apd.SecName,
           trr.bUpdated = 1,
           trr.UpdateRule = 'Warrant Mapping'
      FROM #tmpRecResults trr
      JOIN #tmpAdminPositions apd
        ON trr.AsOfDate = apd.AsOfDate
       AND CHARINDEX(apd.UnderlySymbol, trr.UnderlySymbol) != 0
     WHERE trr.bUpdated = 0
       AND apd.bIsUsed = 0
       AND CHARINDEX('Warrant', trr.SecName) ! = 0
       AND CHARINDEX('Warrant', apd.SecName) != 0

/*  SET USAGE  */
    UPDATE apd
       SET apd.bIsUsed = 1,
           apd.UsageNote = 'Admin match portfolio WARRANT positions on underlying'
      FROM #tmpAdminPositions apd
      JOIN #tmpRecResults trr
        ON trr.AsOfDate = apd.AsOfDate
       AND CHARINDEX(apd.UnderlySymbol, trr.UnderlySymbol) != 0
     WHERE trr.bUpdated = 1
       AND apd.bIsUsed = 0
       AND CHARINDEX('Warrant', trr.SecName) ! = 0
       AND CHARINDEX('Warrant', apd.SecName) != 0


/*  BASKET SECURITY MAPPING   */    
    UPDATE trr
       SET trr.AdmQuantity = apd.Quantity,
           trr.AdmTicker = apd.BbgCode,
           trr.AdmDtdPnlUsd = apd.DtdPnlUsd,
           trr.AdmMtdPnlUsd = apd.MtdPnlUsd,
           trr.AdmYtdPnlUsd = apd.YtdPnlUsd,
           trr.AdmSecName = apd.SecName,
           trr.bUpdated = 1,
           trr.UpdateRule = 'Basket Mapping'
      FROM #tmpRecResults trr
      JOIN #tmpAdminPositions apd
        ON trr.AsOfDate = apd.AsOfDate
       AND CHARINDEX(apd.SecName, trr.secName) != 0
       AND CHARINDEX('Abivax', apd.SecName) = 0
     WHERE trr.bUpdated = 0
       AND apd.bIsUsed = 0 

/*  SET USAGE  */
    UPDATE apd
       SET apd.bIsUsed = 1,
           apd.UsageNote = 'Admin match portfolio BASKET positions'
      FROM #tmpAdminPositions apd
      JOIN #tmpRecResults trr
        ON trr.AsOfDate = apd.AsOfDate
       AND CHARINDEX(apd.SecName, trr.secName) != 0
       AND CHARINDEX('Abivax', apd.SecName) = 0
     WHERE trr.bUpdated = 1
       AND apd.bIsUsed = 0 

/*  OTHER MAPPING   */    
    UPDATE trr
       SET trr.AdmQuantity = apd.Quantity,
           trr.AdmTicker = apd.BbgCode,
           trr.AdmDtdPnlUsd = apd.DtdPnlUsd,
           trr.AdmMtdPnlUsd = apd.MtdPnlUsd,
           trr.AdmYtdPnlUsd = apd.YtdPnlUsd,
           trr.AdmSecName = apd.SecName,
           trr.bUpdated = 1,
           trr.UpdateRule = 'Other Mapping'
      FROM #tmpRecResults trr
      JOIN #tmpAdminPositions apd
        ON trr.AsOfDate = apd.AsOfDate
       AND CHARINDEX(LEFT(apd.SecName, CHARINDEX(' ', apd.SecName)), trr.secName) != 0
       AND COALESCE(apd.SecName, '') NOT IN (SELECT COALESCE(trr.AdmSecName, '') FROM #tmpRecResults trr)
     WHERE trr.bUpdated = 0
       AND apd.bIsUsed = 0
       AND COALESCE(apd.Quantity, 0) != 0

/*  SET USAGE  */
    UPDATE apd
       SET apd.bIsUsed = 1,
           apd.UsageNote = 'Admin match portfolio OTHER MAPPING positions'
      FROM #tmpAdminPositions apd
      JOIN #tmpRecResults trr
        ON trr.AsOfDate = apd.AsOfDate
       AND CHARINDEX(CASE WHEN LEFT(apd.SecName, CHARINDEX(' ', apd.SecName)) = 'Mtem' THEN 'MOLECULAR' ELSE LEFT(apd.SecName, CHARINDEX(' ', apd.SecName)) END, trr.secName) != 0
       AND COALESCE(apd.SecName, '') NOT IN (SELECT COALESCE(trr.AdmSecName, '') FROM #tmpRecResults trr)
     WHERE trr.bUpdated = 1
       AND apd.bIsUsed = 0
       AND COALESCE(apd.Quantity, 0) != 0

/*  OTHER MAPPING 2  */    
    UPDATE trr
       SET trr.AdmQuantity = apd.Quantity,
           trr.AdmTicker = apd.BbgCode,
           trr.AdmDtdPnlUsd = apd.DtdPnlUsd,
           trr.AdmMtdPnlUsd = apd.MtdPnlUsd,
           trr.AdmYtdPnlUsd = apd.YtdPnlUsd,
           trr.AdmSecName = apd.SecName,
           trr.bUpdated = 1,
           trr.UpdateRule = 'Other Mapping 2'
      FROM #tmpRecResults trr
      JOIN #tmpAdminPositions apd
        ON trr.AsOfDate = apd.AsOfDate
       AND CASE WHEN RTRIM(LTRIM(apd.SecName)) = 'Gossamer Bio Inc' AND RTRIM(LTRIM(apd.Custodian)) = 'PRIV' THEN 'GOSSAMER BIO ORD - Private' ELSE LTRIM(RTRIM(apd.SecName)) END = RTRIM(LTRIM(trr.secName))
     WHERE ROUND(apd.Quantity, 0) != 0
       AND trr.bUpdated = 0
       AND apd.bIsUsed = 0

/*  SET USAGE  */
    UPDATE apd
       SET apd.bIsUsed = 1,
           apd.UsageNote = 'Admin match portfolio OTHER MAPPING 2 positions'
      FROM #tmpAdminPositions apd
      JOIN #tmpRecResults trr
        ON trr.AsOfDate = apd.AsOfDate
       AND CASE WHEN RTRIM(LTRIM(apd.SecName)) = 'Gossamer Bio Inc' AND RTRIM(LTRIM(apd.Custodian)) = 'PRIV' THEN 'GOSSAMER BIO ORD - Private' ELSE LTRIM(RTRIM(apd.SecName)) END = RTRIM(LTRIM(trr.secName))
     WHERE ROUND(apd.Quantity, 0) != 0
       AND trr.bUpdated = 1
       AND apd.bIsUsed = 0

/*  ABSENSE OF MAPPINGS ON ADMIN DATA  */
    INSERT INTO #tmpRecResults(
           AsOfDate,
           Strategy,
           Book,
           Ticker,
           UnderlySymbol,
           AdmSecName,
           bUpdated,
           UpdateRule,
           AdmQuantity,
           AdmDtdPnlUsd,
           AdmMtdPnlUsd,
           AdmYtdPnlUsd)
    SELECT apd.AsOfDate,
           apd.TopLevelTag,
           apd.Strategy,
           apd.BBgCode,
           apd.UnderlySymbol,
           apd.SecName,
           1,
           'Unmapped MSFS',
           SUM(apd.Quantity),
           SUM(apd.DtdPnlUsd),
           SUM(apd.MtdPnlUsd),
           SUM(apd.YtdPnlUsd)
      FROM #tmpAdminPositions apd 
     WHERE apd.AsOfDate = @AsOfDate
       AND ROUND(apd.Quantity, 0) != 0
       AND COALESCE(apd.SecName, '') NOT IN (SELECT COALESCE(trr.AdmSecName, '') FROM #tmpRecResults trr)
       AND apd.AssetClass NOT IN ('CURRENCY FORWARDS', 'CASH', 'CURRENCY SPOTS')
       AND apd.bIsUsed = 0
     GROUP BY apd.AsOfDate,
           apd.TopLevelTag,
           apd.Strategy,
           apd.BBgCode,
           apd.SecName,
           apd.UnderlySymbol

/*  SET USAGE  */
    UPDATE apd
       SET apd.bIsUsed = 1,
           apd.UsageNote = 'Unmapped admin positions'
      FROM #tmpAdminPositions apd 
     WHERE apd.AsOfDate = @AsOfDate
       AND ROUND(apd.Quantity, 0) != 0
       AND COALESCE(apd.SecName, '') IN (SELECT COALESCE(trr.AdmSecName, '') FROM #tmpRecResults trr)
       AND apd.AssetClass NOT IN ('CURRENCY FORWARDS', 'CASH', 'CURRENCY SPOTS')
       AND apd.bIsUsed = 0

/*  MSFS Unmapped - update from Enfusion  */    
    UPDATE trr
       SET trr.EnfQuantity = epd.Quantity,
           trr.Ticker = epd.BBYellowKey,
           trr.EnfDtdPnlUsd = epd.DlyPnlUsd,
           trr.EnfMtdPnlUsd = epd.MtdPnlUsd,
           trr.EnfYtdPnlUsd = epd.YtdPnlUsd,
           trr.SecName = epd.InstDescr,
           trr.bUpdated = 1,
           trr.UpdateRule = 'MSFS Only (Enfusion closed)'
      FROM #tmpRecResults trr
      JOIN #tmpEnfPositionDetails epd
        ON trr.AsOfDate = epd.AsOfDate
       AND CHARINDEX(trr.AdmTicker, epd.BBYellowKey) != 0 
     WHERE ROUND(epd.Quantity, 0) != 0
       AND trr.bUpdated = 0
       AND epd.bIsUsed = 0


/*  SET USAGE  */
    UPDATE epd
       SET epd.bIsUsed = 1,
           epd.UsageNote = 'Map Enf closed to Admin only'
      FROM #tmpEnfPositionDetails epd
      JOIN #tmpRecResults trr
        ON trr.AsOfDate = epd.AsOfDate
       AND CHARINDEX(trr.AdmTicker, epd.BBYellowKey) != 0 
     WHERE ROUND(epd.Quantity, 0) != 0
       AND trr.bUpdated = 1
       AND epd.bIsUsed = 0


/*  ADMIN CASH AND FORWARDS CONSOLIDATED */
    INSERT INTO #tmpRecResultsNonSec(
           AsOfDate,
           Strategy,
           Book,
           AdmTicker,
           AdmSecName,
           bUpdated,
           iSort,
           UpdateRule,
           AdmQuantity,
           AdmDtdPnlUsd,
           AdmMtdPnlUsd,
           AdmYtdPnlUsd)
    SELECT apd.AsOfDate,
           'CURRENCY FORWARDS, CASH and SPOTS',
           'NA',
           apd.CcyCode,
           apd.CcyCode,
           1,
           5,
           NULL,
           SUM(apd.Quantity),
           SUM(apd.DtdPnlUsd),
           SUM(apd.MtdPnlUsd),
           SUM(apd.YtdPnlUsd)
      FROM #tmpAdminPositions apd 
     WHERE apd.AsOfDate = @AsOfDate 
       AND COALESCE(RTRIM(LTRIM(apd.SecName)), '') NOT IN (SELECT COALESCE(RTRIM(LTRIM(trr.AdmSecName)), '') FROM #tmpRecResults trr)
       AND apd.AssetClass IN ('CURRENCY FORWARDS', 'CASH', 'CURRENCY SPOTS')
       AND apd.bIsUsed = 0
     GROUP BY apd.AsOfDate,
           apd.CcyCode

/*  SET USAGE  */
    UPDATE apd
       SET apd.bIsUsed = 1,
           apd.UsageNote = 'Admin Cash, FX, Spot'
      FROM #tmpAdminPositions apd 
     WHERE apd.AsOfDate = @AsOfDate 
       AND COALESCE(RTRIM(LTRIM(apd.SecName)), '') NOT IN (SELECT COALESCE(RTRIM(LTRIM(trr.AdmSecName)), '') FROM #tmpRecResults trr)
       AND apd.AssetClass IN ('CURRENCY FORWARDS', 'CASH', 'CURRENCY SPOTS')
       AND apd.bIsUsed = 0


/*  ADMIN INCOME AND EXPENSES */
    INSERT INTO #tmpRecResultsNonSec(
           AsOfDate,
           Strategy,
           Book,
           AdmTicker,
           AdmSecName,
           bUpdated,
           iSort,
           UpdateRule,
           AdmQuantity,
           AdmDtdPnlUsd,
           AdmMtdPnlUsd,
           AdmYtdPnlUsd)
    SELECT apd.AsOfDate,
           'INCOME & EXPENSES',
           'NA',
           apd.BbgCode,
           apd.SecName,
           1,
           10,
           NULL,
           SUM(apd.Quantity),
           SUM(apd.DtdPnlUsd),
           SUM(apd.MtdPnlUsd),
           SUM(apd.YtdPnlUsd)
      FROM #tmpAdminPositions apd 
     WHERE apd.AsOfDate = @AsOfDate 
       AND COALESCE(RTRIM(LTRIM(apd.SecName)), '') NOT IN (SELECT COALESCE(RTRIM(LTRIM(trr.AdmSecName)), '') FROM #tmpRecResults trr)
       AND apd.AssetClass IN ('INCOME/EXPENSE', 'PREPAID EXPENSE', 'ACCRUED EXPENSE', 'ACCRUED INCOME')
       AND apd.bIsUsed = 0
     GROUP BY apd.AsOfDate,
           apd.BbgCode,
           apd.SecName

/*  SET USAGE  */
    UPDATE apd
       SET apd.bIsUsed = 1,
           apd.UsageNote = 'Income and Expenses'
      FROM #tmpAdminPositions apd 
     WHERE apd.AsOfDate = @AsOfDate 
       AND COALESCE(RTRIM(LTRIM(apd.SecName)), '') NOT IN (SELECT COALESCE(RTRIM(LTRIM(trr.AdmSecName)), '') FROM #tmpRecResults trr)
       AND apd.AssetClass IN ('INCOME/EXPENSE', 'PREPAID EXPENSE', 'ACCRUED EXPENSE', 'ACCRUED INCOME')
       AND apd.bIsUsed = 0

/*  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  */
/*  BEGIN CLOSED POSITIONS   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  */
/*  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  */

/*  ENFUSION CLOSED POSITIONS */
    INSERT INTO #tmpRecResultsNonSec(
           AsOfDate,
           Strategy,
           Book,
           Ticker,
           SecName,
           bUpdated,
           iSort,
           UpdateRule,
           EnfQuantity,
           EnfDtdPnlUsd,
           EnfMtdPnlUsd,
           EnfYtdPnlUsd)
    SELECT epd.AsOfDate,
           'CLOSED POSITIONS',
           'NA',
           epd.BBYellowKey,
           epd.InstDescr,
           0,
           11,
           'Enfusion closed positions',
           SUM(epd.Quantity),
           SUM(epd.DlyPnlUsd),
           SUM(epd.MtdPnlUsd),
           SUM(epd.YtdPnlUsd)
      FROM #tmpEnfPositionDetails epd 
     WHERE epd.AsOfDate = epd.AsOfDate
       AND ROUND(epd.Quantity, 0) = 0
       AND ROUND(epd.DlyPnlUsd, 0) = 0
       AND epd.Account IN ('MS Cash', 'MS Swap', 'MS Futures')
       AND epd.AsOfDate = @AsOfDate
       AND epd.bIsUsed = 0
     GROUP BY epd.AsOfDate,
           epd.BBYellowKey,
           epd.InstDescr

/*  SET USAGE  */
    UPDATE epd
       SET epd.bIsUsed = 1,
           epd.UsageNote = 'Enfusion CLOSED positions'
      FROM #tmpEnfPositionDetails epd 
     WHERE epd.AsOfDate = epd.AsOfDate
       AND ROUND(epd.Quantity, 0) = 0
       AND epd.Account IN ('MS Cash', 'MS Swap', 'MS Futures')
       AND epd.AsOfDate = @AsOfDate
       AND epd.bIsUsed = 0


/*  REMOVE "Equity" TAG ON TICKER NAMES  (EQUITIES) WITHOUT LONG SHORT MAPPING  */
    UPDATE trr
       SET trr.AdmQuantity = apd.Quantity,
           trr.AdmTicker = apd.BbgCode,
           trr.AdmDtdPnlUsd = apd.DtdPnlUsd,
           trr.AdmMtdPnlUsd = apd.MtdPnlUsd,
           trr.AdmYtdPnlUsd = apd.YtdPnlUsd,
           trr.AdmSecName = apd.SecName,
           trr.bUpdated = 1,
           trr.UpdateRule = 'Equity Ticker Mapping'
      FROM #tmpRecResultsNonSec trr
      JOIN #tmpAdminPositions apd
        ON trr.AsOfDate = apd.AsOfDate
       AND LTRIM(RTRIM(REPLACE(trr.Ticker, 'Equity', ''))) = LTRIM(RTRIM(REPLACE(apd.BbgCode, 'Equity', '')))
     WHERE trr.Strategy = 'CLOSED POSITIONS'
       AND ROUND(apd.Quantity, 0) = 0
       AND ROUND(apd.DtdPnlUsd, 0) = 0
       AND trr.bUpdated = 0
       AND apd.bIsUsed = 0

/*  SET USAGE  */
    UPDATE apd
       SET apd.bIsUsed = 1,
           apd.UsageNote = 'Admin match portfolio postions (omit Equity yellow key)'
      FROM #tmpAdminPositions apd
      JOIN #tmpRecResultsNonSec trr
        ON trr.AsOfDate = apd.AsOfDate
       AND LTRIM(RTRIM(REPLACE(trr.Ticker, 'Equity', ''))) = LTRIM(RTRIM(REPLACE(apd.BbgCode, 'Equity', '')))
     WHERE trr.Strategy = 'CLOSED POSITIONS'
       AND ROUND(apd.Quantity, 0) = 0
       AND trr.bUpdated = 1
       AND apd.bIsUsed = 0

/*  ADMIN CLOSED POSITIONS */
    INSERT INTO #tmpRecResultsNonSec(
           AsOfDate,
           Strategy,
           Book,
           AdmTicker,
           AdmSecName,
           bUpdated,
           iSort,
           UpdateRule,
           AdmQuantity,
           AdmDtdPnlUsd,
           AdmMtdPnlUsd,
           AdmYtdPnlUsd)
    SELECT apd.AsOfDate,
           'CLOSED POSITIONS',
           'NA',
           apd.BbgCode,
           apd.SecName,
           1,
           20,
           'Admin closed positions sweep',
           SUM(apd.Quantity),
           SUM(apd.DtdPnlUsd),
           SUM(apd.MtdPnlUsd),
           SUM(apd.YtdPnlUsd)
      FROM #tmpAdminPositions apd 
     WHERE apd.AsOfDate = @AsOfDate
       AND apd.AssetClass NOT IN ('CURRENCY FORWARDS', 'CASH', 'CURRENCY SPOTS')
       AND apd.AssetClass NOT IN ('INCOME/EXPENSE', 'PREPAID EXPENSE', 'ACCRUED EXPENSE', 'ACCRUED INCOME')
       AND COALESCE(RTRIM(LTRIM(apd.SecName)), '') NOT IN (SELECT COALESCE(RTRIM(LTRIM(trr.AdmSecName)), '') FROM #tmpRecResults trr)
       AND COALESCE(RTRIM(LTRIM(apd.SecName)), '') NOT IN (SELECT COALESCE(RTRIM(LTRIM(trr.AdmSecName)), '') FROM #tmpRecResultsNonSec trr)
       AND apd.bIsUsed = 0
     GROUP BY apd.AsOfDate,
           apd.BbgCode,
           apd.SecName

/*  SET USAGE  */
    UPDATE apd
       SET apd.bIsUsed = 1,
           apd.UsageNote = 'Admin Closed Positions'
      FROM #tmpAdminPositions apd 
     WHERE apd.AsOfDate = @AsOfDate 
       AND COALESCE(RTRIM(LTRIM(apd.SecName)), '') NOT IN (SELECT COALESCE(RTRIM(LTRIM(trr.AdmSecName)), '') FROM #tmpRecResults trr)
       AND apd.AssetClass NOT IN ('CURRENCY FORWARDS', 'CASH', 'CURRENCY SPOTS')
       AND apd.AssetClass NOT IN ('INCOME/EXPENSE', 'PREPAID EXPENSE', 'ACCRUED EXPENSE', 'ACCRUED INCOME')
       AND apd.bIsUsed = 0


/*  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  */
/*  END CLOSED POSITIONS   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  */
/*  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  */

/*  ADMIN UNMAPPED POSITIONS */
    INSERT INTO #tmpRecResultsNonSec(
           AsOfDate,
           Strategy,
           Book,
           AdmTicker,
           UnderlySymbol,
           AdmSecName,
           bUpdated,
           UpdateRule,
           AdmQuantity,
           AdmDtdPnlUsd,
           AdmMtdPnlUsd,
           AdmYtdPnlUsd)
    SELECT apd.AsOfDate,
           'UNMAPPED POSITIONS',
           'NA',
           apd.BbgCode,
           apd.SecName,
           1,
           20,
           'Admin unmapped positions',
           SUM(apd.Quantity),
           SUM(apd.DtdPnlUsd),
           SUM(apd.MtdPnlUsd),
           SUM(apd.YtdPnlUsd)
      FROM #tmpAdminPositions apd 
     WHERE apd.AsOfDate = @AsOfDate
       AND COALESCE(apd.SecName, '') NOT IN (SELECT COALESCE(trr.AdmSecName, trr.SecName, '') FROM #tmpRecResults trr) 
       AND apd.bIsUsed = 0
     GROUP BY apd.AsOfDate,
           apd.BbgCode,
           apd.SecName

/*  SET USAGE  */
    UPDATE apd
       SET apd.bIsUsed = 1,
           apd.UsageNote = 'Admin unmapped positions'
      FROM #tmpAdminPositions apd 
     WHERE apd.AsOfDate = @AsOfDate 
       AND apd.bIsUsed = 0


/*  ENFUSION INCOME AND EXPENSES */
    INSERT INTO #tmpRecResultsNonSec(
           AsOfDate,
           Strategy,
           Book,
           Ticker,
           SecName,
           bUpdated,
           iSort,
           UpdateRule,
           EnfQuantity,
           EnfDtdPnlUsd,
           EnfMtdPnlUsd,
           EnfYtdPnlUsd)
    SELECT epd.AsOfDate,
           'INCOME & EXPENSES',
           'NA',
           epd.BBYellowKey,
           epd.InstDescr,
           1,
           11,
           'Enfusion Income and Expsenses',
           SUM(epd.Quantity),
           SUM(epd.DlyPnlUsd),
           SUM(epd.MtdPnlUsd),
           SUM(epd.YtdPnlUsd)
      FROM #tmpEnfPositionDetails epd 
     WHERE epd.AsOfDate = epd.AsOfDate
       AND epd.InstrType IN ('Cash') 
       AND epd.Account IN ('Non-Trading')
       AND epd.AsOfDate = @AsOfDate
       AND epd.bIsUsed = 0
     GROUP BY epd.AsOfDate,
           epd.BBYellowKey,
           epd.InstDescr

/*  SET USAGE  */
    UPDATE epd
       SET epd.bIsUsed = 1,
           epd.UsageNote = 'Enfusion Income and Expenses'
      FROM #tmpEnfPositionDetails epd 
     WHERE epd.AsOfDate = epd.AsOfDate
       AND epd.InstrType IN ('Cash') 
       AND epd.Account IN ('Non-Trading')
       AND epd.AsOfDate = @AsOfDate
       AND epd.bIsUsed = 0

/*  ENFUSION CASH FX SPOTS */
    INSERT INTO #tmpRecResultsNonSec(
           AsOfDate,
           Strategy,
           Book,
           Ticker,
           SecName,
           bUpdated,
           iSort,
           UpdateRule,
           EnfQuantity,
           EnfDtdPnlUsd,
           EnfMtdPnlUsd,
           EnfYtdPnlUsd)
    SELECT epd.AsOfDate,
           'CURRENCY FORWARDS, CASH and SPOTS',
           'NA',
           epd.BBYellowKey,
           epd.InstDescr,
           1,
           11,
           'Enfusion Cash, FX and Spot',
           SUM(epd.Quantity),
           SUM(epd.DlyPnlUsd),
           SUM(epd.MtdPnlUsd),
           SUM(epd.YtdPnlUsd)
      FROM #tmpEnfPositionDetails epd 
     WHERE epd.AsOfDate = epd.AsOfDate
       AND epd.InstrType IN ('Cash', 'FX Forward') 
       AND epd.Account NOT IN ('Non-Trading')
       AND epd.AsOfDate = @AsOfDate
       AND epd.bIsUsed = 0
     GROUP BY epd.AsOfDate,
           epd.BBYellowKey,
           epd.InstDescr

/*  SET USAGE  */
    UPDATE epd
       SET epd.bIsUsed = 1,
           epd.UsageNote = 'Enfusion Cash, FX, Spot'
      FROM #tmpEnfPositionDetails epd 
     WHERE epd.AsOfDate = epd.AsOfDate
       AND epd.InstrType IN ('Cash', 'FX Forward') 
       AND epd.Account NOT IN ('Non-Trading')
       AND epd.AsOfDate = @AsOfDate
       AND epd.bIsUsed = 0


IF @RstOutput = 1
  BEGIN
/* INSERT AGGREGATE NON-SEC ITEMS FIRST  */
   INSERT INTO #tmpRecResults(
          AsOfDate,
          Strategy,
          Book,
          Ticker,
          SecName,
          AdmSecName,
          AdmTicker,
          EnfQuantity,
          AdmQuantity,
          EnfDtdPnlUsd,
          AdmDtdPnlUsd,
          EnfMtdPnlUsd,
          AdmMtdPnlUsd,
          EnfYtdPnlUsd,
          AdmYtdPnlUsd,
          bUpdated,
          UpdateRule,
          iSort)
   SELECT tns.AsOfDate,
          tns.Strategy,
          tns.Book,
          'NA',
          'NA',
          'NA',
          'NA',
          SUM(0),
          SUM(0),
          SUM(tns.EnfDtdPnlUsd),
          SUM(tns.AdmDtdPnlUsd),
          SUM(tns.EnfMtdPnlUsd),
          SUM(tns.AdmMtdPnlUsd),
          SUM(tns.EnfYtdPnlUsd),
          SUM(tns.AdmYtdPnlUsd),
          1,
          'Aggregate',
          MAX(iSort)           
     FROM #tmpRecResultsNonSec tns
    GROUP BY tns.AsOfDate,
          tns.Strategy,
          tns.Book

    SELECT trr.AsOfDate,
           trr.Strategy,
           trr.Book,
           trr.Ticker,
           trr.SecName,
           trr.AdmSecName,
           trr.AdmTicker,
           trr.EnfQuantity,
           trr.AdmQuantity,
           COALESCE(trr.EnfQuantity, 0) - COALESCE(trr.AdmQuantity, 0) AS QuantityDiff,
           trr.EnfDtdPnlUsd,
           trr.AdmDtdPnlUsd,
           COALESCE(trr.EnfDtdPnlUsd, 0) - COALESCE(trr.AdmDtdPnlUsd, 0) AS DtdPnLUsdDiff,
           trr.EnfMtdPnlUsd,
           trr.AdmMtdPnlUsd,
           COALESCE(trr.EnfMtdPnlUsd, 0) - COALESCE(trr.AdmMtdPnlUsd, 0) AS MtdPnLUsdDiff,
           trr.EnfYtdPnlUsd,
           trr.AdmYtdPnlUsd,
           COALESCE(trr.EnfYtdPnlUsd, 0) - COALESCE(trr.AdmYtdPnlUsd, 0) AS YtdPnLUsdDiff,
           bUpdated,
           UpdateRule
      FROM #tmpRecResults trr
     WHERE (COALESCE(trr.EnfQuantity, 0) != 0 
        OR COALESCE(trr.AdmQuantity, 0) != 0 
        OR COALESCE(trr.EnfDtdPnlUsd, 0) != 0 
        OR COALESCE(trr.AdmDtdPnlUsd, 0) != 0 
        OR COALESCE(trr.EnfMtdPnlUsd, 0) != 0 
        OR COALESCE(trr.AdmMtdPnlUsd, 0) != 0 
        OR COALESCE(trr.EnfYtdPnlUsd, 0) != 0 
        OR COALESCE(trr.AdmYtdPnlUsd, 0) != 0)
     ORDER BY trr.iSort,
           trr.bUpdated,
           trr.AsOfDate, 
           trr.Strategy,
           trr.Book,
           trr.SecName
  END
ELSE
  BEGIN
    SELECT trr.AsOfDate,
           trr.Strategy,
           trr.Book,
           trr.Ticker,
           trr.SecName,
           trr.AdmSecName,
           trr.AdmTicker,
           trr.EnfQuantity,
           trr.AdmQuantity,
           COALESCE(trr.EnfQuantity, 0) - COALESCE(trr.AdmQuantity, 0) AS QuantityDiff,
           trr.EnfDtdPnlUsd,
           trr.AdmDtdPnlUsd,
           COALESCE(trr.EnfDtdPnlUsd, 0) - COALESCE(trr.AdmDtdPnlUsd, 0) AS DtdPnLUsdDiff,
           trr.EnfMtdPnlUsd,
           trr.AdmMtdPnlUsd,
           COALESCE(trr.EnfMtdPnlUsd, 0) - COALESCE(trr.AdmMtdPnlUsd, 0) AS MtdPnLUsdDiff,
           trr.EnfYtdPnlUsd,
           trr.AdmYtdPnlUsd,
           COALESCE(trr.EnfYtdPnlUsd, 0) - COALESCE(trr.AdmYtdPnlUsd, 0) AS YtdPnLUsdDiff,
           bUpdated,
           UpdateRule
      FROM #tmpRecResultsNonSec trr 
     WHERE trr.Strategy = 'CLOSED POSITIONS'
       AND (COALESCE(trr.EnfQuantity, 0) != 0 
        OR COALESCE(trr.AdmQuantity, 0) != 0 
        OR COALESCE(trr.EnfDtdPnlUsd, 0) != 0 
        OR COALESCE(trr.AdmDtdPnlUsd, 0) != 0 
        OR COALESCE(trr.EnfMtdPnlUsd, 0) != 0 
        OR COALESCE(trr.AdmMtdPnlUsd, 0) != 0 
        OR COALESCE(trr.EnfYtdPnlUsd, 0) != 0 
        OR COALESCE(trr.AdmYtdPnlUsd, 0) != 0)
     ORDER BY trr.iSort,
           trr.bUpdated,
           trr.AsOfDate, 
           trr.Strategy,
           trr.Book,
           trr.SecName
  END            
        

    SET NOCOUNT OFF

  END

GO

GRANT EXECUTE ON dbo.p_RunDailyPositionRec TO PUBLIC
GO      

