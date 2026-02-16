/*
=============================================================
01 - Create Database and Schemas (stage, gold)
=============================================================
Purpose:
  - Create the database safely for a dev/training environment
  - Create schemas: stage (raw landing) and gold (star schema)

WARNING:
  This will DROP the database if it exists.
*/

USE master;
GO

IF DB_ID('DataWarehouseAnalytics') IS NOT NULL
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

CREATE DATABASE DataWarehouseAnalytics;
GO

USE DataWarehouseAnalytics;
GO

CREATE SCHEMA stage;
GO

CREATE SCHEMA gold;
GO
