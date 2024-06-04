CREATE PROCEDURE [dbo].[p_GetBasketMonitorResults](
  @AsOfDate       DATE NULL = DEFAULT)

   /*
  Author:   Lee Kafafian
  Crated:   05/28/2024
  Object:   p_GetBasketMonitorResults
  Example:  EXEC dbo.p_GetBasketMonitorResults 
 */
  
 AS 

   BEGIN

   SET NOCOUNT ON


    CREATE TABLE #tmpProcessRaw(
      Iid                BIGINT NOT NULL,
      MsgCategory        VARCHAR(2500) NOT NULL,
      BasketAlert        VARCHAR(2500) NOT NULL,
      BasketName         VARCHAR(2500) NOT NULL,
      MsgValue           VARCHAR(2500) NOT NULL,
      BasketTicker       VARCHAR(2500) NULL,
      BasketDetail       VARCHAR(2500) NULL,
      MsgPriority        INT NOT NULL,
      MsgInTs            DATETIME NOT NULL,
      bProcessed         BIT NOT NULL DEFAULT 0)

    CREATE TABLE #tmpOutputElements(
      oCategory           VARCHAR(5000) NOT NULL,
      oSubCategory        VARCHAR(5000) NOT NULL,
      oBasketName         VARCHAR(5000) NOT NULL,
      oOutputDetails      VARCHAR(5000) NOT NULL,
      oOrderId            INT NOT NULL)


      IF @AsOfDate IS NULL
        BEGIN
          SELECT @AsOfDate = CAST(GETDATE() AS DATE)
        END

      DECLARE @Tomorrow AS DATE = DATEADD(d, 1, @AsOfDate)
      DECLARE @PostTickerTextMA AS VARCHAR(5000) = 'Equity that announced an M&A transaction today.'
      DECLARE @PostTickerText AS VARCHAR(5000) = 'Equity that is held by Allostery.'
      DECLARE @PreTickerText AS VARCHAR(5000) = 'Basket: MSA1BIOH Index has a constituent:'
      DECLARE @PostTickerTextPxChange AS VARCHAR(5000) = 'Equity with greater than a 50% two-day price move.'
      DECLARE @BasketName AS VARCHAR(255) = ' MSA1BIOH'
      DECLARE @pId AS BIGINT


        INSERT INTO #tmpProcessRaw(
              Iid,
              MsgCategory,
              BasketAlert,
              BasketName,
              MsgValue,
              MsgPriority,
              MsgInTs)
        SELECT msg.Iid,
              msg.MsgCatagory,
              RTRIM(LTRIM(REPLACE(SUBSTRING(msg.MsgCatagory, CHARINDEX('-', msg.MsgCatagory), LEN(msg.MsgCatagory)),'-', ''))) AS BasketAlert,
              RTRIM(LTRIM(REPLACE(SUBSTRING(msg.MsgValue, CHARINDEX('Basket:', msg.MsgValue), CHARINDEX('Index', msg.MsgValue) - 1), 'Basket:', ''))) AS BasketName,
              msg.MsgValue,
              msg.MsgPriority,
              msg.MsgInTs
          FROM dbo.MsgQueue msg
        WHERE msg.MsgInTs BETWEEN @AsOfDate AND @Tomorrow
          AND CHARINDEX('Basket Monitor', msg.MsgCatagory) != 0
        ORDER BY msg.MsgInTs DESC

        UPDATE tpr
           SET tpr.BasketTicker  = LTRIM(RTRIM(REPLACE(SUBSTRING(tpr.msgValue, CHARINDEX(@PreTickerText, tpr.MsgValue), CHARINDEX(@PostTickerTextMA, tpr.MsgValue) - 1), @PreTickerText, '')))
          FROM #tmpProcessRaw tpr
         WHERE tpr.BasketAlert =  'M&A'
           AND tpr.BasketTicker IS NULL

        UPDATE tpr
           SET tpr.BasketTicker  = LTRIM(RTRIM(REPLACE(SUBSTRING(tpr.msgValue, CHARINDEX(@PreTickerText, tpr.MsgValue), CHARINDEX(@PostTickerText, tpr.MsgValue) - 1), @PreTickerText, '')))
          FROM #tmpProcessRaw tpr
         WHERE tpr.BasketAlert =  'in AMF portfolio'
           AND tpr.BasketTicker IS NULL


        UPDATE tpr
           SET tpr.BasketTicker  = LTRIM(RTRIM(REPLACE(SUBSTRING(tpr.msgValue, CHARINDEX(@PreTickerText, tpr.MsgValue), CHARINDEX(@PostTickerTextPxChange, tpr.MsgValue)-1), @PreTickerText, ''))),
               tpr.BasketDetail = LTRIM(RTRIM(REPLACE(SUBSTRING(tpr.msgValue, CHARINDEX(@PostTickerTextPxChange, tpr.MsgValue)-1, LEN(tpr.MsgValue)), @PostTickerTextPxChange, '')))
          FROM #tmpProcessRaw tpr
         WHERE tpr.BasketAlert =  '2D Px Change'
           AND tpr.BasketTicker IS NULL


  /*    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */
  /*    CORPORARTE ACTION DETECTION                                                                                  */
  /*    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   */
        DECLARE @CategoryCorpAct AS VARCHAR(5000) = 'Allostery Basket Corporate Actions:'
        DECLARE @SubcategoryCorpAct AS VARCHAR(5000) = ''
        DECLARE @ConcatCorpActNames AS VARCHAR(5000) = ''
        DECLARE @OrderIdCorpActNames AS INT = 1

        WHILE EXISTS(SELECT TOP 1 tpr.Iid FROM #tmpProcessRaw tpr WHERE tpr.BasketAlert = 'M&A' AND tpr.bProcessed = 0 ORDER BY tpr.BasketTicker ASC)
          BEGIN

            SELECT TOP 1 @pId = tpr.Iid FROM #tmpProcessRaw tpr WHERE tpr.BasketAlert = 'M&A' AND tpr.bProcessed = 0 ORDER BY tpr.BasketTicker ASC

            SELECT @ConcatCorpActNames = @ConcatCorpActNames + RTRIM(LTRIM(SUBSTRING(tpr.BasketTicker, 1, CHARINDEX(' ', tpr.BasketTicker)))) + ', ' FROM #tmpProcessRaw tpr WHERE tpr.Iid = @pId   

            UPDATE tpr
               SET tpr.bProcessed = 1
              FROM #tmpProcessRaw tpr 
             WHERE tpr.Iid = @pId

          END

        INSERT INTO #tmpOutputElements(
              oCategory,
              oSubCategory,
              oBasketName,
              oOutputDetails,
              oOrderId)
        SELECT @CategoryCorpAct,
              @SubcategoryCorpAct,
              @BasketName,
              CASE WHEN COALESCE(@ConcatCorpActNames, '') = '' THEN 'None' ELSE @ConcatCorpActNames END,
              @OrderIdCorpActNames


