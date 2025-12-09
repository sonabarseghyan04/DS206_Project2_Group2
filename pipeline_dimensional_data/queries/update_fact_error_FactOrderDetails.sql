USE [{{database_name}}];

DECLARE @StartDate DATE = CAST('{{start_date}}' AS DATE);
DECLARE @EndDate DATE = CAST('{{end_date}}' AS DATE);

DECLARE @SOR_SK INT = (
    SELECT SOR_SK
    FROM dimensional.Dim_SOR
    WHERE StagingTableName = 'Stg_OrderDetails'
);

-- ================================
-- Insert into FactOrderDetails_Error
-- ================================
INSERT INTO dimensional.FactOrderDetails_Error
(
    FactOrder_SK_PK,
    Product_SK_PK,
    SOR_SK,
    UnitPrice,
    Quantity,
    Discount,
    ErrorReason,
    InsertedAt
)
SELECT
    f.FactOrder_SK_PK,
    p.Product_SK_PK,
    @SOR_SK,
    o.UnitPrice,
    o.Quantity,
    o.Discount,
    CASE
        WHEN f.FactOrder_SK_PK IS NULL THEN 'Missing FactOrder reference'
        WHEN p.Product_SK_PK IS NULL THEN 'Missing Product reference'
        ELSE 'Unknown error'
    END AS ErrorReason,
    GETDATE()
FROM staging.Stg_OrderDetails o
JOIN staging.Stg_Orders ord
    ON ord.OrderID = o.OrderID
LEFT JOIN dimensional.FactOrders f
    ON f.OrderID_NK = o.OrderID
LEFT JOIN dimensional.DimProducts p
    ON p.Product_NK = o.ProductID
WHERE ord.OrderDate BETWEEN @StartDate AND @EndDate
  AND (f.FactOrder_SK_PK IS NULL OR p.Product_SK_PK IS NULL)
  AND NOT EXISTS (
      SELECT 1
      FROM dimensional.FactOrderDetails_Error fe
      WHERE fe.FactOrder_SK_PK = f.FactOrder_SK_PK
        AND fe.Product_SK_PK = p.Product_SK_PK
  );
