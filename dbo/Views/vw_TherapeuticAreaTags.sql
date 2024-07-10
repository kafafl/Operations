ALTER VIEW dbo.vw_TherapeuticAreaTags

  AS

    SELECT apx.AsOfDate,
           apx.PositionId,
           apx.TagReference,
           apx.TagValue,
           apx.CreatedOn
      FROM (SELECT MAX(apt.AsOfDate) AS  AsOfDate,
                   apt.PositionId,
                   apt.TagReference,
                   UPPER(apt.TagValue) AS TagValue,
                   MAX(apt.CreatedOn) AS CreatedOn
              FROM dbo.AmfPortTagging apt
             WHERE apt.TagReference = 'Therapeutic Area'
             GROUP BY apt.PositionId,
                   apt.TagReference,
                   apt.TagValue
            HAVING MAX(apt.AsOfDate) = MAX(apt.AsOfDate)
               AND MAX(apt.CreatedOn) = MAX(apt.CreatedOn)) apx
GO

GRANT SELECT ON dbo.vw_TherapeuticAreaTags TO PUBLIC
GO
