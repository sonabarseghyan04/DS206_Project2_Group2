USE ORDER_DDS;
GO

-- ================================
-- Dim_SOR table
-- ================================
CREATE TABLE dimensional.Dim_SOR (
    SOR_SK INT IDENTITY(1,1) PRIMARY KEY,
    StagingTableName NVARCHAR(255) NOT NULL
);
GO

-- ================================
-- DimCategories (SCD1: overwrite on change)
-- ================================
CREATE TABLE dimensional.DimCategories (
    Category_SK_PK INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID_NK INT NOT NULL,
    SOR_SK INT NULL,
    CategoryName NVARCHAR(255),
    Description NVARCHAR(MAX),
    Row_Created DATETIME NOT NULL DEFAULT GETDATE(),
    Row_Modified DATETIME NULL,
    CONSTRAINT FK_DimCategories_SOR FOREIGN KEY (SOR_SK) REFERENCES dimensional.Dim_SOR(SOR_SK)
);
GO

-- ================================
-- DimSuppliers (SCD3: store current & previous Address)
-- ================================
CREATE TABLE dimensional.DimSuppliers (
    Supplier_SK_PK INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID_NK INT NOT NULL,
    SOR_SK INT NULL,
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
    HomePage NVARCHAR(255),
    PreviousAddress NVARCHAR(255) NULL,
    Effective_Date DATETIME NOT NULL DEFAULT GETDATE(),
    Ineffective_Date DATETIME NULL,
    Row_Created DATETIME NOT NULL DEFAULT GETDATE(),
    Row_Modified DATETIME NULL,
    CONSTRAINT FK_DimSuppliers_SOR FOREIGN KEY (SOR_SK) REFERENCES dimensional.Dim_SOR(SOR_SK)
);
GO


-- ================================
-- DimProducts (SCD2 with delete/closing)
-- ================================
CREATE TABLE dimensional.DimProducts (
    Product_SK_PK INT IDENTITY(1,1) PRIMARY KEY,
    Product_Durable_SK INT NOT NULL,
    Product_NK INT NOT NULL,
    SOR_SK INT NULL,
    ProductName NVARCHAR(255),
    Supplier_SK INT NULL,
    Category_SK INT NULL,
    QuantityPerUnit NVARCHAR(50),
    UnitPrice DECIMAL(19,4),
    UnitsInStock INT,
    UnitsOnOrder INT,
    ReorderLevel INT,
    Discontinued BIT,
    Effective_Date DATETIME NOT NULL DEFAULT GETDATE(),
    Ineffective_Date DATETIME NULL,
    Current_Indicator BIT NOT NULL DEFAULT 1,
    Row_Created DATETIME NOT NULL DEFAULT GETDATE(),
    Row_Modified DATETIME NULL,
    CONSTRAINT FK_DimProducts_Category FOREIGN KEY (Category_SK) REFERENCES dimensional.DimCategories(Category_SK_PK),
    CONSTRAINT FK_DimProducts_Supplier FOREIGN KEY (Supplier_SK) REFERENCES dimensional.DimSuppliers(Supplier_SK_PK),
    CONSTRAINT FK_DimProducts_SOR FOREIGN KEY (SOR_SK) REFERENCES dimensional.Dim_SOR(SOR_SK)
);
GO


-- ================================
-- DimRegion (SCD4)
-- ================================

-- Mini-Dimension: DimRegionMini (region category and importance are chosen as rapidly changing attributes)
CREATE TABLE dimensional.DimRegionMini (
    MiniRegion_SK_PK INT IDENTITY(1,1) PRIMARY KEY,
    RegionCategory NVARCHAR(50),
    RegionImportance NVARCHAR(50),
    Row_Created DATETIME NOT NULL DEFAULT GETDATE(),
    Row_Modified DATETIME NULL
);
GO

