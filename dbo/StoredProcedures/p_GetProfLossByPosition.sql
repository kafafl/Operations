CREATE PROCEDURE [dbo].[p_GetProfLossByPosition](
  @AsOfDate       DATE NULL = DEFAULT,
  @iTopNCount     INT = 20,
  @iRst           INT = 1,
  @bIncludeOpt    BIT = 0,
  @iHierarchy     INT = 1)

   /*
  Author: Lee Kafafian
  Crated: 09/21/2023
  Object: p_GetProfLossByPosition
  Example:  EXEC dbo.p_GetProfLossByPosition @AsOfDate = '04/30/2024', @iTopNCount = 20, @iRst = 3, @iHierarchy = 3
            EXEC dbo.p_GetProfLossByPosition @AsOfDate = '12/29/2023'
 */
  
 AS 

   BEGIN

   SET NOCOUNT ON

    DECLARE @strReportCol AS VARCHAR(255)

    SELECT @strReportCol = CASE WHEN @iRst = 1 THEN 'DlyPnlUsd'
                                WHEN @iRst = 2 THEN 'MlyPnlUsd'
                                WHEN @iRst = 3 THEN 'YlyPnlUsd'
                                WHEN @iRst = 4 THEN 'IlyPnlUsd' 
                                ELSE 'DlyPnlUsd'
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
      [MtdPnlUsd]	             FLOAT (53)    NULL,
      [MtdPnlOfNav]              FLOAT (53)    NULL,
      [YtdPnlUsd]                FLOAT (53)    NULL,
      [YtdPnlOfNav]              FLOAT (53)    NULL,
      [ItdPnlUsd]                FLOAT (53)    NULL)


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
       EXEC dbo.p_GetEnfPositionData @AsOfDate = @AsOfDate

    --SELECT * FROM #tmpProfLossPos tps WHERE tps.BookName = '' AND tps.StratName = ''
    DELETE tps FROM #tmpProfLossPos tps WHERE tps.BookName = '' AND tps.StratName = ''

    --SELECT * FROM #tmpProfLossPos tps WHERE tps.BBYellowKey = ''
    DELETE tps FROM #tmpProfLossPos tps WHERE tps.BBYellowKey = ''


    
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
               SUM(DlyPnlUsd) AS DlyPnlUsd,
               SUM(MtdPnlUsd) AS MtdPnlUsd,
               SUM(YtdPnlUsd) AS YtdPnlUsd,
               SUM(ItdPnlUsd) AS ItdPnlUsd
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
               UnderlyBBYellowKey,
               UnderlyBBYellowKey,
               InstrType,
               SUM(DlyPnlUsd) AS DlyPnlUsd,
               SUM(MtdPnlUsd) AS MtdPnlUsd,
               SUM(YtdPnlUsd) AS YtdPnlUsd,
               SUM(ItdPnlUsd) AS ItdPnlUsd
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


        UPDATE tro
           SET tro.InstDescr = ''
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


    IF @iHierarchy = 1
      BEGIN
        SELECT TOP (@iTopNCount) AsOfDate,
               FundShortName,
               StratName,
               BookName,
               InstDescr,
               BBYellowKey,
               SUM(DlyPnlUsd) AS DlyPnlUsd,
               SUM(MtdPnlUsd) AS MtdPnlUsd,
               SUM(YtdPnlUsd) AS YtdPnlUsd,
               SUM(ItdPnlUsd) AS ItdPnlUsd
          FROM #tmpResultsOut tps
         GROUP BY AsOfDate,
               FundShortName,
               StratName,
               BookName,
               InstDescr,
               BBYellowKey
         ORDER BY CASE @iRst
               WHEN 1 THEN SUM(DlyPnlUsd)
               WHEN 2 THEN SUM(MtdPnlUsd)
               WHEN 3 THEN SUM(YtdPnlUsd)
               WHEN 4 THEN SUM(ItdPnlUsd) END DESC
      END

    IF @iHierarchy = 2
      BEGIN
        SELECT TOP (@iTopNCount) AsOfDate,
               FundShortName,
               StratName,
               StratName,
               InstDescr,
               BBYellowKey,
               SUM(DlyPnlUsd) AS DlyPnlUsd,
               SUM(MtdPnlUsd) AS MtdPnlUsd,
               SUM(YtdPnlUsd) AS YtdPnlUsd,
               SUM(ItdPnlUsd) AS ItdPnlUsd
          FROM #tmpResultsOut tps
         GROUP BY AsOfDate,
               FundShortName,
               StratName,
               InstDescr,
               BBYellowKey
         ORDER BY CASE @iRst
               WHEN 1 THEN SUM(DlyPnlUsd)
               WHEN 2 THEN SUM(MtdPnlUsd)
               WHEN 3 THEN SUM(YtdPnlUsd)
               WHEN 4 THEN SUM(ItdPnlUsd) END DESC
      END

    IF @iHierarchy = 3
      BEGIN
        SELECT TOP (@iTopNCount) AsOfDate,
               FundShortName,
               FundShortName,
               FundShortName,
               InstDescr,
               BBYellowKey,
               SUM(DlyPnlUsd) AS DlyPnlUsd,
               SUM(MtdPnlUsd) AS MtdPnlUsd,
               SUM(YtdPnlUsd) AS YtdPnlUsd,
               SUM(ItdPnlUsd) AS ItdPnlUsd
          FROM #tmpResultsOut tps
         GROUP BY AsOfDate,
               FundShortName,
               InstDescr,
               BBYellowKey
         ORDER BY CASE @iRst
               WHEN 1 THEN SUM(DlyPnlUsd)
               WHEN 2 THEN SUM(MtdPnlUsd)
               WHEN 3 THEN SUM(YtdPnlUsd)
               WHEN 4 THEN SUM(ItdPnlUsd) END DESC
      END


    SET NOCOUNT OFF

   END
GO

   GRANT EXECUTE ON dbo.p_GetProfLossByPosition TO PUBLIC
   GO
