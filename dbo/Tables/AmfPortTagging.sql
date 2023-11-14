CREATE TABLE dbo.AmfPortTagging(
  iId                      BIGINT IDENTITY (1, 1) NOT NULL,
  AsOfDate                 DATE,
  EntityTag                VARCHAR(255),
  PositionId               VARCHAR(255),
  PositionName             VARCHAR(255),
  PositionStrategy         VARCHAR(500),
  TagReference             VARCHAR(255),
  TagValue                 VARCHAR(255),
  CreatedBy                VARCHAR(50)    CONSTRAINT DF_AmfPortTagging_CreatedBy DEFAULT(SUSER_NAME()),
  CreatedOn                DATETIME       CONSTRAINT DF_AmfPortTagging_CreatedOn DEFAULT(GETDATE()))
GO


GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.AmfPortTagging TO PUBLIC
GO
