/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

USE DataWarehouseAnalytics
GO

/*
===============================================================================
01 - Core Business Metrics
===============================================================================
*/

--- Horizontal Format
SELECT
    COUNT(DISTINCT order_number)                                                AS Total_orders,
    SUM(sales_amount)                                                           AS Total_sales,
    SUM(quantity)                                                               AS Total_quantity,
    CAST(SUM(sales_amount) / NULLIF(SUM(quantity), 0) AS DECIMAL(18,2))         AS Weighted_avg_price,
    CAST(SUM(sales_amount) / COUNT(DISTINCT order_number) AS DECIMAL(18,2))     AS Avg_order_value,
    COUNT(DISTINCT customer_key)                                                AS Active_customers,
    (SELECT COUNT(*) FROM gold.dim_customers)                                   AS Total_customers,
    COUNT(DISTINCT product_key)                                                 AS Active_products,
    (SELECT COUNT(*) FROM gold.dim_products)                                    AS Total_products
FROM gold.fact_sales;

--- Vertical Format
WITH metrics AS (
    SELECT
    COUNT(DISTINCT order_number)                                                AS Total_orders,
    SUM(sales_amount)                                                           AS Total_sales,
    SUM(quantity)                                                               AS Total_quantity,
    SUM(sales_amount) / SUM(quantity)                                           AS Weighted_avg_price,
    SUM(sales_amount) / COUNT(DISTINCT order_number)                            AS Avg_order_value,
    COUNT(DISTINCT customer_key)                                                AS Active_customers,
    COUNT(DISTINCT product_key)                                                 AS Active_products
    FROM gold.fact_sales
),
    metrics2 AS (SELECT COUNT(*) AS Total_customers FROM gold.dim_customers
),
    metrics3 AS (SELECT COUNT(*) AS Total_products FROM gold.dim_products
)

SELECT 
    Measure_Name,
    Measure_Value
FROM (
    SELECT 'Total Orders' AS Measure_Name,  Total_orders AS Measure_Value FROM metrics
    UNION ALL
    SELECT 'Total Sales' ,                  Total_sales FROM metrics
    UNION ALL
    SELECT 'Total Quantity',                Total_quantity FROM metrics
    UNION ALL
    SELECT 'Weighted_avg_price',            Weighted_avg_price FROM metrics
    UNION ALL
    SELECT 'Average Order Value',           Avg_order_value FROM metrics
    UNION ALL
    SELECT 'Active Customers',              Active_customers FROM metrics
    UNION ALL
    SELECT 'Total Customers',               Total_customers FROM metrics2
    UNION ALL
    SELECT 'Active Products',               Active_products FROM metrics
    UNION ALL
    SELECT 'Total Products',                Total_products FROM metrics3
) m;

