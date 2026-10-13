
CREATE TABLE transaction_lines (
    invoice_no VARCHAR(20),
    stock_code VARCHAR(50),
    description TEXT,
    quantity INTEGER NOT NULL,
    invoice_date TIMESTAMP NOT NULL,
    unit_price NUMERIC(12, 4) NOT NULL,
    customer_id BIGINT,
    country VARCHAR(100),
    is_cancellation BOOLEAN NOT NULL,
    has_nonpositive_quantity BOOLEAN NOT NULL,
    has_nonpositive_price BOOLEAN NOT NULL,
    has_missing_customer_id BOOLEAN NOT NULL,
    has_missing_description BOOLEAN NOT NULL,
    line_revenue NUMERIC(14, 4) NOT NULL,
    is_valid_sale_line BOOLEAN NOT NULL
);
