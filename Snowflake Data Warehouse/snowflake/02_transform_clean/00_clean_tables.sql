-- =============================================================================
-- File: 00_clean_tables.sql
-- Purpose:
--   Create CLEAN layer tables with standardized data types (numbers, dates)
--   derived from RAW landing tables.
-- =============================================================================

USE ROLE ROLE_DWH_ETL;
USE SECONDARY ROLES NONE;

USE WAREHOUSE WH_ETL;
USE DATABASE DWH_PORTFOLIO;
USE SCHEMA CLEAN;

-- -----------------------------------------------------------------------------
-- CRM
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE crm_cust_info (
  cst_id             NUMBER(38,0),
  cst_key            STRING,
  cst_firstname      STRING,
  cst_lastname       STRING,
  cst_marital_status STRING,
  cst_gndr           STRING,
  cst_create_date    DATE,
  load_ts            TIMESTAMP_NTZ,
  source_file        STRING
);

CREATE OR REPLACE TABLE crm_prd_info (
  prd_id       NUMBER(38,0),
  cat_id       STRING,
  prd_key      STRING,
  prd_nm       STRING,
  prd_cost     NUMBER(18,2),
  prd_line     STRING,
  prd_start_dt DATE,
  prd_end_dt   DATE,
  load_ts      TIMESTAMP_NTZ,
  source_file  STRING
);

CREATE OR REPLACE TABLE crm_sales_details (
  sls_ord_num  STRING,
  sls_prd_key  STRING,
  sls_cust_id  NUMBER(38,0),
  sls_order_dt DATE,
  sls_ship_dt  DATE,
  sls_due_dt   DATE,
  sls_sales    NUMBER(18,2),
  sls_quantity NUMBER(18,2),
  sls_price    NUMBER(18,2),
  load_ts      TIMESTAMP_NTZ,
  source_file  STRING
);

-- -----------------------------------------------------------------------------
-- ERP
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE erp_cust_az12 (
  cid         STRING,
  bdate       DATE,
  gen         STRING,
  load_ts     TIMESTAMP_NTZ,
  source_file STRING
);

CREATE OR REPLACE TABLE erp_loc_a101 (
  cid         STRING,
  cntry       STRING,
  load_ts     TIMESTAMP_NTZ,
  source_file STRING
);

CREATE OR REPLACE TABLE erp_px_cat_g1v2 (
  id          STRING,
  cat         STRING,
  subcat      STRING,
  maintenance STRING,
  load_ts     TIMESTAMP_NTZ,
  source_file STRING
);
