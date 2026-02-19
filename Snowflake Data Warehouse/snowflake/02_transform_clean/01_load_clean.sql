-- =============================================================================
-- File: 01_load_clean.sql
-- Purpose:
--   Populate CLEAN tables from RAW by applying casting, standardization rules,
--   and deduplication to produce typed, reliable datasets for the MART layer.
-- =============================================================================

USE ROLE ROLE_DWH_ETL;
USE SECONDARY ROLES NONE;

USE WAREHOUSE WH_ETL;
USE DATABASE DWH_PORTFOLIO;
USE SCHEMA CLEAN;

-- -----------------------------------------------------------------------------
-- CRM
-- -----------------------------------------------------------------------------

-- CRM Customer information
TRUNCATE TABLE CLEAN.crm_cust_info;
INSERT INTO CLEAN.crm_cust_info(cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, 
                                cst_gndr, cst_create_date, load_ts, source_file)
SELECT
    TRY_TO_NUMBER(r.cst_id)                                 AS cst_id,
    NULLIF(TRIM(r.cst_key), '')                             AS cst_key,
    NULLIF(TRIM(r.cst_firstname), '')                       AS cst_firstname,
    NULLIF(TRIM(r.cst_lastname), '')                        AS cst_lastname,
    
    CASE UPPER(NULLIF(TRIM(r.cst_marital_status), ''))
        WHEN 'S' THEN 'Single'
        WHEN 'M' THEN 'Married'
        ELSE 'N/A'
    END                                                     AS cst_marital_status, 
        
    CASE UPPER(NULLIF(TRIM(r.cst_gndr), ''))
        WHEN 'M' THEN 'Male'
        WHEN 'F' THEN 'Female'
        ELSE 'N/A'
    END                                                     AS cst_gndr,
        
    TRY_TO_DATE(r.cst_create_date, 'YYYY-MM-DD')            AS cst_create_date,
    load_ts,
    source_file
FROM RAW.CRM_CUST_INFO r
WHERE TRY_TO_NUMBER(r.cst_id) IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY TRY_TO_NUMBER(r.cst_id)
    ORDER BY r.load_ts DESC, TRY_TO_DATE(r.cst_create_date, 'YYYY-MM-DD') DESC
) = 1
ORDER BY TRY_TO_NUMBER(r.cst_id);

-- CRM Product Information
TRUNCATE TABLE CLEAN.crm_prd_info;

INSERT INTO CLEAN.crm_prd_info (prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, 
                                prd_start_dt, prd_end_dt, load_ts, source_file)
WITH p AS (
    SELECT
        b.*,
        REPLACE(SUBSTR(b.prd_key, 1, 5), '-', '_') AS cat_id,
        SUBSTR(b.prd_key, 7) AS prd_key_clean,
        -- Parse string date 
        TRY_TO_DATE(b.prd_start_dt, 'YYYY-MM-DD') AS prd_start_dt_d
    FROM RAW.crm_prd_info b
), 
    p2 AS (
        SELECT
            p.*,    
            DATEADD('DAY', -1,
                LEAD(p.prd_start_dt_d) OVER (PARTITION BY p.prd_key_clean ORDER BY p.prd_start_dt_d)
                ) AS prd_end_dt_calc
        FROM p
    )

SELECT
    TRY_TO_NUMBER(p2.prd_id)                        AS prd_id,
    p2.cat_id,
    p2.prd_key_clean                                AS prd_key,
    NULLIF(TRIM(p2.prd_nm), '')                     AS prd_nm,
    TRY_TO_NUMBER(p2.prd_cost)                      AS prd_cost,
    
    CASE UPPER(NULLIF(TRIM(p2.prd_line), ''))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'N/A'
    END                                             AS prd_line,
        
    p2.prd_start_dt_d                               AS prd_start_dt,
    p2.prd_end_dt_calc                              AS prd_end_dt,
    p2.load_ts,
    p2.source_file
FROM p2
ORDER BY TRY_TO_NUMBER(p2.prd_id), p2.prd_key_clean;

-- CRM Sales & Orders
TRUNCATE TABLE CLEAN.crm_sales_details;

INSERT INTO CLEAN.crm_sales_details (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt,
                                    sls_due_dt, sls_sales, sls_quantity, sls_price, load_ts, source_file)

