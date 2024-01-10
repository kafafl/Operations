USE Operations
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
  Example:  EXEC dbo.p_GetPerformanceDetails @BegDate = '01/05/2023', @EndDate = '8/31/2023', @EntityName = 'AMF' 
	          EXEC dbo.p_GetPerformanceDetails @BegDate = '01/05/2023', @EndDate = '1/31/2023', @EntityName = 'AMF', @bAggHolidays = 1 
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


 
        INSERT INTO #tmpDateDetail( 
               AsOfDate, 
               IsWeekday, 
               IsMktHoliday) 
        SELECT AsOfDate, 
               IsWeekday, 
               IsMktHoliday 
          FROM dbo.DateMaster dmx 
         WHERE dmx.AsOfDate BETWEEN @BegDate AND @EndDate 
 
        INSERT INTO #tmpPerfReturnData( 
               AsOfDate, 
               Entity, 
               DailyReturn, 
			         DailyReturnNet) 
        SELECT pdx.AsOfDate, 
	             pdx.Entity, 
			         pdx.DailyReturn, 
			         CASE WHEN Entity = 'AMF' THEN pdx.DailyReturn * 0.8 ELSE pdx.DailyReturn END 
          FROM dbo.PerformanceDetails pdx 
         WHERE pdx.AsOfDate BETWEEN @BegDate AND @EndDate 
           AND pdx.Entity = @EntityName       
 
 
        DECLARE @CalcDate           AS DATE 
		    DECLARE @PrevDate           AS DATE 
		    DECLARE @PostHolidayDate    AS DATE 
		    DECLARE @PrevCompReturn     AS FLOAT 
        DECLARE @PrevCompReturnNet  AS FLOAT 
		    DECLARE @HolidayRetVal      AS FLOAT 
		    DECLARE @HolidayRetNetVal   AS FLOAT 
 
 
        WHILE EXISTS(SELECT TOP 1 prd.AsOfDate FROM #tmpPerfReturnData prd WHERE prd.bProcessed = 0 ORDER BY prd.AsOfDate ASC) 
          BEGIN 
             
            SELECT @CalcDate = NULL, @PrevDate = NULL, @PrevCompReturn = 0, @PrevCompReturnNet = 0 
 
            SELECT TOP 1 @CalcDate = prd.AsOfDate  
			        FROM #tmpPerfReturnData prd  
			       WHERE prd.bProcessed = 0  
			       ORDER BY prd.AsOfDate ASC 
 
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
                 
                UPDATE prd 
								   SET prd.DailyReturn = (((1 + @HolidayRetVal) * (1 + prd.DailyReturn))- 1), 
									     prd.DailyReturnNet = (((1 + @HolidayRetNetVal) * (1 + prd.DailyReturnNet)) - 1) 
									FROM #tmpPerfReturnData prd 
								 WHERE prd.AsOfDate = @PostHolidayDate 
 
								SELECT @CalcDate = @PostHolidayDate 
							END 
 
 
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
							 0, 
							 0, 
							 0, 
							 0, 
							 1 
				  FROM #tmpDateDetail tdd 
				 WHERE tdd.IsWeekday = 1 
				   AND tdd.IsMktHoliday = 0 
				   AND tdd.AsOfDate NOT IN (SELECT prd.AsOfDate FROM #tmpPerfReturnData prd) 
 
 
				UPDATE tpd 
				   SET tpd.DailyRetLogNet = LOG(1 + tpd.DailyReturnNet) 
					FROM #tmpPerfReturnData tpd  
 
         
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

GRANT EXECUTE ON dbo.p_GetPerformanceDetails TO PUBLIC
GO

