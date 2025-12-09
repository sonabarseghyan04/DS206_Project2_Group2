USE ORDER_DDS;


DECLARE @SOR_SK INT =
(
    SELECT SOR_SK
    FROM dimensional.Dim_SOR
    WHERE StagingTableName = 'Stg_Customers'
);

UPDATE dim
SET
    CurrentIndicator = 0,
    IneffectiveDate = GETDATE(),
    Row_Modified = GETDATE()
FROM dimensional.DimCustomers dim
INNER JOIN staging.Stg_Customers src
    ON dim.Customer_NK = src.CustomerID
WHERE dim.CurrentIndicator = 1
AND (
    ISNULL(dim.CompanyName,'') <> ISNULL(src.CompanyName,'')
    OR ISNULL(dim.ContactName,'') <> ISNULL(src.ContactName,'')
    OR ISNULL(dim.ContactTitle,'') <> ISNULL(src.ContactTitle,'')
    OR ISNULL(dim.Address,'') <> ISNULL(src.Address,'')
    OR ISNULL(dim.City,'') <> ISNULL(src.City,'')
    OR ISNULL(dim.Region,'') <> ISNULL(src.Region,'')
    OR ISNULL(dim.PostalCode,'') <> ISNULL(src.PostalCode,'')
    OR ISNULL(dim.Country,'') <> ISNULL(src.Country,'')
    OR ISNULL(dim.Phone,'') <> ISNULL(src.Phone,'')
    OR ISNULL(dim.Fax,'') <> ISNULL(src.Fax,'')
);


INSERT INTO dimensional.DimCustomers
(
    Customer_Durable_SK,
    Customer_NK,
    SOR_SK,
    CompanyName,
    ContactName,
    ContactTitle,
    Address,
    City,
    Region,
    PostalCode,
    Country,
    Phone,
    Fax,
    EffectiveDate,
    CurrentIndicator,
    Row_Created
)
SELECT
    src.CustomerID,
    src.CustomerID,
    @SOR_SK,
    src.CompanyName,
    src.ContactName,
    src.ContactTitle,
    src.Address,
    src.City,
    src.Region,
    src.PostalCode,
    src.Country,
    src.Phone,
    src.Fax,
    GETDATE(),
    1,
    GETDATE()
FROM staging.Stg_Customers src
LEFT JOIN dimensional.DimCustomers dim
    ON src.CustomerID = dim.Customer_NK
    AND dim.CurrentIndicator = 1
WHERE dim.Customer_NK IS NULL
   OR (
       ISNULL(dim.CompanyName,'') <> ISNULL(src.CompanyName,'')
    OR ISNULL(dim.ContactName,'') <> ISNULL(src.ContactName,'')
    OR ISNULL(dim.ContactTitle,'') <> ISNULL(src.ContactTitle,'')
    OR ISNULL(dim.Address,'') <> ISNULL(src.Address,'')
    OR ISNULL(dim.City,'') <> ISNULL(src.City,'')
    OR ISNULL(dim.Region,'') <> ISNULL(src.Region,'')
    OR ISNULL(dim.PostalCode,'') <> ISNULL(src.PostalCode,'')
    OR ISNULL(dim.Country,'') <> ISNULL(src.Country,'')
    OR ISNULL(dim.Phone,'') <> ISNULL(src.Phone,'')
    OR ISNULL(dim.Fax,'') <> ISNULL(src.Fax,'')
   );
