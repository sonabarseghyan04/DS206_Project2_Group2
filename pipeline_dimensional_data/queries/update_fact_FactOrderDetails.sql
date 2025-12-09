USE {{database_name}};


DECLARE @SOR_SK INT = (
    SELECT SOR_SK
    FROM dimensional.Dim_SOR
    WHERE StagingTableName = 'Stg_OrderDetails'
);

INSERT INTO dimensional.FactOrderDetails
(
    FactOrder_SK_PK,
    Product_SK_PK,
    SOR_SK,
    UnitPrice,
    Quantity,
    Discount,
    InsertedAt
)
SELECT
    fo.FactOrder_SK_PK,
    dp.Product_SK_PK,
    @SOR_SK,
    od.UnitPrice,
    od.Quantity,
    od.Discount,
    GETDATE()
FROM staging.Stg_OrderDetails od
JOIN dimensional.FactOrders fo
    ON fo.OrderID_NK = od.OrderID
    AND fo.OrderDate BETWEEN CAST('{{start_date}}' AS DATE)
                         AND CAST('{{end_date}}' AS DATE)
JOIN dimensional.DimProducts dp
    ON dp.Product_NK = od.ProductID
    AND dp.Current_Indicator = 1
WHERE NOT EXISTS (
    SELECT 1
    FROM dimensional.FactOrderDetails fod
    WHERE fod.FactOrder_SK_PK = fo.FactOrder_SK_PK
      AND fod.Product_SK_PK = dp.Product_SK_PK
);

