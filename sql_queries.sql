
-- ============================================================
-- Airline Delay Analysis (2003–2022)
-- SQL Queries
-- Tool: SQLite / DB Browser for SQLite
-- Dataset table: Airline_Delay_Cause
-- Cleaned table: Airline_Delay_Clean
-- ============================================================


-- ============================================================
-- PHASE 1: EXPLORATORY DATA ANALYSIS
-- ============================================================

-- Query 1: Count total records
SELECT COUNT(*) AS total_rows
FROM Airline_Delay_Cause;


-- Query 2: Identify dataset year range
SELECT  
    MIN(year) AS first_year,
    MAX(year) AS last_year
FROM Airline_Delay_Cause;


-- Query 3: Count distinct airlines
SELECT COUNT(DISTINCT carrier_name) AS airlines
FROM Airline_Delay_Cause;


-- Query 4: Count distinct airports
SELECT COUNT(DISTINCT airport) AS airports
FROM Airline_Delay_Cause;


-- Query 5: Total delay minutes by airline
SELECT 
    carrier_name,
    SUM(arr_delay) AS total_delay_minutes
FROM Airline_Delay_Cause
GROUP BY carrier_name
ORDER BY total_delay_minutes DESC
LIMIT 10;


-- Query 6: Average delay minutes per flight by airline
SELECT
    carrier_name,
    SUM(arr_delay) AS total_delay_minutes,
    SUM(arr_flights) AS total_flights,
    ROUND(SUM(arr_delay) * 1.0 / SUM(arr_flights), 2) AS delay_minutes_per_flight
FROM Airline_Delay_Cause
WHERE carrier_name IS NOT NULL
GROUP BY carrier_name
HAVING SUM(arr_flights) > 100000
ORDER BY delay_minutes_per_flight DESC
LIMIT 10;


-- Query 7: Initial delay cause totals
SELECT 
    SUM(carrier_delay) AS carrier_delay,
    SUM(weather_delay) AS weather_delay,
    SUM(nas_delay) AS nas_delay,
    SUM(security_delay) AS security_delay,
    SUM(late_aircraft_delay) AS late_aircraft_delay
FROM Airline_Delay_Cause;



-- ============================================================
-- PHASE 2: DATA QUALITY CHECKS
-- ============================================================

-- Query 8: Check missing carrier names
SELECT COUNT(*) AS missing_carrier_names
FROM Airline_Delay_Cause
WHERE carrier_name IS NULL;


-- Query 9: Inspect missing carrier records
SELECT *
FROM Airline_Delay_Cause
WHERE carrier_name IS NULL;


-- Query 10: Full null audit across key columns
SELECT
    SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS year_nulls,
    SUM(CASE WHEN month IS NULL THEN 1 ELSE 0 END) AS month_nulls,
    SUM(CASE WHEN carrier IS NULL THEN 1 ELSE 0 END) AS carrier_nulls,
    SUM(CASE WHEN carrier_name IS NULL THEN 1 ELSE 0 END) AS carrier_name_nulls,
    SUM(CASE WHEN airport IS NULL THEN 1 ELSE 0 END) AS airport_nulls,
    SUM(CASE WHEN airport_name IS NULL THEN 1 ELSE 0 END) AS airport_name_nulls,
    SUM(CASE WHEN arr_flights IS NULL THEN 1 ELSE 0 END) AS arr_flights_nulls,
    SUM(CASE WHEN arr_del15 IS NULL THEN 1 ELSE 0 END) AS arr_del15_nulls,
    SUM(CASE WHEN arr_cancelled IS NULL THEN 1 ELSE 0 END) AS arr_cancelled_nulls,
    SUM(CASE WHEN arr_diverted IS NULL THEN 1 ELSE 0 END) AS arr_diverted_nulls,
    SUM(CASE WHEN arr_delay IS NULL THEN 1 ELSE 0 END) AS arr_delay_nulls,
    SUM(CASE WHEN carrier_delay IS NULL THEN 1 ELSE 0 END) AS carrier_delay_nulls,
    SUM(CASE WHEN weather_delay IS NULL THEN 1 ELSE 0 END) AS weather_delay_nulls,
    SUM(CASE WHEN nas_delay IS NULL THEN 1 ELSE 0 END) AS nas_delay_nulls,
    SUM(CASE WHEN security_delay IS NULL THEN 1 ELSE 0 END) AS security_delay_nulls,
    SUM(CASE WHEN late_aircraft_delay IS NULL THEN 1 ELSE 0 END) AS late_aircraft_delay_nulls
FROM Airline_Delay_Cause;


