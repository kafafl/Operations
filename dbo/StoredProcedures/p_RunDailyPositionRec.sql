  CREATE PROCEDURE dbo.p_RunDailyPositionRec(
    @AsOfDate             DATE NULL = DEFAULT)
 
 /*
  Author: Lee Kafafian
  Crated: 09/21/2023
  Object: p_RunDailyPositionRec
  Example:  EXEC dbo.p_RunDailyPositionRec @AsOfDate = '10/16/2023'
 */
  
 AS 

   BEGIN

   SET NOCOUNT ON

    DECLARE @AsOfDateCheck AS DATE

    SELECT TOP 1 @AsOfDateCheck = epd.AsOfDate FROM dbo.EnfPositionDetails epd ORDER BY epd.AsOfDate DESC

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
        bUpdated           BIT DEFAULT 0,
        UpdateRule         VARCHAR(255))

/* START WITH ALL POSITIONS IN ENFUSION  */
    INSERT INTO #tmpRecResults(
           AsOfDate,
           Strategy,
           Book,
           Ticker,
           SecName,
           UnderlySymbol,
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
           SUM(epd.Quantity),
           SUM(epd.DlyPnlUsd),
           SUM(epd.MtdPnlUsd),
           SUM(epd.YtdPnlUsd)
      FROM dbo.EnfPositionDetails epd 
     WHERE epd.AsOfDate = @AsOfDate
       AND epd.Quantity != 0
       AND epd.StratName != ''
       AND epd.BookName != ''
       AND CHARINDEX('Settled Cash', epd.InstDescr) = 0
     GROUP BY epd.AsOfDate,
           epd.StratName,
           epd.BookName,
           epd.BBYellowKey,
           epd.InstDescr,
           epd.UnderlyBBYellowKey


/*  UPDATE CLOSED POSITION P&L FROM ENFUSION  */
    UPDATE trr
       SET trr.EnfQuantity = trr.EnfQuantity + epd.Quantity,
           trr.EnfDtdPnlUsd = trr.EnfDtdPnlUsd + epd.DlyPnlUsd,
           trr.EnfMtdPnlUsd = trr.EnfMtdPnlUsd + epd.MtdPnlUsd,
           trr.EnfYtdPnlUsd = trr.EnfYtdPnlUsd + epd.YtdPnlUsd
      FROM #tmpRecResults trr
      JOIN dbo.EnfPositionDetails epd 
        ON trr.AsOfDate = epd.AsOfDate
       AND trr.Ticker = epd.BBYellowKey
       AND trr.SecName = epd.InstDescr
     WHERE epd.Quantity = 0      



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
      JOIN dbo.AdminPositionDetails apd
        ON trr.AsOfDate = apd.AsOfDate
       AND LTRIM(RTRIM(REPLACE(trr.Ticker, 'Equity', ''))) = LTRIM(RTRIM(REPLACE(apd.BbgCode, 'Equity', '')))
     WHERE trr.bUpdated = 0

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
      JOIN dbo.AdminPositionDetails apd
        ON trr.AsOfDate = apd.AsOfDate
       AND LTRIM(RTRIM(REPLACE(trr.Ticker, 'Index', ''))) = LTRIM(RTRIM(REPLACE(apd.BbgCode, 'Index', '')))
     WHERE trr.bUpdated = 0

