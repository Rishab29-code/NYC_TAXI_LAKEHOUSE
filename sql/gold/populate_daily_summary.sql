INSERT INTO iceberg.nyc_taxi.gold_daily_summary
SELECT
    CAST(pickup_datetime AS DATE) AS pickup_date,
    COUNT(*) AS total_trips,

    COUNT_IF(is_missing_passenger_count) AS trips_with_missing_passenger_count,
    COUNT_IF(has_negative_fare) AS trips_with_negative_fare,
    COUNT_IF(has_negative_total) AS trips_with_negative_total,
    COUNT_IF(has_zero_distance) AS trips_with_zero_distance,
    COUNT_IF(has_invalid_trip_timing) AS trips_with_invalid_timing,

    SUM(trip_distance) AS total_distance,
    AVG(trip_distance) AS average_distance,
    AVG(trip_duration_minutes) AS average_duration_minutes,

    SUM(fare_amount) AS total_fare,
    SUM(tip_amount) AS total_tips,
    SUM(total_amount) AS total_revenue

FROM iceberg.nyc_taxi.silver_taxi_trips
WHERE pickup_datetime IS NOT NULL
GROUP BY CAST(pickup_datetime AS DATE);
