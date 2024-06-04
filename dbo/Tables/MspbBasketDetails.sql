/*
ALTER TABLE [dbo].[MspbBasketDetails] SET ( SYSTEM_VERSIONING = OFF  )
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MspbBasketDetails]') AND type in (N'U'))
DROP TABLE [dbo].[MspbBasketDetails]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MspbBasketDetails_history]') AND type in (N'U'))
DROP TABLE [dbo].[MspbBasketDetails_history]
GO
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MspbBasketDetails](
	[iId]                         BIGINT IDENTITY(1, 1) NOT NULL,
    CONSTRAINT [PK_BasketDetails] PRIMARY KEY CLUSTERED (iId),
    [PortfolioID]                 VARCHAR(255) NOT NULL,
    [PortfolioName]               VARCHAR(255) NOT NULL,
    [BasketTicker]                VARCHAR(255) NOT NULL,
    [CompTicker]                  VARCHAR(255) NOT NULL,     
    [CompName]                    VARCHAR(255) NOT NULL,
    [PctWeight]                   FLOAT NULL,
    [CompDefShares]               FLOAT NULL,
    [CompPrice]                   FLOAT NULL,
    [Divisor]                     FLOAT NULL,
    [CompRIC]                     VARCHAR(255) NOT NULL,
    [CompSEDOL]                   VARCHAR(255) NOT NULL,
    [CompCcy]                     VARCHAR(255) NOT NULL,
    [AsOfDate]                    DATE,
    [CompISIN]                    VARCHAR(255) NOT NULL,
    [BasketRIC]                   VARCHAR(255) NOT NULL,
    [BasketId]                    VARCHAR(255) NOT NULL,
    [BasketCcy]                   VARCHAR(255) NOT NULL,
    [BasketQuantity]              FLOAT NULL,
    [BasketPrice]                 FLOAT NULL,
    [BasketMarkPrice]             FLOAT NULL,
    [FxRate]                      FLOAT NULL,
    [CompPriceBskCcy]             FLOAT NULL,
    [BasketNotional]              FLOAT NULL,
    [ExpNotional]                 FLOAT NULL,
    [CompExpShares]               FLOAT NULL,
    [PairBasket]                  FLOAT NULL,
    [CompExpNotional]             FLOAT NULL,
    [CompBbg]                     VARCHAR(255),
	  [SysStartTime]                DATETIME2(7)  GENERATED ALWAYS AS ROW START NOT NULL,
	  [SysEndTime]                  DATETIME2(7)  GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[MspbBasketDetails_history])
)
GO
