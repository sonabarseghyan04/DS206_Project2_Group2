DECLARE @SOR_SK INT = (
    SELECT SOR_SK
    FROM dimensional.Dim_SOR
    WHERE StagingTableName = 'Stg_Territories'
);

-- Insert new mini-dimension rows for rapidly changing attributes
INSERT INTO dimensional.DimTerritoriesMini
(
    TerritoryCode,
    Row_Created
)
SELECT DISTINCT s.TerritoryCode, GETDATE()
FROM staging.Stg_Territories s
LEFT JOIN dimensional.DimTerritoriesMini m
    ON m.TerritoryCode = s.TerritoryCode
WHERE m.MiniTerritory_SK_PK IS NULL;

-- Insert new base dimension rows for new or changed slowly changing attributes
INSERT INTO dimensional.DimTerritories
(
    TerritoryID_NK,
    SOR_SK,
    TerritoryDescription,
    Region_SK,
    MiniTerritory_SK,
    Row_Created
)
SELECT
    s.TerritoryID,
    @SOR_SK,
    s.TerritoryDescription,
    r.Region_SK_PK,
    m.MiniTerritory_SK_PK,
    GETDATE()
FROM staging.Stg_Territories s
JOIN dimensional.DimRegion r
    ON r.RegionID_NK = s.RegionID
JOIN dimensional.DimTerritoriesMini m
    ON m.TerritoryCode = s.TerritoryCode
LEFT JOIN dimensional.DimTerritories d
    ON d.TerritoryID_NK = s.TerritoryID
   AND d.TerritoryDescription = s.TerritoryDescription
   AND d.Region_SK = r.Region_SK_PK
   AND d.MiniTerritory_SK = m.MiniTerritory_SK_PK
WHERE d.Territory_SK_PK IS NULL;
