# NYC Taxi Open Lakehouse on AWS

An end-to-end data engineering project that ingests NYC TLC
yellow taxi trip data into an Apache Iceberg lakehouse on AWS S3,
queries it with Trino, and transforms raw records into a
quality-flagged Silver layer.

## Architecture

NYC TLC Parquet
    |
    v
AWS S3 - Raw source data
    |
    v
Python + PyArrow + PyIceberg
    |
    v
Apache Iceberg Bronze table on S3
    |
    v
Trino SQL transformations
    |
    v
Apache Iceberg Silver table on S3

The Iceberg REST catalog provides table metadata operations.
Trino is the SQL query engine. S3 stores the source data,
Iceberg metadata, and table data files.

## Technology Stack

- AWS S3: object storage
- Apache Iceberg: open table format and snapshots
- PyArrow: Parquet reading and Arrow data processing
- PyIceberg: Python Iceberg ingestion
- Iceberg REST catalog: catalog service
- Trino: SQL queries, transformations, and validation
- Python: ingestion orchestration

## Source Dataset

- Dataset: NYC TLC Yellow Taxi Trip Records
- Period: January 2025 source file
- Source format: Parquet
- Source location:
  s3://nyc-taxi-lakehouse-rishab/raw/yellow/yellow_tripdata_2025-01.parquet

## Data Layers

### Bronze

Table: iceberg.nyc_taxi.bronze_taxi_trips

- Preserves the source records in a typed Iceberg table.
- Stored as Parquet data files on S3.
- Loaded using Python, PyArrow, and PyIceberg.

### Silver

Table: iceberg.nyc_taxi.silver_taxi_trips

- Retains all Bronze rows.
- Adds trip duration in minutes.
- Adds flags for missing passenger counts, negative fares,
  negative totals, zero-distance trips, invalid trip timing,
  and timestamps outside January 2025.
- Preserves anomalous records rather than silently deleting them.

## Project Structure

.
├── load_bronze.py
├── README.md
└── sql
    ├── bronze
    │   └── validate_bronze.sql
    └── silver
        ├── create_silver.sql
        ├── transform_silver.sql
        └── validate_silver.sql

## Initial Validation Results

Source rows loaded: 3,475,226
Bronze rows: 3,475,226
Silver rows: 3,475,226
Exact duplicate groups: 0
Rows with missing passenger count: 540,149
Negative fares: 144,118
Negative totals: 63,037
Zero-distance trips: 90,893
Drop-off before pickup: 124

Additional timestamp-boundary checks identified records outside
January 2025. These records are flagged for review rather than
automatically removed.

## Running SQL

From the project root, with Trino running:

    ./trino-cli --server http://127.0.0.1:8080 \
      --file sql/bronze/validate_bronze.sql

    ./trino-cli --server http://127.0.0.1:8080 \
      --file sql/silver/validate_silver.sql

The Silver creation script is intended for initial setup.
The transformation script performs a one-time INSERT and must
not be rerun against an already-populated Silver table.

## Future Enhancements

- Automated data-quality assertions
- Gold analytical tables and business metrics
- dbt-managed SQL transformations
- Query performance and Iceberg maintenance
- Dashboard integration with Power BI
- Deployment and reproducibility improvements

## Data Integrity

Bronze remains unchanged by the Silver transformation.
Quality flags classify suspicious records without treating
every anomaly as invalid.