-- Base/Primary Dimension: DimRegion (slowly changing attributes)
CREATE TABLE dimensional.DimRegion (
    Region_SK_PK INT IDENTITY(1,1) PRIMARY KEY,
    RegionID_NK INT NOT NULL,
    SOR_SK INT NULL,
    RegionDescription NVARCHAR(255),
    MiniRegion_SK INT NOT NULL,
    Row_Created DATETIME NOT NULL DEFAULT GETDATE(),
    Row_Modified DATETIME NULL,
    CONSTRAINT FK_DimRegion_Mini FOREIGN KEY (MiniRegion_SK)
        REFERENCES dimensional.DimRegionMini(MiniRegion_SK_PK),
    CONSTRAINT FK_DimRegion_SOR FOREIGN KEY (SOR_SK) REFERENCES dimensional.Dim_SOR(SOR_SK)
);
GO

-- ================================
-- DimTerritories (SCD4)
-- ================================

-- Mini-Dimension: DimTerritoriesMini (assuming TerritoryCode is rapidly changing)
CREATE TABLE dimensional.DimTerritoriesMini (
    MiniTerritory_SK_PK INT IDENTITY(1,1) PRIMARY KEY,
    TerritoryCode NVARCHAR(10),
    Row_Created DATETIME NOT NULL DEFAULT GETDATE(),
    Row_Modified DATETIME NULL
);
GO

-- Base/Primary Dimension: DimTerritories (slowly changing attributes)
CREATE TABLE dimensional.DimTerritories (
    Territory_SK_PK INT IDENTITY(1,1) PRIMARY KEY,
    TerritoryID_NK NVARCHAR(10) NOT NULL,
    SOR_SK INT NULL,
    TerritoryDescription NVARCHAR(255),
    Region_SK INT NOT NULL,
    MiniTerritory_SK INT NOT NULL,
    Row_Created DATETIME NOT NULL DEFAULT GETDATE(),
    Row_Modified DATETIME NULL,
    CONSTRAINT FK_DimTerritories_Region FOREIGN KEY (Region_SK)
        REFERENCES dimensional.DimRegion(Region_SK_PK),
    CONSTRAINT FK_DimTerritories_Mini FOREIGN KEY (MiniTerritory_SK)
        REFERENCES dimensional.DimTerritoriesMini(MiniTerritory_SK_PK),
    CONSTRAINT FK_DimTerritory_SOR FOREIGN KEY (SOR_SK) REFERENCES dimensional.Dim_SOR(SOR_SK)
);
GO

-- ================================
-- DimCustomers (SCD2: versioned)
-- ================================
CREATE TABLE dimensional.DimCustomers (
    Customer_SK_PK INT IDENTITY(1,1) PRIMARY KEY,
    Customer_Durable_SK NVARCHAR(10) NOT NULL,
    Customer_NK NVARCHAR(10) NOT NULL,
    SOR_SK INT NULL,
    CompanyName NVARCHAR(255),
    ContactName NVARCHAR(255),
    ContactTitle NVARCHAR(255),
    Address NVARCHAR(255),
    City NVARCHAR(100),
    Region NVARCHAR(100),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(100),
    Phone NVARCHAR(50),
    Fax NVARCHAR(50),
    EffectiveDate DATETIME NOT NULL DEFAULT GETDATE(),
    IneffectiveDate DATETIME NULL,
    CurrentIndicator BIT NOT NULL DEFAULT 1,
    Row_Created DATETIME NOT NULL DEFAULT GETDATE(),
    Row_Modified DATETIME NULL,
    CONSTRAINT FK_DimCustomers_SOR FOREIGN KEY (SOR_SK) REFERENCES dimensional.Dim_SOR(SOR_SK)
);
GO


-- ================================
-- DimEmployees (SCD1 with delete)
-- ================================
CREATE TABLE dimensional.DimEmployees (
    Employee_SK_PK INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID_NK INT NOT NULL,
    SOR_SK INT NULL,
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
    PhotoPath NVARCHAR(255),
    InsertedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_DimEmployees_SOR FOREIGN KEY (SOR_SK) REFERENCES dimensional.Dim_SOR(SOR_SK)
);
GO

-- ================================
-- DimShippers (SCD1 with delete)
-- ================================
CREATE TABLE dimensional.DimShippers (
    Shipper_SK_PK INT IDENTITY(1,1) PRIMARY KEY,
    ShipperID_NK INT NOT NULL,
    SOR_SK INT,
    CompanyName NVARCHAR(255),
    Phone NVARCHAR(50),
    InsertedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_DimShippers_SOR FOREIGN KEY (SOR_SK) REFERENCES dimensional.Dim_SOR(SOR_SK)
);
GO

