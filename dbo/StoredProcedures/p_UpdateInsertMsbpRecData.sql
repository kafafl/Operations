SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE dbo.p_UpdateInsertMspbRecData(
    @AsOfDate          DATE,
    @recId             VARCHAR(500),
    @recAction         VARCHAR(500),
    @recComment        VARCHAR(500),
    @recResponse       VARCHAR(500),
    @recFundName       VARCHAR(500),
    @recSection        VARCHAR(500),
    @recCustodian      VARCHAR(500),
    @recSummary        VARCHAR(500),
    @recIdentifier     VARCHAR(500),
    @recSecDescr       VARCHAR(500),
    @recTradeId        VARCHAR(500),
    @recTradeDate      VARCHAR(500),
    @recMsQuantity     VARCHAR(500),
    @recCuQuantity     VARCHAR(500),
    @recQuantDiff      VARCHAR(500),
    @recMsAmount       VARCHAR(500),
    @recCuAmount       VARCHAR(500),
    @recAmtDiff        VARCHAR(500),
    @recMsComm         VARCHAR(500),
    @recCuComm         VARCHAR(500),
    @recCommDiff       VARCHAR(500),
    @recSettleCcy      VARCHAR(500),
    @recStrategy       VARCHAR(500),
    @recBreakAge       VARCHAR(500),
    @recPortfolio      VARCHAR(500),
    @recSource         VARCHAR(500))
  
 /*
  Author:   Lee Kafafian
  Crated:   09/25/2024
  Object:   p_UpdateInsertMspbRecData
  Example:  EXEC dbo.p_UpdateInsertMspbRecData @AsOfDate = '01/02/2023'...
 */
  
 AS 

  BEGIN
     
    SET NOCOUNT ON

    IF EXISTS(SELECT TOP 1 * FROM dbo.MsfsStatusReportExecSummary rec WHERE rec.AsOfDate = @AsOfDate  AND 1 = 0)
      BEGIN
        UPDATE epd
           SET epd.AsOfDate = @AsOfDate
            /* ADD AT SOME POINT */
          FROM dbo.MsfsStatusReportExecSummary epd
         WHERE epd.AsOfDate = @AsOfDate
      END
    ELSE
      BEGIN
        INSERT INTO dbo.MsfsStatusReportExecSummary(
               AsOfDate,
               iRecId,
               RecAction,
               RecComment,
               RecResponse,
               FundName,
               RecSection,
               RecCustodian,
               BreakSummary,
               RecIdentifier,
               MsSecDescription,
               RecTradeId,
               RecTradeDate,
               RecMsQuantity,
               RecCuQuantity,
               RecQuantDiff,
               RecMsAmount,
               RecCuAmount,
               RecAmntDiff,
               RecMsComm,
               RecCuComm,
               RecCommDiff,
               RecSettleCcy,
               RecStrategy,
               RecBreakAge,
               RecPortfolio,
               RecSource)
       SELECT  @AsOfDate,
               @recId,
               @recAction,
               @recComment,
               @recResponse,
               @recFundName,
               @recSection,
               @recCustodian,
               @recSummary,
               @recIdentifier,
               @recSecDescr,
               @recTradeId,
               @recTradeDate,
               @recMsQuantity,
               @recCuQuantity,
               @recQuantDiff,
               @recMsAmount,
               @recCuAmount,
               @recAmtDiff,
               @recMsComm,
               @recCuComm,
               @recCommDiff,
               @recSettleCcy,
               @recStrategy,
               @recBreakAge,
               @recPortfolio,
               @recSource         
      END

    SET NOCOUNT OFF
  END
GO

GRANT EXECUTE ON dbo.p_UpdateInsertMspbRecData TO PUBLIC
GO