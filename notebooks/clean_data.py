
from pathlib import Path

import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parent.parent
INPUT_FILE = PROJECT_ROOT / "data" / "Online Retail.xlsx"
OUTPUT_DIR = PROJECT_ROOT / "data" / "processed"
OUTPUT_FILE = OUTPUT_DIR / "transactions_cleaned.csv"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# 1. Load raw data
df = pd.read_excel(INPUT_FILE)
original_rows = len(df)

# 2. Remove exact duplicate rows from the analytical copy
duplicate_count = int(df.duplicated().sum())
df = df.drop_duplicates().copy()

# 3. Correct the customer ID data type
df["CustomerID"] = pd.to_numeric(
    df["CustomerID"], errors="coerce"
).astype("Int64")

# 4. Flag records for transparent analysis
df["IsCancellation"] = (
    df["InvoiceNo"].astype(str).str.startswith("C")
)

df["HasNonPositiveQuantity"] = df["Quantity"] <= 0
df["HasNonPositivePrice"] = df["UnitPrice"] <= 0
df["HasMissingCustomerID"] = df["CustomerID"].isna()
df["HasMissingDescription"] = df["Description"].isna()

# 5. Calculate line revenue for the full cleaned dataset
df["LineRevenue"] = df["Quantity"] * df["UnitPrice"]

# 6. Identify standard sale lines
df["IsValidSaleLine"] = (
    ~df["IsCancellation"]
    & (df["Quantity"] > 0)
    & (df["UnitPrice"] > 0)
)

# 7. Save all deduplicated records with flags.
# Do not discard returns, cancellations or unidentified customers.
df.to_csv(OUTPUT_FILE, index=False)

# 8. Print a cleaning report
sales = df.loc[df["IsValidSaleLine"]]

print("\n--- CLEANING REPORT ---")
print(f"Original rows: {original_rows:,}")
print(f"Exact duplicates removed: {duplicate_count:,}")
print(f"Rows after deduplication: {len(df):,}")
print(f"Standard sale lines: {len(sales):,}")
print(f"Cancellation records: {df['IsCancellation'].sum():,}")
print(
    "Non-positive quantity records: "
    f"{df['HasNonPositiveQuantity'].sum():,}"
)
print(
    "Non-positive price records: "
    f"{df['HasNonPositivePrice'].sum():,}"
)
print(
    "Missing customer IDs: "
    f"{df['HasMissingCustomerID'].sum():,}"
)
print(f"Missing descriptions: {df['HasMissingDescription'].sum():,}")

print("\n--- STANDARD SALES SUMMARY ---")
print(f"Unique invoices: {sales['InvoiceNo'].nunique():,}")
print(f"Identified customers: {sales['CustomerID'].nunique():,}")
print(f"Units sold: {sales['Quantity'].sum():,}")
print(f"Sales value: {sales['LineRevenue'].sum():,.2f}")

print(f"\nSaved cleaned data to: {OUTPUT_FILE}")
