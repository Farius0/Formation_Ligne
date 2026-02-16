
/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

USE DataWarehouseAnalytics
GO

/*
===============================================================================
01 - Customer Distribution by Country
===============================================================================
*/

SELECT 
    country,
    COUNT(*) AS customer_count
FROM gold.dim_customers
GROUP BY country
ORDER BY customer_count DESC;

/*
===============================================================================
02 - Product Hierarchy Overview
===============================================================================
*/

SELECT 
    category,
    subcategory,
    COUNT(*) AS product_count
FROM gold.dim_products
WHERE category IS NOT NULL
GROUP BY category, subcategory
ORDER BY category, subcategory;

SELECT 
    category,
    subcategory,
    product_name,
    COUNT(*) AS product_count
FROM gold.dim_products
GROUP BY category, subcategory, product_name
ORDER BY category, subcategory, product_name;