# Data Catalog -- Gold Layer

## Overview

The **Gold layer** represents the business-ready data model designed for
analytics and reporting. It follows a **Star Schema** structure composed
of:

-   **Dimension tables** (descriptive attributes)
-   **Fact tables** (measurable business events)

This layer ensures: - Cleaned and standardized data - Referential integrity - Business-aligned naming conventions

------------------------------------------------------------------------

# 1. 🧾 gold.dim_customers

## Purpose

Stores customer master data enriched with demographic and geographic
attributes.

## Grain

**One row per customer (unique by `customer_id`).**

## Columns

| Column Name       | Data Type        | Description                                                      |
|------------------|-----------------|------------------------------------------------------------------|
| customer_key     | INT             | Surrogate key uniquely identifying each customer record.        |
| customer_id      | INT             | Source-system customer identifier (CRM).                        |
| customer_number  | NVARCHAR(50)    | Business / customer reference (CRM key).                        |
| first_name       | NVARCHAR(50)    | Standardized customer first name.                               |
| last_name        | NVARCHAR(50)    | Standardized customer last name.                                |
| country          | NVARCHAR(50)    | Standardized country name (e.g., Germany, United States).       |
| marital_status   | NVARCHAR(50)    | Standardized marital status (Single, Married, N/A).             |
| gender           | NVARCHAR(20)    | Standardized gender (Male, Female, N/A).                        |
| birthdate        | DATE            | Customer birthdate (YYYY-MM-DD).                                |
| create_date      | DATE            | Customer record creation date from CRM.                         |

## Data Quality Rules

-   `customer_id` must be unique.
-   `gender` values limited to: Male, Female, N/A.
-   `marital_status` values limited to: Single, Married, N/A.
-   `birthdate` cannot be in the future.
-   `country` must be standardized (no country codes).

------------------------------------------------------------------------

# 2.📦 gold.dim_products

## Purpose

Provides current product attributes enriched with ERP category
information.

## Grain

**One row per current product (unique by `product_number`).**

## Columns

| Column Name       | Data Type        | Description                                                     |
|------------------|-----------------|-----------------------------------------------------------------|
| product_key      | INT             | Surrogate key uniquely identifying each product record.        |
| product_id       | INT             | Source-system product identifier (CRM).                        |
| product_number   | NVARCHAR(50)    | Business product reference code.                               |
| product_name     | NVARCHAR(100)   | Descriptive product name.                                      |
| category_id      | NVARCHAR(50)    | ERP category identifier.                                       |
| category         | NVARCHAR(100)   | Product category (e.g., Bikes, Components).                    |
| subcategory      | NVARCHAR(100)   | Detailed product classification.                               |
| maintenance      | NVARCHAR(100)   | Maintenance attribute from ERP.                                |
| cost             | DECIMAL(18,2)   | Product cost in monetary units.                                |
| product_line     | NVARCHAR(50)    | Product line (Road, Mountain, Touring, etc.).                  |
| start_date       | DATE            | Product effective start date.                                  |

## Data Quality Rules

-   `product_number` must be unique.
-   `cost` must be \>= 0.
-   `start_date` cannot be in the future.
-   Only current products are included (historical rows excluded).

------------------------------------------------------------------------

# 3. 🧾 gold.fact_sales

## Purpose

Stores transactional sales data at the order line level for KPI
calculation and reporting.

## Grain

**One row per sales order line.**

## Columns


| Column Name     | Data Type        | Description                                                     |
|----------------|-----------------|-----------------------------------------------------------------|
| order_number   | NVARCHAR(50)    | Sales order identifier (e.g., SO54496).                         |
| product_key    | INT             | Foreign key referencing `gold.dim_products`.                   |
| customer_key   | INT             | Foreign key referencing `gold.dim_customers`.                  |
| order_date     | DATE            | Order date.                                                    |
| shipping_date  | DATE            | Shipping date.                                                 |
| due_date       | DATE            | Payment due date.                                              |
| sales_amount   | DECIMAL(18,2)   | Total sales amount for the order line.                         |
| quantity       | INT             | Quantity sold.                                                 |
| price          | DECIMAL(18,2)   | Unit price.                                                    |

## Data Quality Rules

-   `product_key` must exist in `gold.dim_products`.
-   `customer_key` must exist in `gold.dim_customers`.
-   `sales_amount` must be \>= 0.
-   `quantity` must be \> 0.
-   `price` must be \>= 0.
-   `order_date` must be between 2000-01-01 and current date.
-   `shipping_date` must be \>= `order_date`.
-   `due_date` must be \>= `order_date`.

------------------------------------------------------------------------

# Referential Integrity

The Gold layer enforces:

-   Foreign key constraints between fact and dimensions
-   Unique constraints on business keys
-   Business-standardized attributes