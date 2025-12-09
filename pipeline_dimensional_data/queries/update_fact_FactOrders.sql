USE [{{database_name}}];



DECLARE @StartDate DATE = CAST('{{start_date}}' AS DATE);
DECLARE @EndDate DATE = CAST('{{end_date}}' AS DATE);


DECLARE @SOR_SK INT = (
    SELECT SOR_SK
    FROM dimensional.Dim_SOR
    WHERE StagingTableName = 'Stg_Orders'
);


INSERT INTO dimensional.FactOrders
(
    OrderID_NK,
    Customer_SK_PK,
    Employee_SK_PK,
    Shipper_SK_PK,
    Territory_SK_PK,
    MiniTerritory_SK_PK,
    SOR_SK,
    OrderDate,
    RequiredDate,
    ShippedDate,
    Freight,
    InsertedAt
)
SELECT
    o.OrderID AS OrderID_NK,
    dc.Customer_SK_PK,
    de.Employee_SK_PK,
    ds.Shipper_SK_PK,
    dt.Territory_SK_PK,
    dtm.MiniTerritory_SK_PK,
    @SOR_SK,
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
AND NOT EXISTS (
    SELECT 1
    FROM dimensional.FactOrders f
    WHERE f.OrderID_NK = o.OrderID
);

