/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/
USE DataWarehouseAnalytics
GO

/*
===============================================================================
Part-to-Whole Analysis - Category Contribution
===============================================================================
*/

WITH category_sales AS (
    SELECT
        COALESCE(p.category, 'Unknown') AS category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    INNER JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY COALESCE(p.category, 'Unknown')
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    CONCAT(CAST(
        100.0 * total_sales / NULLIF(SUM(total_sales) OVER (), 0)
        AS decimal(6,2)
    ), ' %') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;
