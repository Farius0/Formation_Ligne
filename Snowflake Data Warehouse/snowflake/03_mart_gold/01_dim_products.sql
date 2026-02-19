-- =============================================================================
-- File: 01_dim_products.sql
-- Purpose:
--   Build the product dimension from CLEAN CRM product data and enrich it
--   with ERP category attributes. Keeps only the current (active) product record.
-- =============================================================================

USE ROLE ROLE_DWH_ETL;
USE SECONDARY ROLES NONE;

USE WAREHOUSE WH_ETL;
USE DATABASE DWH_PORTFOLIO;
USE SCHEMA MART;

CREATE OR REPLACE TABLE MART.dim_products AS
SELECT
    MD5(pn.prd_key)              AS product_key,
    pn.prd_id                    AS product_id,
    pn.prd_key                   AS product_number,
    pn.prd_nm                    AS product_name,
    pn.cat_id                    AS category_id,
    pc.cat                       AS category,
    pc.subcat                    AS subcategory,
    pc.maintenance               AS maintenance,
    pn.prd_cost                  AS cost,
    pn.prd_line                  AS product_line,
    pn.prd_start_dt              AS start_date
FROM CLEAN.crm_prd_info pn
LEFT JOIN CLEAN.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL;