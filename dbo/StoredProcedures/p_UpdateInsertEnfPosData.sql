CREATE PROCEDURE dbo.p_UpdateInsertEnfPosData(
    @AsOfDate             DATE NULL = DEFAULT,
    @FundShortName        VARCHAR (255) ,
    @StratName            VARCHAR (255),
    @BookName             VARCHAR (255) ,
    @InstDescr            VARCHAR (255) ,
    @BBYellowKey	        VARCHAR (255) ,
    @UnderlyBBYellowKey	  VARCHAR (255) ,
    @Account	            VARCHAR (255) ,
    @CcyOne               VARCHAR (255) ,
    @CcyTwo               VARCHAR (255) ,
    @InstrType            VARCHAR(255),
    @Quantity             FLOAT (53) ,
    @NetAvgCost           FLOAT (53) ,
    @OverallCost          FLOAT (53) ,
    @FairValue	          FLOAT (53) ,
    @NetMarketValue       FLOAT (53) ,
    @DlyPnlUsd            FLOAT (53) ,
    @DlyPnlOfNav          FLOAT (53) ,
    @MtdPnlUsd	          FLOAT (53) ,
    @MtdPnlOfNav          FLOAT (53) ,
    @YtdPnlUsd            FLOAT (53) ,
    @YtdPnlOfNav          FLOAT (53) ,
    @ItdPnlUsd            FLOAT (53) ,
    @GrExpOfGLNav         FLOAT (53),
    @Delta                FLOAT (53),
    @DeltaAdjMV           FLOAT (53),
    @DeltaExp             FLOAT (53) NULL,
    @LongShort            VARCHAR (255) NULL,
    @GrossExp             FLOAT (53) NULL,
    @LongMV               FLOAT (53) NULL,
    @ShortMV              FLOAT (53) NULL,
    @InstrTypeCode        VARCHAR (255) NULL,
    @InstrTypeUnder       VARCHAR (255) NULL)
 
 /*
  Author: Lee Kafafian
  Crated: 09/20/2023
  Object: p_UpdateInsertEnfPosData
  Example:  EXEC dbo.p_UpdateInsertEnfPosData @AsOfDate = '01/02/2023', @Entity = 'AMF', @DailyReturn = 0.01

 */
  
 AS 

  BEGIN
     
    IF EXISTS(SELECT TOP 1 * FROM dbo.EnfPositionDetails epd WHERE epd.AsOfDate = @AsOfDate AND 1 = 0)
      BEGIN

        UPDATE epd
           SET epd.BookName = @BookName
            /* ADD AT SOME POINT */
          FROM dbo.EnfPositionDetails epd
         WHERE epd.AsOfDate = @AsOfDate  

      END
    ELSE
      BEGIN
        INSERT INTO dbo.EnfPositionDetails(
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
               GrossExp,
               LongMV,
               ShortMV,
               InstrTypeCode,
               InstrTypeUnder)
        SELECT @AsOfDate,
               @FundShortName,
               @StratName,
               @BookName,
               @InstDescr,
               @BBYellowKey,
               @UnderlyBBYellowKey,
               @Account,
               @CcyOne,
               @CcyTwo,
               @InstrType,
               @Quantity,
               @NetAvgCost,
               @OverallCost,
               @FairValue,
               @NetMarketValue,
               @DlyPnlUsd,
               @DlyPnlOfNav,
               @MtdPnlUsd,
               @MtdPnlOfNav,
               @YtdPnlUsd,
               @YtdPnlOfNav,
               @ItdPnlUsd,
               @GrExpOfGLNav,
               @Delta,
               @DeltaAdjMV,
               @DeltaExp,
               @LongShort,
               @GrossExp,
               @LongMV,
               @ShortMV,
               @InstrTypeCode,
               @InstrTypeUnder
      END

  
  END

GO

GRANT EXECUTE ON dbo.p_UpdateInsertEnfPosData TO PUBLIC
GO