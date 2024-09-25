SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[p_ClearMspbRecData](
    @AsOfDate             DATE)
 
 /*
  Author: Lee Kafafian
  Crated: 01/25/2024
  Object: p_ClearMspbRecData
  Example:  EXEC dbo.p_ClearMspbRecData @AsOfDate = '05/12/2024'
 */
  
 AS 

  BEGIN

    SET NOCOUNT ON
     
    DELETE msfs
      FROM dbo.MsfsStatusReportExecSummary msfs
     WHERE msfs.AsOfDate = @AsOfDate

    SET NOCOUNT OFF

  END

GO

GRANT EXECUTE ON dbo.p_ClearMspbRecData TO PUBLIC
GO