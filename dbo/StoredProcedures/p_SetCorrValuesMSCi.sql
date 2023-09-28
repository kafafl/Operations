USE Operations
GO

CREATE PROCEDURE dbo.p_SetCorrValuesMSCi(
   @AsOfDate        DATE,
   @PortfolioName   VARCHAR(500),
   @Ticker          VARCHAR(500),
   @SecName         VARCHAR(500), 
   @Quantity        FLOAT,
   @Price           FLOAT, 
   @MktVal          FLOAT, 
   @WeightMod       FLOAT, 
   @MktCorr         FLOAT, 
   @BmkCorr         FLOAT)
 
 /*
  Author: Lee Kafafian
  Crated: 09/25/2023
  Object: p_SetCorrValuesMSCi
  Example:  EXEC dbo.p_SetCorrValuesMSCi @MsgValue = 'Here is a message.', @MsgPriority = 1, @MsgCatagory = 'Basket Monitor', @MsgInTs = '09/24/2023 09:35:19' 
 */
  
 AS 
   BEGIN
   SET NOCOUNT ON
     
    DECLARE @BBYellowkey AS VARCHAR(500)
    
    INSERT INTO dbo.MSCiCorrelations(
           AsOfDate,
           PortfolioName,
           Ticker,
           SecName,
           Quantity,
           Price,
	    MktVal,
           WeightMod,
           MktCorr,
           BmkCorr)
    SELECT @AsOfDate,
           @PortfolioName,
           @Ticker,
           @SecName,
           @Quantity,
           @Price,
           @MktVal,
           @WeightMod,
           @MktCorr,
           @bmkCorr


   /*  UPDATE WITH YELLOW KEY  */
       SELECT TOP 1 @BBYellowkey = epd.BBYellowKey 
         FROM dbo.EnfPositionDetails epd 
        WHERE epd.AsOfDate = @AsOfDate
	   AND epd.InstrType = 'Equity'
          AND CHARINDEX(@Ticker, epd.BBYellowKey) !=0

	UPDATE mcc
	   SET mcc.BbgYellowKey = @BBYellowkey
	  FROM dbo.MSCiCorrelations mcc
	 WHERE mcc.Ticker = @Ticker
	   AND mcc.SEcName = @SecName
	   AND mcc.AsOfDate = @AsOfDate

    SELECT @AsOfDate,
           @PortfolioName,
           @Ticker,
           @SecName,
           @Quantity,
           @Price,
           @MktVal,
           @WeightMod,
           @MktCorr,
           @bmkCorr



   SET NOCOUNT OFF
   END


GRANT EXECUTE ON dbo.p_SetCorrValuesMSCi TO PUBLIC
GO
