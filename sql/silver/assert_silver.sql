-- 1. Bronze and Silver must contain the same number of rows. 
SELECT 'row_count_mismatch' AS failed_check 
WHERE ( 
    SELECT COUNT(*) FROM iceberg.nyc_taxi.silver_taxi_trips 
) <> ( 
    SELECT COUNT(*) FROM iceberg.nyc_taxi.bronze_taxi_trips 
) 
 
UNION ALL 
 
-- 2. Quality flags must never be NULL. 
SELECT 'null_quality_flags' 
WHERE ( 
    SELECT COUNT_IF( 
        is_missing_passenger_count IS NULL 
        OR has_negative_fare IS NULL 
        OR has_negative_total IS NULL 
        OR has_zero_distance IS NULL 
        OR has_invalid_trip_timing IS NULL 
        OR has_pickup_outside_january IS NULL 
        OR has_dropoff_outside_january IS NULL 
    ) 
    FROM iceberg.nyc_taxi.silver_taxi_trips 
) > 0 
 
UNION ALL 
 
-- 3. The invalid-timing flag must match the actual timestamps. 
SELECT 'timing_flag_mismatch' 
WHERE ( 
    SELECT COUNT_IF( 
        has_invalid_trip_timing IS DISTINCT FROM 
        (dropoff_datetime < pickup_datetime) 
    ) 
    FROM iceberg.nyc_taxi.silver_taxi_trips 
) > 0 
 
UNION ALL 
 
-- 4. The missing-passenger flag must match the source value. 
SELECT 'passenger_flag_mismatch' 
WHERE ( 
    SELECT COUNT_IF( 
        is_missing_passenger_count IS DISTINCT FROM 
        (passenger_count IS NULL) 
    ) 
    FROM iceberg.nyc_taxi.silver_taxi_trips 
) > 0 
 
UNION ALL 
 
-- 5. Negative-fare flags must match the fare values. 
SELECT 'fare_flag_mismatch' 
WHERE ( 
    SELECT COUNT_IF( 
        has_negative_fare IS DISTINCT FROM 
        (fare_amount < 0) 
    ) 
    FROM iceberg.nyc_taxi.silver_taxi_trips 
) > 0 
 
UNION ALL 
 
-- 6. Negative-total flags must match the total values. 
SELECT 'total_flag_mismatch' 
WHERE ( 
    SELECT COUNT_IF( 
        has_negative_total IS DISTINCT FROM 
        (total_amount < 0) 
    ) 
    FROM iceberg.nyc_taxi.silver_taxi_trips 
) > 0; 
