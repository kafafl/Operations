CREATE TABLE MSCiCorrelations( 
   [Iid]             BIGINT IDENTITY (1, 1) NOT NULL,
   [AsOfDate]        DATE,
   [PortfolioName]   VARCHAR(500),
   [Ticker]          VARCHAR(500),
   [BbgYellowKey]    VARCHAR(500),
   [SecName]         VARCHAR(500), 
   [Quantity]        FLOAT,
   [Price]           FLOAT, 
   [MktVal]          FLOAT, 
   [WeightMod]       FLOAT, 
   [MktCorr]         FLOAT, 
   [BmkCorr]         FLOAT)
   GO