IF OBJECT_ID('dbo.PerformanceDetails', 'U') IS NOT NULL
  BEGIN 
    DROP TABLE dbo.PerformanceDetails
  END


CREATE TABLE dbo.PerformanceDetails(
  PerfId        BIGINT IDENTITY,
  AsOfDate      DATE,
  Entity        VARCHAR(255),
  DailyReturn   FLOAT,
  PerfNote      VARCHAR(1000))


GRANT SELECT, INSERT, UPDATE ON dbo.PerformanceDetails TO PUBLIC
GO


ALTER TABLE dbo.PerformanceDetails 
            ADD CreatedBy                VARCHAR(50)    CONSTRAINT DF_PerfDetails_CreatedBy DEFAULT(SUSER_NAME()),
                CreatedOn                DATETIME       CONSTRAINT DF_perfDetails_CreatedOn DEFAULT(GETDATE()),
                UpdatedBy                VARCHAR(50) NULL,
                UpdatedOn                DATETIME NULL
                GO