/*    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */
/*    ALPHA LONG OVERLAP                                                                                          */
/*    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */
      DECLARE @CategoryAlphaOverlap AS VARCHAR(5000) = 'Allostery Long Alpha Overlap:'
      DECLARE @SubcategoryAlphaOverlap AS VARCHAR(5000) = ''
      DECLARE @ConcatAlphaOverlap AS VARCHAR(5000) = ''
      DECLARE @OrderIdAlphaOverlap AS INT = 2

      WHILE EXISTS(SELECT TOP 1 tpr.Iid FROM #tmpProcessRaw tpr WHERE tpr.BasketAlert = 'in AMF portfolio' AND tpr.bProcessed = 0 ORDER BY tpr.BasketTicker ASC)
        BEGIN

          SELECT TOP 1 @pId = tpr.Iid FROM #tmpProcessRaw tpr WHERE tpr.BasketAlert = 'in AMF portfolio' AND tpr.bProcessed = 0 ORDER BY tpr.BasketTicker ASC
          
          SELECT @ConcatAlphaOverlap = @ConcatAlphaOverlap + RTRIM(LTRIM(SUBSTRING(tpr.BasketTicker, 1, CHARINDEX(' ', tpr.BasketTicker)))) + ', ' FROM #tmpProcessRaw tpr WHERE tpr.Iid = @pId   

          UPDATE tpr
             SET tpr.bProcessed = 1
            FROM #tmpProcessRaw tpr 
           WHERE tpr.Iid = @pId

        END

      INSERT INTO #tmpOutputElements(
            oCategory,
            oSubCategory,
            oBasketName,
            oOutputDetails,
            oOrderId)
      SELECT @CategoryAlphaOverlap,
            @SubcategoryAlphaOverlap,
            @BasketName,
            @ConcatAlphaOverlap,
            @OrderIdAlphaOverlap


