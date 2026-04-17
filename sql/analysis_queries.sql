-- Uber Trip Analysis SQL
-- we have loaded the cleaned file `uber_trip_analysis_cleaned.csv`
-- into a SQL table named `uber_trip_analysis`.

-- columns:
-- start_date TIMESTAMP
-- end_date TIMESTAMP
-- category TEXT
-- start TEXT
-- stop TEXT
-- miles NUMERIC
-- purpose TEXT
-- duration_min NUMERIC
-- month_num INT
-- month TEXT
-- weekday TEXT
-- hour INT
-- trip_type TEXT
-- distance_band TEXT
-- avg_speed_mph NUMERIC

-- 1) Overall KPI summary
SELECT
    COUNT(*) AS total_trips,
    ROUND(SUM(miles), 1) AS total_miles,
    ROUND(SUM(duration_min) / 60.0, 1) AS total_hours,
    ROUND(AVG(miles), 2) AS avg_trip_miles,
    ROUND(AVG(duration_min), 2) AS avg_trip_duration_min
FROM uber_trip_analysis;

-- 2) Business vs personal trip mix
SELECT
    category,
    COUNT(*) AS trips,
    ROUND(SUM(miles), 1) AS total_miles,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS trip_share_pct
FROM uber_trip_analysis
GROUP BY category
ORDER BY trips DESC;

-- 3) Monthly trip volume and distance
SELECT
    month_num,
    month,
    COUNT(*) AS trips,
    ROUND(SUM(miles), 1) AS total_miles,
    ROUND(AVG(miles), 2) AS avg_miles_per_trip
FROM uber_trip_analysis
GROUP BY month_num, month
ORDER BY month_num;

-- 4) Weekday analysis
SELECT
    weekday,
    COUNT(*) AS trips,
    ROUND(SUM(miles), 1) AS total_miles
FROM uber_trip_analysis
GROUP BY weekday
ORDER BY trips DESC;

-- 5) Hourly pattern
SELECT
    hour,
    COUNT(*) AS trips,
    ROUND(SUM(miles), 1) AS total_miles
FROM uber_trip_analysis
GROUP BY hour
ORDER BY hour;

-- 6) Purpose analysis
SELECT
    purpose,
    COUNT(*) AS trips,
    ROUND(SUM(miles), 1) AS total_miles,
    ROUND(AVG(miles), 2) AS avg_miles_per_trip
FROM uber_trip_analysis
GROUP BY purpose
ORDER BY trips DESC, total_miles DESC;

-- 7) Top start locations
SELECT
    start,
    COUNT(*) AS trips
FROM uber_trip_analysis
GROUP BY start
ORDER BY trips DESC
LIMIT 10;

-- 8) Top routes by trip count
SELECT
    start,
    stop,
    COUNT(*) AS trips,
    ROUND(SUM(miles), 1) AS total_miles
FROM uber_trip_analysis
GROUP BY start, stop
ORDER BY trips DESC, total_miles DESC
LIMIT 10;

-- 9) Distance band distribution
SELECT
    distance_band,
    COUNT(*) AS trips
FROM uber_trip_analysis
GROUP BY distance_band
ORDER BY trips DESC;

-- 10) Speed summary (exclude zero or null durations if needed)
SELECT
    ROUND(AVG(avg_speed_mph), 2) AS avg_speed_mph,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_speed_mph), 2) AS median_speed_mph
FROM uber_trip_analysis
WHERE avg_speed_mph IS NOT NULL;

-- 11) Longest trips
SELECT
    start_date,
    start,
    stop,
    category,
    purpose,
    miles,
    duration_min
FROM uber_trip_analysis
ORDER BY miles DESC
LIMIT 10;

-- 12) Data-quality audit
SELECT
    SUM(CASE WHEN purpose = 'Unknown' THEN 1 ELSE 0 END) AS unknown_purpose_rows,
    SUM(CASE WHEN start = 'Unknown Location' OR stop = 'Unknown Location' THEN 1 ELSE 0 END) AS unknown_location_rows,
    SUM(CASE WHEN duration_min <= 0 THEN 1 ELSE 0 END) AS zero_or_negative_duration_rows
FROM uber_trip_analysis;
