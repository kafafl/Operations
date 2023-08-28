CREATE TABLE [dbo].[Instruments] (
    [iId]              BIGINT        IDENTITY (1, 1) NOT NULL,
    [InstrNameDescr]   VARCHAR (255) NULL,
    [InstrBbgYelowKey] VARCHAR (255) NULL,
    [InstrSedol]       VARCHAR (24)  NULL,
    [InstrCusip]       VARCHAR (24)  NULL,
    [InstrIsin]        VARCHAR (24)  NULL,
    [InstrCurrency]    VARCHAR (12)  NULL,
    [InstrType]        VARCHAR (255) NULL,
    [InstrTypeSort]    BIGINT        NULL,
    [InstrUnderBbgId]  VARCHAR (255) NULL,
    [InstrUnderlying]  BIGINT        NULL
);


GO

