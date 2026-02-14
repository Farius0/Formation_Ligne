/*
=============================================================
Create / Initialize DataWarehouse Database and Schemas
=============================================================
Purpose:
  + Creates the database if it does not exist
  + Creates schemas (bronze, silver, gold) if they do not exist
  + Optional: allows a full reset (DROP/RECREATE) when @Reset = 1

WARNING:
  + @Reset = 1 will DROP the database (DESTRUCTIVE)
=============================================================
*/

SET NOCOUNT ON;
GO

USE master;
GO

DECLARE @DbName sysname = N'DataWarehouse';
DECLARE @Reset bit = 1;

/*IF (@Reset = 1 AND @DbName LIKE N'Data%')
BEGIN
    THROW 50001, 'Reset blocked: database name looks like PROD.', 1;
END;
*/

IF DB_ID(@DbName) IS NOT NULL AND @Reset = 1
BEGIN
    DECLARE @sql_a nvarchar(max) =
        N'ALTER DATABASE ' + QUOTENAME(@DbName) + N' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
          DROP DATABASE ' + QUOTENAME(@DbName) + N';';
    EXEC sys.sp_executesql @sql_a;
END;

IF DB_ID(@DbName) IS NULL
BEGIN
    DECLARE @sql_b nvarchar(max) = N'CREATE DATABASE ' + QUOTENAME(@DbName) + N';';
    EXEC sys.sp_executesql @sql_b;
END;
GO

DECLARE @DbName sysname = N'DataWarehouse';

DECLARE @sql_schemas nvarchar(max) = N'
USE ' + QUOTENAME(@DbName) + N';

IF SCHEMA_ID(N''bronze'') IS NULL EXEC(N''CREATE SCHEMA bronze;'');
IF SCHEMA_ID(N''silver'') IS NULL EXEC(N''CREATE SCHEMA silver;'');
IF SCHEMA_ID(N''gold'')   IS NULL EXEC(N''CREATE SCHEMA gold;'');
';

EXEC sys.sp_executesql @sql_schemas;
GO
