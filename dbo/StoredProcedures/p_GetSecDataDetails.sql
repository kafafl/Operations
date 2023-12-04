USE Operations
GO

CREATE PROCEDURE dbo.p_GetSecDataDetails(
    @AsOfDate   DATE NULL = DEFAULT )
 
 /*
  Author:   Lee Kafafian
  Crated:   11/27/2023
  Object:   p_GetSecDataDetails
  Example:  EXEC dbo.p_GetSecDataDetails @AsOfDate = '11/27/2023'

 */
  
 AS 

   BEGIN

   SET NOCOUNT ON

    IF @AsOfDate IS NULL
      BEGIN
        SELECT TOP 1 @AsOfDate = CAST(fad.AsOfDate AS DATE) FROM dbo.EnfPositionDetails fad ORDER BY fad.AsOfDate DESC, fad.UpdatedOn DESC
      END

/*  FUND ASSETS TEMP TABLE   */
    CREATE TABLE #tmpSecData(
      AsOfDate        DATE,
      BBYellowKey     VARCHAR(500),
      InstDescr       VARCHAR(500),
      StratName       VARCHAR(500),
      BookName        VARCHAR(500),
      CcyOne          VARCHAR(12),
      InstrType       VARCHAR(255),
      UnderlyBBYellow VARCHAR(255), 
      bProcessed      BIT DEFAULT 0)


     INSERT INTO #tmpSecData(
            AsOfDate,
            BBYellowKey,
            InstDescr,
            StratName,
            BookName,
            CcyOne,
            InstrType,
            UnderlyBBYellow)
     SELECT epf.AsOfDate,
            CASE WHEN RTRIM(LTRIM(epf.BBYellowKey)) = '' THEN CASE WHEN RTRIM(LTRIM(epf.UnderlyBBYellowKey)) != '' THEN RTRIM(LTRIM(epf.UnderlyBBYellowKey)) ELSE RTRIM(LTRIM(epf.InstDescr)) END ELSE RTRIM(LTRIM(epf.BBYellowKey)) END AS BBYellowKey,
            epf.InstDescr,
            epf.StratName,
            epf.BookName,
            epf.CcyOne,
            epf.InstrType,
            epf.UnderlyBBYellowKey
       FROM dbo.EnfPositionDetails epf
      WHERE epf.AsOfDate = @AsOfDate
        AND ROUND(epf.Quantity, 0) != 0
        AND epf.InstrType NOT IN ('Cash')
        AND CASE WHEN RTRIM(LTRIM(epf.BBYellowKey)) = '' THEN CASE WHEN RTRIM(LTRIM(epf.UnderlyBBYellowKey)) != '' THEN RTRIM(LTRIM(epf.UnderlyBBYellowKey)) ELSE RTRIM(LTRIM(epf.InstDescr)) END ELSE RTRIM(LTRIM(epf.BBYellowKey)) END  != ''
        AND RTRIM(LTRIM(epf.InstDescr)) != ''
        AND RTRIM(LTRIM(epf.StratName)) != ''
        AND RTRIM(LTRIM(epf.BookName)) != ''
       GROUP BY epf.AsOfDate,
             CASE WHEN RTRIM(LTRIM(epf.BBYellowKey)) = '' THEN CASE WHEN RTRIM(LTRIM(epf.UnderlyBBYellowKey)) != '' THEN RTRIM(LTRIM(epf.UnderlyBBYellowKey)) ELSE RTRIM(LTRIM(epf.InstDescr)) END ELSE RTRIM(LTRIM(epf.BBYellowKey)) END,
             epf.InstDescr,
             epf.StratName,
             epf.BookName,
             epf.CcyOne,
             epf.InstrType,
             epf.UnderlyBBYellowKey
       ORDER BY epf.AsOfDate, 
             CASE WHEN RTRIM(LTRIM(epf.BBYellowKey)) = '' THEN CASE WHEN RTRIM(LTRIM(epf.UnderlyBBYellowKey)) != '' THEN RTRIM(LTRIM(epf.UnderlyBBYellowKey)) ELSE RTRIM(LTRIM(epf.InstDescr)) END ELSE RTRIM(LTRIM(epf.BBYellowKey)) END,
             epf.InstDescr,
             epf.StratName,
             epf.BookName,
             epf.CcyOne,
             epf.InstrType,
             epf.UnderlyBBYellowKey


