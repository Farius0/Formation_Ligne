-- =============================================================================
-- File: 02_roles_and_grants.sql
-- Purpose:
--   Minimal RBAC setup for the Snowflake DWH portfolio project.
--   Roles:
--     - ROLE_DWH_ADMIN   : project administration
--     - ROLE_DWH_ETL     : ingestion + transformations (RAW/CLEAN/MART)
--     - ROLE_DWH_ANALYST : read-only access to MART layer
-- =============================================================================

USE ROLE ACCOUNTADMIN;

-- -----------------------------------------------------------------------------
-- Create roles
-- -----------------------------------------------------------------------------
CREATE OR REPLACE ROLE ROLE_DWH_ADMIN;
CREATE OR REPLACE ROLE ROLE_DWH_ETL;
CREATE OR REPLACE ROLE ROLE_DWH_ANALYST;

-- -----------------------------------------------------------------------------
-- Database usage
-- -----------------------------------------------------------------------------
GRANT USAGE ON DATABASE DWH_PORTFOLIO TO ROLE ROLE_DWH_ADMIN;
GRANT USAGE ON DATABASE DWH_PORTFOLIO TO ROLE ROLE_DWH_ETL;
GRANT USAGE ON DATABASE DWH_PORTFOLIO TO ROLE ROLE_DWH_ANALYST;

-- -----------------------------------------------------------------------------
-- Schema privileges
-- -----------------------------------------------------------------------------
-- RAW: landing + staging objects
GRANT USAGE, CREATE TABLE, CREATE VIEW, CREATE STAGE, CREATE FILE FORMAT, CREATE STREAM
  ON SCHEMA DWH_PORTFOLIO.RAW TO ROLE ROLE_DWH_ETL;

-- CLEAN: standardized datasets + orchestration objects
GRANT USAGE, CREATE TABLE, CREATE VIEW, CREATE TASK
  ON SCHEMA DWH_PORTFOLIO.CLEAN TO ROLE ROLE_DWH_ETL;

-- MART: dimensional / reporting layer
GRANT USAGE, CREATE TABLE, CREATE VIEW
  ON SCHEMA DWH_PORTFOLIO.MART TO ROLE ROLE_DWH_ETL;

GRANT USAGE ON SCHEMA DWH_PORTFOLIO.MART TO ROLE ROLE_DWH_ANALYST;

-- -----------------------------------------------------------------------------
-- Warehouse privileges
-- -----------------------------------------------------------------------------
GRANT USAGE, OPERATE ON WAREHOUSE WH_ETL TO ROLE ROLE_DWH_ETL;
GRANT USAGE, OPERATE ON WAREHOUSE WH_BI  TO ROLE ROLE_DWH_ANALYST;

-- -----------------------------------------------------------------------------
-- Analyst read access (tables + views) on MART
-- -----------------------------------------------------------------------------
GRANT SELECT ON ALL TABLES IN SCHEMA DWH_PORTFOLIO.MART TO ROLE ROLE_DWH_ANALYST;
GRANT SELECT ON FUTURE TABLES IN SCHEMA DWH_PORTFOLIO.MART TO ROLE ROLE_DWH_ANALYST;

GRANT SELECT ON ALL VIEWS IN SCHEMA DWH_PORTFOLIO.MART TO ROLE ROLE_DWH_ANALYST;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA DWH_PORTFOLIO.MART TO ROLE ROLE_DWH_ANALYST;

-- -----------------------------------------------------------------------------
-- Optional: make DWH_ADMIN inherit ETL + ANALYST (simplifies operations)
-- -----------------------------------------------------------------------------
GRANT ROLE ROLE_DWH_ETL     TO ROLE ROLE_DWH_ADMIN;
GRANT ROLE ROLE_DWH_ANALYST TO ROLE ROLE_DWH_ADMIN;
