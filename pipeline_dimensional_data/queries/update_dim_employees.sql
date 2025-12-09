USE ORDER_DDS;


DECLARE @SOR_SK INT =
(
    SELECT SOR_SK
    FROM dimensional.Dim_SOR
    WHERE StagingTableName = 'Stg_Employees'
);


DELETE D
FROM dimensional.DimEmployees D
LEFT JOIN staging.Stg_Employees S
    ON D.EmployeeID_NK = S.EmployeeID
WHERE S.EmployeeID IS NULL;

UPDATE D
SET
    SOR_SK = @SOR_SK,
    LastName = S.LastName,
    FirstName = S.FirstName,
    Title = S.Title,
    TitleOfCourtesy = S.TitleOfCourtesy,
    BirthDate = S.BirthDate,
    HireDate = S.HireDate,
    Address = S.Address,
    City = S.City,
    Region = S.Region,
    PostalCode = S.PostalCode,
    Country = S.Country,
    HomePhone = S.HomePhone,
    Extension = S.Extension,
    Notes = S.Notes,
    ReportsTo = S.ReportsTo,
    PhotoPath = S.PhotoPath,
    InsertedAt = GETDATE()
FROM dimensional.DimEmployees D
INNER JOIN staging.Stg_Employees S
    ON D.EmployeeID_NK = S.EmployeeID
WHERE

    (
        ISNULL(D.LastName,'') <> ISNULL(S.LastName,'') OR
        ISNULL(D.FirstName,'') <> ISNULL(S.FirstName,'') OR
        ISNULL(D.Title,'') <> ISNULL(S.Title,'') OR
        ISNULL(D.TitleOfCourtesy,'') <> ISNULL(S.TitleOfCourtesy,'') OR
        ISNULL(D.BirthDate,'1900-01-01') <> ISNULL(S.BirthDate,'1900-01-01') OR
        ISNULL(D.HireDate,'1900-01-01') <> ISNULL(S.HireDate,'1900-01-01') OR
        ISNULL(D.Address,'') <> ISNULL(S.Address,'') OR
        ISNULL(D.City,'') <> ISNULL(S.City,'') OR
        ISNULL(D.Region,'') <> ISNULL(S.Region,'') OR
        ISNULL(D.PostalCode,'') <> ISNULL(S.PostalCode,'') OR
        ISNULL(D.Country,'') <> ISNULL(S.Country,'') OR
        ISNULL(D.HomePhone,'') <> ISNULL(S.HomePhone,'') OR
        ISNULL(D.Extension,'') <> ISNULL(S.Extension,'') OR
        ISNULL(D.Notes,'') <> ISNULL(S.Notes,'') OR
        ISNULL(D.ReportsTo,-1) <> ISNULL(S.ReportsTo,-1) OR
        ISNULL(D.PhotoPath,'') <> ISNULL(S.PhotoPath,'')
    );


INSERT INTO dimensional.DimEmployees
(
    EmployeeID_NK,
    SOR_SK,
    LastName,
    FirstName,
    Title,
    TitleOfCourtesy,
    BirthDate,
    HireDate,
    Address,
    City,
    Region,
    PostalCode,
    Country,
    HomePhone,
    Extension,
    Notes,
    ReportsTo,
    PhotoPath,
    InsertedAt
)
SELECT
    S.EmployeeID,
    @SOR_SK,
    S.LastName,
    S.FirstName,
    S.Title,
    S.TitleOfCourtesy,
    S.BirthDate,
    S.HireDate,
    S.Address,
    S.City,
    S.Region,
    S.PostalCode,
    S.Country,
    S.HomePhone,
    S.Extension,
    S.Notes,
    S.ReportsTo,
    S.PhotoPath,
    GETDATE()
FROM staging.Stg_Employees S
LEFT JOIN dimensional.DimEmployees D
    ON S.EmployeeID = D.EmployeeID_NK
WHERE D.EmployeeID_NK IS NULL;

