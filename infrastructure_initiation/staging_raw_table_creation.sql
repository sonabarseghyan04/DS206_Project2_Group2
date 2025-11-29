USE ORDER_DDS;
GO

-- Categories
CREATE TABLE dbo.Stg_Categories (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT,
    CategoryName NVARCHAR(255),
    Description NVARCHAR(MAX)
);
GO

-- Customers
CREATE TABLE dbo.Stg_Customers (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID NVARCHAR(10),
    CompanyName NVARCHAR(255),
    ContactName NVARCHAR(255),
    ContactTitle NVARCHAR(255),
    Address NVARCHAR(255),
    City NVARCHAR(100),
    Region NVARCHAR(100),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(100),
    Phone NVARCHAR(50),
    Fax NVARCHAR(50)
);
GO

-- Employees
CREATE TABLE dbo.Stg_Employees (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT,
    LastName NVARCHAR(50),
    FirstName NVARCHAR(50),
    Title NVARCHAR(100),
    TitleOfCourtesy NVARCHAR(50),
    BirthDate DATE,
    HireDate DATE,
    Address NVARCHAR(255),
    City NVARCHAR(100),
    Region NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(50),
    HomePhone NVARCHAR(50),
    Extension NVARCHAR(10),
    Notes NVARCHAR(MAX),
    ReportsTo INT,
    PhotoPath NVARCHAR(255)
);
GO

-- Order Details
CREATE TABLE dbo.Stg_OrderDetails (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    UnitPrice DECIMAL(19,4),
    Quantity INT,
    Discount FLOAT
);
GO

-- Orders
CREATE TABLE dbo.Stg_Orders (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    CustomerID NVARCHAR(10),
    EmployeeID INT,
    OrderDate DATE,
    RequiredDate DATE,
    ShippedDate DATE,
    ShipVia INT,
    Freight DECIMAL(19,4),
    ShipName NVARCHAR(255),
    ShipAddress NVARCHAR(255),
    ShipCity NVARCHAR(100),
    ShipRegion NVARCHAR(50),
    ShipPostalCode NVARCHAR(20),
    ShipCountry NVARCHAR(50),
    TerritoryID INT
);
GO

-- Products
CREATE TABLE dbo.Stg_Products (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    ProductName NVARCHAR(255),
    SupplierID INT,
    CategoryID INT,
    QuantityPerUnit NVARCHAR(50),
    UnitPrice DECIMAL(19,4),
    UnitsInStock INT,
    UnitsOnOrder INT,
    ReorderLevel INT,
    Discontinued BIT
);
GO

-- Region
CREATE TABLE dbo.Stg_Region (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    RegionID INT,
    RegionDescription NVARCHAR(255),
    RegionCategory NVARCHAR(50),
    RegionImportance NVARCHAR(50)
);
GO

-- Shippers
CREATE TABLE dbo.Stg_Shippers (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    ShipperID INT,
    CompanyName NVARCHAR(255),
    Phone NVARCHAR(50)
);
GO

-- Suppliers
CREATE TABLE dbo.Stg_Suppliers (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT,
    CompanyName NVARCHAR(255),
    ContactName NVARCHAR(255),
    ContactTitle NVARCHAR(255),
    Address NVARCHAR(255),
    City NVARCHAR(100),
    Region NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(50),
    Phone NVARCHAR(50),
    Fax NVARCHAR(50),
    HomePage NVARCHAR(255)
);
GO

-- Territories
CREATE TABLE dbo.Stg_Territories (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    TerritoryID NVARCHAR(10),
    TerritoryDescription NVARCHAR(255),
    TerritoryCode NVARCHAR(10),
    RegionID INT
);
GO
