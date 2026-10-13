
-- 1. Monthly sales performance view
CREATE OR REPLACE VIEW vw_monthly_sales AS
SELECT
    DATE_TRUNC('month', invoice_date)::DATE AS sales_month,
    COUNT(DISTINCT invoice_no) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(quantity) AS units_sold,
    ROUND(SUM(line_revenue), 2) AS gross_sales_gbp
FROM transaction_lines
WHERE is_valid_sale_line = TRUE
GROUP BY DATE_TRUNC('month', invoice_date);


-- 2. Country performance view
CREATE OR REPLACE VIEW vw_country_sales AS
SELECT
    country,
    COUNT(DISTINCT invoice_no) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(quantity) AS units_sold,
    ROUND(SUM(line_revenue), 2) AS gross_sales_gbp
FROM transaction_lines
WHERE is_valid_sale_line = TRUE
GROUP BY country;


-- 3. Product performance view
CREATE OR REPLACE VIEW vw_product_sales AS
SELECT
    stock_code,
    MAX(description) AS product_name,
    SUM(quantity) AS units_sold,
    COUNT(DISTINCT invoice_no) AS orders_containing_product,
    ROUND(SUM(line_revenue), 2) AS gross_sales_gbp
FROM transaction_lines
WHERE is_valid_sale_line = TRUE
GROUP BY stock_code;


-- 4. Customer-level metrics view
CREATE OR REPLACE VIEW vw_customer_metrics AS
SELECT
    customer_id,
    MAX(invoice_date)::DATE AS last_purchase_date,
    COUNT(DISTINCT invoice_no) AS frequency,
    ROUND(SUM(line_revenue), 2) AS monetary_value_gbp,
    (SELECT MAX(invoice_date)::DATE + 1 FROM transaction_lines)
        - MAX(invoice_date)::DATE AS recency_days
FROM transaction_lines
WHERE is_valid_sale_line = TRUE
  AND customer_id IS NOT NULL
GROUP BY customer_id;
