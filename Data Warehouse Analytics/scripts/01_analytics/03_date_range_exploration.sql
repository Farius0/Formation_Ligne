/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

USE DataWarehouseAnalytics
GO

/*
===============================================================================
01 - Orders Date Range
===============================================================================
*/

SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(DAY,   MIN(order_date), MAX(order_date))  AS range_days,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date))  AS month_boundaries,
    CAST(DATEDIFF(DAY, MIN(order_date), MAX(order_date)) / 30.0 AS INT)  AS approx_months,
    DATEDIFF(YEAR,  MIN(order_date), MAX(order_date))  AS year_boundaries,
    CAST(DATEDIFF(DAY, MIN(order_date), MAX(order_date)) / 365.25 AS INT) AS approx_years
FROM gold.fact_sales
WHERE order_date IS NOT NULL;


/*
===============================================================================
02 - Oldest & Youngest Customer (Exact Age)
===============================================================================
*/

SELECT
    MIN(birthdate) AS oldest_birthdate,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE())
      - CASE 
          WHEN DATEADD(YEAR, DATEDIFF(YEAR, MIN(birthdate), GETDATE()), MIN(birthdate)) > GETDATE()
          THEN 1 ELSE 0
        END AS oldest_age_exact,

    MAX(birthdate) AS youngest_birthdate,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE())
      - CASE 
          WHEN DATEADD(YEAR, DATEDIFF(YEAR, MAX(birthdate), GETDATE()), MAX(birthdate)) > GETDATE()
          THEN 1 ELSE 0
        END AS youngest_age_exact
FROM gold.dim_customers
WHERE birthdate IS NOT NULL;