WITH p AS (
    SELECT
        b.sls_ord_num,
        b.sls_prd_key,
        b.sls_cust_id,
        b.load_ts,
        b.source_file,
        TRY_TO_DATE(b.sls_order_dt, 'YYYYMMDD') AS order_dt,
        TRY_TO_DATE(b.sls_ship_dt, 'YYYYMMDD')  AS ship_dt,
        TRY_TO_DATE(b.sls_due_dt, 'YYYYMMDD')   AS due_dt,
        TRY_TO_NUMBER(b.sls_sales)              AS sales_n,
        TRY_TO_NUMBER(b.sls_quantity)           AS qty_n,
        TRY_TO_NUMBER(b.sls_price)              AS price_n
    FROM RAW.crm_sales_details b
),
c AS (
  SELECT
    p.sls_ord_num,
    p.sls_prd_key,
    p.sls_cust_id,
    p.sales_n,
    p.qty_n,
    p.price_n,
    p.load_ts,
    p.source_file,
    IFF(p.order_dt BETWEEN DATE '2000-01-01' AND CURRENT_DATE(), p.order_dt, NULL)      AS order_dt, -- date valid
    IFF(p.ship_dt  BETWEEN DATE '2000-01-01' AND CURRENT_DATE(), p.ship_dt,  NULL)      AS ship_dt,
    IFF(p.due_dt   BETWEEN DATE '2000-01-01' AND CURRENT_DATE(), p.due_dt,   NULL)      AS due_dt,
    (p.qty_n * ABS(p.price_n))                                                          AS expected_sales,
    IFF(
      p.sales_n IS NOT NULL AND p.qty_n IS NOT NULL AND p.price_n IS NOT NULL
      AND ABS(p.sales_n - (p.qty_n * ABS(p.price_n))) <= 0.01,
      TRUE, FALSE
    )                                                                                   AS sales_matches
  FROM p
)

SELECT
    c.sls_ord_num,
    c.sls_prd_key,
    TRY_TO_NUMBER(c.sls_cust_id)                                        AS sls_cust_id,
    c.order_dt,
    c.ship_dt,
    c.due_dt,
    
  -- Sales final:
  CAST(
    CASE
      WHEN qty_n IS NULL OR qty_n = 0 THEN NULL  
      WHEN sales_n IS NULL OR sales_n <= 0 THEN expected_sales
      WHEN price_n IS NULL THEN sales_n
      WHEN ABS(sales_n - expected_sales) <= 0.01 THEN sales_n
      ELSE expected_sales
    END
  AS NUMBER(18,2))                                                      AS sls_sales,
    
    c.qty_n                                                             AS sls_quantity,
    
  -- Price final:
  CAST(
    CASE
      WHEN qty_n IS NULL OR qty_n = 0 THEN NULL
      WHEN price_n IS NOT NULL AND price_n > 0 THEN price_n
      WHEN sales_n IS NOT NULL AND sales_n > 0 THEN sales_n / qty_n
      WHEN expected_sales IS NOT NULL THEN expected_sales / qty_n
      ELSE NULL
    END
  AS NUMBER(18,2))                                                      AS sls_price,

    c.load_ts,
    c.source_file
FROM c;

-- -----------------------------------------------------------------------------
-- ERP
-- -----------------------------------------------------------------------------

-- ERP Customer Information
TRUNCATE TABLE CLEAN.erp_cust_az12;

INSERT INTO CLEAN.erp_cust_az12 (cid, bdate, gen, load_ts, source_file)
SELECT

    CASE
        WHEN b.cid LIKE 'NAS%' THEN SUBSTR(b.cid, 4)
        ELSE b.cid
    END                                                             AS cid,

    CASE
        WHEN TRY_TO_DATE(b.bdate) IS NULL THEN NULL
        WHEN TRY_TO_DATE(b.bdate) > CURRENT_DATE() THEN NULL
        ELSE TRY_TO_DATE(b.bdate)
    END                                                             AS bdate,

    CASE UPPER(NULLIF(TRIM(b.gen), ''))
        WHEN 'F' THEN 'Female'
        WHEN 'FEMALE' THEN 'Female'
        WHEN 'M' THEN 'Male'
        WHEN 'MALE' THEN 'Male'
        ELSE 'N/A'
    END                                                             AS gen,
        
  load_ts,
  source_file
FROM RAW.erp_cust_az12 b;

-- ERP Locations
TRUNCATE TABLE CLEAN.erp_loc_a101;
INSERT INTO CLEAN.erp_loc_a101  (cid, cntry, load_ts, source_file)
SELECT
    REPLACE(b.cid, '-', '')                                                 AS cid,
    CASE
        WHEN b.cntry IS NULL OR TRIM(b.cntry) = '' THEN 'N/A'
        WHEN UPPER(TRIM(b.cntry)) = 'DE' THEN 'Germany'
        WHEN UPPER(TRIM(b.cntry)) IN ('US', 'USA') THEN 'United States'
        ELSE TRIM(b.cntry)
    END                                                                     AS cntry,
  load_ts,
  source_file
FROM RAW.erp_loc_a101 b;

-- ERP categories
TRUNCATE TABLE CLEAN.erp_px_cat_g1v2;
INSERT INTO CLEAN.erp_px_cat_g1v2(id, cat, subcat, maintenance, load_ts, source_file)
TRUNCATE TABLE CLEAN.erp_px_cat_g1v2;

INSERT INTO CLEAN.erp_px_cat_g1v2 (id, cat, subcat, maintenance, load_ts, source_file)
SELECT
  id,
  cat,
  subcat,
  maintenance,
  load_ts,
  source_file
FROM RAW.erp_px_cat_g1v2;