/*    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */
/*    PRICE CHANGE                                                                                                */   
/*    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */
      DECLARE @CategoryTwoDayPriceChange AS VARCHAR(5000) = 'Allostery Basket Large Two-Day Prices Changes:'
      DECLARE @SubcategoryTwoDayPriceChangePos AS VARCHAR(5000) = 'Positive Price Change > 50%'
      DECLARE @SubcategoryTwoDayPriceChangeNeg AS VARCHAR(5000) = 'Negative Price Change < -50%'
      DECLARE @ConcatTwoDayPriceChangePos AS VARCHAR(5000) = ''
      DECLARE @ConcatTwoDayPriceChangeNeg AS VARCHAR(5000) = ''
      DECLARE @BasketPriceChange AS FLOAT
      DECLARE @OrderIdPriceChangePos AS INT = 3
      DECLARE @OrderIdPriceChangeNeg AS INT = 4

      WHILE EXISTS(SELECT TOP 1 tpr.Iid FROM #tmpProcessRaw tpr WHERE tpr.BasketAlert = '2D Px Change' AND tpr.bProcessed = 0 ORDER BY tpr.BasketTicker ASC)
        BEGIN
          SELECT TOP 1 @pId = tpr.Iid FROM #tmpProcessRaw tpr WHERE tpr.BasketAlert = '2D Px Change' AND tpr.bProcessed = 0 ORDER BY tpr.BasketTicker ASC
          SELECT @BasketPriceChange = CAST(REPLACE(tpr.BasketDetail, '%', '') AS FLOAT) FROM #tmpProcessRaw tpr WHERE tpr.Iid = @pId 

          IF @BasketPriceChange > 0.00
            BEGIN
              SELECT @ConcatTwoDayPriceChangePos = @ConcatTwoDayPriceChangePos + RTRIM(LTRIM(SUBSTRING(tpr.BasketTicker, 1, CHARINDEX(' ', tpr.BasketTicker)))) + ' ('+ COALESCE(tpr.BasketDetail, '') + ')'  + ', ' FROM #tmpProcessRaw tpr WHERE tpr.Iid = @pId   
            END
          ELSE
            BEGIN
              SELECT @ConcatTwoDayPriceChangeNeg = @ConcatTwoDayPriceChangeNeg + RTRIM(LTRIM(SUBSTRING(tpr.BasketTicker, 1, CHARINDEX(' ', tpr.BasketTicker)))) + ' ('+ COALESCE(tpr.BasketDetail, '') + ')'  + ', ' FROM #tmpProcessRaw tpr WHERE tpr.Iid = @pId   
            END

          UPDATE tpr
            SET tpr.bProcessed = 1
            FROM #tmpProcessRaw tpr 
          WHERE tpr.Iid = @pId
        END


      INSERT INTO #tmpOutputElements(
            oCategory,
            oSubCategory,
            oBasketName,
            oOutputDetails,
            oOrderId)
      SELECT @CategoryTwoDayPriceChange,
            @SubcategoryTwoDayPriceChangePos,
            @BasketName,
            CASE WHEN @ConcatTwoDayPriceChangePos = '' THEN 'None' ELSE @ConcatTwoDayPriceChangePos END,
            @OrderIdPriceChangePos

      INSERT INTO #tmpOutputElements(
            oCategory,
            oSubCategory,
            oBasketName,
            oOutputDetails,
            oOrderId)
      SELECT @CategoryTwoDayPriceChange,
            @SubcategoryTwoDayPriceChangeNeg,
            @BasketName,
            CASE WHEN @ConcatTwoDayPriceChangeNeg = '' THEN 'None' ELSE @ConcatTwoDayPriceChangeNeg END,
            @OrderIdPriceChangeNeg
/*    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */



        UPDATE toe
           SET toe.oOutputDetails = CASE WHEN CHARINDEX(',', toe.oOutputDetails, LEN(toe.oOutputDetails)-1) != 0 THEN SUBSTRING(toe.oOutputDetails, 1, LEN(toe.oOutputDetails)-1) ELSE toe.oOutputDetails END
          FROM #tmpOutputElements toe


        SELECT oCategory,
               oSubCategory,
               oBasketName,
               oOutputDetails,
               oOrderId 
          FROM #tmpOutputElements toe 
         ORDER BY toe.oOrderId


    SET NOCOUNT OFF

   END
GO

   GRANT EXECUTE ON dbo.p_GetBasketMonitorResults TO PUBLIC
   GO

