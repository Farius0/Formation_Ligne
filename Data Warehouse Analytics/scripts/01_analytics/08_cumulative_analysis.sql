/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

USE DataWarehouseAnalytics
GO

/*
===============================================================================
1 - Cumulative Analysis - Annual Running Total
===============================================================================
*/

WITH annual AS (
    SELECT
        DATETRUNC(year, order_date) AS year_start,
        SUM(sales_amount) AS total_sales,
        SUM(sales_amount) / NULLIF(SUM(quantity), 0) AS weighted_avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
)
SELECT
    year_start,
    total_sales,
    SUM(total_sales) OVER (ORDER BY year_start) AS running_total_sales,
    AVG(weighted_avg_price) OVER (ORDER BY year_start) AS moving_avg_price
FROM annual
ORDER BY year_start;

/*
===============================================================================
2 - Cumulative Analysis - Monthly Running Total + 3M Moving Average
===============================================================================
*/

WITH monthly AS (
    SELECT
        DATETRUNC(month, order_date) AS month_start,
        SUM(sales_amount) AS total_sales,
        SUM(sales_amount) / NULLIF(SUM(quantity), 0) AS weighted_avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
)
SELECT
    month_start,
    total_sales,
    SUM(total_sales) OVER (ORDER BY month_start) AS running_total_sales,
    AVG(weighted_avg_price) OVER (
        ORDER BY month_start
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_price_3m
FROM monthly
ORDER BY month_start;
