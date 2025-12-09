USE ORDER_DDS;

DECLARE @SOR_SK INT = (
    SELECT SOR_SK
    FROM dimensional.Dim_SOR
    WHERE StagingTableName = 'Stg_Products'
);

--------------------------------------
-- 1. Mark missing products as inactive
--------------------------------------
UPDATE dp
SET dp.Current_Indicator = 0,
    dp.Ineffective_Date = GETDATE(),
    dp.Row_Modified = GETDATE()
FROM dimensional.DimProducts dp
LEFT JOIN staging.Stg_Products sp
    ON dp.Product_NK = sp.ProductID
WHERE sp.ProductID IS NULL
  AND dp.Current_Indicator = 1;

--------------------------------------
-- 2. Mark changed products as inactive
--------------------------------------
UPDATE dp
SET dp.Current_Indicator = 0,
    dp.Ineffective_Date = GETDATE(),
    dp.Row_Modified = GETDATE()
FROM dimensional.DimProducts dp
JOIN staging.Stg_Products sp
    ON dp.Product_NK = sp.ProductID
JOIN dimensional.DimSuppliers ds
    ON ds.SupplierID_NK = sp.SupplierID
JOIN dimensional.DimCategories dc
    ON dc.CategoryID_NK = sp.CategoryID
WHERE dp.Current_Indicator = 1
  AND (
        ISNULL(dp.ProductName,'') <> ISNULL(sp.ProductName,'')
    OR  ISNULL(dp.Supplier_SK,0) <> ds.Supplier_SK_PK
    OR  ISNULL(dp.Category_SK,0) <> dc.Category_SK_PK
    OR  ISNULL(dp.QuantityPerUnit,'') <> ISNULL(sp.QuantityPerUnit,'')
    OR  ISNULL(dp.UnitPrice,0) <> ISNULL(sp.UnitPrice,0)
    OR  ISNULL(dp.UnitsInStock,0) <> ISNULL(sp.UnitsInStock,0)
    OR  ISNULL(dp.UnitsOnOrder,0) <> ISNULL(sp.UnitsOnOrder,0)
    OR  ISNULL(dp.ReorderLevel,0) <> ISNULL(sp.ReorderLevel,0)
    OR  ISNULL(dp.Discontinued,0) <> ISNULL(sp.Discontinued,0)
  );

--------------------------------------
-- 3. Insert new current rows
--------------------------------------
INSERT INTO dimensional.DimProducts
(
    Product_Durable_SK,
    Product_NK,
    SOR_SK,
    ProductName,
    Supplier_SK,
    Category_SK,
    QuantityPerUnit,
    UnitPrice,
    UnitsInStock,
    UnitsOnOrder,
    ReorderLevel,
    Discontinued,
    Effective_Date,
    Current_Indicator,
    Row_Created
)
SELECT
    ISNULL(dp.Product_Durable_SK, (SELECT ISNULL(MAX(Product_Durable_SK),0)+1 FROM dimensional.DimProducts)),
    sp.ProductID,
    @SOR_SK,
    sp.ProductName,
    s.Supplier_SK_PK,
    c.Category_SK_PK,
    sp.QuantityPerUnit,
    sp.UnitPrice,
    sp.UnitsInStock,
    sp.UnitsOnOrder,
    sp.ReorderLevel,
    sp.Discontinued,
    GETDATE(),
    1,
    GETDATE()
FROM staging.Stg_Products sp
LEFT JOIN dimensional.DimProducts dp
    ON dp.Product_NK = sp.ProductID
    AND dp.Current_Indicator = 1
LEFT JOIN dimensional.DimSuppliers s
    ON s.SupplierID_NK = sp.SupplierID
LEFT JOIN dimensional.DimCategories c
    ON c.CategoryID_NK = sp.CategoryID
WHERE dp.Product_NK IS NULL;

--------------------------------------
-- 4. Cleanup: ensure only ONE current row per Product_NK
--------------------------------------
WITH cte AS (
    SELECT Product_SK_PK,
           ROW_NUMBER() OVER(PARTITION BY Product_NK ORDER BY Effective_Date DESC, Product_SK_PK DESC) AS rn
    FROM dimensional.DimProducts
    WHERE Current_Indicator = 1
)
UPDATE dp
SET Current_Indicator = 0,
    Ineffective_Date = GETDATE(),
    Row_Modified = GETDATE()
FROM dimensional.DimProducts dp
JOIN cte
  ON dp.Product_SK_PK = cte.Product_SK_PK
WHERE cte.rn > 1;
