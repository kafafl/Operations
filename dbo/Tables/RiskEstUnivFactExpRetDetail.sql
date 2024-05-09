CREATE TABLE dbo.RiskEstUnivFactExpRetDetail(
  iId                      BIGINT IDENTITY (1, 1) NOT NULL,
  AsOfDate                 DATE,
  AssetIdBarra             VARCHAR(255),
  AssetNameBarra           VARCHAR(255),
  FactorNameBarra          VARCHAR(255),
  RetVal                   FLOAT,
  JobReference             VARCHAR(255),
  CreatedBy                VARCHAR(50)    CONSTRAINT DF_RiskEstUnivFactExpRetDetail_CreatedBy DEFAULT(SUSER_NAME()),
  CreatedOn                DATETIME       CONSTRAINT DF_RiskEstUnivFactExpRetDetail_CreatedOn DEFAULT(GETDATE()))
GO


GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.RiskEstUnivFactExpRetDetail TO PUBLIC
GO
