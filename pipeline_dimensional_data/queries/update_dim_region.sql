USE ORDER_DDS;


DECLARE @SOR_SK INT = (
    SELECT SOR_SK
    FROM dimensional.Dim_SOR
    WHERE StagingTableName = 'Stg_Region'
);


-- Insert new mini-dimension rows if RegionCategory or RegionImportance changed
INSERT INTO dimensional.DimRegionMini
(
    RegionCategory,
    RegionImportance,
    Row_Created
)
SELECT DISTINCT
    s.RegionCategory,
    s.RegionImportance,
    GETDATE()
FROM staging.Stg_Region s
LEFT JOIN dimensional.DimRegionMini m
    ON ISNULL(m.RegionCategory,'') = ISNULL(s.RegionCategory,'')
   AND ISNULL(m.RegionImportance,'') = ISNULL(s.RegionImportance,'')
WHERE m.MiniRegion_SK_PK IS NULL;


-- Insert new base dimension rows if not exists
INSERT INTO dimensional.DimRegion
(
    RegionID_NK,
    SOR_SK,
    RegionDescription,
    MiniRegion_SK,
    Row_Created
)
SELECT
    s.RegionID,
    @SOR_SK,
    s.RegionDescription,
    m.MiniRegion_SK_PK,
    GETDATE()
FROM staging.Stg_Region s
LEFT JOIN dimensional.DimRegionMini m
    ON m.RegionCategory = s.RegionCategory
   AND m.RegionImportance = s.RegionImportance
LEFT JOIN dimensional.DimRegion d
    ON d.RegionID_NK = s.RegionID
WHERE d.RegionID_NK IS NULL;


-- Update existing base dimension rows if Mini-Dimension changed
UPDATE d
SET d.MiniRegion_SK = m.MiniRegion_SK_PK,
    d.Row_Modified = GETDATE()
FROM dimensional.DimRegion d
JOIN staging.Stg_Region s
    ON d.RegionID_NK = s.RegionID
JOIN dimensional.DimRegionMini m
    ON m.RegionCategory = s.RegionCategory
   AND m.RegionImportance = s.RegionImportance
WHERE d.MiniRegion_SK <> m.MiniRegion_SK_PK;


