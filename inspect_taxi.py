import pandas as pd
from pathlib import Path

FILE = Path(__file__).resolve().with_name("yellow_tripdata_2025-01.parquet")
df = pd.read_parquet(FILE)

print("\n========== SHAPE ==========")
print(df.shape)

print("\n========== COLUMNS ==========")
for column in df.columns:
    print(column)

print("\n========== DATA TYPES ==========")
print(df.dtypes)

print("\n========== FIRST 5 ROWS ==========")
print(df.head())

print("\n========== NULL COUNTS ==========")
print(df.isnull().sum())

print("\n========== UNIQUE COUNTS ==========")
for column in df.columns:
    print(f"{column}: {df[column].nunique()}")

print("\n========== NUMERIC SUMMARY ==========")
print(df.describe().T)