/*  NORMALIZE THE DATA FOR THE SPREADSHEET  */
    UPDATE tsd
       SET tsd.StratName = 'US Alpha Longs',
           tsd.bProcessed = 1
      FROM #tmpSecData tsd
     WHERE tsd.StratName = 'Alpha Long'
       AND tsd.CcyOne IN ('USD', 'CAD')
       AND tsd.bProcessed = 0

    UPDATE tsd
       SET tsd.StratName = 'Ex US Alpha Longs',
           tsd.bProcessed = 1
      FROM #tmpSecData tsd
     WHERE tsd.StratName = 'Alpha Long'
       AND tsd.CcyOne NOT IN ('USD', 'CAD')
       AND tsd.bProcessed = 0

    UPDATE tsd
       SET tsd.StratName = 'US Alpha Shorts',
           tsd.bProcessed = 1
      FROM #tmpSecData tsd
     WHERE tsd.StratName = 'Alpha Short'
       AND tsd.CcyOne = 'USD'
       AND tsd.bProcessed = 0

    UPDATE tsd
       SET tsd.StratName = 'Ex US Alpha Shorts',
           tsd.bProcessed = 1
      FROM #tmpSecData tsd
     WHERE tsd.StratName = 'Alpha Short'
       AND tsd.CcyOne != 'USD'
       AND tsd.bProcessed = 0

    UPDATE tsd
       SET tsd.StratName = 'US TARGET EQUITY ETF SHORTS',
           tsd.bProcessed = 1
      FROM #tmpSecData tsd
     WHERE tsd.StratName = 'Equity Hedge'
       AND tsd.BookName != 'Equity Hedge - Tail'
       AND tsd.bProcessed = 0

    UPDATE tsd
       SET tsd.StratName = 'Tail Hedges',
           tsd.bProcessed = 1
      FROM #tmpSecData tsd
     WHERE tsd.BookName = 'Equity Hedge - Tail'
       AND tsd.bProcessed = 0


    UPDATE tsd
       SET tsd.StratName = 'US Core Biotech Shorts',
           tsd.bProcessed = 1
      FROM #tmpSecData tsd
     WHERE tsd.StratName = 'Biotech Hedge'
       AND tsd.InstrType NOT IN ('Listed Option')
       AND tsd.bProcessed = 0

    UPDATE tsd
       SET tsd.StratName = 'US Core Biotech Shorts Tail Hedge',
           tsd.bProcessed = 1
      FROM #tmpSecData tsd
     WHERE tsd.StratName = 'Biotech Hedge'
       AND tsd.InstrType IN ('Listed Option')
       AND tsd.bProcessed = 0

    UPDATE tsd
       SET tsd.BBYellowKey = 'MSA14568 Index',
           tsd.UnderlyBBYellow = 'MSA14568 Index',
           tsd.BookName = 'Equity Hedge - Core',
           tsd.StratName = 'US TARGET EQUITY ETF SHORTS'
      FROM #tmpSecData tsd
     WHERE tsd.InstDescr = 'MSA14568'

    UPDATE tsd
       SET tsd.BBYellowKey = 'GOSS US Equity',
           tsd.UnderlyBBYellow = 'GOSS US Equity'
      FROM #tmpSecData tsd
     WHERE tsd.InstDescr = 'GOSSAMER BIO ORD - Private'

    UPDATE tsd
       SET tsd.BBYellowKey = 'MTEM US Equity',
           tsd.UnderlyBBYellow = 'MTEM US Equity'
      FROM #tmpSecData tsd
     WHERE tsd.InstDescr = 'MOLECULAR TEMPLATES - Private'

    UPDATE tsd
       SET tsd.BBYellowKey = 'MSCL CN Equity',
           tsd.UnderlyBBYellow = 'MSCL CN Equity'
      FROM #tmpSecData tsd
     WHERE tsd.InstDescr = 'SATELLOS BIOSCIENCE ORD Private'

    UPDATE tsd
       SET tsd.BBYellowKey = 'TRML US Equity',
           tsd.UnderlyBBYellow = 'TRML US Equity'
      FROM #tmpSecData tsd
     WHERE tsd.InstDescr = 'TALARIS THERAPEUTICS ORD - Private'

    UPDATE tsd
       SET tsd.BBYellowKey = 'ZURA US Equity',
           tsd.UnderlyBBYellow = 'ZURA US Equity'
      FROM #tmpSecData tsd
     WHERE tsd.InstDescr = 'ZURA Private'

    UPDATE tsd
       SET tsd.BBYellowKey = 'GOSS Warrant',
           tsd.UnderlyBBYellow = 'GOSS US Equity'
      FROM #tmpSecData tsd
     WHERE tsd.InstDescr = 'GOSSAMER BIO ORD - Warrant'

    UPDATE tsd
       SET tsd.BBYellowKey = 'ELEV Warrant',
           tsd.UnderlyBBYellow = 'ELEV US Equity'
      FROM #tmpSecData tsd
     WHERE tsd.InstDescr = 'ELEVATION ONCOLOGY ORD - Warrant'


     SELECT AsOfDate,
            BBYellowKey,
            InstDescr,
            StratName,
            BookName,
            CcyOne,
            InstrType,
            UnderlyBBYellow
       FROM #tmpSecData tfa
       ORDER BY AsOfDate,
            BBYellowKey,
            InstDescr,
            StratName,
            BookName,
            CcyOne,
            InstrType,
            UnderlyBBYellow

   SET NOCOUNT OFF

   END
   GO

   GRANT EXECUTE ON dbo.p_GetSecDataDetails TO PUBLIC
   GO