/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

USE DataWarehouseAnalytics
GO

/*
===============================================================================
Segment products into cost ranges and 
count how many products fall into each segment
===============================================================================
*/

WITH product_segments AS (
    SELECT
        product_key,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost >= 100 AND cost < 500 THEN '100-499'
            WHEN cost >= 500 AND cost < 1000 THEN '500-999'
            ELSE '1000+'
        END AS cost_range
    FROM gold.dim_products
)
SELECT 
    cost_range,
    COUNT(*) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

/*
===============================================================================================
Group customers into three segments based on their spending behavior:
	
    - VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
===============================================================================================
*/
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
--        MIN(f.order_date) AS first_order,
--        MAX(f.order_date) AS last_order,
        DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan
    FROM gold.dim_customers c
    LEFT JOIN gold.fact_sales f
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,
    COUNT(*) AS total_customers
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN total_spending IS NULL THEN 'No Purchase'
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) segmented
GROUP BY customer_segment
ORDER BY total_customers DESC;
