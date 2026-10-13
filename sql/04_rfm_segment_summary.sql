
-- RFM customer segment summary

WITH customer_metrics AS (
    SELECT
        customer_id,
        MAX(invoice_date)::DATE AS last_purchase_date,
        COUNT(DISTINCT invoice_no) AS frequency,
        SUM(line_revenue) AS monetary_value
    FROM transaction_lines
    WHERE is_valid_sale_line = TRUE
      AND customer_id IS NOT NULL
    GROUP BY customer_id
),
reference_date AS (
    SELECT MAX(invoice_date)::DATE + 1 AS analysis_date
    FROM transaction_lines
),
rfm AS (
    SELECT
        cm.customer_id,
        (rd.analysis_date - cm.last_purchase_date) AS recency_days,
        cm.frequency,
        cm.monetary_value
    FROM customer_metrics cm
    CROSS JOIN reference_date rd
),
scored AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary_value ASC) AS monetary_score
    FROM rfm
),
segmented AS (
    SELECT
        *,
        CASE
            WHEN recency_score >= 4
             AND frequency_score >= 4
             AND monetary_score >= 4
                THEN 'High-Value Active'
            WHEN recency_score >= 3
             AND frequency_score >= 4
                THEN 'Loyal Customer'
            WHEN recency_score <= 2
             AND frequency_score >= 3
                THEN 'At-Risk Loyal'
            WHEN frequency_score = 1
                THEN 'Low-Frequency Customer'
            ELSE 'Regular Customer'
        END AS customer_segment
    FROM scored
)
SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(SUM(monetary_value), 2) AS gross_sales_gbp,
    ROUND(AVG(monetary_value), 2) AS avg_customer_sales_gbp,
    ROUND(AVG(recency_days), 1) AS avg_recency_days,
    ROUND(AVG(frequency), 2) AS avg_orders_per_customer
FROM segmented
GROUP BY customer_segment
ORDER BY gross_sales_gbp DESC;
