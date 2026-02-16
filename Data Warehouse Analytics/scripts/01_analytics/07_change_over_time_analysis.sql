/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATEFROMPARTS, DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/

USE DataWarehouseAnalytics
GO

/*
===============================================================================
01 - Sales performance over time
===============================================================================
*/

SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers_dis,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

/*
===============================================================================
02 - Annual Sales Trend
===============================================================================
*/

SELECT
    YEAR(order_date) AS order_year,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers_dis,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

/*
===============================================================================
03 - Monthly Sales Trend
===============================================================================
*/

SELECT
    DATETRUNC(month, order_date) AS month_start,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY month_start;

/*
===============================================================================
03b - Monthly Sales Trend (Formatted)
===============================================================================
*/

WITH monthly AS (
    SELECT
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS month_start,
        SUM(sales_amount) AS total_sales,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(quantity) AS total_quantity
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
)
SELECT
    FORMAT(month_start, 'yyyy-MMM') AS month_label,
    total_sales,
    total_customers,
    total_quantity
FROM monthly
ORDER BY month_start;

/*
===============================================================================
04 - Month-over-Month (MoM) Growth
===============================================================================
*/

WITH monthly AS (
    SELECT
        DATETRUNC(month, order_date) AS month_start,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
),
final AS (
    SELECT
        month_start,
        total_sales,
        LAG(total_sales) OVER (ORDER BY month_start) AS prev_month_sales
    FROM monthly
)
SELECT
    month_start,
    total_sales,
    prev_month_sales,
    CONCAT(CAST(100.0 * (total_sales - prev_month_sales) / NULLIF(prev_month_sales, 0) AS decimal(7,2)), ' %')  AS mom_growth_pct
FROM final
ORDER BY month_start;