-- Query 11: Count rows with missing key values
SELECT COUNT(*) AS rows_with_missing_values
FROM Airline_Delay_Cause
WHERE carrier_name IS NULL
   OR airport IS NULL
   OR airport_name IS NULL
   OR arr_flights IS NULL
   OR arr_del15 IS NULL
   OR arr_cancelled IS NULL
   OR arr_diverted IS NULL
   OR arr_delay IS NULL
   OR carrier_delay IS NULL
   OR weather_delay IS NULL
   OR nas_delay IS NULL
   OR security_delay IS NULL
   OR late_aircraft_delay IS NULL;


-- Query 12: Inspect rows with missing key values
SELECT *
FROM Airline_Delay_Cause
WHERE carrier_name IS NULL
   OR airport IS NULL
   OR airport_name IS NULL
   OR arr_flights IS NULL
   OR arr_del15 IS NULL
   OR arr_cancelled IS NULL
   OR arr_diverted IS NULL
   OR arr_delay IS NULL
   OR carrier_delay IS NULL
   OR weather_delay IS NULL
   OR nas_delay IS NULL
   OR security_delay IS NULL
   OR late_aircraft_delay IS NULL;


-- Query 13: Check for duplicate airline-airport-month records
SELECT
    year,
    month,
    carrier,
    carrier_name,
    airport,
    airport_name,
    COUNT(*) AS duplicate_count
FROM Airline_Delay_Cause
GROUP BY
    year,
    month,
    carrier,
    carrier_name,
    airport,
    airport_name
HAVING COUNT(*) > 1;


-- Query 14: Validate month and year ranges
SELECT
    MIN(month) AS min_month,
    MAX(month) AS max_month,
    MIN(year) AS min_year,
    MAX(year) AS max_year
FROM Airline_Delay_Cause;



-- ============================================================
-- PHASE 3: DATA CLEANING
-- ============================================================

-- Query 15: Review airport records needing code repair
SELECT DISTINCT airport, airport_name
FROM Airline_Delay_Cause
WHERE airport_name IN (
    'Phoenix, AZ: Phoenix Sky Harbor International',
    'Pittsburgh, PA: Pittsburgh International',
    'Petersburg, AK: Petersburg James A Johnson'
);


-- Query 16: Repair missing airport codes
UPDATE Airline_Delay_Cause
SET airport = CASE
    WHEN airport_name = 'Phoenix, AZ: Phoenix Sky Harbor International' THEN 'PHX'
    WHEN airport_name = 'Pittsburgh, PA: Pittsburgh International' THEN 'PIT'
    WHEN airport_name = 'Petersburg, AK: Petersburg James A Johnson' THEN 'PSG'
END
WHERE airport IS NULL;


-- Query 17: Verify airport code repair
SELECT DISTINCT airport, airport_name
FROM Airline_Delay_Cause
WHERE airport_name IN (
    'Phoenix, AZ: Phoenix Sky Harbor International',
    'Pittsburgh, PA: Pittsburgh International',
    'Petersburg, AK: Petersburg James A Johnson'
);


-- Query 18: Create cleaned analysis table
CREATE TABLE Airline_Delay_Clean AS
SELECT *
FROM Airline_Delay_Cause
WHERE carrier_name IS NOT NULL
  AND airport IS NOT NULL
  AND airport_name IS NOT NULL
  AND arr_flights IS NOT NULL
  AND arr_del15 IS NOT NULL
  AND arr_cancelled IS NOT NULL
  AND arr_diverted IS NOT NULL
  AND arr_delay IS NOT NULL
  AND carrier_delay IS NOT NULL
  AND weather_delay IS NOT NULL
  AND nas_delay IS NOT NULL
  AND security_delay IS NOT NULL
  AND late_aircraft_delay IS NOT NULL;


-- Query 19: Compare original and cleaned row counts
SELECT
    (SELECT COUNT(*) FROM Airline_Delay_Cause) AS original_rows,
    (SELECT COUNT(*) FROM Airline_Delay_Clean) AS cleaned_rows,
    (SELECT COUNT(*) FROM Airline_Delay_Cause) -
    (SELECT COUNT(*) FROM Airline_Delay_Clean) AS removed_rows;



-- ============================================================
-- PHASE 4: AIRLINE PERFORMANCE ANALYSIS
-- ============================================================

-- Query 20: Total delay minutes by airline
SELECT 
    carrier_name,
    SUM(arr_delay) AS total_delay_minutes
FROM Airline_Delay_Clean
GROUP BY carrier_name
ORDER BY total_delay_minutes DESC
LIMIT 10;


