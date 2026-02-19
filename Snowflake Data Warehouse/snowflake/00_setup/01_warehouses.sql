-- =============================================================================
-- File: 01_warehouses.sql
-- Purpose:
--   Create dedicated virtual warehouses for compute separation:
--   - WH_ETL: data ingestion and transformations
--   - WH_BI : analytical and reporting workloads
--
-- Design choices:
--   - XSMALL size for cost efficiency (portfolio/sandbox context)
--   - AUTO_SUSPEND to minimize idle compute cost
--   - AUTO_RESUME for seamless execution
-- =============================================================================

USE ROLE ACCOUNTADMIN;

-- -----------------------------------------------------------------------------
-- ETL Warehouse (Data loading & transformations)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE WAREHOUSE WH_ETL
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60              -- suspend after 60 seconds of inactivity
  AUTO_RESUME = TRUE             -- resume automatically on query
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Compute warehouse dedicated to ETL workloads';

-- -----------------------------------------------------------------------------
-- BI Warehouse (Analytics & reporting)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE WAREHOUSE WH_BI
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Compute warehouse dedicated to BI and analytics workloads';
