USE ORDER_DDS;



DECLARE @SOR_SK INT = (
    SELECT SOR_SK
    FROM dimensional.Dim_SOR
    WHERE StagingTableName = 'Stg_Shippers'
);


DELETE d
FROM dimensional.DimShippers d
LEFT JOIN staging.Stg_Shippers s
    ON d.ShipperID_NK = s.ShipperID
WHERE s.ShipperID IS NULL;


UPDATE d
SET
    d.CompanyName = s.CompanyName,
    d.Phone = s.Phone,
    d.SOR_SK = @SOR_SK
FROM dimensional.DimShippers d
JOIN staging.Stg_Shippers s
    ON d.ShipperID_NK = s.ShipperID
WHERE ISNULL(d.CompanyName,'') <> ISNULL(s.CompanyName,'')
   OR ISNULL(d.Phone,'') <> ISNULL(s.Phone,'');


INSERT INTO dimensional.DimShippers
(
    ShipperID_NK,
    SOR_SK,
    CompanyName,
    Phone,
    InsertedAt
)
SELECT
    s.ShipperID,
    @SOR_SK,
    s.CompanyName,
    s.Phone,
    GETDATE()
FROM staging.Stg_Shippers s
LEFT JOIN dimensional.DimShippers d
    ON d.ShipperID_NK = s.ShipperID
WHERE d.ShipperID_NK IS NULL;


