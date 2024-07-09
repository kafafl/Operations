  
  CREATE TABLE [dbo].[RiskEstUniverse](
    IdxRow                         BIGINT IDENTITY(1, 1),
    AsOfDate                       DATE,
    AssetId                        VARCHAR(MAX),
    AssetName                      VARCHAR(MAX),
    FactorName                     VARCHAR(MAX),
    RetValue                       FLOAT,
    JobReference                   VARCHAR(255),
    CreatedBy                      VARCHAR(50)    CONSTRAINT DF_RiskEstUnivDetail_CreatedBy DEFAULT(SUSER_NAME()),
    CreatedOn                      DATETIME       CONSTRAINT DF_RiskEstUnivDetail_CreatedOn DEFAULT(GETDATE())
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

GRANT SELECT, UPDATE, INSERT, DELETE TO PUBLIC
GO

/*  ADDED INDEXES IN JUNE 2024 (difficult portfolio times) TO IMPROVE PERFORMANCE  */
IF EXISTS(
    SELECT * 
    FROM sys.indexes 
    WHERE name='cidx_RiskEstUniverse' AND OBJECT_ID = OBJECT_ID('RiskEstUniverse')
)
BEGIN
    DROP INDEX cidx_RiskEstUniverse ON [dbo].[RiskEstUniverse]
END
GO

CREATE CLUSTERED INDEX cidx_RiskEstUniverse ON RiskEstUniverse(JobReference, AsOfDate); 
GO


IF EXISTS(
    SELECT * 
    FROM sys.indexes 
    WHERE name='idx_RiskEstUniAsOfDate' AND OBJECT_ID = OBJECT_ID('RiskEstUniverse')
)
BEGIN
    DROP INDEX idx_RiskEstUniAsOfDate ON [dbo].[RiskEstUniverse]
END
GO

CREATE NONCLUSTERED INDEX [idx_RiskEstUniAsOfDate] ON [dbo].[RiskEstUniverse] ([AsOfDate]) INCLUDE ([CreatedOn],[FactorName])
GO

