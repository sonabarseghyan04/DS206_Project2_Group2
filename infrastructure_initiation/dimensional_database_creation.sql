IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'ORDER_DDS')
BEGIN
    CREATE DATABASE ORDER_DDS;
    PRINT 'Database ORDER_DDS created successfully';
END
ELSE
BEGIN
    PRINT 'Database ORDER_DDS already exists';
END
GO

USE ORDER_DDS;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'staging')
    EXEC('CREATE SCHEMA staging');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'dimensional')
    EXEC('CREATE SCHEMA dimensional');
GO
