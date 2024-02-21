USE Operations
GO

ALTER PROCEDURE dbo.p_GetEnfPositionData(
  @AsOfDate   DATE NULL = DEFAULT,
  @ResultSet  INT = 1,
  @EquitiesOnly BIT = 0)
 
 /*
  Author: Lee Kafafian
  Crated: 09/21/2023
  Object: p_GetEnfPositionData
  Example:  EXEC dbo.p_GetEnfPositionData @AsOfDate = '01/12/2024', @ResultSet = 1
            EXEC dbo.p_GetEnfPositionData @AsOfDate = '12/29/2023', @ResultSet = 1, @EquitiesOnly = 1
 */
  
 AS 

   BEGIN

   SET NOCOUNT ON

    DECLARE @AsOfDateCheck AS DATE
    DECLARE @AsOfPrevBusDate AS DATE

    SELECT TOP 1 @AsOfDateCheck = epd.AsOfDate FROM dbo.EnfPositionDetails epd ORDER BY epd.AsOfDate DESC

      IF @AsOfDate IS NULL OR @AsOfDate > @AsOfDateCheck
        BEGIN
          SELECT @AsOfDate = @AsOfDateCheck
        END

    SELECT TOP 1 @AsOfPrevBusDate = epd.AsOfDate FROM dbo.EnfPositionDetails epd WHERE epd.AsOfDate < @AsOfDate ORDER BY epd.AsOfDate DESC
    

    CREATE TABLE #tmpPositions(  
      [AsOfDate]             DATE          NOT NULL,
      [FundShortName]        VARCHAR (255) NOT NULL,
      [StratName]            VARCHAR (255) NULL,
      [BookName]             VARCHAR (255) NULL,
      [InstDescr]            VARCHAR (255) NOT NULL,
      [BBYellowKey]	         VARCHAR (255) NULL,
      [UnderlyBBYellowKey]   VARCHAR (255) NULL,
      [Account]	             VARCHAR (255) NOT NULL,
      [CcyOne]               VARCHAR (255) NULL,
      [CcyTwo]               VARCHAR (255) NULL,
      [InstrType]            VARCHAR (255) NULL,
      [Quantity]             FLOAT (53) NULL,
      [NetAvgCost]           FLOAT (53) NULL,
      [OverallCost]          FLOAT (53) NULL,
      [FairValue]	           FLOAT (53) NULL,
      [NetMarketValue]       FLOAT (53) NULL,
      [DlyPnlUsd]            FLOAT (53) NULL,
      [DlyPnlOfNav]          FLOAT (53) NULL,
      [MtdPnlUsd]	           FLOAT (53) NULL,
      [MtdPnlOfNav]          FLOAT (53) NULL,
      [YtdPnlUsd]            FLOAT (53) NULL,
      [YtdPnlOfNav]          FLOAT (53) NULL,
      [ItdPnlUsd]            FLOAT (53) NULL,
      [GrExpOfGLNav]         FLOAT (53) NULL,
      [Delta]                FLOAT (53),
      [DeltaAdjMV]           FLOAT (53),
      [DeltaExp]             FLOAT (53) NULL,
      [LongShort]            VARCHAR (255) NULL,
      [GrossExp]             FLOAT (53) NULL,
      [LongMV]               FLOAT (53) NULL,
      [ShortMV]              FLOAT (53) NULL,
      [InstrTypeCode]        VARCHAR (255) NULL,
      [InstrTypeUnder]       VARCHAR (255) NULL,
      [PrevBusDayNMV]        FLOAT (53) NULL)


     INSERT INTO #tmpPositions(
            AsOfDate,
            FundShortName,
            StratName,
            BookName,
            InstDescr,
            BBYellowKey,
            UnderlyBBYellowKey,
            Account,
            CcyOne,
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
            LongMV,
            ShortMv,
            InstrTypeCode,
            InstrTypeUnder)
     SELECT epd.AsOfDate,
            epd.FundShortName,
            epd.StratName,
            epd.BookName,
            epd.InstDescr,
            epd.BBYellowKey,
            epd.UnderlyBBYellowKey,
            epd.Account,
            epd.CcyOne,
            epd.CcyTwo,
            epd.InstrType,
            epd.Quantity,
            epd.NetAvgCost,
            epd.OverallCost,
            epd.FairValue,
            epd.NetMarketValue,
            epd.DlyPnlUsd,
            epd.DlyPnlOfNav,
            epd.MtdPnlUsd,
            epd.MtdPnlOfNav,
            epd.YtdPnlUsd,
            epd.YtdPnlOfNav,
            epd.ItdPnlUsd,
            epd.GrExpOfGLNav,
            epd.Delta,
            epd.DeltaAdjMV,
            epd.DeltaExp,
            epd.LongShort,
            epd.LongMV,
            epd.ShortMv,
            epd.InstrTypeCode,
            epd.InstrTypeUnder
       FROM dbo.EnfPositionDetails epd
      WHERE epd.AsOfDate = @AsOfDate

        

   UPDATE tpx
      SET tpx.PrevBusDayNMV = 0
     FROM #tmpPositions tpx
     JOIN dbo.EnfPositionDetails epx
       ON tpx.BBYellowKey = epx.BBYellowKey
      AND tpx.BookName = epx.BookName
      AND tpx.StratName = epx.StratName
      AND tpx.InstDescr = epx.InstDescr
    WHERE epx.AsOfDate = @PrevBusDayNMV

