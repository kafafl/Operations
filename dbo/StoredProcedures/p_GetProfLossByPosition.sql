SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[p_GetProfLossByPosition](
  @AsOfDate       DATE,
  @StrtDate       DATE NULL = DEFAULT,
  @iTopNCount     INT = 20,
  @iRst           INT = 1,
  @bIncludeOpt    BIT = 0,
  @iHierarchy     INT = 1,
  @iOrder         INT = 0)

   /*
  Author: Lee Kafafian
  Crated: 09/21/2023
  Object: p_GetProfLossByPosition
  Example:  EXEC dbo.p_GetProfLossByPosition @AsOfDate = '04/30/2024', @iTopNCount = 400, @iRst = 1, @iHierarchy = 1, @iOrder = 2
            EXEC dbo.p_GetProfLossByPosition @AsOfDate = '5/24/2024', @iTopNCount = 25, @iRst = 3, @iHierarchy = 1, @iOrder = 1


            EXEC dbo.p_GetProfLossByPosition @AsOfDate = '6/28/2024'
            EXEC dbo.p_GetProfLossByPosition @AsOfDate = '6/28/2024', @iTopNCount = 400, @iRst = 1, @iHierarchy = 1, @iOrder = 2
            EXEC dbo.p_GetProfLossByPosition @AsOfDate = '05/31/2024', @StrtDate = '01/01/2024', @iTopNCount = 400, @iRst = 5, @iHierarchy = 1, @iOrder = 5
 */
  
 AS 

   BEGIN

   SET NOCOUNT ON


    IF @StrtDate IS NULL
      BEGIN
        SELECT @StrtDate = @AsOfDate
      END

    CREATE TABLE #tmpProfLossPos(  
      [AsOfDate]                 DATE          NOT NULL,
      [FundShortName]            VARCHAR (255) NOT NULL,
      [StratName]                VARCHAR (255) NULL,
      [BookName]                 VARCHAR (255) NULL,
      [InstDescr]                VARCHAR (255) NOT NULL,
      [BBYellowKey]	             VARCHAR (255) NULL,
      [UnderlyBBYellowKey]       VARCHAR (255) NULL,
      [Account]	                 VARCHAR (255) NOT NULL,
      [CcyOne]                   VARCHAR (255) NULL,
      [CcyTwo]                   VARCHAR (255) NULL,
      [InstrType]                VARCHAR (255) NULL,
      [Quantity]                 FLOAT (53)    NULL,
      [NetAvgCost]               FLOAT (53)    NULL,
      [OverallCost]              FLOAT (53)    NULL,
      [FairValue]	               FLOAT (53)    NULL,
      [NetMarketValue]           FLOAT (53)    NULL,
      [DlyPnlUsd]                FLOAT (53)    NULL,
      [DlyPnlOfNav]              FLOAT (53)    NULL,
      [MtdPnlUsd]	               FLOAT (53)    NULL,
      [MtdPnlOfNav]              FLOAT (53)    NULL,
      [YtdPnlUsd]                FLOAT (53)    NULL,
      [YtdPnlOfNav]              FLOAT (53)    NULL,
      [ItdPnlUsd]                FLOAT (53)    NULL,
      [GrExpOfGLNav]             FLOAT (53)    NULL,
      [Delta]                    FLOAT (53),
      [DeltaAdjMV]               FLOAT (53),
      [DeltaExp]                 FLOAT (53)    NULL,
      [LongShort]                VARCHAR (255) NULL,
      [GrossExp]                 FLOAT (53)    NULL,
      [LongMV]                   FLOAT (53)    NULL,
      [ShortMV]                  FLOAT (53)    NULL,
      [InstrTypeCode]            VARCHAR (255) NULL,
      [InstrTypeUnder]           VARCHAR (255) NULL,
      [PrevBusDayNMV]            FLOAT (53)    NULL)

    CREATE TABLE #tmpProfLossPosPtd(  
      [AsOfDate]                 DATE          NOT NULL,
      [FundShortName]            VARCHAR (255) NOT NULL,
      [StratName]                VARCHAR (255) NULL,
      [BookName]                 VARCHAR (255) NULL,
      [InstDescr]                VARCHAR (255) NOT NULL,
      [BBYellowKey]	             VARCHAR (255) NULL,
      [UnderlyBBYellowKey]       VARCHAR (255) NULL,
      [Account]	                 VARCHAR (255) NOT NULL,
      [CcyOne]                   VARCHAR (255) NULL,
      [CcyTwo]                   VARCHAR (255) NULL,
      [InstrType]                VARCHAR (255) NULL,
      [Quantity]                 FLOAT (53)    NULL,
      [NetAvgCost]               FLOAT (53)    NULL,
      [OverallCost]              FLOAT (53)    NULL,
      [FairValue]	               FLOAT (53)    NULL,
      [NetMarketValue]           FLOAT (53)    NULL,
      [DlyPnlUsd]                FLOAT (53)    NULL,
      [DlyPnlOfNav]              FLOAT (53)    NULL,
      [MtdPnlUsd]	               FLOAT (53)    NULL,
      [MtdPnlOfNav]              FLOAT (53)    NULL,
      [YtdPnlUsd]                FLOAT (53)    NULL,
      [YtdPnlOfNav]              FLOAT (53)    NULL,
      [ItdPnlUsd]                FLOAT (53)    NULL,
      [GrExpOfGLNav]             FLOAT (53)    NULL,
      [Delta]                    FLOAT (53),
      [DeltaAdjMV]               FLOAT (53),
      [DeltaExp]                 FLOAT (53)    NULL,
      [LongShort]                VARCHAR (255) NULL,
      [GrossExp]                 FLOAT (53)    NULL,
      [LongMV]                   FLOAT (53)    NULL,
      [ShortMV]                  FLOAT (53)    NULL,
      [InstrTypeCode]            VARCHAR (255) NULL,
      [InstrTypeUnder]           VARCHAR (255) NULL,
      [PrevBusDayNMV]            FLOAT (53)    NULL)

    CREATE TABLE #tmpResultsOut(
      [AsOfDate]                 DATE          NOT NULL,
      [FundShortName]            VARCHAR (255) NOT NULL,
      [StratName]                VARCHAR (255) NULL,
      [BookName]                 VARCHAR (255) NULL,
      [InstDescr]                VARCHAR (255) NOT NULL,
      [BBYellowKey]	             VARCHAR (255) NULL,
      [UnderlyBBYellowKey]       VARCHAR (255) NULL,
      [InstrType]                VARCHAR (255) NULL,
      [DlyPnlUsd]                FLOAT (53)    NULL,
      [DlyPnlOfNav]              FLOAT (53)    NULL,
      [MtdPnlUsd]	               FLOAT (53)    NULL,
      [MtdPnlOfNav]              FLOAT (53)    NULL,
      [YtdPnlUsd]                FLOAT (53)    NULL,
      [YtdPnlOfNav]              FLOAT (53)    NULL,
      [ItdPnlUsd]                FLOAT (53)    NULL,
      [PtdPnlUsd]                FLOAT (53)    NULL)

    CREATE TABLE #tmpResultsOutPtd(
      [AsOfDate]                 DATE          NOT NULL,
      [FundShortName]            VARCHAR (255) NOT NULL,
      [StratName]                VARCHAR (255) NULL,
      [BookName]                 VARCHAR (255) NULL,
      [InstDescr]                VARCHAR (255) NOT NULL,
      [BBYellowKey]	             VARCHAR (255) NULL,
      [UnderlyBBYellowKey]       VARCHAR (255) NULL,
      [InstrType]                VARCHAR (255) NULL,
      [DlyPnlUsd]                FLOAT (53)    NULL,
      [DlyPnlOfNav]              FLOAT (53)    NULL,
      [MtdPnlUsd]	               FLOAT (53)    NULL,
      [MtdPnlOfNav]              FLOAT (53)    NULL,
      [YtdPnlUsd]                FLOAT (53)    NULL,
      [YtdPnlOfNav]              FLOAT (53)    NULL,
      [ItdPnlUsd]                FLOAT (53)    NULL,
      [PdtPnlUsd]                FLOAT (53)    NULL)


    /*   START THE DATA GATHERING PROCESS  */
         INSERT INTO #tmpProfLossPos(
                AsOfDate,
                FundShortName,
                StratName,
                BookName,
                InstDescr,
                BBYellowKey,
                UnderlyBBYellowKey,
                Account,
                InstrType,
                CcyOne,
                CcyTwo,
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
                Delta,
                DeltaAdjMV,
                DeltaExp,
                LongShort,
                LongMV,
                ShortMV,
                GrExpOfGLNav,
                InstrTypeCode,
                InstrTypeUnder,
                PrevBusDayNMV)
           EXEC dbo.p_GetEnfPositionData @AsOfDate = @AsOfDate, @ResultSet = 0

            IF @StrtDate != @AsOfDate
              BEGIN
                INSERT INTO #tmpProfLossPosPTd(
                        AsOfDate,
                        FundShortName,
                        StratName,
                        BookName,
                        InstDescr,
                        BBYellowKey,
                        UnderlyBBYellowKey,
                        Account,
                        InstrType,
                        CcyOne,
                        CcyTwo,
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
                        Delta,
                        DeltaAdjMV,
                        DeltaExp,
                        LongShort,
                        LongMV,
                        ShortMV,
                        GrExpOfGLNav,
                        InstrTypeCode,
                        InstrTypeUnder,
                        PrevBusDayNMV)
                   EXEC dbo.p_GetEnfPositionData @AsOfDate = @StrtDate, @ResultSet = 0
              END


        DELETE tps FROM #tmpProfLossPos tps WHERE tps.BookName = '' AND tps.StratName = ''
        DELETE tps FROM #tmpProfLossPos tps WHERE RTRIM(LTRIM(tps.BBYellowKey)) = ''

        DELETE tps FROM #tmpProfLossPosPtd tps WHERE tps.BookName = '' AND tps.StratName = ''
        DELETE tps FROM #tmpProfLossPosPtd tps WHERE RTRIM(LTRIM(tps.BBYellowKey)) = ''

        DELETE tps FROM #tmpProfLossPos tps WHERE tps.BookName IS NULL AND tps.StratName IS NULL
        DELETE tps FROM #tmpProfLossPos tps WHERE tps.BBYellowKey IS NULL

        DELETE tps FROM #tmpProfLossPosPtd tps WHERE tps.BookName IS NULL AND tps.StratName IS NULL
        DELETE tps FROM #tmpProfLossPosPtd tps WHERE tps.BBYellowKey IS NULL

        UPDATE tps SET tps.BBYellowKey = tps.UnderlyBBYellowKey FROM #tmpProfLossPos tps WHERE tps.InstrType IN ('Equity')
        UPDATE tps SET tps.BBYellowKey = tps.UnderlyBBYellowKey FROM #tmpProfLossPosPtd tps WHERE tps.InstrType IN ('Equity')


        /*
        SELECT * FROM #tmpProfLossPos WHERE BBYellowKey = '4568 JP Equity'
        SELECT * FROM #tmpProfLossPosPtd WHERE BBYellowKey = '4568 JP Equity'
        */

        INSERT INTO #tmpResultsOut(
               AsOfDate,
               FundShortName,
               StratName,
               BookName,
               InstDescr,
               BBYellowKey,
               UnderlyBBYellowKey,
               InstrType,
               DlyPnlUsd,
               MtdPnlUsd,
               YtdPnlUsd,
               ItdPnlUsd)
        SELECT AsOfDate,
               FundShortName,
               StratName,
               BookName,
               InstDescr,
               BBYellowKey,
               UnderlyBBYellowKey,
               InstrType,
               SUM(ROUND(DlyPnlUsd, 2)) AS DlyPnlUsd,
               SUM(ROUND(MtdPnlUsd, 2)) AS MtdPnlUsd,
               SUM(ROUND(YtdPnlUsd, 2)) AS YtdPnlUsd,
               SUM(ROUND(ItdPnlUsd, 2)) AS ItdPnlUsd
          FROM #tmpProfLossPos tps
         WHERE tps.StratName IN ('Alpha Long', 'Alpha Short')
           AND tps.InstrType IN ('Equity')
         GROUP BY AsOfDate,
               FundShortName,
               StratName,
               BookName,
               InstDescr,
               BBYellowKey,
               UnderlyBBYellowKey,
               InstrType

        INSERT INTO #tmpResultsOut(
               AsOfDate,
               FundShortName,
               StratName,
               BookName,
               InstDescr,
               BBYellowKey,
               UnderlyBBYellowKey,
               InstrType,
               DlyPnlUsd,
               MtdPnlUsd,
               YtdPnlUsd,
               ItdPnlUsd)
        SELECT AsOfDate,
               FundShortName,
               StratName,
               BookName,
               InstDescr,
               BBYellowKey,
               UnderlyBBYellowKey,
               InstrType,
               SUM(ROUND(DlyPnlUsd, 2)) AS DlyPnlUsd,
               SUM(ROUND(MtdPnlUsd, 2)) AS MtdPnlUsd,
               SUM(ROUND(YtdPnlUsd, 2)) AS YtdPnlUsd,
               SUM(ROUND(ItdPnlUsd, 2)) AS ItdPnlUsd
          FROM #tmpProfLossPos tps
         WHERE tps.StratName IN ('Alpha Long', 'Alpha Short')
           AND tps.InstrType IN ('Listed Option')
         GROUP BY AsOfDate,
               FundShortName,
               StratName,
               BookName,
               InstDescr,
               BBYellowKey,
               UnderlyBBYellowKey,
               InstrType


    IF @StrtDate != @AsOfDate
      BEGIN
        INSERT INTO #tmpResultsOutPtd(
               AsOfDate,
               FundShortName,
               StratName,
               BookName,
               InstDescr,
               BBYellowKey,
               UnderlyBBYellowKey,
               InstrType,
               DlyPnlUsd,
               MtdPnlUsd,
               YtdPnlUsd,
               ItdPnlUsd)
        SELECT AsOfDate,
               FundShortName,
               StratName,
               BookName,
               InstDescr,
               BBYellowKey,
               UnderlyBBYellowKey,
               InstrType,
               SUM(ROUND(DlyPnlUsd, 2)) AS DlyPnlUsd,
               SUM(ROUND(MtdPnlUsd, 2)) AS MtdPnlUsd,
               SUM(ROUND(YtdPnlUsd, 2)) AS YtdPnlUsd,
               SUM(ROUND(ItdPnlUsd, 2)) AS ItdPnlUsd
          FROM #tmpProfLossPosPtd tps
         WHERE tps.StratName IN ('Alpha Long', 'Alpha Short')
           AND tps.InstrType IN ('Equity')
         GROUP BY AsOfDate,
               FundShortName,
               StratName,
               BookName,
               InstDescr,
               BBYellowKey,
               UnderlyBBYellowKey,
               InstrType

        INSERT INTO #tmpResultsOutPtd(
               AsOfDate,
               FundShortName,
               StratName,
               BookName,
               InstDescr,
               BBYellowKey,
               UnderlyBBYellowKey,
               InstrType,
               DlyPnlUsd,
               MtdPnlUsd,
               YtdPnlUsd,
               ItdPnlUsd)
        SELECT AsOfDate,
               FundShortName,
               StratName,
               BookName,
               InstDescr,
               BBYellowKey,
               UnderlyBBYellowKey,
               InstrType,
               SUM(ROUND(DlyPnlUsd, 2)) AS DlyPnlUsd,
               SUM(ROUND(MtdPnlUsd, 2)) AS MtdPnlUsd,
               SUM(ROUND(YtdPnlUsd, 2)) AS YtdPnlUsd,
               SUM(ROUND(ItdPnlUsd, 2)) AS ItdPnlUsd
          FROM #tmpProfLossPosPtd tps
         WHERE tps.StratName IN ('Alpha Long', 'Alpha Short')
           AND tps.InstrType IN ('Listed Option')
         GROUP BY AsOfDate,
               FundShortName,
               StratName,
               BookName,
               InstDescr,
               BBYellowKey,
               UnderlyBBYellowKey,
               InstrType

      END

    DELETE tro FROM #tmpResultsOut tro WHERE tro.BBYellowKey = ''
    DELETE trx FROM #tmpResultsOut trx WHERE trx.BBYellowKey = ''


      /*
      SELECT * FROM #tmpResultsOut WHERE BBYellowKey = '4568 JP Equity'
      SELECT * FROM #tmpResultsOutPtd WHERE BBYellowKey = '4568 JP Equity'

      SELECT tps.*,
              tpx.*
                FROM #tmpResultsOut tps
                LEFT JOIN #tmpResultsOutPtd tpx
                  ON tps.FundShortName = tpx.FundShortName
                AND tps.StratName = tpx.StratName
                AND tps.BookName = tpx.BookName
                AND tps.InstDescr = tpx.InstDescr
                AND tps.BBYellowKey = tpx.BBYellowKey
      WHERE tps.BBYellowKey = '4568 JP Equity'

      SELECT @StrtDate AS StrtDate, @AsOfDate AS AsOfDate

      RETURN
      */


    IF @StrtDate != @AsOfDate
      BEGIN
        UPDATE tps
           SET tps.PtdPnlUsd = ROUND(COALESCE(tps.ItdPnlUsd, 0) - COALESCE(tpx.ItdPnlUsd, 0), 0)
          FROM #tmpResultsOut tps
          LEFT JOIN #tmpResultsOutPtd tpx
            ON tps.FundShortName = tpx.FundShortName
           AND tps.StratName = tpx.StratName
           AND tps.BookName = tpx.BookName
           AND tps.InstDescr = tpx.InstDescr
           AND tps.BBYellowKey = tpx.BBYellowKey
      END

        UPDATE tro
           SET tro.InstDescr = '',
               tro.BBYellowKey = tro.UnderlyBBYellowKey
          FROM #tmpResultsOut tro
         WHERE tro.InstrType = 'Listed Option'

        UPDATE tro
           SET tro.InstDescr = trz.InstDescr
          FROM #tmpResultsOut tro
          JOIN (SELECT trx.InstDescr, trx.BBYellowKey FROM #tmpResultsOut trx WHERE trx.InstrType = 'Equity' GROUP BY trx.InstDescr, trx.BBYellowKey) trz
            ON tro.BBYellowKey = trz.BBYellowKey
         WHERE tro.InstrType = 'Listed Option'

        UPDATE tro
           SET tro.InstDescr = tro.BBYellowKey + ' (Options Only)'
          FROM #tmpResultsOut tro
         WHERE tro.InstrType = 'Listed Option'
           AND tro.InstDescr = ''

/*
        UPDATE tro
           SET tro.InstDescr = ''
          FROM #tmpResultsOutPtd tro
         WHERE tro.InstrType = 'Listed Option'

        UPDATE tro
           SET tro.InstDescr = trz.InstDescr
          FROM #tmpResultsOutPtd tro
          JOIN (SELECT trx.InstDescr, trx.BBYellowKey FROM #tmpResultsOutPtd trx WHERE trx.InstrType = 'Equity' GROUP BY trx.InstDescr, trx.BBYellowKey) trz
            ON tro.BBYellowKey = trz.BBYellowKey
         WHERE tro.InstrType = 'Listed Option'

        UPDATE tro
           SET tro.InstDescr = tro.BBYellowKey + ' (Options Only)'
          FROM #tmpResultsOutPtd tro
         WHERE tro.InstrType = 'Listed Option'
           AND tro.InstDescr = ''
*/

    IF @iHierarchy = 1
      BEGIN
        SELECT TOP (@iTopNCount) AsOfDate,
               COALESCE(@StrtDate, '') AS StartDate,
               FundShortName,
               StratName,
               BookName,
               InstDescr,
               BBYellowKey,
               SUM(DlyPnlUsd) AS DlyPnlUsd,
               SUM(MtdPnlUsd) AS MtdPnlUsd,
               SUM(YtdPnlUsd) AS YtdPnlUsd,
               SUM(ItdPnlUsd) AS ItdPnlUsd,
               SUM(PtdPnlUsd) AS PtdPnlUsd
          FROM #tmpResultsOut tps
         GROUP BY AsOfDate,
               FundShortName,
               StratName,
               BookName,
               InstDescr,
               BBYellowKey
         HAVING CASE @iRst
               WHEN 1 THEN SUM(DlyPnlUsd)
               WHEN 2 THEN SUM(MtdPnlUsd)
               WHEN 3 THEN SUM(YtdPnlUsd)
               WHEN 4 THEN SUM(ItdPnlUsd) 
               WHEN 5 THEN SUM(PtdPnlUsd) END != 0
         ORDER BY CASE @iOrder 
                    WHEN 1 THEN
                      CASE @iRst
                        WHEN 1 THEN SUM(DlyPnlUsd)
                        WHEN 2 THEN SUM(MtdPnlUsd)
                        WHEN 3 THEN SUM(YtdPnlUsd)
                        WHEN 4 THEN SUM(ItdPnlUsd) 
                        WHEN 5 THEN SUM(PtdPnlUsd) END
                      END DESC,
                  CASE @iOrder 
                    WHEN 2 THEN
                      CASE @iRst
                        WHEN 1 THEN SUM(DlyPnlUsd)
                        WHEN 2 THEN SUM(MtdPnlUsd)
                        WHEN 3 THEN SUM(YtdPnlUsd)
                        WHEN 4 THEN SUM(ItdPnlUsd)
                        WHEN 5 THEN SUM(PtdPnlUsd) END
                      END ASC 
      END

    IF @iHierarchy = 2
      BEGIN
        SELECT TOP (@iTopNCount) AsOfDate,
               COALESCE(@StrtDate, '') AS StartDate,
               FundShortName,
               StratName,
               StratName,
               InstDescr,
               BBYellowKey,
               SUM(DlyPnlUsd) AS DlyPnlUsd,
               SUM(MtdPnlUsd) AS MtdPnlUsd,
               SUM(YtdPnlUsd) AS YtdPnlUsd,
               SUM(ItdPnlUsd) AS ItdPnlUsd,
               SUM(PtdPnlUsd) AS PdtPnlUsd
          FROM #tmpResultsOut tps
         GROUP BY AsOfDate,
               FundShortName,
               StratName,
               InstDescr,
               BBYellowKey
        HAVING CASE @iRst
               WHEN 1 THEN SUM(DlyPnlUsd)
               WHEN 2 THEN SUM(MtdPnlUsd)
               WHEN 3 THEN SUM(YtdPnlUsd)
               WHEN 4 THEN SUM(ItdPnlUsd)
               WHEN 5 THEN SUM(PtdPnlUsd) END != 0
         ORDER BY CASE @iOrder 
                    WHEN 1 THEN
                      CASE @iRst
                        WHEN 1 THEN SUM(DlyPnlUsd)
                        WHEN 2 THEN SUM(MtdPnlUsd)
                        WHEN 3 THEN SUM(YtdPnlUsd)
                        WHEN 4 THEN SUM(ItdPnlUsd) 
                        WHEN 5 THEN SUM(PtdPnlUsd) END
                      END DESC,
                  CASE @iOrder 
                    WHEN 2 THEN
                      CASE @iRst
                        WHEN 1 THEN SUM(DlyPnlUsd)
                        WHEN 2 THEN SUM(MtdPnlUsd)
                        WHEN 3 THEN SUM(YtdPnlUsd)
                        WHEN 4 THEN SUM(ItdPnlUsd) 
                        WHEN 5 THEN SUM(PtdPnlUsd) END
                      END ASC 
      END

    IF @iHierarchy = 3
      BEGIN
        SELECT TOP (@iTopNCount) AsOfDate,
               COALESCE(@StrtDate, '') AS StartDate,
               FundShortName,
               FundShortName,
               FundShortName,
               InstDescr,
               BBYellowKey,
               SUM(DlyPnlUsd) AS DlyPnlUsd,
               SUM(MtdPnlUsd) AS MtdPnlUsd,
               SUM(YtdPnlUsd) AS YtdPnlUsd,
               SUM(ItdPnlUsd) AS ItdPnlUsd,
               SUM(PtdPnlUsd) AS PdtPnlUsd
          FROM #tmpResultsOut tps
         GROUP BY AsOfDate,
               FundShortName,
               InstDescr,
               BBYellowKey
        HAVING CASE @iRst
               WHEN 1 THEN SUM(DlyPnlUsd)
               WHEN 2 THEN SUM(MtdPnlUsd)
               WHEN 3 THEN SUM(YtdPnlUsd)
               WHEN 4 THEN SUM(ItdPnlUsd)
               WHEN 5 THEN SUM(PtdPnlUsd) END != 0
         ORDER BY CASE @iOrder 
                    WHEN 1 THEN
                      CASE @iRst
                        WHEN 1 THEN SUM(DlyPnlUsd)
                        WHEN 2 THEN SUM(MtdPnlUsd)
                        WHEN 3 THEN SUM(YtdPnlUsd)
                        WHEN 4 THEN SUM(ItdPnlUsd)
                        WHEN 5 THEN SUM(PtdPnlUsd)  END
                      END DESC,
                  CASE @iOrder 
                    WHEN 2 THEN
                      CASE @iRst
                        WHEN 1 THEN SUM(DlyPnlUsd)
                        WHEN 2 THEN SUM(MtdPnlUsd)
                        WHEN 3 THEN SUM(YtdPnlUsd)
                        WHEN 4 THEN SUM(ItdPnlUsd)
                        WHEN 5 THEN SUM(PtdPnlUsd)  END
                      END ASC 
      END


    SET NOCOUNT OFF

   END
GO


   GRANT EXECUTE ON dbo.p_GetProfLossByPosition TO PUBLIC
   GO
