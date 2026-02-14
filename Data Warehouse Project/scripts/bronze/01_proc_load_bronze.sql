USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @start_time        DATETIME2(0),
        @end_time          DATETIME2(0),
        @batch_start_time  DATETIME2(0),
        @batch_end_time    DATETIME2(0),
        @RunId             UNIQUEIDENTIFIER = NEWID(),
        @pathcrmfolder     NVARCHAR(4000) = N'C:\dwh_files\crm\',
        @patherpfolder     NVARCHAR(4000) = N'C:\dwh_files\erp\',
        @sql               NVARCHAR(MAX),
        @file              NVARCHAR(260),
        @rows              INT;

    BEGIN TRY
        SET @batch_start_time = SYSDATETIME();

        PRINT '================================================';
        PRINT 'Loading Bronze Layer';
        PRINT 'RunId: ' + CAST(@RunId AS NVARCHAR(36));
        PRINT 'Started: ' + CONVERT(NVARCHAR(19), @batch_start_time, 120);
        PRINT '================================================';

        /* ---------------------------- CRM ---------------------------- */
        PRINT '------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------------';

        /* crm_cust_info */
        SET @start_time = SYSDATETIME();
        SET @file = N'cust_info.csv';
        PRINT '>> Bulk path: ' + @pathcrmfolder + @file;

        TRUNCATE TABLE staging.crm_cust_info;

        SET @sql = N'
        BULK INSERT staging.crm_cust_info
        FROM ' + QUOTENAME(@pathcrmfolder + @file, '''') + N'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0d0a'', TABLOCK);';
        EXEC sys.sp_executesql @sql;

        TRUNCATE TABLE bronze.crm_cust_info;

        INSERT INTO bronze.crm_cust_info (
            cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date,
            dwh_source_system, dwh_ingest_run_id, dwh_source_file
        )
        SELECT
            s.cst_id, s.cst_key, s.cst_firstname, s.cst_lastname, s.cst_marital_status, s.cst_gndr, s.cst_create_date,
            N'crm', @RunId, @file
        FROM staging.crm_cust_info AS s;

        SET @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Loaded: bronze.crm_cust_info | Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        /* crm_prd_info */
        SET @start_time = SYSDATETIME();
        SET @file = N'prd_info.csv';
        PRINT '>> Bulk path: ' + @pathcrmfolder + @file;

        TRUNCATE TABLE staging.crm_prd_info;

        SET @sql = N'
        BULK INSERT staging.crm_prd_info
        FROM ' + QUOTENAME(@pathcrmfolder + @file, '''') + N'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0d0a'', TABLOCK);';
        EXEC sys.sp_executesql @sql;

        TRUNCATE TABLE bronze.crm_prd_info;

        INSERT INTO bronze.crm_prd_info (
            prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt,
            dwh_source_system, dwh_ingest_run_id, dwh_source_file
        )
        SELECT
            s.prd_id, s.prd_key, s.prd_nm, s.prd_cost, s.prd_line, s.prd_start_dt, s.prd_end_dt,
            N'crm', @RunId, @file
        FROM staging.crm_prd_info AS s;

        SET @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Loaded: bronze.crm_prd_info | Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        /* crm_sales_details */
        SET @start_time = SYSDATETIME();
        SET @file = N'sales_details.csv';
        PRINT '>> Bulk path: ' + @pathcrmfolder + @file;

        TRUNCATE TABLE staging.crm_sales_details;

        SET @sql = N'
        BULK INSERT staging.crm_sales_details
        FROM ' + QUOTENAME(@pathcrmfolder + @file, '''') + N'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0d0a'', TABLOCK);';
        EXEC sys.sp_executesql @sql;

        TRUNCATE TABLE bronze.crm_sales_details;

        INSERT INTO bronze.crm_sales_details (
            sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price,
            dwh_source_system, dwh_ingest_run_id, dwh_source_file
        )
        SELECT
            s.sls_ord_num, s.sls_prd_key, s.sls_cust_id, s.sls_order_dt, s.sls_ship_dt, s.sls_due_dt, s.sls_sales, s.sls_quantity, s.sls_price,
            N'crm', @RunId, @file
        FROM staging.crm_sales_details AS s;

        SET @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Loaded: bronze.crm_sales_details | Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        /* ---------------------------- ERP ---------------------------- */
        PRINT '------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '------------------------------------------------';

        /* erp_loc_a101 */
        SET @start_time = SYSDATETIME();
        SET @file = N'loc_a101.csv';
        PRINT '>> Bulk path: ' + @patherpfolder + @file;

        TRUNCATE TABLE staging.erp_loc_a101;

        SET @sql = N'
        BULK INSERT staging.erp_loc_a101
        FROM ' + QUOTENAME(@patherpfolder + @file, '''') + N'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0d0a'', TABLOCK);';
        EXEC sys.sp_executesql @sql;

        TRUNCATE TABLE bronze.erp_loc_a101;

        INSERT INTO bronze.erp_loc_a101 (
            cid, cntry,
            dwh_source_system, dwh_ingest_run_id, dwh_source_file
        )
        SELECT
            s.cid, s.cntry,
            N'erp', @RunId, @file
        FROM staging.erp_loc_a101 AS s;

        SET @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Loaded: bronze.erp_loc_a101 | Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        /* erp_cust_az12 */
        SET @start_time = SYSDATETIME();
        SET @file = N'cust_az12.csv';
        PRINT '>> Bulk path: ' + @patherpfolder + @file;

        TRUNCATE TABLE staging.erp_cust_az12;

        SET @sql = N'
        BULK INSERT staging.erp_cust_az12
        FROM ' + QUOTENAME(@patherpfolder + @file, '''') + N'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0d0a'', TABLOCK);';
        EXEC sys.sp_executesql @sql;

        TRUNCATE TABLE bronze.erp_cust_az12;

        INSERT INTO bronze.erp_cust_az12 (
            cid, bdate, gen,
            dwh_source_system, dwh_ingest_run_id, dwh_source_file
        )
        SELECT
            s.cid, s.bdate, s.gen,
            N'erp', @RunId, @file
        FROM staging.erp_cust_az12 AS s;

        SET @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Loaded: bronze.erp_cust_az12 | Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        /* erp_px_cat_g1v2 */
        SET @start_time = SYSDATETIME();
        SET @file = N'px_cat_g1v2.csv';
        PRINT '>> Bulk path: ' + @patherpfolder + @file;

        TRUNCATE TABLE staging.erp_px_cat_g1v2;

        SET @sql = N'
        BULK INSERT staging.erp_px_cat_g1v2
        FROM ' + QUOTENAME(@patherpfolder + @file, '''') + N'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0d0a'', TABLOCK);';
        EXEC sys.sp_executesql @sql;

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        INSERT INTO bronze.erp_px_cat_g1v2 (
            id, cat, subcat, maintenance,
            dwh_source_system, dwh_ingest_run_id, dwh_source_file
        )
        SELECT
            s.id, s.cat, s.subcat, s.maintenance,
            N'erp', @RunId, @file
        FROM staging.erp_px_cat_g1v2 AS s;

        SET @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Loaded: bronze.erp_px_cat_g1v2 | Rows: ' + CAST(@rows AS NVARCHAR(20));
        PRINT '>> Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> -------------';

        /* Clean staging only if everything succeeded */
        SET @sql = N'';

        SELECT @sql += N'TRUNCATE TABLE staging.' + QUOTENAME(t.name) + N';' + CHAR(13) + CHAR(10)
        FROM sys.tables t
        JOIN sys.schemas s ON t.schema_id = s.schema_id
        WHERE s.name = 'staging';

        IF @sql IS NOT NULL AND LEN(@sql) > 0
        BEGIN
            PRINT 'Truncating staging tables:';
            EXEC sys.sp_executesql @sql;
        END

        SET @batch_end_time = SYSDATETIME();
        PRINT '==========================================';
        PRINT 'Loading Bronze Layer is Completed';
        PRINT 'Total Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '==========================================';
    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
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