/*  REMOVE "Index" TAG ON TICKER NAMES  */
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
      JOIN dbo.AdminPositionDetails apd
        ON trr.AsOfDate = apd.AsOfDate
       AND trr.Ticker = apd.BbgCode
     WHERE trr.bUpdated = 0

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
      JOIN dbo.AdminPositionDetails apd
        ON trr.AsOfDate = apd.AsOfDate
       AND LEFT(trr.SecName, CHARINDEX(' ', trr.SecName)) = LEFT(apd.SecName, CHARINDEX(' ', apd.SecName))
       --AND CHARINDEX(apd.UnderlySymbol, trr.UnderlySymbol) != 0
     WHERE trr.bUpdated = 0
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
      JOIN dbo.AdminPositionDetails apd
        ON trr.AsOfDate = apd.AsOfDate
       AND CHARINDEX(apd.UnderlySymbol, trr.UnderlySymbol) != 0
     WHERE trr.bUpdated = 0
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
      JOIN dbo.AdminPositionDetails apd
        ON trr.AsOfDate = apd.AsOfDate
       AND CHARINDEX(apd.SecName, trr.secName) != 0
     WHERE trr.bUpdated = 0

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
      JOIN dbo.AdminPositionDetails apd
        ON trr.AsOfDate = apd.AsOfDate
       AND CHARINDEX(CASE WHEN LEFT(apd.SecName, CHARINDEX(' ', apd.SecName)) = 'Mtem' THEN 'MOLECULAR' ELSE LEFT(apd.SecName, CHARINDEX(' ', apd.SecName)) END, trr.secName) != 0
       AND COALESCE(apd.SecName, '') NOT IN (SELECT COALESCE(trr.AdmSecName, trr.SecName, '') FROM #tmpRecResults trr)
     WHERE trr.bUpdated = 0


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
      JOIN dbo.AdminPositionDetails apd
        ON trr.AsOfDate = apd.AsOfDate
       AND CHARINDEX(CASE WHEN LEFT(apd.SecName, CHARINDEX(' ', apd.SecName)) = 'Gossamer Bio Inc' AND apd.Custodian = 'PRIV' THEN 'GOSSAMER BIO ORD - Private ' ELSE LEFT(apd.SecName, CHARINDEX(' ', apd.SecName)) END, trr.secName) != 0
       AND COALESCE(apd.SecName, '') NOT IN (SELECT COALESCE(trr.AdmSecName, trr.SecName, '') FROM #tmpRecResults trr)
     WHERE trr.bUpdated = 0




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
           0,
           'Unmapped MSFS',
           SUM(apd.Quantity),
           SUM(apd.DtdPnlUsd),
           SUM(apd.MtdPnlUsd),
           SUM(apd.YtdPnlUsd)
      FROM dbo.AdminPositionDetails apd 
     WHERE apd.AsOfDate = @AsOfDate
       AND apd.Quantity != 0
       AND COALESCE(apd.SecName, '') NOT IN (SELECT COALESCE(trr.AdmSecName, trr.SecName, '') FROM #tmpRecResults trr)
       AND apd.AssetClass NOT IN ('CURRENCY FORWARDS', 'CASH')
     GROUP BY apd.AsOfDate,
           apd.TopLevelTag,
           apd.Strategy,
           apd.BBgCode,
           apd.SecName,
           apd.UnderlySymbol

/*
    SELECT apd.* 
      FROM dbo.AdminPositionDetails apd 
     WHERE apd.AsOfDate = @AsOfDate 
       AND COALESCE(apd.SecName, '') NOT IN (SELECT COALESCE(trr.AdmSecName, '') FROM #tmpRecResults trr)
       AND apd.Quantity != 0
       AND apd.AssetClass NOT IN ('CURRENCY FORWARDS', 'CASH')
*/


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
     ORDER BY trr.bUpdated,
           trr.AsOfDate, 
           trr.Strategy,
           trr.Book,
           trr.SecName
        

    SET NOCOUNT OFF

  END

GO

GRANT EXECUTE ON dbo.p_RunDailyPositionRec TO PUBLIC
GO      



/*
SELECT TOP 1000 * FROM dbo.EnfPositionDetails WHERE instDescr LIKE '%moon%' ORDER BY AsOfDate DeSC


SELECT TOP 1000 LEFT(apd.SecName, CHARINDEX(' ', apd.SecName)), * FROM dbo.AdminPositionDetails apd WHERE CHARINDEX('Private', SecName) != 0 AND apd.AsOfDate = '10/13/2023' AND CHARINDEX('Private', apd.SecName) != 0 ORDER BY AsOfDate


SELECT * 
  FROM dbo.AdminPositionDetails apd
 WHERE apd.AsOfDate = '10/13/2023'
   AND CHARINDEX('MSA14568', apd.SecName) != 0
   ORDER BY apd.SecName


SELECT * 
  FROM dbo.EnfPositionDetails apd
 WHERE apd.AsOfDate = '10/13/2023'
   AND CHARINDEX('MSA14568', apd.InstDescr) != 0
   ORDER BY apd.InstDescr

*/
