CREATE OR REPLACE VIEW vw_customer_rfm_segments AS
WITH reference_date AS (
    SELECT MAX(invoice_date)::date + 1 AS analysis_date
    FROM transaction_lines
    WHERE is_valid_sale_line = TRUE
),
customer_base AS (
    SELECT
        t.customer_id,
        MAX(t.invoice_date)::date AS last_purchase_date,
        COUNT(DISTINCT t.invoice_no) AS purchase_frequency,
        SUM(t.line_revenue) AS monetary_value_gbp,
        r.analysis_date - MAX(t.invoice_date)::date AS recency_days
    FROM transaction_lines t
    CROSS JOIN reference_date r
    WHERE t.is_valid_sale_line = TRUE
      AND t.customer_id IS NOT NULL
    GROUP BY t.customer_id, r.analysis_date
),
rfm_scores AS (
    SELECT
        *,
        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,
        NTILE(5) OVER (
            ORDER BY purchase_frequency ASC
        ) AS f_score,
        NTILE(5) OVER (
            ORDER BY monetary_value_gbp ASC
        ) AS m_score
    FROM customer_base
)
SELECT
    *,
    CASE
        WHEN r_score >= 4
         AND f_score >= 4
         AND m_score >= 4
            THEN 'High-Value Active'
        WHEN r_score >= 3
         AND f_score >= 4
            THEN 'Loyal Customer'
        WHEN r_score <= 2
         AND f_score >= 3
            THEN 'At-Risk Loyal'
        WHEN f_score = 1
            THEN 'Low-Frequency Customer'
        ELSE 'Regular Customer'
    END AS customer_segment
FROM rfm_scores;