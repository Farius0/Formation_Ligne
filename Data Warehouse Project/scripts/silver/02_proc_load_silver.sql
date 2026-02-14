USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @start_time        DATETIME2(0),
        @end_time          DATETIME2(0),
        @batch_start_time  DATETIME2(0),
        @batch_end_time    DATETIME2(0),
        @RunId             UNIQUEIDENTIFIER = NEWID(),
        @rows              INT;

    BEGIN TRY
        SET @batch_start_time = SYSDATETIME();

        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT 'RunId: ' + CAST(@RunId AS NVARCHAR(36));
        PRINT 'Started: ' + CONVERT(NVARCHAR(19), @batch_start_time, 120);
        PRINT '================================================';

        /* ---------------------------- CRM ---------------------------- */
        PRINT '------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------------';

        /* crm_cust_info */
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Inserting Data Into: silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info (
            cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date,
            dwh_source_system, dwh_ingest_run_id, dwh_bronze_run_id, dwh_source_file
        )
        SELECT
            x.cst_id,
            NULLIF(TRIM(x.cst_key), ''),
            NULLIF(TRIM(x.cst_firstname), ''),
            NULLIF(TRIM(x.cst_lastname), ''),
            CASE UPPER(NULLIF(TRIM(x.cst_marital_status), ''))
                WHEN 'S' THEN 'Single'
                WHEN 'M' THEN 'Married'
                ELSE 'N/A'
            END AS cst_marital_status,-- Normalize marital status values to readable format
            CASE UPPER(NULLIF(TRIM(x.cst_gndr), ''))
                WHEN 'M' THEN 'Male'
                WHEN 'F' THEN 'Female'
                ELSE 'N/A'
            END AS cst_gndr, -- Normalize gender values to readable format
            x.cst_create_date,
            x.dwh_source_system,
            @RunId,
            x.dwh_ingest_run_id,
            x.dwh_source_file
        FROM (
            SELECT
                b.*,
                ROW_NUMBER() OVER (
                    PARTITION BY b.cst_id
                    ORDER BY b.dwh_load_datetime DESC, b.cst_create_date DESC
                ) AS rn
            FROM bronze.crm_cust_info b
            WHERE b.cst_id IS NOT NULL
        ) AS x
        WHERE x.rn = 1;  -- Select the most recent record per customer

        SET @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Loaded: silver.crm_cust_info | Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        /* crm_prd_info */
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT '>> Inserting Data Into: silver.crm_prd_info';

        WITH p AS (
            SELECT
                b.*,
                REPLACE(SUBSTRING(b.prd_key, 1, 5), '-', '_') AS cat_id,
                SUBSTRING(b.prd_key, 7, LEN(b.prd_key)) AS prd_key_clean
            FROM bronze.crm_prd_info b
        ),
        p2 AS (
            SELECT
                p.*,
                DATEADD(DAY, -1,
                    CAST(LEAD(p.prd_start_dt) OVER (PARTITION BY p.prd_key_clean ORDER BY p.prd_start_dt) AS date)
                ) AS prd_end_dt_calc
            FROM p
        )
        INSERT INTO silver.crm_prd_info (
            prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt,
            dwh_source_system, dwh_ingest_run_id, dwh_bronze_run_id, dwh_source_file
        )
        SELECT
            p2.prd_id,
            p2.cat_id,
            p2.prd_key_clean,
            p2.prd_nm,
            p2.prd_cost,
            CASE UPPER(NULLIF(TRIM(p2.prd_line), ''))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'N/A'
            END AS prd_line,
            p2.prd_start_dt,
            p2.prd_end_dt_calc,
            p2.dwh_source_system,
            @RunId,
            p2.dwh_ingest_run_id,
            p2.dwh_source_file
        FROM p2;

        SET @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Loaded: silver.crm_prd_info | Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        /* crm_sales_details */
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT '>> Inserting Data Into: silver.crm_sales_details';

        INSERT INTO silver.crm_sales_details (
            sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price,
            dwh_source_system, dwh_ingest_run_id, dwh_bronze_run_id, dwh_source_file
        )
        SELECT
            b.sls_ord_num,
            b.sls_prd_key,
            b.sls_cust_id,
            CASE WHEN d.order_dt IS NULL OR d.order_dt NOT BETWEEN '2000-01-01' AND CAST(GETDATE() AS date) THEN NULL ELSE d.order_dt END,
            CASE WHEN d.ship_dt  IS NULL OR d.ship_dt  NOT BETWEEN '2000-01-01' AND CAST(GETDATE() AS date) THEN NULL ELSE d.ship_dt  END,
            CASE WHEN d.due_dt   IS NULL OR d.due_dt   NOT BETWEEN '2000-01-01' AND CAST(GETDATE() AS date) THEN NULL ELSE d.due_dt   END,
            s.sales_final,
            b.sls_quantity,
            s.price_final,
            b.dwh_source_system,
            @RunId,
            b.dwh_ingest_run_id,
            b.dwh_source_file
        FROM bronze.crm_sales_details b
        CROSS APPLY (
            SELECT
                TRY_CONVERT(date, CONVERT(char(8), b.sls_order_dt)) AS order_dt,
                TRY_CONVERT(date, CONVERT(char(8), b.sls_ship_dt))  AS ship_dt,
                TRY_CONVERT(date, CONVERT(char(8), b.sls_due_dt))   AS due_dt
        ) d
        CROSS APPLY (
            SELECT
                CAST(
                    CASE
                        WHEN b.sls_sales IS NULL OR b.sls_sales <= 0
                             OR b.sls_quantity IS NULL OR b.sls_quantity <= 0
                             OR b.sls_price IS NULL OR b.sls_price <= 0
                             OR b.sls_sales <> b.sls_quantity * ABS(b.sls_price)
                        THEN (b.sls_quantity * ABS(b.sls_price))
                        ELSE b.sls_sales
                    END
                AS DECIMAL(18,2)) AS sales_final,
                CAST(
                    CASE
                        WHEN b.sls_price IS NULL OR b.sls_price <= 0
                        THEN ( (b.sls_quantity * ABS(b.sls_price)) / NULLIF(b.sls_quantity,0) )
                        ELSE b.sls_price
                    END
                AS DECIMAL(18,2)) AS price_final
        ) s;

        SET @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Loaded: silver.crm_sales_details | Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        /* ---------------------------- ERP ---------------------------- */
        PRINT '------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '------------------------------------------------';

        /* erp_loc_a101 */
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        INSERT INTO silver.erp_loc_a101 (
            cid, cntry,
            dwh_source_system, dwh_ingest_run_id, dwh_bronze_run_id, dwh_source_file
        )
        SELECT
            REPLACE(b.cid, '-', '') AS cid,
            CASE
                WHEN b.cntry IS NULL OR TRIM(b.cntry) = '' THEN 'N/A'
                WHEN TRIM(b.cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(b.cntry) IN ('US', 'USA') THEN 'United States'
                ELSE TRIM(b.cntry)
            END AS cntry, -- Normalize and Handle missing or blank country codes
            b.dwh_source_system,
            @RunId,
            b.dwh_ingest_run_id,
            b.dwh_source_file
        FROM bronze.erp_loc_a101 b;

        SET @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Loaded: silver.erp_loc_a101 | Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        /* erp_cust_az12 */
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        INSERT INTO silver.erp_cust_az12 (
            cid, bdate, gen,
            dwh_source_system, dwh_ingest_run_id, dwh_bronze_run_id, dwh_source_file
        )
        SELECT
            CASE WHEN b.cid LIKE 'NAS%' THEN SUBSTRING(b.cid, 4, LEN(b.cid)) ELSE b.cid END AS cid,
            CASE WHEN b.bdate > CAST(GETDATE() AS DATE) THEN NULL ELSE b.bdate END AS bdate,
            CASE UPPER(NULLIF(TRIM(b.gen), ''))
                WHEN 'F' THEN 'Female'
                WHEN 'FEMALE' THEN 'Female'
                WHEN 'M' THEN 'Male'
                WHEN 'MALE' THEN 'Male'
                ELSE 'N/A'
            END AS gen,
            b.dwh_source_system,
            @RunId,
            b.dwh_ingest_run_id,
            b.dwh_source_file
        FROM bronze.erp_cust_az12 b;

        SET @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Loaded: silver.erp_cust_az12 | Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        /* erp_px_cat_g1v2 */
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        INSERT INTO silver.erp_px_cat_g1v2 (
            id, cat, subcat, maintenance,
            dwh_source_system, dwh_ingest_run_id, dwh_bronze_run_id, dwh_source_file
        )
        SELECT
            b.id, b.cat, b.subcat, b.maintenance,
            b.dwh_source_system,
            @RunId,
            b.dwh_ingest_run_id,
            b.dwh_source_file
        FROM bronze.erp_px_cat_g1v2 b;

        SET @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Loaded: silver.erp_px_cat_g1v2 | Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        SET @batch_end_time = SYSDATETIME();
        PRINT '==========================================';
        PRINT 'Loading Silver Layer is Completed';
        PRINT 'Total Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '==========================================';
    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT 'Message: ' + ERROR_MESSAGE();
        PRINT 'Number : ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'State  : ' + CAST(ERROR_STATE() AS NVARCHAR(20));
        PRINT 'Line   : ' + CAST(ERROR_LINE() AS NVARCHAR(20));
        PRINT 'Proc   : ' + ISNULL(ERROR_PROCEDURE(), N'(adhoc)');
        PRINT '==========================================';
        THROW;
    END CATCH
END;
GO
