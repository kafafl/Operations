CREATE TABLE [dbo].[PortfolioMap] (
    [iId]            BIGINT        IDENTITY (1, 1) NOT NULL,
    [PortDate]       DATE          NOT NULL,
    [InstrNameDescr] VARCHAR (255) NOT NULL,
    [InstrTicker]    VARCHAR (50)  NULL,
    [BookName]       VARCHAR (255) NULL,
    [BbgYellowKey]   VARCHAR (255) NULL,
    [Quantity]       FLOAT (53)    NULL,
    [PortComment]    VARCHAR (500) NULL,
    [UpdateDateTime] DATETIME      NULL
);


GO

