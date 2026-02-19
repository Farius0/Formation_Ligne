-- =============================================================================
-- File: 00_db_schemas.sql
-- Purpose:
--   Create the project database and core schemas following a RAW -> CLEAN -> MART
--   layering pattern for the Snowflake DWH portfolio.
-- =============================================================================

USE ROLE ACCOUNTADMIN;

-- -----------------------------------------------------------------------------
-- Database
-- -----------------------------------------------------------------------------
CREATE OR REPLACE DATABASE DWH_PORTFOLIO
  COMMENT = 'Portfolio Data Warehouse (Snowflake): RAW/CLEAN/MART layers';

USE DATABASE DWH_PORTFOLIO;

-- -----------------------------------------------------------------------------
-- Schemas
-- -----------------------------------------------------------------------------
CREATE OR REPLACE SCHEMA RAW
  COMMENT = 'Landing layer: raw ingested data (minimal transformations)';

CREATE OR REPLACE SCHEMA CLEAN
  COMMENT = 'Standardized layer: cleaned, typed, validated datasets';

CREATE OR REPLACE SCHEMA MART
  COMMENT = 'Business layer: dimensional model / marts for analytics';

-- -----------------------------------------------------------------------------
-- Quick verification
-- -----------------------------------------------------------------------------
SHOW DATABASES LIKE 'DWH_PORTFOLIO';
SHOW SCHEMAS IN DATABASE DWH_PORTFOLIO;
