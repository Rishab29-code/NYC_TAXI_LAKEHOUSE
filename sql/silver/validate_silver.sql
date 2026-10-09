-- Silver row-count and quality-flag validation.
-- Read-only: does not modify either table.

SELECT
    COUNT(*) AS total_rows,
    COUNT_IF(is_missing_passenger_count)
        AS missing_passenger_count,
    COUNT_IF(has_negative_fare) AS negative_fares,
    COUNT_IF(has_negative_total) AS negative_totals,
    COUNT_IF(has_zero_distance) AS zero_distance_trips,
    COUNT_IF(has_invalid_trip_timing) AS invalid_trip_timing,
    COUNT_IF(has_pickup_outside_january)
        AS pickups_outside_january,
    COUNT_IF(has_dropoff_outside_january)
        AS dropoffs_outside_january,
    COUNT_IF(trip_duration_minutes < 0)
        AS negative_durations,
    COUNT_IF(trip_duration_minutes IS NULL)
        AS null_durations
FROM iceberg.nyc_taxi.silver_taxi_trips;
