-- =============================================================================
-- File: 00_file_formats.sql
-- Purpose:
--   Define reusable CSV file format(s) for the RAW ingestion layer.
-- =============================================================================

USE ROLE ROLE_DWH_ETL;
USE SECONDARY ROLES NONE;

USE WAREHOUSE WH_ETL;
USE DATABASE DWH_PORTFOLIO;
USE SCHEMA RAW;

CREATE OR REPLACE FILE FORMAT FF_CSV
  TYPE = CSV
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  TRIM_SPACE = TRUE
  EMPTY_FIELD_AS_NULL = TRUE
  NULL_IF = ('', 'NULL', 'null')
  -- ENCODING = 'UTF8'
  COMMENT = 'Default CSV file format for portfolio RAW ingestion';

-- Quick verification
SHOW FILE FORMATS LIKE 'FF_CSV' IN SCHEMA RAW;
