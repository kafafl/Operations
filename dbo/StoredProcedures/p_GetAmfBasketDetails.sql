SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[p_GetAmfBasketDetails]( 
    @AsOfDate          DATE = NULL,
    @BasketName        VARCHAR(255) = 'MSA1BIOH') 
 
 /* 
  Author:   Lee Kafafian 
  Crated:   05/08/2024 
  Object:   p_GetAmfBasketDetails 
  Example:  EXEC dbo.p_GetAmfBasketDetails @AsOfDate = '08/07/2024', @BasketName = 'MSA1BIOH'
 */ 
   
 AS  
  BEGIN 
    SET NOCOUNT ON 


          CREATE TABLE #tmpBasketOutput(
            AsOfDate           DATE,
            Portoflio          VARCHAR(255),
            Basket             VARCHAR(255),
            Ticker             VARCHAR(255),
            SecName            VARCHAR(255),
            Shares             NUMERIC(30, 2),
            Price              NUMERIC(30, 2),
            PctWeight          FLOAT,
            ExpNotional        FLOAT,
            RIC                VARCHAR(255),
            SEDOL              VARCHAR(255),
            ISIN               VARCHAR(255),
            Divisor            FLOAT,
            BasketPrice        NUMERIC(30, 2),
            BasketNotional     FLOAT,
            BasketExposure     FLOAT,
            VolumeDate         DATE,
            Avg30dVol          FLOAT,
            Avg30d$Vol         FLOAT,
            SlDate             DATE,
            SlTicker           VARCHAR(255),
            SlShareAvail       FLOAT,
            SlRebate           FLOAT,
            SlRateType         VARCHAR(255))


          CREATE TABLE #tmpSLAvail(
            AsOfDate           DATE,
            BbgTicker          VARCHAR(500),
            SecName            VARCHAR(500),
            IdSedol            VARCHAR(500),
            IdCusip            VARCHAR(500),
            slIdentier         VARCHAR(500),
            slIdType           VARCHAR(500),
            AvailAmount        FLOAT,
            SLRate             NUMERIC(30, 2),
            SLRateType         VARCHAR(50),
            UpdateDate         DATETIME)


        IF @AsOfDate IS NULL
          BEGIN
            SELECT @AsOfDate = CAST(GETDATE() AS DATE)
          END


         INSERT INTO #tmpBasketOutput(
                AsOfDate,
                Portoflio,
                Basket,
                Ticker,
                SecName,
                Shares,
                Price,
                PctWeight,
                ExpNotional,
                RIC,
                SEDOL,
                ISIN,
                Divisor,
                BasketPrice,
                BasketNotional,
                BasketExposure,
                SlTicker)
         SELECT mspb.AsOfDate,
                mspb.PortfolioName,
                mspb.BasketTicker,
                mspb.CompTicker,
                mspb.CompName,
                mspb.CompDefShares,
                CAST(mspb.CompPrice AS NUMERIC(30, 2)),
                mspb.PctWeight,
                mspb.CompExpNotional,
                mspb.CompRIC,
                mspb.CompSEDOL,
                mspb.CompISIN,
                mspb.Divisor,
                mspb.BasketMarkPrice,
                mspb.BasketNotional,
                mspb.ExpNotional,
                LTRIM(RTRIM(LEFT(mspb.CompBbg, CHARINDEX(' ', mspb.CompBbg))))
           FROM dbo.MspbBasketDetails mspb
          WHERE mspb.AsOfDate = (SELECT TOP 1 msbx.AsOfDate FROM dbo.MspbBasketDetails msbx WHERE msbx.AsOfDate <= @AsOfDate ORDER BY msbx.AsOfDate DESC)
            AND mspb.BasketTicker = @BasketName 
          ORDER BY mspb.AsOfDate,
                mspb.CompName,
                mspb.PortfolioName,
                mspb.BasketTicker,
                mspb.CompTicker

        /*  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */
        /*  SUPPORTING DATA CALLS                    */
            DECLARE @AsOfSl AS DATE
            DECLARE @AsOfBmu AS DATE
            DECLARE @AsOfVol AS DATE
            
            SELECT TOP 1 @AsOfSl = msa.AsOfDate FROM dbo.MspbSLAvailability msa WHERE msa.AsOfDate <= @AsOfDate ORDER BY msa.AsOfDate DESC
            SELECT TOP 1 @AsOfBmu = bmu.AsOfDate FROM dbo.BiotechMasterUniverse bmu WHERE bmu.AsOfDate <= @AsOfSl ORDER BY bmu.AsOfDate DESC

            SELECT TOP 1 @AsOfVol = amd.AsOfDate
              FROM dbo.AmfMarketData amd
             WHERE amd.PositionIdType = 'BloombergTicker'
               AND amd.DataSource = 'Bloomberg'
               AND amd.AsOfDate <= @AsOfDate
             ORDER BY amd.AsOfDate DESC


        /*  BEGIN STOCK LOAN AVAILABILITY CARVE OUT  */
        /*  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */

            INSERT INTO #tmpSLAvail(
                    AsOfDate,
                    BbgTicker,
                    SecName,
                    IdSedol,
                    IdCusip,
                    UpdateDate)
             SELECT bmu.AsOfDate,
                    bmu.BbgTicker,
                    bmu.SecName,
                    RTRIM(LTRIM(bmu.IdSEDOL)),
                    RTRIM(LTRIM(bmu.IdCUSIP)),
                    MAX(bmu.SysStartTime) AS TsDataCapture
               FROM dbo.BiotechMasterUniverse bmu
              WHERE (bmu.IdSEDOL IS NOT NULL OR bmu.IdCUSIP IS NOT NULL)
                AND bmu.AsOfDate = @AsOfBmu
              GROUP BY bmu.AsOfDate,
                    bmu.BbgTicker,
                    bmu.SecName, 
                    bmu.IdSEDOL,
                    bmu.IdCUSIP
             HAVING MAX(bmu.SysStartTime) = MAX(bmu.SysStartTime)
              ORDER BY bmu.AsOfDate,
                    bmu.BbgTicker, 
                    bmu.SecName,
                    bmu.IdSEDOL,
                    bmu.IdCUSIP

             UPDATE sla
                SET sla.AvailAmount = msa.AvailAmount,
                    sla.SLRate = msa.SLRate,
                    sla.SLRateType = msa.SLRateType,
                    sla.slIdentier = msa.Identifier,
                    sla.slIdType = 'SEDOL'
               FROM #tmpSLAvail sla
               JOIN dbo.MspbSLAvailability msa
                 ON sla.AsOfDate = msa.AsOfDate
                AND sla.IdSedol = msa.Identifier
              WHERE sla.slIdentier IS NULL 
                
             UPDATE sla
                SET sla.AvailAmount = msa.AvailAmount,
                    sla.SLRate = msa.SLRate,
                    sla.SLRateType = msa.SLRateType,
                    sla.slIdentier = msa.Identifier,
                    sla.slIdType = 'CUSIP'
               FROM #tmpSLAvail sla
               JOIN dbo.MspbSLAvailability msa
                 ON sla.AsOfDate = msa.AsOfDate
                AND sla.IdCusip = msa.Identifier
              WHERE sla.slIdentier IS NULL 

        /*  END STOCK LOAN AVAILABILITY CARVE OUT  */
        /*  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */

             UPDATE tbo
                SET tbo.SlDate = sla.AsOfDate,
                    tbo.SlShareAvail = sla.AvailAmount,
                    tbo.SlRebate = sla.SLRate,
                    tbo.SlRateType = sla.SLRateType
               FROM #tmpBasketOutput tbo
               JOIN #tmpSLAvail sla
                 ON (tbo.SEDOL = sla.IdSedol OR CHARINDEX(tbo.Ticker, sla.BbgTicker) != 0)


        /*  BEGIN AVERAGE VOLUME CARVE OUT           */
        /*  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */

            UPDATE tbo
               SET tbo.VolumeDate = amd.AsOfDate,
                   tbo.Avg30dVol = amd.MdValue,
                   tbo.Avg30d$Vol = amd.MdValue * tbo.Price
              FROM #tmpBasketOutput tbo
              JOIN dbo.AmfMarketData amd
                ON CHARINDEX(tbo.Ticker, amd.PositionId) != 0
             WHERE amd.PositionIdType = 'BloombergTicker'
               AND amd.DataSource = 'Bloomberg'
               AND amd.TagMnemonic = 'VOLUME_AVG_30D'
               AND amd.AsOfDate = @AsOfVol



        /*     SELECT DATA OUT FOR SCREEN USE        */
        /*  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */

        SELECT tbo.AsOfDate,
               tbo.Portoflio,
               tbo.Basket,
               tbo.Ticker,
               tbo.SecName,
               tbo.Shares,
               tbo.Price,
               tbo.PctWeight,
               tbo.ExpNotional,
               tbo.RIC,
               tbo.SEDOL,
               tbo.ISIN,
               tbo.Divisor,
               tbo.BasketPrice,
               tbo.BasketNotional,
               tbo.BasketExposure,
               tbo.VolumeDate,
               tbo.Avg30dVol,
               tbo.Avg30d$Vol,
               tbo.SlDate,
               tbo.SlTicker,
               tbo.SlShareAvail,
               tbo.SlRebate,
               tbo.SlRateType
          FROM #tmpBasketOutput tbo
          ORDER BY tbo.AsOfDate,
               tbo.Portoflio,
               tbo.Basket,
               tbo.Ticker,
               tbo.SecName


    SET NOCOUNT OFF 
  END 
GO


GRANT EXECUTE ON dbo.p_GetAmfBasketDetails TO PUBLIC
GO


