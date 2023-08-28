CREATE PROCEDURE dbo.p_GetSimplePort(
    @PortDate   DATE NULL = DEFAULT )
 
 
 /*
  Author: Lee Kafafian
  Crated: 08/25/2023
  Object: p_GetSimplePort
  Example:  EXEC dbo.p_GetSimplePort @PortDate = '08/25/2023'
 */
  
 AS 

   BEGIN

     IF @PortDate IS NULL
       BEGIN
         SELECT @PortDate = CAST(GETDATE() AS DATE)
       END

     SELECT pmp.PortDate,
            pmp.InstrNameDescr,
            pmp.InstrTicker,
            pmp.BookName,
            pmp.BbgYellowKey,
            pmp.Quantity,
            pmp.PortComment,
            pmp.UpdateDateTime
       FROM dbo.PortfolioMap pmp
      WHERE pmp.PortDate = @PortDate 
      ORDER BY pmp.BookName,
            pmp.InstrNameDescr
  
   END

GO

