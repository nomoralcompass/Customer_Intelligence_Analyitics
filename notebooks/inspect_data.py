
from pathlib import Path

import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parent.parent
DATA_FILE = PROJECT_ROOT / "data" / "Online Retail.xlsx"

df = pd.read_excel(DATA_FILE)

print("\n--- DATASET SHAPE ---")
print(f"Rows: {df.shape[0]:,}")
print(f"Columns: {df.shape[1]}")

print("\n--- COLUMN NAMES ---")
print(df.columns.tolist())

print("\n--- DATA TYPES ---")
print(df.dtypes)

print("\n--- FIRST FIVE ROWS ---")
print(df.head().to_string())

print("\n--- MISSING VALUES ---")
print(df.isna().sum().sort_values(ascending=False))

print("\n--- DUPLICATE ROWS ---")
print(df.duplicated().sum())

print("\n--- NUMERIC SUMMARY ---")
print(df[["Quantity", "UnitPrice"]].describe())

print("\n--- INVOICE DATE RANGE ---")
print(
    f"From {df['InvoiceDate'].min()} "
    f"to {df['InvoiceDate'].max()}"
)

print("\n--- CANCELLED INVOICES ---")
print(df["InvoiceNo"].astype(str).str.startswith("C").sum())

print("\n--- NON-POSITIVE QUANTITIES ---")
print((df["Quantity"] <= 0).sum())

print("\n--- NON-POSITIVE PRICES ---")
print((df["UnitPrice"] <= 0).sum())

print("\n--- CUSTOMER COUNT ---")
print(df["CustomerID"].nunique())

print("\n--- COUNTRIES ---")
print(df["Country"].nunique())
