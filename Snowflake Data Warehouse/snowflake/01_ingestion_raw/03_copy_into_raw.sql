-- =============================================================================
-- File: 03_copy_into_raw.sql
-- Purpose:
--   Load CRM and ERP source CSV files from internal stages into RAW tables.
--   - Business columns are loaded as STRING (source fidelity).
--   - Lineage column source_file is populated using METADATA$FILENAME.
-- =============================================================================

USE ROLE ROLE_DWH_ETL;
USE SECONDARY ROLES NONE;

USE WAREHOUSE WH_ETL;
USE DATABASE DWH_PORTFOLIO;
USE SCHEMA RAW;

-- -----------------------------------------------------------------------------
-- Optional: full-refresh behavior
-- -----------------------------------------------------------------------------
-- TRUNCATE TABLE crm_cust_info;
-- TRUNCATE TABLE crm_prd_info;
-- TRUNCATE TABLE crm_sales_details;
-- TRUNCATE TABLE erp_cust_az12;
-- TRUNCATE TABLE erp_loc_a101;
-- TRUNCATE TABLE erp_px_cat_g1v2;

-- -----------------------------------------------------------------------------
-- CRM
-- -----------------------------------------------------------------------------
COPY INTO crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date, source_file)
FROM (
  SELECT
    $1::STRING,
    $2::STRING,
    $3::STRING,
    $4::STRING,
    $5::STRING,
    $6::STRING,
    $7::STRING,
    METADATA$FILENAME::STRING
  FROM @STG_CRM/cust_info.csv
)
FILE_FORMAT = (FORMAT_NAME = FF_CSV)
ON_ERROR = 'ABORT_STATEMENT'
PURGE = FALSE;

COPY INTO crm_prd_info (prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt, source_file)
FROM (
  SELECT
    $1::STRING,
    $2::STRING,
    $3::STRING,
    $4::STRING,
    $5::STRING,
    $6::STRING,
    $7::STRING,
    METADATA$FILENAME::STRING
  FROM @STG_CRM/prd_info.csv
)
FILE_FORMAT = (FORMAT_NAME = FF_CSV)
ON_ERROR = 'ABORT_STATEMENT'
PURGE = FALSE;

COPY INTO crm_sales_details (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price, source_file)
FROM (
  SELECT
    $1::STRING,
    $2::STRING,
    $3::STRING,
    $4::STRING,
    $5::STRING,
    $6::STRING,
    $7::STRING,
    $8::STRING,
    $9::STRING,
    METADATA$FILENAME::STRING
  FROM @STG_CRM/sales_details.csv
)
FILE_FORMAT = (FORMAT_NAME = FF_CSV)
ON_ERROR = 'ABORT_STATEMENT'
PURGE = FALSE;

-- -----------------------------------------------------------------------------
-- ERP
-- -----------------------------------------------------------------------------
COPY INTO erp_cust_az12 (cid, bdate, gen, source_file)
FROM (
  SELECT
    $1::STRING,
    $2::STRING,
    $3::STRING,
    METADATA$FILENAME::STRING
  FROM @STG_ERP/CUST_AZ12.csv
)
FILE_FORMAT = (FORMAT_NAME = FF_CSV)
ON_ERROR = 'ABORT_STATEMENT'
PURGE = FALSE;

COPY INTO erp_loc_a101 (cid, cntry, source_file)
FROM (
  SELECT
    $1::STRING,
    $2::STRING,
    METADATA$FILENAME::STRING
  FROM @STG_ERP/LOC_A101.csv
)
FILE_FORMAT = (FORMAT_NAME = FF_CSV)
ON_ERROR = 'ABORT_STATEMENT'
PURGE = FALSE;

COPY INTO erp_px_cat_g1v2 (id, cat, subcat, maintenance, source_file)
FROM (
  SELECT
    $1::STRING,
    $2::STRING,
    $3::STRING,
    $4::STRING,
    METADATA$FILENAME::STRING
  FROM @STG_ERP/PX_CAT_G1V2.csv
)
FILE_FORMAT = (FORMAT_NAME = FF_CSV)
ON_ERROR = 'ABORT_STATEMENT'
PURGE = FALSE;
