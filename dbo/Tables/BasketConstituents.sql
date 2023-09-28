USE Operations
GO

CREATE TABLE [dbo].[BasketConstituents](
  iId          BIGINT IDENTITY (1, 1) NOT NULL,
  BasketName   VARCHAR(255) NULL,
  ConstName    VARCHAR (255) NULL,

  UpdateDate   DATETIME)
  GO

ALTER TABLE [dbo].[BasketConstituents]
  ADD COLUMN BasketWght    FLOAT NULL
  GO

