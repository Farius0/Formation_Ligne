-- =============================================================================
-- File: 02_raw_tables.sql
-- Purpose:
--   Create RAW landing tables for CRM and ERP source files.
--   All business columns are stored as STRING to preserve source fidelity.
--   Technical columns are added for lineage and load auditing.
-- =============================================================================

USE ROLE ROLE_DWH_ETL;
USE SECONDARY ROLES NONE;

USE WAREHOUSE WH_ETL;
USE DATABASE DWH_PORTFOLIO;
USE SCHEMA RAW;

-- -----------------------------------------------------------------------------
-- CRM
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE crm_cust_info (
  cst_id             STRING,
  cst_key            STRING,
  cst_firstname      STRING,
  cst_lastname       STRING,
  cst_marital_status STRING,
  cst_gndr           STRING,
  cst_create_date    STRING,
  load_ts            TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  source_file        STRING
);

CREATE OR REPLACE TABLE crm_prd_info (
  prd_id        STRING,
  prd_key       STRING,
  prd_nm        STRING,
  prd_cost      STRING,
  prd_line      STRING,
  prd_start_dt  STRING,
  prd_end_dt    STRING,
  load_ts       TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  source_file   STRING
);

CREATE OR REPLACE TABLE crm_sales_details (
  sls_ord_num  STRING,
  sls_prd_key  STRING,
  sls_cust_id  STRING,
  sls_order_dt STRING,
  sls_ship_dt  STRING,
  sls_due_dt   STRING,
  sls_sales    STRING,
  sls_quantity STRING,
  sls_price    STRING,
  load_ts      TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  source_file  STRING
);

-- -----------------------------------------------------------------------------
-- ERP
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE erp_cust_az12 (
  cid         STRING,
  bdate       STRING,
  gen         STRING,
  load_ts     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  source_file STRING
);

CREATE OR REPLACE TABLE erp_loc_a101 (
  cid         STRING,
  cntry       STRING,
  load_ts     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  source_file STRING
);

CREATE OR REPLACE TABLE erp_px_cat_g1v2 (
  id          STRING,
  cat         STRING,
  subcat      STRING,
  maintenance STRING,
  load_ts     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  source_file STRING
);
