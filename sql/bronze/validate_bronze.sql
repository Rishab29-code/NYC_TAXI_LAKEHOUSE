-- Bronze data-quality profile
-- Read-only: does not modify the table.

SELECT
    COUNT(*) AS total_rows,
    COUNT_IF(passenger_count IS NULL) AS null_passenger_count,
    COUNT_IF(fare_amount < 0) AS negative_fares,
    COUNT_IF(total_amount < 0) AS negative_totals,
    COUNT_IF(trip_distance = 0) AS zero_distance_trips,
    COUNT_IF(dropoff_datetime < pickup_datetime)
        AS invalid_trip_timing,
    COUNT_IF(
        pickup_datetime < TIMESTAMP '2025-01-01 00:00:00'
        OR pickup_datetime >= TIMESTAMP '2025-02-01 00:00:00'
    ) AS pickups_outside_january,
    COUNT_IF(
        dropoff_datetime < TIMESTAMP '2025-01-01 00:00:00'
        OR dropoff_datetime >= TIMESTAMP '2025-02-01 00:00:00'
    ) AS dropoffs_outside_january
FROM iceberg.nyc_taxi.bronze_taxi_trips;
