import pyarrow as pa
import pyarrow.parquet as pq

from pyiceberg.catalog import load_catalog


# ============================================================
# Configuration
# ============================================================

SOURCE_FILE = (
    "s3://nyc-taxi-lakehouse-rishab/"
    "raw/yellow/yellow_tripdata_2025-01.parquet"
)

CATALOG_URI = "http://127.0.0.1:8181"

NAMESPACE = "nyc_taxi"
TABLE_NAME = "bronze_taxi_trips"


# ============================================================
# Source → Bronze column mapping
# ============================================================

COLUMN_MAPPING = {
    "VendorID": "vendor_id",
    "tpep_pickup_datetime": "pickup_datetime",
    "tpep_dropoff_datetime": "dropoff_datetime",
    "passenger_count": "passenger_count",
    "trip_distance": "trip_distance",
    "RatecodeID": "rate_code_id",
    "store_and_fwd_flag": "store_and_fwd_flag",
    "PULocationID": "pickup_location_id",
    "DOLocationID": "dropoff_location_id",
    "payment_type": "payment_type",
    "fare_amount": "fare_amount",
    "extra": "extra",
    "mta_tax": "mta_tax",
    "tip_amount": "tip_amount",
    "tolls_amount": "tolls_amount",
    "improvement_surcharge": "improvement_surcharge",
    "total_amount": "total_amount",
    "congestion_surcharge": "congestion_surcharge",
    "Airport_fee": "airport_fee",
    "cbd_congestion_fee": "cbd_congestion_fee",
}


TARGET_COLUMNS = [
    "vendor_id",
    "pickup_datetime",
    "dropoff_datetime",
    "passenger_count",
    "trip_distance",
    "rate_code_id",
    "store_and_fwd_flag",
    "pickup_location_id",
    "dropoff_location_id",
    "payment_type",
    "fare_amount",
    "extra",
    "mta_tax",
    "tip_amount",
    "tolls_amount",
    "improvement_surcharge",
    "total_amount",
    "congestion_surcharge",
    "airport_fee",
    "cbd_congestion_fee",
]


# ============================================================
# Load source
# ============================================================

print("Reading source Parquet...")

source_table = pq.read_table(SOURCE_FILE)

print(f"Source rows: {source_table.num_rows:,}")
print(f"Source columns: {source_table.num_columns}")


# ============================================================
# Rename columns
# ============================================================

print("Renaming columns...")

source_table = source_table.rename_columns(
    [
        COLUMN_MAPPING[column]
        for column in source_table.column_names
    ]
)


# ============================================================
# Cast to Bronze schema
# ============================================================

print("Casting columns...")

decimal_type = pa.decimal128(12, 2)

cast_types = {
    "vendor_id": pa.int32(),
    "pickup_datetime": pa.timestamp("us"),
    "dropoff_datetime": pa.timestamp("us"),
    "passenger_count": pa.int32(),
    "trip_distance": pa.float64(),
    "rate_code_id": pa.int32(),
    "store_and_fwd_flag": pa.string(),
    "pickup_location_id": pa.int32(),
    "dropoff_location_id": pa.int32(),
    "payment_type": pa.int32(),
    "fare_amount": decimal_type,
    "extra": decimal_type,
    "mta_tax": decimal_type,
    "tip_amount": decimal_type,
    "tolls_amount": decimal_type,
    "improvement_surcharge": decimal_type,
    "total_amount": decimal_type,
    "congestion_surcharge": decimal_type,
    "airport_fee": decimal_type,
    "cbd_congestion_fee": decimal_type,
}


arrays = []

for column in TARGET_COLUMNS:
    print(f"  {column}")
    arrays.append(
        source_table[column].cast(cast_types[column])
    )


bronze_arrow_table = pa.Table.from_arrays(
    arrays,
    names=TARGET_COLUMNS,
)

print("\nBronze Arrow schema:")
print(bronze_arrow_table.schema)


# ============================================================
# Connect to Iceberg REST Catalog
# ============================================================

print("\nConnecting to Iceberg REST catalog...")

catalog = load_catalog(
    "nyc_taxi",
    type="rest",
    uri=CATALOG_URI,
    **{
        "s3.region": "ap-southeast-2",
        "s3.endpoint": "https://s3.ap-southeast-2.amazonaws.com",
    },
)


# ============================================================
# Load Bronze table
# ============================================================

print("Loading Bronze Iceberg table...")

bronze_table = catalog.load_table(
    (NAMESPACE, TABLE_NAME)
)

print("Table loaded.")


# ============================================================
# Check existing snapshots
# ============================================================


print("Checking whether Bronze already contains data...")

existing_rows = bronze_table.scan(
    selected_fields=(),
).to_arrow().num_rows

print(f"Existing rows: {existing_rows:,}")

if existing_rows > 0:
    print("Bronze table already contains data.")
    print("Stopping to prevent duplicate ingestion.")
    raise SystemExit(0)

print(f"Appending {bronze_arrow_table.num_rows:,} rows to Bronze...")
bronze_table.append(bronze_arrow_table)

print("Append finished. Verifying row count...")

from pyiceberg.expressions import AlwaysTrue

bronze_table.refresh()

actual_rows = sum(
    batch.num_rows
    for batch in bronze_table.scan(
        row_filter=AlwaysTrue(),
        selected_fields=("vendor_id",),
    ).to_arrow_batch_reader()
)

print(f"Rows after append: {actual_rows:,}")

if actual_rows != bronze_arrow_table.num_rows:
    raise RuntimeError(
        f"Row-count verification failed: expected "
        f"{bronze_arrow_table.num_rows:,}, found {actual_rows:,}"
    )

print("Bronze ingestion completed and verified successfully.")