-- ONE-TIME LOAD: do not rerun against an already-populated table.
-- Copies all Bronze rows and derives Silver quality flags.

INSERT INTO iceberg.nyc_taxi.silver_taxi_trips
SELECT
    vendor_id,
    pickup_datetime,
    dropoff_datetime,
    passenger_count,
    trip_distance,
    rate_code_id,
    store_and_fwd_flag,
    pickup_location_id,
    dropoff_location_id,
    payment_type,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount,
    congestion_surcharge,
    airport_fee,
    cbd_congestion_fee,

    date_diff(
        'millisecond',
        pickup_datetime,
        dropoff_datetime
    ) / 60000.0 AS trip_duration_minutes,

    passenger_count IS NULL AS is_missing_passenger_count,
    fare_amount < 0 AS has_negative_fare,
    total_amount < 0 AS has_negative_total,
    trip_distance = 0 AS has_zero_distance,

    dropoff_datetime < pickup_datetime
        AS has_invalid_trip_timing,

    pickup_datetime < TIMESTAMP '2025-01-01 00:00:00'
        OR pickup_datetime >= TIMESTAMP '2025-02-01 00:00:00'
        AS has_pickup_outside_january,

    dropoff_datetime < TIMESTAMP '2025-01-01 00:00:00'
        OR dropoff_datetime >= TIMESTAMP '2025-02-01 00:00:00'
        AS has_dropoff_outside_january

FROM iceberg.nyc_taxi.bronze_taxi_trips;
