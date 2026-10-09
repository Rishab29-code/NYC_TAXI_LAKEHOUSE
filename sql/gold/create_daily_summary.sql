CREATE TABLE IF NOT EXISTS iceberg.nyc_taxi.gold_daily_summary (
    pickup_date DATE,
    total_trips BIGINT,
    trips_with_missing_passenger_count BIGINT,
    trips_with_negative_fare BIGINT,
    trips_with_negative_total BIGINT,
    trips_with_zero_distance BIGINT,
    trips_with_invalid_timing BIGINT,
    total_distance DOUBLE,
    average_distance DOUBLE,
    average_duration_minutes DOUBLE,
    total_fare DECIMAL(18, 2),
    total_tips DECIMAL(18, 2),
    total_revenue DECIMAL(18, 2)
)
WITH (
    location = 's3://nyc-taxi-lakehouse-rishab/iceberg/nyc_taxi/gold_daily_summary',
    format = 'PARQUET'
);