/*  UPDATE 'ABVX UNDERLYING'  */
    UPDATE tsp
       SET tsp.UnderlyBBYellowKey = tsp.BBYellowKey
      FROM #tmpPositions tsp
	   WHERE CHARINDEX('ABVX US', tsp.BBYellowKey) != 0

/*  UPDATE 'MSA14568' with known BookName change  */
    UPDATE tsp
       SET tsp.BookName = 'Equity Hedge - Core'
      FROM #tmpPositions tsp
	   WHERE CHARINDEX('MSA14568', tsp.InstDescr) != 0


    IF @EquitiesOnly = 1
      BEGIN
        DELETE tsp           
          FROM #tmpPositions tsp
	       WHERE tsp.InstrType != 'Equity'
      END


  IF @ResultSet = 1
    BEGIN
      DELETE tsp
        FROM #tmpPositions tsp
       WHERE ABS(ROUND(tsp.Quantity, 0)) = 0
	  END


      SELECT tsp.AsOfDate,
             tsp.FundShortName,
             tsp.StratName,
             tsp.BookName,
             tsp.InstDescr,
             tsp.BBYellowKey,
             tsp.UnderlyBBYellowKey,
             tsp.Account,
             tsp.InstrType,
             tsp.CcyOne,
             tsp.CcyTwo,
             tsp.Quantity,
             tsp.NetAvgCost,
             tsp.OverallCost,
             tsp.FairValue,
             tsp.NetMarketValue,
             tsp.DlyPnlUsd,
             tsp.DlyPnlOfNav,
             tsp.MtdPnlUsd,
             tsp.MtdPnlOfNav,
             tsp.YtdPnlUsd,
             tsp.YtdPnlOfNav,
             tsp.ItdPnlUsd,
             tsp.Delta,
             tsp.DeltaAdjMV,
             tsp.DeltaExp,
			       tsp.LongShort,
             tsp.LongMV,
             tsp.ShortMV,
			       tsp.GrExpOfGLNav AS GrossExp,
             tsp.InstrTypeCode,
             tsp.InstrTypeUnder,
             tsp.PrevBusDayNMV
        FROM #tmpPositions tsp
	     WHERE 1 = 1
         AND CHARINDEX('FX Spot', tsp.InstDescr) = 0
		     AND CHARINDEX('FX Forward', tsp.InstDescr) = 0
         AND (CHARINDEX('Settled Cash', tsp.InstDescr) = 0)
	     ORDER BY tsp.AsOfDate,
             tsp.FundShortName,
             CASE WHEN RTRIM(LTRIM(tsp.StratName)) = '' THEN 'zzz' ELSE tsp.StratName END,
             CASE WHEN RTRIM(LTRIM(tsp.BookName)) = '' THEN 'zzz' ELSE tsp.BookName END,
             tsp.InstDescr,
             tsp.BBYellowKey,
             tsp.UnderlyBBYellowKey


   SET NOCOUNT OFF

   END
   GO

   GRANT EXECUTE ON dbo.p_GetEnfPositionData TO PUBLIC
   GO
