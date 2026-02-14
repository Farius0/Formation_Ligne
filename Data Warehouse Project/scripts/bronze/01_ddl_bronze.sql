/*
===============================================================================
DDL Script: Create Bronze + Staging Tables
===============================================================================
Purpose:
  + Ensures required schemas exist (bronze, staging)
  + Recreates tables in the 'bronze' schema with DWH technical columns
  + Recreates 'staging' tables used for BULK INSERT (no technical columns)
Notes:
  - Bronze is RAW: no PK/FK, minimal constraints, keep source-like structure
  - Staging is transient: truncate/refresh each load
===============================================================================
*/

USE DataWarehouse;
GO

SET NOCOUNT ON;
GO

/* ---------------------------------------------------------------------------
Ensure Schemas
--------------------------------------------------------------------------- */
IF SCHEMA_ID(N'bronze') IS NULL
    EXEC(N'CREATE SCHEMA bronze;');
GO

IF SCHEMA_ID(N'staging') IS NULL
    EXEC(N'CREATE SCHEMA staging;');
GO

/* ---------------------------------------------------------------------------
BRONZE TABLES (RAW + technical columns)
--------------------------------------------------------------------------- */

-- CRM - Customer
DROP TABLE IF EXISTS bronze.crm_cust_info;
GO
CREATE TABLE bronze.crm_cust_info (
    -- Source columns (raw)
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE,

    -- Technical columns (dwh_)
    dwh_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    dwh_load_datetime   DATETIME2(3) NOT NULL CONSTRAINT df_bronze_crm_cust_info_load_dt DEFAULT SYSUTCDATETIME(),
    dwh_source_system   NVARCHAR(50) NULL,
    dwh_ingest_run_id   UNIQUEIDENTIFIER NULL,
    dwh_source_file     NVARCHAR(260) NULL
);
GO

-- CRM - Product
DROP TABLE IF EXISTS bronze.crm_prd_info;
GO
CREATE TABLE bronze.crm_prd_info (
    -- Source columns (raw)
    prd_id       INT,
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     DECIMAL(18,2),
    prd_line     NVARCHAR(50),
    prd_start_dt DATETIME2(3),
    prd_end_dt   DATETIME2(3),

    -- Technical columns (dwh_)
    dwh_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    dwh_load_datetime   DATETIME2(3) NOT NULL CONSTRAINT df_bronze_crm_prd_info_load_dt DEFAULT SYSUTCDATETIME(),
    dwh_source_system   NVARCHAR(50) NULL,
    dwh_ingest_run_id   UNIQUEIDENTIFIER NULL,
    dwh_source_file     NVARCHAR(260) NULL
);
GO

-- CRM - Sales Details
DROP TABLE IF EXISTS bronze.crm_sales_details;
GO
CREATE TABLE bronze.crm_sales_details (
    -- Source columns (raw)
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,

    -- Dates stored as INT in source
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,

    -- Money/qty
    sls_sales    DECIMAL(18,2),
    sls_quantity INT,
    sls_price    DECIMAL(18,2),

    -- Technical columns (dwh_)
    dwh_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    dwh_load_datetime   DATETIME2(3) NOT NULL CONSTRAINT df_bronze_crm_sales_details_load_dt DEFAULT SYSUTCDATETIME(),
    dwh_source_system   NVARCHAR(50) NULL,
    dwh_ingest_run_id   UNIQUEIDENTIFIER NULL,
    dwh_source_file     NVARCHAR(260) NULL
);
GO

-- ERP - Location
DROP TABLE IF EXISTS bronze.erp_loc_a101;
GO
CREATE TABLE bronze.erp_loc_a101 (
    -- Source columns (raw)
    cid    NVARCHAR(50),
    cntry  NVARCHAR(50),

    -- Technical columns (dwh_)
    dwh_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    dwh_load_datetime   DATETIME2(3) NOT NULL CONSTRAINT df_bronze_erp_loc_a101_load_dt DEFAULT SYSUTCDATETIME(),
    dwh_source_system   NVARCHAR(50) NULL,
    dwh_ingest_run_id   UNIQUEIDENTIFIER NULL,
    dwh_source_file     NVARCHAR(260) NULL
);
GO

-- ERP - Customer
DROP TABLE IF EXISTS bronze.erp_cust_az12;
GO
CREATE TABLE bronze.erp_cust_az12 (
    -- Source columns (raw)
    cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50),

    -- Technical columns (dwh_)
    dwh_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    dwh_load_datetime   DATETIME2(3) NOT NULL CONSTRAINT df_bronze_erp_cust_az12_load_dt DEFAULT SYSUTCDATETIME(),
    dwh_source_system   NVARCHAR(50) NULL,
    dwh_ingest_run_id   UNIQUEIDENTIFIER NULL,
    dwh_source_file     NVARCHAR(260) NULL
);
GO

-- ERP - Product Category
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
GO
CREATE TABLE bronze.erp_px_cat_g1v2 (
    -- Source columns (raw)
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50),

    -- Technical columns (dwh_)
    dwh_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    dwh_load_datetime   DATETIME2(3) NOT NULL CONSTRAINT df_bronze_erp_px_cat_g1v2_load_dt DEFAULT SYSUTCDATETIME(),
    dwh_source_system   NVARCHAR(50) NULL,
    dwh_ingest_run_id   UNIQUEIDENTIFIER NULL,
    dwh_source_file     NVARCHAR(260) NULL
);
GO

/* ---------------------------------------------------------------------------
STAGING TABLES (for BULK INSERT; no technical columns)
--------------------------------------------------------------------------- */

-- CRM staging
DROP TABLE IF EXISTS staging.crm_cust_info;
GO
CREATE TABLE staging.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE
);
GO

DROP TABLE IF EXISTS staging.crm_prd_info;
GO
CREATE TABLE staging.crm_prd_info (
    prd_id       INT,
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     DECIMAL(18,2),
    prd_line     NVARCHAR(50),
    prd_start_dt DATETIME2(3),
    prd_end_dt   DATETIME2(3)
);
GO

DROP TABLE IF EXISTS staging.crm_sales_details;
GO
CREATE TABLE staging.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    DECIMAL(18,2),
    sls_quantity INT,
    sls_price    DECIMAL(18,2)
);
GO

-- ERP staging
DROP TABLE IF EXISTS staging.erp_loc_a101;
GO
CREATE TABLE staging.erp_loc_a101 (
    cid    NVARCHAR(50),
    cntry  NVARCHAR(50)
);
GO

DROP TABLE IF EXISTS staging.erp_cust_az12;
GO
CREATE TABLE staging.erp_cust_az12 (
    cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50)
);
GO

DROP TABLE IF EXISTS staging.erp_px_cat_g1v2;
GO
CREATE TABLE staging.erp_px_cat_g1v2 (
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50)
);
GO
