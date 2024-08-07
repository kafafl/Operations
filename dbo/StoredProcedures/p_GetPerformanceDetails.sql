SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[p_GetPerformanceDetails]( 
    @BegDate         DATE, 
    @EndDate         DATE, 
    @EntityName      VARCHAR(255), 
    @bAggHolidays    BIT = 1,
	  @OutputWeekly    BIT = 0) 
 
/* 
  Author:   Lee Kafafian 
  Crated:   09/05/2023 
  Object:   p_GetPerformanceDetails 
  Example:  EXEC dbo.p_GetPerformanceDetails @BegDate = '04/01/2024', @EndDate = '07/08/2024', @EntityName = 'AMF UNHEDGED' 
	        EXEC dbo.p_GetPerformanceDetails @BegDate = '05/01/2024', @EndDate = '7/31/2024', @EntityName = 'AMF', @bAggHolidays = 1 
 */ 
   
  AS  
 
    BEGIN 
       
      CREATE TABLE #tmpDateDetail( 
        AsOfDate	      DATE NOT NULL, 
        IsWeekday	      BIT, 
        IsMktHoliday      BIT) 
 
      CREATE TABLE #tmpPerfReturnData( 
        AsOfDate          DATE NOT NULL, 
        Entity            VARCHAR(500), 
        DailyReturn       FLOAT, 
		DailyReturnNet    FLOAT, 
	   	DailyRetLogNet    FLOAT, 
        PeriodReturn      FLOAT, 
		PeriodReturnNet   FLOAT, 
        bProcessed        BIT DEFAULT 0)

      CREATE TABLE #tmpPerfReturnDataWeekly( 
        AsOfDate          DATE NOT NULL, 
        Entity            VARCHAR(500), 
        DailyReturn       FLOAT, 
		DailyReturnNet    FLOAT, 
		DailyRetLogNet    FLOAT, 
        PeriodReturn      FLOAT, 
		PeriodReturnNet   FLOAT, 
        bProcessed        BIT DEFAULT 0) 

      CREATE TABLE #tmpHedgePerf(
        AsOfDate          DATE,
        BBYelloKey        VARCHAR(255),
        NAV               FLOAT,
        DeltaAdjMv        FLOAT,
        PctOfNav          FLOAT,
        DtdPerf           FLOAT,
        PctOfPerf         FLOAT)

      CREATE TABLE #tmpFundProfLoss(
        AsOfDate          DATE,
        Entity            VARCHAR(255),
        YtdPnlUsd         FLOAT DEFAULT 1)


        INSERT INTO #tmpDateDetail( 
               AsOfDate, 
               IsWeekday, 
               IsMktHoliday) 
        SELECT AsOfDate, 
               IsWeekday, 
               IsMktHoliday 
          FROM dbo.DateMaster dmx 
         WHERE dmx.AsOfDate BETWEEN @BegDate AND @EndDate
           AND dmx.IsWeekday = 1
 
         INSERT INTO #tmpPerfReturnData( 
                AsOfDate, 
                Entity, 
                DailyReturn, 
			    DailyReturnNet) 
         SELECT pdx.AsOfDate, 
                @EntityName, 
			    pdx.DailyReturn, 
			    pdx.DailyReturn 
           FROM dbo.PerformanceDetails pdx 
          WHERE pdx.AsOfDate BETWEEN @BegDate AND @EndDate 
            AND pdx.Entity = CASE WHEN @EntityName = 'AMF UNHEDGED' THEN 'AMF' ELSE @EntityName END

    IF @EntityName IN ('AMF', 'AMF UNHEDGED')
      BEGIN

         INSERT INTO #tmpFundProfLoss(
                AsOfDate,
                Entity,
                YtdPnlUsd)
         SELECT apd.AsOfDate,
                'AMF',
                SUM(COALESCE(apd.YtdPnlUsd, 0))
           FROM dbo.AdminPositionDetails apd
          WHERE apd.AsOfDate BETWEEN @BegDate AND @EndDate
          GROUP BY apd.AsOfDate

         INSERT INTO #tmpFundProfLoss(
                AsOfDate,
                Entity)
         SELECT tdd.AsOfDate,
                'AMF'
            FROM #tmpDateDetail tdd
           WHERE tdd.AsOfDate NOT IN (SELECT DISTINCT tfl.AsOfDate FROM #tmpFundProfLoss tfl)

         UPDATE prd
            SET prd.DailyReturnNet = prd.DailyReturn * (CASE WHEN fpl.YtdPnlUsd >= 0 THEN 0.80 ELSE 1 END)
            FROM #tmpPerfReturnData prd
            JOIN #tmpFundProfLoss fpl
              ON prd.AsOfDate = fpl.AsOfDate
      END


        IF @EntityName = 'AMF UNHEDGED'
          BEGIN
            /*  ADD UNHEDGING LOGIC HERE   */
                INSERT INTO #tmpHedgePerf(
                       AsOfDate,
                       BBYelloKey,
                       NAV,
                       DeltaAdjMv,
                       PctOfNav) 
                SELECT epd.AsOfDate,
                       epd.BBYellowKey,
                       fad.AssetValue AS NAV,
                       epd.DeltaAdjMV,
                       ABS(COALESCE(epd.DeltaAdjMV, 1) /  COALESCE(fad.AssetValue, 1)) AS PctOfNav
                  FROM dbo.EnfPositionDetails epd
                  JOIN dbo.FundAssetsDetails fad
                    ON epd.AsOfDate = fad.AsOfDate         
                 WHERE epd.AsOfDate BETWEEN @BegDate AND @EndDate 
                   AND epd.BBYellowKey IN ('MSA1BIO Index', 'MSA1BIOH Index')
                   AND fad.Entity = 'AMF NAV'
                 ORDER BY epd.AsOfDate,
                       epd.BBYellowKey

                UPDATE thp
                   SET thp.DtdPerf = pdx.DailyReturn
                  FROM #tmpHedgePerf thp
                  JOIN dbo.PerformanceDetails pdx
                    ON pdx.Entity = thp.BBYelloKey
                   AND pdx.AsOfDate = thp.AsOfDate

                UPDATE thp
                   SET thp.PctOfPerf = COALESCE(thp.PctOfNav, 0) * COALESCE(thp.DtdPerf, 0)
                  FROM #tmpHedgePerf thp

                /*
                SELECT thp.AsOfDate,
                       SUM(thp.PctOfPerf) AS HedgePerf 
                  FROM #tmpHedgePerf thp
                 GROUP BY thp.AsOfDate
                */

                UPDATE tpr
                   SET tpr.DailyReturn = tpr.DailyReturn - hhx.HedgePerf
                  FROM #tmpPerfReturnData tpr
                  JOIN (SELECT thp.AsOfDate,
                               SUM(thp.PctOfPerf) AS HedgePerf 
                          FROM #tmpHedgePerf thp
                         GROUP BY thp.AsOfDate) hhx
                    ON tpr.AsOfDate = hhx.AsOfDate

                UPDATE tpr
                   SET tpr.DailyReturnNet = tpr.DailyReturn * 0.80
                  FROM #tmpPerfReturnData tpr
          END


        DECLARE @CalcDate           AS DATE 
		DECLARE @PrevDate           AS DATE 
		DECLARE @PostHolidayDate    AS DATE         
		DECLARE @PreHolidayDate     AS DATE 
		DECLARE @PrevCompReturn     AS FLOAT 
        DECLARE @PrevCompReturnNet  AS FLOAT 
		DECLARE @HolidayRetVal      AS FLOAT 
		DECLARE @HolidayRetNetVal   AS FLOAT 
        
        
    /*  FIRST TIME THROUGH SET THE VALUES FOR RETURNS, NET RETURNS, AGG RETURNS ON HOLIDAYS  */    
        WHILE EXISTS(SELECT TOP 1 prd.AsOfDate FROM #tmpPerfReturnData prd WHERE prd.bProcessed = 0 ORDER BY prd.AsOfDate ASC) 
          BEGIN 
             
            SELECT @CalcDate = NULL, @PrevDate = NULL, @PrevCompReturn = 0, @PrevCompReturnNet = 0 
 
            SELECT TOP 1 @CalcDate = prd.AsOfDate  
			        FROM #tmpPerfReturnData prd  
			       WHERE prd.bProcessed = 0  
			       ORDER BY prd.AsOfDate ASC 
 
        /*  HOLIDAY MANAGEMENT  */
            IF EXISTS(SELECT 1 FROM #tmpDateDetail tdd WHERE tdd.AsOfDate = @CalcDate AND tdd.IsMktHoliday = 1) AND @bAggHolidays = 1 
			        BEGIN							   
                      SELECT @HolidayRetVal = prd.DailyReturn, 
                             @HolidayRetNetVal = prd.DailyReturnNet  
                        FROM #tmpPerfReturnData prd  
                       WHERE prd.AsOfDate = @CalcDate 
                
                      DELETE prd 
                        FROM #tmpPerfReturnData prd  
                       WHERE prd.AsOfDate = @CalcDate 
                        
                      SELECT TOP 1 @PostHolidayDate = prd.AsOfDate  
                        FROM #tmpPerfReturnData prd 
                       WHERE prd.AsOfDate > @CalcDate 
                         AND prd.bProcessed = 0 
                       ORDER BY prd.AsOfDate ASC

                      SELECT TOP 1 @PreHolidayDate = prd.AsOfDate  
                        FROM #tmpPerfReturnData prd 
                       WHERE prd.AsOfDate < @CalcDate 
                         AND prd.bProcessed = 1 
                       ORDER BY prd.AsOfDate DESC

                        IF @PostHolidayDate IS NULL
                          BEGIN
                            SELECT DISTINCT TOP 1 @PostHolidayDate = pdx.AsOfDate 
                              FROM dbo.PerformanceDetails pdx 
                             WHERE pdx.AsOfDate > @CalcDate
                             ORDER BY pdx.AsOfDate ASC
                          END

                        IF MONTH(@PostHolidayDate) != MONTH(@CalcDate)
                          BEGIN
                            UPDATE prd 
                               SET prd.DailyReturn = (((1 + prd.DailyReturn) * (1 + @HolidayRetVal))- 1), 
                                   prd.DailyReturnNet = (((1 + prd.DailyReturnNet) * (1 + @HolidayRetNetVal)) - 1) 
                              FROM #tmpPerfReturnData prd 
                             WHERE prd.AsOfDate = @PreHolidayDate                   
                          END
                        ELSE
                          BEGIN
                            UPDATE prd 
                               SET prd.DailyReturn = (((1 + @HolidayRetVal) * (1 + prd.DailyReturn))- 1), 
                                   prd.DailyReturnNet = (((1 + @HolidayRetNetVal) * (1 + prd.DailyReturnNet)) - 1) 
                              FROM #tmpPerfReturnData prd 
                             WHERE prd.AsOfDate = @PostHolidayDate    
                          END
				      SELECT @CalcDate = @PostHolidayDate 
			      END 
 
            UPDATE prd 
               SET prd.bProcessed = 1 
              FROM #tmpPerfReturnData prd 
             WHERE prd.AsOfDate = @CalcDate

		      END
 

        UPDATE trd SET trd.bProcessed = 0 FROM #tmpPerfReturnData trd

    /*  COMPOUND THE RETURNS IN ANOTHER LOOP THROUGH  (THIS IS NEEDED BECAUSE HOLIDAY RETURNS ARE FWD & BKWD APPLIED)  */
        WHILE EXISTS(SELECT TOP 1 prd.AsOfDate FROM #tmpPerfReturnData prd WHERE prd.bProcessed = 0 ORDER BY prd.AsOfDate ASC) 
          BEGIN

            SELECT @CalcDate = NULL, @PrevDate = NULL, @PrevCompReturn = 0, @PrevCompReturnNet = 0 
 
            SELECT TOP 1 @CalcDate = prd.AsOfDate  
			  FROM #tmpPerfReturnData prd  
			 WHERE prd.bProcessed = 0  
			 ORDER BY prd.AsOfDate ASC

        /*  COMPOUND RETURNS   */
            SELECT TOP 1 @PrevDate = prd.AsOfDate, 
			       @PrevCompReturn = prd.PeriodReturn, 
				   @PrevCompReturnNet = prd.PeriodReturnNet 
			  FROM #tmpPerfReturnData prd 
			 WHERE prd.AsOfDate < @CalcDate 
			   AND prd.bProcessed = 1            
			 ORDER BY prd.AsOfDate DESC  
 
            IF @PrevDate IS NULL 
			  BEGIN 
                UPDATE prd 
                   SET prd.PeriodReturn = ((1 + prd.DailyReturn) - 1), 
			           prd.PeriodReturnNet = ((1 + prd.DailyReturnNet) - 1), 
			           prd.bProcessed = 1 
                  FROM #tmpPerfReturnData prd 
                 WHERE prd.AsOfDate = @CalcDate  
			  END 
			ELSE 
              BEGIN
                UPDATE prd 
                   SET prd.PeriodReturn = (((1 + prd.DailyReturn) * (1 + @PrevCompReturn)) - 1), 
				       prd.PeriodReturnNet = (((1 + prd.DailyReturnNet) * (1 + @PrevCompReturnNet)) - 1), 
			           prd.bProcessed = 1 
                  FROM #tmpPerfReturnData prd 
                 WHERE prd.AsOfDate = @CalcDate
			  END 
          END 

    /*  ADD ANY DUMMY RECORDS TO COMPLETE MATRIX (SHOULD BE A PARAMETER)  */
         INSERT INTO #tmpPerfReturnData( 
			    AsOfDate, 
			    Entity, 
			    DailyReturn, 
			    DailyReturnNet, 
			    PeriodReturn, 
			    PeriodReturnNet, 
			    bProcessed) 
         SELECT tdd.AsOfDate, 
			    @EntityName, 
			    NULL, 
			    NULL, 
			    NULL, 
			    NULL, 
			    1 
		   FROM #tmpDateDetail tdd 
		  WHERE tdd.IsWeekday = 1 
		    AND tdd.IsMktHoliday = 0 
		    AND tdd.AsOfDate NOT IN (SELECT prd.AsOfDate FROM #tmpPerfReturnData prd) 
                
		 UPDATE tpd 
			SET tpd.DailyRetLogNet = LOG(1 + tpd.DailyReturnNet) 
		   FROM #tmpPerfReturnData tpd  

 
    /*  THE LAST STEP FOR OUTPUT RECORDSETS (LOOK INTO REASON FOR "weekly")     */
        IF @OutputWeekly = 1
		  BEGIN
            SELECT * FROM #tmpPerfReturnData trd WHERE DATEPART(dw, trd.AsOfDate) = 6
          END
		ELSE
		  BEGIN
            SELECT tpd.AsOfDate, 
				   tpd.Entity, 
				   tpd.DailyReturn, 
				   tpd.DailyReturnNet, 
				   tpd.PeriodReturn, 
				   tpd.PeriodReturnNet, 
				   tpd.DailyRetLogNet  
              FROM #tmpPerfReturnData tpd  
             ORDER BY tpd.AsOfDate ASC 
          END

    END 
GO


GRANT EXECUTE on dbo.p_GetPerformanceDetails TO PUBLIC
GO