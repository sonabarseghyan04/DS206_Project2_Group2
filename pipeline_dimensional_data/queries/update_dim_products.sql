
USE ORDER_DDS;



DECLARE @SOR_SK INT = (
    SELECT SOR_SK
    FROM dimensional.Dim_SOR
    WHERE StagingTableName = 'Stg_Products'
);


UPDATE dp
SET dp.Ineffective_Date = GETDATE(),
    dp.Current_Indicator = 0,
    dp.Row_Modified = GETDATE()
FROM dimensional.DimProducts dp
LEFT JOIN staging.Stg_Products sp
    ON dp.Product_NK = sp.ProductID
WHERE sp.ProductID IS NULL
AND dp.Current_Indicator = 1;


UPDATE dp
SET dp.Ineffective_Date = GETDATE(),
    dp.Current_Indicator = 0,
    dp.Row_Modified = GETDATE()
FROM dimensional.DimProducts dp
JOIN staging.Stg_Products sp
    ON dp.Product_NK = sp.ProductID
WHERE dp.Current_Indicator = 1
AND (
        ISNULL(dp.ProductName,'') <> ISNULL(sp.ProductName,'')
    OR  ISNULL(dp.Supplier_SK,0) <> ISNULL(sp.SupplierID,0)
    OR  ISNULL(dp.Category_SK,0) <> ISNULL(sp.CategoryID,0)
    OR  ISNULL(dp.QuantityPerUnit,'') <> ISNULL(sp.QuantityPerUnit,'')
    OR  ISNULL(dp.UnitPrice,0) <> ISNULL(sp.UnitPrice,0)
    OR  ISNULL(dp.UnitsInStock,0) <> ISNULL(sp.UnitsInStock,0)
    OR  ISNULL(dp.UnitsOnOrder,0) <> ISNULL(sp.UnitsOnOrder,0)
    OR  ISNULL(dp.ReorderLevel,0) <> ISNULL(sp.ReorderLevel,0)
    OR  ISNULL(dp.Discontinued,0) <> ISNULL(sp.Discontinued,0)
);


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

    COALESCE(dp.Product_Durable_SK, (SELECT ISNULL(MAX(Product_Durable_SK),0)+1 FROM dimensional.DimProducts)),
    sp.ProductID,
    @SOR_SK,
    sp.ProductName,
    sp.SupplierID,
    sp.CategoryID,
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
    AND dp.Current_Indicator = 0
WHERE dp.Product_NK IS NULL
   OR (
        ISNULL(dp.ProductName,'') <> ISNULL(sp.ProductName,'')
    OR  ISNULL(dp.Supplier_SK,0) <> ISNULL(sp.SupplierID,0)
    OR  ISNULL(dp.Category_SK,0) <> ISNULL(sp.CategoryID,0)
    OR  ISNULL(dp.QuantityPerUnit,'') <> ISNULL(sp.QuantityPerUnit,'')
    OR  ISNULL(dp.UnitPrice,0) <> ISNULL(sp.UnitPrice,0)
    OR  ISNULL(dp.UnitsInStock,0) <> ISNULL(sp.UnitsInStock,0)
    OR  ISNULL(dp.UnitsOnOrder,0) <> ISNULL(sp.UnitsOnOrder,0)
    OR  ISNULL(dp.ReorderLevel,0) <> ISNULL(sp.ReorderLevel,0)
    OR  ISNULL(dp.Discontinued,0) <> ISNULL(sp.Discontinued,0)
   );