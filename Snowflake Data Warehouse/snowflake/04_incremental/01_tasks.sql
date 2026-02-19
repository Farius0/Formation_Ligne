-- =============================================================================
-- File: 01_tasks.sql
-- Purpose:
--   Portfolio demo task: incrementally load sales rows from the RAW stream into
--   CLEAN.crm_sales_details by applying the same typing and consistency rules
--   as the full refresh load.
-- =============================================================================

USE ROLE ROLE_DWH_ETL;
USE SECONDARY ROLES NONE;

USE WAREHOUSE WH_ETL;
USE DATABASE DWH_PORTFOLIO;

CREATE OR REPLACE TASK CLEAN.TSK_LOAD_SALES_INCREMENTAL
  WAREHOUSE = WH_ETL
  SCHEDULE  = 'USING CRON 0 */6 * * * UTC'
AS
INSERT INTO CLEAN.crm_sales_details (
  sls_ord_num,
  sls_prd_key,
  sls_cust_id,
  sls_order_dt,
  sls_ship_dt,
  sls_due_dt,
  sls_sales,
  sls_quantity,
  sls_price,
  load_ts,
  source_file
)
WITH p AS (
  SELECT
    NULLIF(TRIM(b.sls_ord_num), '')                         AS sls_ord_num,
    NULLIF(TRIM(b.sls_prd_key), '')                         AS sls_prd_key,
    b.sls_cust_id                                           AS sls_cust_id,
    b.load_ts                                               AS load_ts,
    b.source_file                                           AS source_file,

    TRY_TO_DATE(b.sls_order_dt, 'YYYYMMDD')                 AS order_dt,
    TRY_TO_DATE(b.sls_ship_dt,  'YYYYMMDD')                 AS ship_dt,
    TRY_TO_DATE(b.sls_due_dt,   'YYYYMMDD')                 AS due_dt,

    TRY_TO_NUMBER(b.sls_sales)                              AS sales_n,
    TRY_TO_NUMBER(b.sls_quantity)                           AS qty_n,
    TRY_TO_NUMBER(b.sls_price)                              AS price_n
  FROM RAW.STRM_CRM_SALES_DETAILS b
  WHERE METADATA$ACTION = 'INSERT'
),
c AS (
  SELECT
    p.sls_ord_num,
    p.sls_prd_key,
    TRY_TO_NUMBER(p.sls_cust_id)                            AS sls_cust_id,

    IFF(p.order_dt BETWEEN DATE '2000-01-01' AND CURRENT_DATE(), p.order_dt, NULL) AS order_dt,
    IFF(p.ship_dt  BETWEEN DATE '2000-01-01' AND CURRENT_DATE(), p.ship_dt,  NULL) AS ship_dt,
    IFF(p.due_dt   BETWEEN DATE '2000-01-01' AND CURRENT_DATE(), p.due_dt,   NULL) AS due_dt,

    p.sales_n,
    p.qty_n,
    p.price_n,

    (p.qty_n * ABS(p.price_n))                              AS expected_sales,
    p.load_ts,
    p.source_file
  FROM p
),
dedup AS (
  SELECT *
  FROM c
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY sls_ord_num, sls_prd_key, sls_cust_id, order_dt
    ORDER BY load_ts DESC
  ) = 1
)
SELECT
  d.sls_ord_num,
  d.sls_prd_key,
  d.sls_cust_id,
  d.order_dt                                                AS sls_order_dt,
  d.ship_dt                                                 AS sls_ship_dt,
  d.due_dt                                                  AS sls_due_dt,

  CAST(
    CASE
      WHEN d.qty_n IS NULL OR d.qty_n = 0 THEN NULL
      WHEN d.sales_n IS NULL OR d.sales_n <= 0 THEN d.expected_sales
      WHEN d.price_n IS NULL THEN d.sales_n
      WHEN ABS(d.sales_n - d.expected_sales) <= 0.01 THEN d.sales_n
      ELSE d.expected_sales
    END
  AS NUMBER(18,2))                                          AS sls_sales,

  CAST(d.qty_n AS NUMBER(18,2))                             AS sls_quantity,

  CAST(
    CASE
      WHEN d.qty_n IS NULL OR d.qty_n = 0 THEN NULL
      WHEN d.price_n IS NOT NULL AND d.price_n > 0 THEN d.price_n
      WHEN d.sales_n IS NOT NULL AND d.sales_n > 0 THEN d.sales_n / d.qty_n
      WHEN d.expected_sales IS NOT NULL THEN d.expected_sales / d.qty_n
      ELSE NULL
    END
  AS NUMBER(18,2))                                          AS sls_price,

  d.load_ts,
  d.source_file
FROM dedup d;

-- To start:
-- ALTER TASK CLEAN.TSK_LOAD_SALES_INCREMENTAL RESUME;
--
-- To stop:
-- ALTER TASK CLEAN.TSK_LOAD_SALES_INCREMENTAL SUSPEND;
