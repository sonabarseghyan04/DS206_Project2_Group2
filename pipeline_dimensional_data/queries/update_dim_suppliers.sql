USE ORDER_DDS;



DECLARE @SOR_SK INT = (
    SELECT SOR_SK
    FROM dimensional.Dim_SOR
    WHERE StagingTableName = 'Stg_Suppliers'
);


UPDATE d
SET
    d.PreviousAddress = d.Address,
    d.Address = s.Address,
    d.CompanyName = s.CompanyName,
    d.ContactName = s.ContactName,
    d.ContactTitle = s.ContactTitle,
    d.City = s.City,
    d.Region = s.Region,
    d.PostalCode = s.PostalCode,
    d.Country = s.Country,
    d.Phone = s.Phone,
    d.Fax = s.Fax,
    d.HomePage = s.HomePage,
    d.SOR_SK = @SOR_SK,
    d.Row_Modified = GETDATE()
FROM dimensional.DimSuppliers d
JOIN staging.Stg_Suppliers s
    ON d.SupplierID_NK = s.SupplierID
WHERE ISNULL(d.Address,'') <> ISNULL(s.Address,'');  -- tracking only Address changes


--updating other attributes if changed but Address did not change

UPDATE d
SET
    d.CompanyName = s.CompanyName,
    d.ContactName = s.ContactName,
    d.ContactTitle = s.ContactTitle,
    d.City = s.City,
    d.Region = s.Region,
    d.PostalCode = s.PostalCode,
    d.Country = s.Country,
    d.Phone = s.Phone,
    d.Fax = s.Fax,
    d.HomePage = s.HomePage,
    d.SOR_SK = @SOR_SK,
    d.Row_Modified = GETDATE()
FROM dimensional.DimSuppliers d
JOIN staging.Stg_Suppliers s
    ON d.SupplierID_NK = s.SupplierID
WHERE ISNULL(d.Address,'') = ISNULL(s.Address,'')
  AND (
        ISNULL(d.CompanyName,'') <> ISNULL(s.CompanyName,'')
     OR ISNULL(d.ContactName,'') <> ISNULL(s.ContactName,'')
     OR ISNULL(d.ContactTitle,'') <> ISNULL(s.ContactTitle,'')
     OR ISNULL(d.City,'') <> ISNULL(s.City,'')
     OR ISNULL(d.Region,'') <> ISNULL(s.Region,'')
     OR ISNULL(d.PostalCode,'') <> ISNULL(s.PostalCode,'')
     OR ISNULL(d.Country,'') <> ISNULL(s.Country,'')
     OR ISNULL(d.Phone,'') <> ISNULL(s.Phone,'')
     OR ISNULL(d.Fax,'') <> ISNULL(s.Fax,'')
     OR ISNULL(d.HomePage,'') <> ISNULL(s.HomePage,'')
  );


-- Insert new rows from source not in dimension

INSERT INTO dimensional.DimSuppliers
(
    SupplierID_NK,
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
    HomePage,
    PreviousAddress,
    Effective_Date,
    Row_Created
)
SELECT
    s.SupplierID,
    @SOR_SK,
    s.CompanyName,
    s.ContactName,
    s.ContactTitle,
    s.Address,
    s.City,
    s.Region,
    s.PostalCode,
    s.Country,
    s.Phone,
    s.Fax,
    s.HomePage,
    NULL,
    GETDATE(),
    GETDATE()
FROM staging.Stg_Suppliers s
LEFT JOIN dimensional.DimSuppliers d
    ON d.SupplierID_NK = s.SupplierID
WHERE d.SupplierID_NK IS NULL;