-- Query 21: Average delay minutes per flight by airline
SELECT
    carrier_name,
    SUM(arr_delay) AS total_delay_minutes,
    SUM(arr_flights) AS total_flights,
    ROUND(SUM(arr_delay) * 1.0 / SUM(arr_flights), 2) AS delay_minutes_per_flight
FROM Airline_Delay_Clean
GROUP BY carrier_name
HAVING SUM(arr_flights) > 100000
ORDER BY delay_minutes_per_flight DESC
LIMIT 10;


-- Query 22: Airline delay rate
SELECT
    carrier_name,
    SUM(arr_flights) AS total_flights,
    SUM(arr_del15) AS delayed_flights,
    ROUND(SUM(arr_del15) * 100.0 / SUM(arr_flights), 2) AS delay_rate_pct
FROM Airline_Delay_Clean
GROUP BY carrier_name
HAVING SUM(arr_flights) > 0
ORDER BY delay_rate_pct DESC;


-- Query 23: Check strongest airline performers by lowest delay rate
SELECT
    carrier_name,
    SUM(arr_flights) AS total_flights,
    SUM(arr_del15) AS delayed_flights,
    ROUND(SUM(arr_del15) * 100.0 / SUM(arr_flights), 2) AS delay_rate_pct
FROM Airline_Delay_Clean
GROUP BY carrier_name
HAVING SUM(arr_flights) >= 100000
ORDER BY delay_rate_pct ASC;



-- ============================================================
-- PHASE 5: DELAY CAUSE ANALYSIS
-- ============================================================

-- Query 24: Delay cause totals
SELECT 
    SUM(carrier_delay) AS carrier_delay,
    SUM(weather_delay) AS weather_delay,
    SUM(nas_delay) AS nas_delay,
    SUM(security_delay) AS security_delay,
    SUM(late_aircraft_delay) AS late_aircraft_delay
FROM Airline_Delay_Clean;


-- Query 25: Convert delay causes into rows for visualization
SELECT 'Late Aircraft' AS delay_cause, SUM(late_aircraft_delay) AS total_minutes
FROM Airline_Delay_Clean

UNION ALL

SELECT 'Carrier', SUM(carrier_delay)
FROM Airline_Delay_Clean

UNION ALL

SELECT 'NAS', SUM(nas_delay)
FROM Airline_Delay_Clean

UNION ALL

SELECT 'Weather', SUM(weather_delay)
FROM Airline_Delay_Clean

UNION ALL

SELECT 'Security', SUM(security_delay)
FROM Airline_Delay_Clean

ORDER BY total_minutes DESC;



-- ============================================================
-- PHASE 6: AIRPORT PERFORMANCE ANALYSIS
-- ============================================================

-- Query 26: Average delay minutes per flight by airport
SELECT
    airport_name,
    SUM(arr_delay) AS total_delay_minutes,
    SUM(arr_flights) AS total_flights,
    ROUND(SUM(arr_delay) * 1.0 / SUM(arr_flights), 2) AS delay_minutes_per_flight
FROM Airline_Delay_Clean
GROUP BY airport_name
HAVING SUM(arr_flights) > 100000
ORDER BY delay_minutes_per_flight DESC
LIMIT 10;


-- Query 27: Airport traffic volume vs average delay
SELECT
    airport,
    airport_name,
    SUM(arr_flights) AS total_flights,
    ROUND(SUM(arr_delay) * 1.0 / SUM(arr_flights), 2) AS avg_delay_minutes_per_flight
FROM Airline_Delay_Clean
GROUP BY airport, airport_name
HAVING SUM(arr_flights) >= 100000
ORDER BY avg_delay_minutes_per_flight DESC;



-- ============================================================
-- PHASE 7: TREND ANALYSIS
-- ============================================================

-- Query 28: Yearly delay trends
SELECT
    year,
    SUM(arr_flights) AS total_flights,
    SUM(arr_delay) AS total_delay_minutes,
    ROUND(SUM(arr_delay) * 1.0 / SUM(arr_flights), 2) AS delay_minutes_per_flight
FROM Airline_Delay_Clean
GROUP BY year
ORDER BY year;


-- Query 29: Monthly delay trends
SELECT
    month,
    SUM(arr_delay) AS total_delay_minutes,
    SUM(arr_flights) AS total_flights,
    ROUND(SUM(arr_delay) * 1.0 / SUM(arr_flights), 2) AS delay_minutes_per_flight
FROM Airline_Delay_Clean
GROUP BY month
ORDER BY delay_minutes_per_flight DESC;


-- Query 30: Delay causes by year
SELECT
    year,
    SUM(carrier_delay) AS carrier_delay,
    SUM(weather_delay) AS weather_delay,
    SUM(nas_delay) AS nas_delay,
    SUM(security_delay) AS security_delay,
    SUM(late_aircraft_delay) AS late_aircraft_delay
