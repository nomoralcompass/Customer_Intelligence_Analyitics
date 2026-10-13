
from getpass import getpass
from pathlib import Path

import pandas as pd
from sqlalchemy import (
    Boolean, BigInteger, Integer, Numeric, Text, VARCHAR,
    TIMESTAMP, create_engine, text
)
from sqlalchemy.engine import URL

ROOT = Path(__file__).resolve().parent.parent
CSV_FILE = ROOT / "data" / "processed" / "transactions_cleaned.csv"

if not CSV_FILE.exists():
    raise FileNotFoundError(f"Missing cleaned CSV: {CSV_FILE}")

password = getpass("PostgreSQL password for user postgres: ")

url = URL.create(
    drivername="postgresql+psycopg",
    username="postgres",
    password=password,
    host="localhost",
    port=5432,
    database="customer_intelligence",
)

engine = create_engine(url)

# Map CSV column names to SQL-friendly names.
df = pd.read_csv(CSV_FILE)

df = df.rename(columns={
    "InvoiceNo": "invoice_no",
    "StockCode": "stock_code",
    "Description": "description",
    "Quantity": "quantity",
    "InvoiceDate": "invoice_date",
    "UnitPrice": "unit_price",
    "CustomerID": "customer_id",
    "Country": "country",
    "IsCancellation": "is_cancellation",
    "HasNonPositiveQuantity": "has_nonpositive_quantity",
    "HasNonPositivePrice": "has_nonpositive_price",
    "HasMissingCustomerID": "has_missing_customer_id",
    "HasMissingDescription": "has_missing_description",
    "LineRevenue": "line_revenue",
    "IsValidSaleLine": "is_valid_sale_line",
})

df["customer_id"] = df["customer_id"].astype("Int64")
df["invoice_date"] = pd.to_datetime(df["invoice_date"])

column_types = {
    "invoice_no": VARCHAR(20),
    "stock_code": VARCHAR(50),
    "description": Text(),
    "quantity": Integer(),
    "invoice_date": TIMESTAMP(),
    "unit_price": Numeric(12, 4),
    "customer_id": BigInteger(),
    "country": VARCHAR(100),
    "is_cancellation": Boolean(),
    "has_nonpositive_quantity": Boolean(),
    "has_nonpositive_price": Boolean(),
    "has_missing_customer_id": Boolean(),
    "has_missing_description": Boolean(),
    "line_revenue": Numeric(14, 4),
    "is_valid_sale_line": Boolean(),
}

# Prevent accidental replacement of an existing table.
with engine.connect() as conn:
    exists = conn.execute(text("""
        SELECT EXISTS (
            SELECT 1
            FROM information_schema.tables
            WHERE table_schema = 'public'
              AND table_name = 'transaction_lines'
        )
    """)).scalar_one()

if exists:
    raise RuntimeError(
        "transaction_lines already exists. "
        "Inspect it before attempting another import."
    )

try:
    df.to_sql(
        "transaction_lines",
        engine,
        if_exists="fail",
        index=False,
        chunksize=5000,
        dtype=column_types,
    )

    with engine.connect() as conn:
        count = conn.execute(
            text("SELECT COUNT(*) FROM transaction_lines")
        ).scalar_one()

    print(f"Successfully imported {count:,} rows.")

except Exception:
    # If an import fails partway through, remove the incomplete table.
    # This script only creates the table when it did not exist before.
    with engine.begin() as conn:
        conn.execute(text("DROP TABLE IF EXISTS transaction_lines"))
    raise

finally:
    engine.dispose()
