/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Purpose:
  + Ensures silver schema exists
  + Recreates tables in the 'silver' schema (cleaned/conformed layer)
  + Adds DWH technical columns including lineage to Bronze run id
Notes:
  - Silver stores standardized types (e.g., dates as DATE)
  - Transformations are applied during load into Silver
===============================================================================
*/

USE DataWarehouse;
GO

SET NOCOUNT ON;
GO

/* ---------------------------------------------------------------------------
Ensure Schema
--------------------------------------------------------------------------- */
IF SCHEMA_ID(N'silver') IS NULL
    EXEC(N'CREATE SCHEMA silver;');
GO

/* ---------------------------------------------------------------------------
SILVER TABLES (cleaned/conformed + technical columns)
--------------------------------------------------------------------------- */

-- CRM - Customer
DROP TABLE IF EXISTS silver.crm_cust_info;
GO
CREATE TABLE silver.crm_cust_info (
    -- Business/source columns (cleaned)
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE,

    -- Technical columns (dwh_)
    dwh_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    dwh_load_datetime   DATETIME2(3) NOT NULL CONSTRAINT df_silver_crm_cust_info_load_dt DEFAULT SYSUTCDATETIME(),
    dwh_source_system   NVARCHAR(50) NULL,
    dwh_ingest_run_id   UNIQUEIDENTIFIER NULL,        -- Silver run id
    dwh_bronze_run_id   UNIQUEIDENTIFIER NULL,        -- lineage to Bronze run id
    dwh_source_file     NVARCHAR(260) NULL
);
GO

-- CRM - Product
DROP TABLE IF EXISTS silver.crm_prd_info;
GO
CREATE TABLE silver.crm_prd_info (
    -- Business/source columns (cleaned)
    prd_id       INT,
    cat_id       NVARCHAR(50),
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     DECIMAL(18,2),
    prd_line     NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt   DATE,

    -- Technical columns (dwh_)
    dwh_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    dwh_load_datetime   DATETIME2(3) NOT NULL CONSTRAINT df_silver_crm_prd_info_load_dt DEFAULT SYSUTCDATETIME(),
    dwh_source_system   NVARCHAR(50) NULL,
    dwh_ingest_run_id   UNIQUEIDENTIFIER NULL,        -- Silver run id
    dwh_bronze_run_id   UNIQUEIDENTIFIER NULL,        -- lineage to Bronze run id
    dwh_source_file     NVARCHAR(260) NULL
);
GO

-- CRM - Sales Details
DROP TABLE IF EXISTS silver.crm_sales_details;
GO
CREATE TABLE silver.crm_sales_details (
    -- Business/source columns (cleaned)
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,

    -- Dates standardized in Silver
    sls_order_dt DATE NULL,
    sls_ship_dt  DATE NULL,
    sls_due_dt   DATE NULL,

    -- Money/qty
    sls_sales    DECIMAL(18,2),
    sls_quantity INT,
    sls_price    DECIMAL(18,2),

    -- Technical columns (dwh_)
    dwh_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    dwh_load_datetime   DATETIME2(3) NOT NULL CONSTRAINT df_silver_crm_sales_details_load_dt DEFAULT SYSUTCDATETIME(),
    dwh_source_system   NVARCHAR(50) NULL,
    dwh_ingest_run_id   UNIQUEIDENTIFIER NULL,        -- Silver run id
    dwh_bronze_run_id   UNIQUEIDENTIFIER NULL,        -- lineage to Bronze run id
    dwh_source_file     NVARCHAR(260) NULL
);
GO

-- ERP - Location
DROP TABLE IF EXISTS silver.erp_loc_a101;
GO
CREATE TABLE silver.erp_loc_a101 (
    -- Business/source columns (cleaned)
    cid    NVARCHAR(50),
    cntry  NVARCHAR(50),

    -- Technical columns (dwh_)
    dwh_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    dwh_load_datetime   DATETIME2(3) NOT NULL CONSTRAINT df_silver_erp_loc_a101_load_dt DEFAULT SYSUTCDATETIME(),
    dwh_source_system   NVARCHAR(50) NULL,
    dwh_ingest_run_id   UNIQUEIDENTIFIER NULL,        -- Silver run id
    dwh_bronze_run_id   UNIQUEIDENTIFIER NULL,        -- lineage to Bronze run id
    dwh_source_file     NVARCHAR(260) NULL
);
GO

-- ERP - Customer
DROP TABLE IF EXISTS silver.erp_cust_az12;
GO
CREATE TABLE silver.erp_cust_az12 (
    -- Business/source columns (cleaned)
    cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50),

    -- Technical columns (dwh_)
    dwh_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    dwh_load_datetime   DATETIME2(3) NOT NULL CONSTRAINT df_silver_erp_cust_az12_load_dt DEFAULT SYSUTCDATETIME(),
    dwh_source_system   NVARCHAR(50) NULL,
    dwh_ingest_run_id   UNIQUEIDENTIFIER NULL,        -- Silver run id
    dwh_bronze_run_id   UNIQUEIDENTIFIER NULL,        -- lineage to Bronze run id
    dwh_source_file     NVARCHAR(260) NULL
);
GO

-- ERP - Product Category
DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;
GO
CREATE TABLE silver.erp_px_cat_g1v2 (
    -- Business/source columns (cleaned)
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50),

    -- Technical columns (dwh_)
    dwh_row_id          BIGINT IDENTITY(1,1) NOT NULL,
    dwh_load_datetime   DATETIME2(3) NOT NULL CONSTRAINT df_silver_erp_px_cat_g1v2_load_dt DEFAULT SYSUTCDATETIME(),
    dwh_source_system   NVARCHAR(50) NULL,
    dwh_ingest_run_id   UNIQUEIDENTIFIER NULL,        -- Silver run id
    dwh_bronze_run_id   UNIQUEIDENTIFIER NULL,        -- lineage to Bronze run id
    dwh_source_file     NVARCHAR(260) NULL
);
GO
