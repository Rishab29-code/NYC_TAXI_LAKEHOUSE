-- 1. Gold trip counts must reconcile to Silver.
SELECT 'trip_count_mismatch' AS failed_check
WHERE (
    SELECT COALESCE(SUM(total_trips), 0)
    FROM iceberg.nyc_taxi.gold_daily_summary
) <> (
    SELECT COUNT(*)
    FROM iceberg.nyc_taxi.silver_taxi_trips
    WHERE pickup_datetime IS NOT NULL
)

UNION ALL

-- 2. There must be exactly one row per pickup date.
SELECT 'duplicate_pickup_dates'
WHERE (
    SELECT COUNT(*) FROM iceberg.nyc_taxi.gold_daily_summary
) <> (
    SELECT COUNT(DISTINCT pickup_date)
    FROM iceberg.nyc_taxi.gold_daily_summary
)

UNION ALL

-- 3. Pickup dates must not be NULL.
SELECT 'null_pickup_dates'
WHERE (
    SELECT COUNT_IF(pickup_date IS NULL)
    FROM iceberg.nyc_taxi.gold_daily_summary
) > 0

UNION ALL

-- 4. Daily trip counts must be positive.
SELECT 'non_positive_daily_trip_counts'
WHERE (
    SELECT COUNT_IF(total_trips <= 0 OR total_trips IS NULL)
    FROM iceberg.nyc_taxi.gold_daily_summary
) > 0;
