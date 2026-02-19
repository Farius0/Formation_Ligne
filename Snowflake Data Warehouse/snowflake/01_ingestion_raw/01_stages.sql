-- =============================================================================
-- File: 01_stages.sql
-- Purpose:
--   Create internal stages used to load CRM/ERP CSV files into the RAW layer.
--
-- Notes:
--   - Internal stages are populated using PUT (SnowSQL/CLI), not via Snowsight SQL.
-- =============================================================================

USE ROLE ROLE_DWH_ETL;
USE SECONDARY ROLES NONE;

USE WAREHOUSE WH_ETL;
USE DATABASE DWH_PORTFOLIO;
USE SCHEMA RAW;

-- -----------------------------------------------------------------------------
-- Internal stages (populated via PUT)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE STAGE STG_CRM
  FILE_FORMAT = FF_CSV
  COMMENT = 'Internal stage for CRM source CSV files';

CREATE OR REPLACE STAGE STG_ERP
  FILE_FORMAT = FF_CSV
  COMMENT = 'Internal stage for ERP source CSV files';

-- -----------------------------------------------------------------------------
-- Quick verification
-- -----------------------------------------------------------------------------
SHOW STAGES LIKE 'STG_%' IN SCHEMA RAW;

-- List staged files (after upload)
LIST @STG_CRM;
LIST @STG_ERP;
