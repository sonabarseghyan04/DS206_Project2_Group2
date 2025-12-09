USE ORDER_DDS;


DECLARE @SOR_SK INT;


SELECT @SOR_SK = SOR_SK
FROM dimensional.Dim_SOR
WHERE StagingTableName = 'Stg_Categories';

MERGE dimensional.DimCategories AS target
USING staging.Stg_Categories AS source
ON target.CategoryID_NK = source.CategoryID
WHEN MATCHED AND
    (ISNULL(target.CategoryName,'') <> ISNULL(source.CategoryName,'')
     OR ISNULL(target.Description,'') <> ISNULL(source.Description,''))
THEN
    UPDATE SET
        target.CategoryName = source.CategoryName,
        target.Description = source.Description,
        target.SOR_SK = @SOR_SK,
        target.Row_Modified = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (CategoryID_NK, SOR_SK, CategoryName, Description, Row_Created)
    VALUES (source.CategoryID, @SOR_SK, source.CategoryName, source.Description, GETDATE());

