CREATE TABLE dbo.DateMaster (
  AsOfDate	      DATE NOT NULL,
  IsWeekday	      BIT NOT NULL DEFAULT = 0,
  IsMktHoliday    BIT NOT NULL DEFAULT = 0)


GRANT SELECT, UPDATE, INSERT ON dbo.DateMaster TO PUBLIC
GO