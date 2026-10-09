# NYC Taxi Lakehouse — Operations Runbook

## 1. Architecture

- S3 raw/ stores the original NYC TLC Parquet dataset.
- PyArrow and PyIceberg handle Python ingestion into Iceberg.
- The Iceberg REST catalog provides table metadata operations.
- S3 iceberg/ stores Iceberg data files and metadata.
- Trino executes SQL transformations and validations.
- Bronze stores typed source records.
- Silver adds trip durations and data-quality flags.
- Gold stores daily analytical aggregates.

AWS region: ap-southeast-2

## 2. Prerequisites

- WSL, Python, and the project virtual environment
- Docker Desktop integrated with WSL
- AWS CLI configured for the project S3 bucket
- Trino installed locally
- Trino CLI in the project root

Never commit AWS credentials, local environment files, the
virtual environment, downloaded executables, or source datasets.

## 3. Start the services

Run these commands individually in your terminal.

Start the Iceberg REST catalog:

    docker start iceberg-rest

Verify the catalog:

    curl -fsS http://127.0.0.1:8181/v1/config

Start Trino:

    cd /mnt/c/Work/nyc-taxi-lakehouse/trino
    ./bin/launcher start

Verify Trino:

    curl -fsS http://127.0.0.1:8080/v1/info

Connect to Trino:

    cd /mnt/c/Work/nyc-taxi-lakehouse
    ./trino-cli --server http://127.0.0.1:8080

Use 127.0.0.1 for the Trino CLI connection.

## 4. Validate existing data

From the project root, run:

    ./trino-cli --server http://127.0.0.1:8080 --file sql/bronze/validate_bronze.sql

    ./trino-cli --server http://127.0.0.1:8080 --file sql/silver/validate_silver.sql

    ./trino-cli --server http://127.0.0.1:8080 --file sql/silver/assert_silver.sql

    ./trino-cli --server http://127.0.0.1:8080 --file sql/gold/validate_daily_summary.sql

Assertion scripts return no failed-check rows when their checks pass.
Profile scripts report metrics for inspection.

## 5. Table setup and transformations

### Bronze

load_bronze.py reads the raw Parquet source and appends records
to Bronze. Do not rerun ingestion against an already populated
table unless an idempotent load or intentional rebuild is planned.

### Silver

- create_silver.sql creates the table if it does not exist.
- transform_silver.sql performs the Silver INSERT.
- validate_silver.sql profiles the result.
- assert_silver.sql checks integrity.

The current Silver transformation is a one-time INSERT.
Do not rerun it against populated Silver data.

### Gold

- create_daily_summary.sql creates the Gold table if needed.
- populate_daily_summary.sql inserts daily aggregates.
- validate_daily_summary.sql checks the result.

The current Gold population is a one-time INSERT.
Do not rerun it against populated Gold data.

CREATE TABLE IF NOT EXISTS does not repair an existing schema.

## 6. Data quality

- Bronze preserves typed source records.
- Silver flags anomalies rather than silently deleting records.
- Gold aggregates trips by pickup date.
- The source includes pickup timestamps outside January 2025.
- Negative fares, negative totals, missing passenger counts,
  zero-distance trips, and invalid timing require interpretation.
- Compare row counts and quality flags before and after changes.

## 7. Git workflow

From the project root:

    git status
    git add README.md docs/ sql/
    git diff --cached --stat
    git commit -m "Add lakehouse operations runbook"
    git push

Review staged changes before committing. Never stage credentials,
local datasets, or downloaded runtime files.

## 8. Recovery

If a service is unavailable, check its status and logs before
rerunning ingestion or transformations.

Do not drop Iceberg tables or delete S3 table paths as routine
troubleshooting. Metadata and snapshots may be needed for recovery.

Before rebuilding a layer, verify row counts, target table,
S3 location, and how existing data will be handled.

## 9. Verified baseline

- Source records: 3,475,226
- Bronze records: 3,475,226
- Silver records: 3,475,226
- Gold daily summary rows: 33
- Gold aggregated trip count: 3,475,226
- Silver integrity assertions: passed
- Gold validation assertions: passed
