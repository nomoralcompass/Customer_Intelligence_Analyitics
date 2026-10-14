
-- 1. Monthly revenue performance
-- Uses valid sale lines only; excludes cancellations and invalid quantities/prices.

SELECT
    DATE_TRUNC('month', invoice_date)::DATE AS sales_month,
    COUNT(DISTINCT invoice_no) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(quantity) AS units_sold,
    ROUND(SUM(line_revenue), 2) AS gross_sales_gbp
FROM transaction_lines
WHERE is_valid_sale_line = TRUE
GROUP BY DATE_TRUNC('month', invoice_date)
ORDER BY sales_month;


-- 2. Top 10 products by gross sales value

SELECT
    stock_code,
    MAX(description) AS product_name,
    SUM(quantity) AS units_sold,
    COUNT(DISTINCT invoice_no) AS orders_containing_product,
    ROUND(SUM(line_revenue), 2) AS gross_sales_gbp
FROM transaction_lines
WHERE is_valid_sale_line = TRUE
GROUP BY stock_code
ORDER BY gross_sales_gbp DESC
LIMIT 10;


-- 3. Revenue by country

SELECT
    country,
    COUNT(DISTINCT invoice_no) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(quantity) AS units_sold,
    ROUND(SUM(line_revenue), 2) AS gross_sales_gbp
FROM transaction_lines
WHERE is_valid_sale_line = TRUE
GROUP BY country
ORDER BY gross_sales_gbp DESC;