FROM Airline_Delay_Clean
GROUP BY year
ORDER BY year;



-- ============================================================
-- PHASE 8: EXPORT-READY SUMMARY TABLES FOR TABLEAU
-- ============================================================

-- Query 31: Create Q1 delay causes table
CREATE TABLE Q1_Delay_Causes AS
SELECT 'Late Aircraft' AS delay_cause, SUM(late_aircraft_delay) AS total_minutes
FROM Airline_Delay_Clean

UNION ALL

SELECT 'Carrier', SUM(carrier_delay)
FROM Airline_Delay_Clean

UNION ALL

SELECT 'NAS', SUM(nas_delay)
FROM Airline_Delay_Clean

UNION ALL

SELECT 'Weather', SUM(weather_delay)
FROM Airline_Delay_Clean

UNION ALL

SELECT 'Security', SUM(security_delay)
FROM Airline_Delay_Clean;


-- Query 32: Create Q2 airline delay rates table
CREATE TABLE Q2_Airline_Delay_Rates AS
SELECT
    carrier_name,
    SUM(arr_flights) AS total_flights,
    SUM(arr_del15) AS delayed_flights,
    ROUND(SUM(arr_del15) * 100.0 / SUM(arr_flights), 2) AS delay_rate_pct,
    ROUND(SUM(arr_delay) * 1.0 / SUM(arr_flights), 2) AS avg_delay_minutes_per_flight
FROM Airline_Delay_Clean
GROUP BY carrier_name
HAVING SUM(arr_flights) >= 100000
ORDER BY delay_rate_pct DESC;


-- Query 33: Create Q3 airport bottlenecks table
CREATE TABLE Q3_Airport_Bottlenecks AS
SELECT
    airport,
    airport_name,
    SUM(arr_flights) AS total_flights,
    SUM(arr_delay) AS total_delay_minutes,
    ROUND(SUM(arr_delay) * 1.0 / SUM(arr_flights), 2) AS avg_delay_minutes_per_flight,
    ROUND(SUM(arr_del15) * 100.0 / SUM(arr_flights), 2) AS delay_rate_pct
FROM Airline_Delay_Clean
GROUP BY airport, airport_name
HAVING SUM(arr_flights) >= 100000
ORDER BY avg_delay_minutes_per_flight DESC;


-- Query 34: Create Q4 monthly delay patterns table
CREATE TABLE Q4_Monthly_Delay_Patterns AS
SELECT
    month,
    SUM(arr_flights) AS total_flights,
    SUM(arr_del15) AS delayed_flights,
    SUM(arr_delay) AS total_delay_minutes,
    ROUND(SUM(arr_del15) * 100.0 / SUM(arr_flights), 2) AS delay_rate_pct,
    ROUND(SUM(arr_delay) * 1.0 / SUM(arr_flights), 2) AS avg_delay_minutes_per_flight,
    SUM(carrier_delay) AS carrier_delay,
    SUM(weather_delay) AS weather_delay,
    SUM(nas_delay) AS nas_delay,
    SUM(security_delay) AS security_delay,
    SUM(late_aircraft_delay) AS late_aircraft_delay
FROM Airline_Delay_Clean
GROUP BY month
ORDER BY month;


-- Query 35: Create Q5 yearly delay trends table
CREATE TABLE Q5_Yearly_Delay_Trends AS
SELECT
    year,
    SUM(arr_flights) AS total_flights,
    SUM(arr_del15) AS delayed_flights,
    SUM(arr_delay) AS total_delay_minutes,
    ROUND(SUM(arr_del15) * 100.0 / SUM(arr_flights), 2) AS delay_rate_pct,
    ROUND(SUM(arr_delay) * 1.0 / SUM(arr_flights), 2) AS avg_delay_minutes_per_flight,
    SUM(carrier_delay) AS carrier_delay,
    SUM(weather_delay) AS weather_delay,
    SUM(nas_delay) AS nas_delay,
    SUM(security_delay) AS security_delay,
    SUM(late_aircraft_delay) AS late_aircraft_delay
FROM Airline_Delay_Clean
GROUP BY year
ORDER BY year;


-- Query 36: Review export-ready tables
SELECT * FROM Q1_Delay_Causes;
SELECT * FROM Q2_Airline_Delay_Rates;
SELECT * FROM Q3_Airport_Bottlenecks;
SELECT * FROM Q4_Monthly_Delay_Patterns;
SELECT * FROM Q5_Yearly_Delay_Trends;

