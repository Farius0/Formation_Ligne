/*
=============================================================
03 - Load CSV into STAGE, then transform into GOLD
=============================================================
Process:
  1) TRUNCATE stage tables
  2) BULK INSERT into stage (raw NVARCHAR)
  3) TRUNCATE gold tables
  4) INSERT into gold with TRY_CONVERT + cleanup
  5) Reset stage (Optional)
*/

USE DataWarehouseAnalytics;
GO

SET NOCOUNT ON;
GO

DECLARE @BasePath nvarchar(4000) = N'C:\dwh_files\analytics\';

DECLARE @sql nvarchar(max);

-- 1) Reset stage
TRUNCATE TABLE stage.dim_customers_raw;
TRUNCATE TABLE stage.dim_products_raw;
TRUNCATE TABLE stage.fact_sales_raw;

-- 2) BULK INSERT into stage (raw)
SET @sql = N'
BULK INSERT stage.dim_customers_raw
FROM ''' + @BasePath + N'dim_customers.csv''
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '','',
    ROWTERMINATOR = ''0x0d0a'',
    TABLOCK,
    CODEPAGE = ''65001''
);';
EXEC sys.sp_executesql @sql;

SET @sql = N'
BULK INSERT stage.dim_products_raw
FROM ''' + @BasePath + N'dim_products.csv''
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '','',
    ROWTERMINATOR = ''0x0d0a'',
    TABLOCK,
    CODEPAGE = ''65001''
);';
EXEC sys.sp_executesql @sql;

SET @sql = N'
BULK INSERT stage.fact_sales_raw
FROM ''' + @BasePath + N'fact_sales.csv''
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '','',
    ROWTERMINATOR = ''0x0d0a'',
    TABLOCK,
    CODEPAGE = ''65001''
);';
EXEC sys.sp_executesql @sql;

-- 3) Reset gold 

DELETE FROM gold.fact_sales; -- delete fact first because of FK
DELETE FROM gold.dim_products;
DELETE FROM gold.dim_customers;

-- 4) Transform into gold (typed)
INSERT INTO gold.dim_customers (
    customer_key, customer_id, customer_number, first_name, last_name,
    country, marital_status, gender, birthdate, create_date
)
SELECT
    TRY_CONVERT(int, NULLIF(LTRIM(RTRIM(customer_key)), ''))     AS customer_key,
    TRY_CONVERT(int, NULLIF(LTRIM(RTRIM(customer_id)), ''))      AS customer_id,
    NULLIF(LTRIM(RTRIM(customer_number)), '')                    AS customer_number,
    NULLIF(LTRIM(RTRIM(first_name)), '')                         AS first_name,
    NULLIF(LTRIM(RTRIM(last_name)), '')                          AS last_name,
    NULLIF(LTRIM(RTRIM(country)), '')                            AS country,
    NULLIF(LTRIM(RTRIM(marital_status)), '')                     AS marital_status,
    NULLIF(LTRIM(RTRIM(gender)), '')                             AS gender,
    TRY_CONVERT(date, NULLIF(LTRIM(RTRIM(birthdate)), ''))       AS birthdate,
    TRY_CONVERT(date, NULLIF(LTRIM(RTRIM(create_date)), ''))     AS create_date
FROM stage.dim_customers_raw
WHERE TRY_CONVERT(int, NULLIF(LTRIM(RTRIM(customer_key)), '')) IS NOT NULL
;

INSERT INTO gold.dim_products (
    product_key, product_id, product_number, product_name,
    category_id, category, subcategory, maintenance,
    cost, product_line, start_date
)
SELECT
    TRY_CONVERT(int, NULLIF(LTRIM(RTRIM(product_key)), ''))         AS product_key,
    TRY_CONVERT(int, NULLIF(LTRIM(RTRIM(product_id)), ''))          AS product_id,
    NULLIF(LTRIM(RTRIM(product_number)), '')                        AS product_number,
    NULLIF(LTRIM(RTRIM(product_name)), '')                          AS product_name,
    NULLIF(LTRIM(RTRIM(category_id)), '')                           AS category_id,
    NULLIF(LTRIM(RTRIM(category)), '')                              AS category,
    NULLIF(LTRIM(RTRIM(subcategory)), '')                           AS subcategory,
    NULLIF(LTRIM(RTRIM(maintenance)), '')                           AS maintenance,
    TRY_CONVERT(decimal(18,2), NULLIF(LTRIM(RTRIM(cost)), ''))      AS cost,
    NULLIF(LTRIM(RTRIM(product_line)), '')                          AS product_line,
    TRY_CONVERT(date, NULLIF(LTRIM(RTRIM(start_date)), ''))         AS start_date
FROM stage.dim_products_raw
WHERE TRY_CONVERT(int, NULLIF(LTRIM(RTRIM(product_key)), '')) IS NOT NULL;

-- Load fact last (FK needs dims)
INSERT INTO gold.fact_sales (
    order_number, product_key, customer_key,
    order_date, shipping_date, due_date,
    sales_amount, quantity, price
)
SELECT
    NULLIF(LTRIM(RTRIM(order_number)), '')                              AS order_number,
    TRY_CONVERT(int, NULLIF(LTRIM(RTRIM(product_key)), ''))             AS product_key,
    TRY_CONVERT(int, NULLIF(LTRIM(RTRIM(customer_key)), ''))            AS customer_key,
    TRY_CONVERT(date, NULLIF(LTRIM(RTRIM(order_date)), ''))             AS order_date,
    TRY_CONVERT(date, NULLIF(LTRIM(RTRIM(shipping_date)), ''))          AS shipping_date,
    TRY_CONVERT(date, NULLIF(LTRIM(RTRIM(due_date)), ''))               AS due_date,
    TRY_CONVERT(decimal(18,2), NULLIF(LTRIM(RTRIM(sales_amount)), ''))  AS sales_amount,
    TRY_CONVERT(int, NULLIF(LTRIM(RTRIM(quantity)), ''))                AS quantity,
    TRY_CONVERT(decimal(18,2), NULLIF(LTRIM(RTRIM(price)), ''))         AS price
FROM stage.fact_sales_raw
WHERE NULLIF(LTRIM(RTRIM(order_number)), '') IS NOT NULL;

-- 5) Reset stage (Optional)
TRUNCATE TABLE stage.dim_customers_raw;
TRUNCATE TABLE stage.dim_products_raw;
TRUNCATE TABLE stage.fact_sales_raw;