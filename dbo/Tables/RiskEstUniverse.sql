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