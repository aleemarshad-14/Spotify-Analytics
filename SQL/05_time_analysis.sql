/*
    Spotify Analytics Project
    05 - Time Analysis
*/

-- 1. Listening by date
SELECT
    CAST(ts AS DATE) AS listening_date,
    COUNT(*) AS total_plays,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS listening_hours
FROM clean_dataset_spotify
GROUP BY CAST(ts AS DATE)
ORDER BY listening_date;


-- 2. Listening by year
SELECT
    YEAR(ts) AS listening_year,
    COUNT(*) AS total_plays,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS listening_hours
FROM clean_dataset_spotify
GROUP BY YEAR(ts)
ORDER BY listening_year;


-- 3. Listening by month
SELECT
    YEAR(ts) AS listening_year,
    MONTH(ts) AS month_number,
    DATENAME(MONTH, ts) AS month_name,
    COUNT(*) AS total_plays,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS listening_hours
FROM clean_dataset_spotify
GROUP BY
    YEAR(ts),
    MONTH(ts),
    DATENAME(MONTH, ts)
ORDER BY listening_year, month_number;


-- 4. Listening by day of week
SELECT
    DATEPART(WEEKDAY, ts) AS weekday_number,
    DATENAME(WEEKDAY, ts) AS weekday_name,
    COUNT(*) AS total_plays,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS listening_hours
FROM clean_dataset_spotify
GROUP BY
    DATEPART(WEEKDAY, ts),
    DATENAME(WEEKDAY, ts)
ORDER BY weekday_number;


-- 5. Listening by hour of day
SELECT
    DATEPART(HOUR, ts) AS listening_hour,
    COUNT(*) AS total_plays,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS listening_hours
FROM clean_dataset_spotify
GROUP BY DATEPART(HOUR, ts)
ORDER BY listening_hour;


-- 6. Listening by hour and weekday
SELECT
    DATENAME(WEEKDAY, ts) AS weekday_name,
    DATEPART(WEEKDAY, ts) AS weekday_number,
    DATEPART(HOUR, ts) AS listening_hour,
    COUNT(*) AS total_plays,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS listening_hours
FROM clean_dataset_spotify
GROUP BY
    DATENAME(WEEKDAY, ts),
    DATEPART(WEEKDAY, ts),
    DATEPART(HOUR, ts)
ORDER BY weekday_number, listening_hour;


-- 7. Monthly skip rate
SELECT
    YEAR(ts) AS listening_year,
    MONTH(ts) AS month_number,
    DATENAME(MONTH, ts) AS month_name,
    COUNT(*) AS total_plays,
    SUM(CASE WHEN skipped = 1 THEN 1 ELSE 0 END) AS skipped_plays,
    ROUND(
        100.0 * SUM(CASE WHEN skipped = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS skip_rate_percentage
FROM clean_dataset_spotify
GROUP BY
    YEAR(ts),
    MONTH(ts),
    DATENAME(MONTH, ts)
ORDER BY listening_year, month_number;


-- 8. Year-over-year listening summary
WITH yearly AS (
    SELECT
        YEAR(ts) AS listening_year,
        COUNT(*) AS total_plays,
        SUM(ms_played) AS total_ms_played
    FROM clean_dataset_spotify
    GROUP BY YEAR(ts)
)
SELECT
    listening_year,
    total_plays,
    ROUND(total_ms_played / 3600000.0, 2) AS listening_hours,
    LAG(total_plays) OVER (ORDER BY listening_year) AS previous_year_plays,
    ROUND(
        100.0 * (
            total_plays - LAG(total_plays) OVER (ORDER BY listening_year)
        ) / NULLIF(LAG(total_plays) OVER (ORDER BY listening_year), 0),
        2
    ) AS yoy_play_growth_percentage
FROM yearly
ORDER BY listening_year;
