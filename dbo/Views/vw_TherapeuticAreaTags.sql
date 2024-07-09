
CREATE VIEW dbo.vw_TherapeuticAreaTags

  AS

    SELECT * 
      FROM (SELECT MAX(apt.AsOfDate) AS  AsOfDate,
                   PositionId,
                   TagReference,
                   UPPER(TagValue) AS TagValue,
                   MAX(apt.CreatedOn) AS CreatedOn
              FROM dbo.AmfPortTagging apt
             GROUP BY PositionId,
                   TagReference,
                   TagValue
            HAVING MAX(apt.AsOfDate) = MAX(apt.AsOfDate)
               AND MAX(apt.CreatedOn) = MAX(apt.CreatedOn)) apx
     WHERE apx.TagReference = 'Therapeutic Area'


/*  */

GRANT SELECT ON dbo.vw_TherapeuticAreaTags TO PUBLIC
GO

