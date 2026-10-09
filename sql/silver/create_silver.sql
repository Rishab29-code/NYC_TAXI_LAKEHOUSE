-- Create the Silver Iceberg table if it does not exist.
-- This defines the schema; it does not populate the table.

CREATE TABLE IF NOT EXISTS iceberg.nyc_taxi.silver_taxi_trips (
    vendor_id INTEGER,
    pickup_datetime TIMESTAMP,
    dropoff_datetime TIMESTAMP,
    passenger_count INTEGER,
    trip_distance DOUBLE,
    rate_code_id INTEGER,
    store_and_fwd_flag VARCHAR,
    pickup_location_id INTEGER,
    dropoff_location_id INTEGER,
    payment_type INTEGER,
    fare_amount DECIMAL(12,2),
    extra DECIMAL(12,2),
    mta_tax DECIMAL(12,2),
    tip_amount DECIMAL(12,2),
    tolls_amount DECIMAL(12,2),
    improvement_surcharge DECIMAL(12,2),
    total_amount DECIMAL(12,2),
    congestion_surcharge DECIMAL(12,2),
    airport_fee DECIMAL(12,2),
    cbd_congestion_fee DECIMAL(12,2),

    trip_duration_minutes DOUBLE,

    is_missing_passenger_count BOOLEAN,
    has_negative_fare BOOLEAN,
    has_negative_total BOOLEAN,
    has_zero_distance BOOLEAN,
    has_invalid_trip_timing BOOLEAN,
    has_pickup_outside_january BOOLEAN,
    has_dropoff_outside_january BOOLEAN
)
WITH (
    location = 's3://nyc-taxi-lakehouse-rishab/iceberg/nyc_taxi/silver_taxi_trips',
    format = 'PARQUET'
);
