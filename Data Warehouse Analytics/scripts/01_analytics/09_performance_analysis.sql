/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

USE DataWarehouseAnalytics
GO

/*
===============================================================================
Performance Analysis - Year-over-Year (YoY) Product Sales
===============================================================================
*/

WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    INNER JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
),
final AS (
    SELECT
        order_year,
        product_name,
        current_sales,
        AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales_over_period,
        LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales
    FROM yearly_product_sales
)
SELECT
    order_year,
    product_name,
    current_sales,
    avg_sales_over_period,
    current_sales - avg_sales_over_period AS diff_avg,
    CASE
        WHEN current_sales > avg_sales_over_period THEN 'Above Avg'
        WHEN current_sales < avg_sales_over_period THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_flag,
    py_sales,
    current_sales - py_sales AS diff_py,
    CASE 
        WHEN py_sales IS NULL THEN NULL
        WHEN py_sales = 0 THEN NULL
        ELSE CAST(
            100.0 * (current_sales - py_sales) / py_sales
        AS decimal(10,2))
    END AS yoy_growth_pct,
    CASE
        WHEN py_sales IS NULL THEN 'N/A'
        WHEN current_sales > py_sales THEN 'Increase'
        WHEN current_sales < py_sales THEN 'Decrease'
        ELSE 'No Change'
    END AS yoy_flag
FROM final
ORDER BY product_name, order_year;