-- ================================
-- FactOrders
-- ================================
CREATE TABLE dimensional.FactOrders (
    FactOrder_SK_PK INT IDENTITY(1,1) PRIMARY KEY,
    OrderID_NK INT NOT NULL,
    Customer_SK_PK INT,
    Employee_SK_PK INT,
    Shipper_SK_PK INT,
    Territory_SK_PK INT,
    MiniTerritory_SK_PK INT,
    SOR_SK INT NULL, 
    OrderDate DATE,
    RequiredDate DATE,
    ShippedDate DATE,
    Freight DECIMAL(19,4),
    InsertedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_FactOrders_Customer
        FOREIGN KEY (Customer_SK_PK) REFERENCES dimensional.DimCustomers(Customer_SK_PK),
    CONSTRAINT FK_FactOrders_Employee
        FOREIGN KEY (Employee_SK_PK) REFERENCES dimensional.DimEmployees(Employee_SK_PK),
    CONSTRAINT FK_FactOrders_Shipper
        FOREIGN KEY (Shipper_SK_PK) REFERENCES dimensional.DimShippers(Shipper_SK_PK),
    CONSTRAINT FK_FactOrders_Territory
        FOREIGN KEY (Territory_SK_PK) REFERENCES dimensional.DimTerritories(Territory_SK_PK),
    CONSTRAINT FK_FactOrders_MiniTerritory
        FOREIGN KEY (MiniTerritory_SK_PK) REFERENCES dimensional.DimTerritoriesMini(MiniTerritory_SK_PK),
    CONSTRAINT FK_FactOrders_SOR
        FOREIGN KEY (SOR_SK) REFERENCES dimensional.Dim_SOR(SOR_SK)
);
GO

USE [ORDER_DDS];
GO

CREATE TABLE dimensional.FactOrders_Error (
    FactOrder_Error_SK INT IDENTITY(1,1) PRIMARY KEY,
    OrderID_NK INT,
    CustomerID INT,
    EmployeeID INT,
    ShipVia INT,
    TerritoryID INT,
    MiniTerritoryID INT,
    SOR_SK INT NULL,
    ErrorMessage NVARCHAR(255),
    OrderDate DATE,
    RequiredDate DATE,
    ShippedDate DATE,
    Freight DECIMAL(19,4),
    InsertedAt DATETIME NOT NULL DEFAULT GETDATE()
);
GO


-- ================================
-- FactOrderDetails
-- ================================
CREATE TABLE dimensional.FactOrderDetails (
    FactOrder_SK_PK INT NOT NULL,
    Product_SK_PK INT NOT NULL,
    SOR_SK INT NULL,  
    UnitPrice DECIMAL(19,4),
    Quantity INT,
    Discount DECIMAL(5,2),
    InsertedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_FactOrderDetails PRIMARY KEY (FactOrder_SK_PK, Product_SK_PK),
    CONSTRAINT FK_FactOrderDetails_Product
        FOREIGN KEY (Product_SK_PK) REFERENCES dimensional.DimProducts(Product_SK_PK),
    CONSTRAINT FK_FactOrderDetails_Order
        FOREIGN KEY (FactOrder_SK_PK) REFERENCES dimensional.FactOrders(FactOrder_SK_PK),
    CONSTRAINT FK_FactOrderDetails_SOR
        FOREIGN KEY (SOR_SK) REFERENCES dimensional.Dim_SOR(SOR_SK)
);
GO

CREATE TABLE dimensional.FactOrderDetails_Error (
    FactOrder_SK_PK INT NULL,
    Product_SK_PK INT NULL,
    SOR_SK INT NULL,
    UnitPrice DECIMAL(19,4) NULL,
    Quantity INT NULL,
    Discount DECIMAL(5,2) NULL,
    ErrorReason NVARCHAR(255) NOT NULL,
    InsertedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_FactOrderDetailsError_SOR
        FOREIGN KEY (SOR_SK) REFERENCES dimensional.Dim_SOR(SOR_SK)
);
GO