/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for specific tables.

Table Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

USE DataWarehouseAnalytics
GO

/*
===============================================================================
01 - Database Exploration (Tables)
===============================================================================
Purpose:
  - List all user tables for the project (stage & gold)
===============================================================================
*/

SELECT 
    t.TABLE_SCHEMA,
    t.TABLE_NAME,
    t.TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES t
WHERE t.TABLE_TYPE = 'BASE TABLE'
  AND t.TABLE_SCHEMA IN ('stage','gold')
ORDER BY t.TABLE_SCHEMA, t.TABLE_NAME;

SELECT 
    s.name AS schema_name,
    t.name AS table_name
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name IN ('stage','gold')
ORDER BY s.name, t.name;

/*
===============================================================================
02 - Table Exploration (Columns)
===============================================================================
Purpose:
  - Inspect columns, datatypes and nullability for a given table
===============================================================================
*/

DECLARE @Schema sysname = 'gold';
DECLARE @Table  sysname = 'dim_customers';

SELECT 
    c.ORDINAL_POSITION,
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = @Schema
  AND c.TABLE_NAME = @Table
ORDER BY c.ORDINAL_POSITION;


/*
===============================================================================
03 - Constraints Exploration (Primary Keys)
===============================================================================
*/

SELECT 
    tc.TABLE_SCHEMA,
    tc.TABLE_NAME,
    kcu.COLUMN_NAME AS pk_column
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
  ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
 AND tc.TABLE_SCHEMA = kcu.TABLE_SCHEMA
WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
  AND tc.TABLE_SCHEMA IN ('gold','stage')
ORDER BY tc.TABLE_SCHEMA, tc.TABLE_NAME, kcu.ORDINAL_POSITION;


/*
===============================================================================
04 - Constraints Exploration (Foreign Keys)
===============================================================================
*/

SELECT
    fk.name AS fk_name,
    OBJECT_SCHEMA_NAME(fk.parent_object_id) AS from_schema,
    OBJECT_NAME(fk.parent_object_id) AS from_table,
    c1.name AS from_column,
    OBJECT_SCHEMA_NAME(fk.referenced_object_id) AS to_schema,
    OBJECT_NAME(fk.referenced_object_id) AS to_table,
    c2.name AS to_column
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc 
  ON fk.object_id = fkc.constraint_object_id
JOIN sys.columns c1 
  ON c1.object_id = fkc.parent_object_id AND c1.column_id = fkc.parent_column_id
JOIN sys.columns c2 
  ON c2.object_id = fkc.referenced_object_id AND c2.column_id = fkc.referenced_column_id
WHERE OBJECT_SCHEMA_NAME(fk.parent_object_id) = 'gold'
ORDER BY fk.name;


/*
===============================================================================
05 - Row Counts (Gold tables)
===============================================================================
*/

SELECT 'gold.dim_customers' AS table_name, COUNT(*) AS row_count FROM gold.dim_customers
UNION ALL
SELECT 'gold.dim_products',  COUNT(*) FROM gold.dim_products
UNION ALL
SELECT 'gold.fact_sales',    COUNT(*) FROM gold.fact_sales;

/*
===============================================================================
06 - Date Coverage (Fact)
===============================================================================
*/

SELECT
    MIN(order_date)    AS min_order_date,
    MAX(order_date)    AS max_order_date,
    MIN(shipping_date) AS min_shipping_date,
    MAX(shipping_date) AS max_shipping_date
FROM gold.fact_sales;

/*
===============================================================================
07 - Orphan Facts Check
===============================================================================
*/

SELECT TOP 50 fs.*
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc ON fs.customer_key = dc.customer_key
LEFT JOIN gold.dim_products dp  ON fs.product_key  = dp.product_key
WHERE dc.customer_key IS NULL
   OR dp.product_key IS NULL;
