-- =============================================================================
-- File: 00_streams.sql
-- Purpose:
--   Create a stream to capture changes on RAW sales details (CDC demo).
-- =============================================================================

USE ROLE ROLE_DWH_ETL;
USE SECONDARY ROLES NONE;

USE WAREHOUSE WH_ETL;
USE DATABASE DWH_PORTFOLIO;
USE SCHEMA RAW;

-- Check 

CREATE OR REPLACE STREAM STRM_CRM_SALES_DETAILS
  ON TABLE crm_sales_details
  COMMENT = 'CDC stream on RAW CRM sales details (portfolio demo)';
  -- SHOW_INITIAL_ROWS = TRUE;
