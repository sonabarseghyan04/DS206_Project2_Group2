USE [{{database_name}}];

DECLARE @StartDate DATE = CAST('{{start_date}}' AS DATE);
DECLARE @EndDate DATE = CAST('{{end_date}}' AS DATE);

DECLARE @SOR_SK INT = (
    SELECT SOR_SK
    FROM dimensional.Dim_SOR
    WHERE StagingTableName = 'Stg_Orders'
);

-- ================================
-- Insert into FactOrders_Error
-- ================================
INSERT INTO dimensional.FactOrders_Error
(
    OrderID_NK,
    CustomerID,
    EmployeeID,
    ShipVia,
    TerritoryID,
    MiniTerritoryID,
    SOR_SK,
    ErrorMessage,
    OrderDate,
    RequiredDate,
    ShippedDate,
    Freight,
    InsertedAt
)
SELECT
    o.OrderID,
    o.CustomerID,
    o.EmployeeID,
    o.ShipVia,
    o.TerritoryID,
    dtm.MiniTerritory_SK_PK,
    @SOR_SK,
    CASE
        WHEN dc.Customer_SK_PK IS NULL THEN 'Missing Customer in DimCustomers'
        WHEN de.Employee_SK_PK IS NULL THEN 'Missing Employee in DimEmployees'
        WHEN ds.Shipper_SK_PK IS NULL THEN 'Missing Shipper in DimShippers'
        WHEN dt.Territory_SK_PK IS NULL THEN 'Missing Territory in DimTerritories'
        WHEN dtm.MiniTerritory_SK_PK IS NULL THEN 'Missing MiniTerritory in DimTerritoriesMini'
        ELSE 'Unknown Error'
    END AS ErrorMessage,
    o.OrderDate,
    o.RequiredDate,
    o.ShippedDate,
    o.Freight,
    GETDATE()
FROM staging.Stg_Orders o
LEFT JOIN dimensional.DimCustomers dc
    ON dc.Customer_NK = o.CustomerID
    AND dc.CurrentIndicator = 1
LEFT JOIN dimensional.DimEmployees de
    ON de.EmployeeID_NK = o.EmployeeID
LEFT JOIN dimensional.DimShippers ds
    ON ds.ShipperID_NK = o.ShipVia
LEFT JOIN dimensional.DimTerritories dt
    ON dt.TerritoryID_NK = o.TerritoryID
LEFT JOIN dimensional.DimTerritoriesMini dtm
    ON dtm.MiniTerritory_SK_PK = dt.MiniTerritory_SK
WHERE o.OrderDate BETWEEN @StartDate AND @EndDate
AND (
    dc.Customer_SK_PK IS NULL
    OR de.Employee_SK_PK IS NULL
    OR ds.Shipper_SK_PK IS NULL
    OR dt.Territory_SK_PK IS NULL
    OR dtm.MiniTerritory_SK_PK IS NULL
)
AND NOT EXISTS (
    SELECT 1
    FROM dimensional.FactOrders_Error fe
    WHERE fe.OrderID_NK = o.OrderID
);
