-- ======================================================================
-- STEP 3: Medallion Architecture (Bronze -> Silver -> Gold Views)
-- ======================================================================

USE DATABASE ECOMMERCE_DB;
USE ROLE SYSADMIN;

-- Create Schemas for organization
CREATE OR REPLACE SCHEMA ECOMMERCE_DB.SILVER;
CREATE OR REPLACE SCHEMA ECOMMERCE_DB.GOLD;

-- ==================
-- SILVER LAYER
-- ==================
-- Limpeza Básica, tipagem e deduplicação (Simulada por view para arquitetura Zero-ETL)
CREATE OR REPLACE VIEW ECOMMERCE_DB.SILVER.v_sales_cleaned AS
SELECT DISTINCT
    transaction_id,
    UPPER(TRIM(customer_name)) AS customer_name_clean,
    LOWER(TRIM(customer_email)) AS customer_email_clean,
    UPPER(TRIM(product_name)) AS product_category,
    quantity,
    unit_price,
    (quantity * unit_price) AS calculated_total_amount,
    transaction_date,
    DATE_TRUNC('DAY', transaction_date) AS sales_date
FROM ECOMMERCE_DB.RAW.raw_sales
WHERE transaction_id IS NOT NULL;


-- ==================
-- GOLD LAYER
-- ==================
-- Agregado de Faturamento por Produto
CREATE OR REPLACE VIEW ECOMMERCE_DB.GOLD.v_revenue_by_product AS
SELECT
    product_category,
    SUM(quantity) AS total_units_sold,
    SUM(calculated_total_amount) AS total_revenue,
    COUNT(DISTINCT transaction_id) AS total_transactions
FROM ECOMMERCE_DB.SILVER.v_sales_cleaned
GROUP BY product_category
ORDER BY total_revenue DESC;

-- Agregado de Comportamento do Cliente
CREATE OR REPLACE VIEW ECOMMERCE_DB.GOLD.v_customer_insights AS
SELECT
    customer_email_clean,
    customer_name_clean,
    COUNT(transaction_id) AS total_purchases,
    SUM(calculated_total_amount) AS ltv_revenue, -- Lifetime Value
    MAX(transaction_date) AS last_purchase_date
FROM ECOMMERCE_DB.SILVER.v_sales_cleaned
GROUP BY customer_email_clean, customer_name_clean
ORDER BY ltv_revenue DESC;
