-- =============================================================================
-- File: 02_fact_sales.sql
-- Purpose:
--   Build the sales fact table at sales order line grain by joining CLEAN sales
--   details to MART dimensions (products, customers) and exposing measures.
-- =============================================================================

USE ROLE ROLE_DWH_ETL;
USE SECONDARY ROLES NONE;

USE WAREHOUSE WH_ETL;
USE DATABASE DWH_PORTFOLIO;
USE SCHEMA MART;

-- Fact table at sales order line grain
CREATE OR REPLACE TABLE MART.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key  AS product_key,
    cu.customer_key AS customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM CLEAN.crm_sales_details sd
LEFT JOIN MART.dim_products pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN MART.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;