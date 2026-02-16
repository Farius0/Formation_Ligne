/*
=============================================================
02 - Create Stage & Gold Tables + Constraints + Indexes
=============================================================
Design:
  - stage.* tables are raw landing (all NVARCHAR)
  - gold.* tables are typed + constrained (star schema)
*/

USE DataWarehouseAnalytics;
GO

/*-----------------------------
  STAGE TABLES (raw)
------------------------------*/
IF OBJECT_ID('stage.dim_customers_raw','U') IS NOT NULL DROP TABLE stage.dim_customers_raw;
IF OBJECT_ID('stage.dim_products_raw','U') IS NOT NULL DROP TABLE stage.dim_products_raw;
IF OBJECT_ID('stage.fact_sales_raw','U') IS NOT NULL DROP TABLE stage.fact_sales_raw;
GO

CREATE TABLE stage.dim_customers_raw (
    customer_key     nvarchar(50) NULL,
    customer_id      nvarchar(50) NULL,
    customer_number  nvarchar(200) NULL,
    first_name       nvarchar(200) NULL,
    last_name        nvarchar(200) NULL,
    country          nvarchar(200) NULL,
    marital_status   nvarchar(200) NULL,
    gender           nvarchar(200) NULL,
    birthdate        nvarchar(50) NULL,
    create_date      nvarchar(50) NULL
);
GO

CREATE TABLE stage.dim_products_raw (
    product_key     nvarchar(50) NULL,
    product_id      nvarchar(50) NULL,
    product_number  nvarchar(200) NULL,
    product_name    nvarchar(500) NULL,
    category_id     nvarchar(50) NULL,
    category        nvarchar(200) NULL,
    subcategory     nvarchar(200) NULL,
    maintenance     nvarchar(200) NULL,
    cost            nvarchar(50) NULL,
    product_line    nvarchar(200) NULL,
    start_date      nvarchar(50) NULL
);
GO

CREATE TABLE stage.fact_sales_raw (
    order_number   nvarchar(200) NULL,
    product_key    nvarchar(50) NULL,
    customer_key   nvarchar(50) NULL,
    order_date     nvarchar(50) NULL,
    shipping_date  nvarchar(50) NULL,
    due_date       nvarchar(50) NULL,
    sales_amount   nvarchar(50) NULL,
    quantity       nvarchar(50) NULL,
    price          nvarchar(50) NULL
);
GO


/*-----------------------------
  GOLD TABLES (typed, star schema)
------------------------------*/
IF OBJECT_ID('gold.fact_sales','U') IS NOT NULL DROP TABLE gold.fact_sales;
IF OBJECT_ID('gold.dim_products','U') IS NOT NULL DROP TABLE gold.dim_products;
IF OBJECT_ID('gold.dim_customers','U') IS NOT NULL DROP TABLE gold.dim_customers;
GO

CREATE TABLE gold.dim_customers (
    customer_key     int            NOT NULL,
    customer_id      int            NULL,
    customer_number  nvarchar(50)   NULL,
    first_name       nvarchar(50)   NULL,
    last_name        nvarchar(50)   NULL,
    country          nvarchar(50)   NULL,
    marital_status   nvarchar(50)   NULL,
    gender           nvarchar(50)   NULL,
    birthdate        date           NULL,
    create_date      date           NULL,

    CONSTRAINT PK_dim_customers PRIMARY KEY CLUSTERED (customer_key)
);
GO

CREATE TABLE gold.dim_products (
    product_key     int            NOT NULL,
    product_id      int            NULL,
    product_number  nvarchar(50)   NULL,
    product_name    nvarchar(200)  NULL,
    category_id     nvarchar(50)   NULL,
    category        nvarchar(50)   NULL,
    subcategory     nvarchar(50)   NULL,
    maintenance     nvarchar(50)   NULL,
    cost            decimal(18,2)  NULL,
    product_line    nvarchar(50)   NULL,
    start_date      date           NULL,

    CONSTRAINT PK_dim_products PRIMARY KEY CLUSTERED (product_key)
);
GO

CREATE TABLE gold.fact_sales (
    order_number   nvarchar(50)    NOT NULL,
    product_key    int             NOT NULL,
    customer_key   int             NOT NULL,
    order_date     date            NULL,
    shipping_date  date            NULL,
    due_date       date            NULL,
    sales_amount   decimal(18,2)   NULL,
    quantity       int             NULL,
    price          decimal(18,2)   NULL
);
GO

/*-----------------------------
  Constraints (FK)
------------------------------*/
ALTER TABLE gold.fact_sales
ADD CONSTRAINT FK_fact_sales_dim_products
FOREIGN KEY (product_key) REFERENCES gold.dim_products(product_key);
GO

ALTER TABLE gold.fact_sales
ADD CONSTRAINT FK_fact_sales_dim_customers
FOREIGN KEY (customer_key) REFERENCES gold.dim_customers(customer_key);
GO

-- Minimal indexes for analytics
CREATE INDEX IX_fact_sales_order_date  ON gold.fact_sales(order_date);
CREATE INDEX IX_fact_sales_customer    ON gold.fact_sales(customer_key);
CREATE INDEX IX_fact_sales_product     ON gold.fact_sales(product_key);
GO
