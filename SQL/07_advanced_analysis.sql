/*
    Spotify Analytics Project
    07 - Advanced Analysis
*/

-- 1. Listening behavior by platform
SELECT
    platform,
    COUNT(*) AS total_plays,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS listening_hours,
    ROUND(AVG(ms_played) / 60000.0, 2) AS avg_minutes_per_play,
    ROUND(
        100.0 * SUM(CASE WHEN skipped = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS skip_rate_percentage
FROM clean_dataset_spotify
GROUP BY platform
ORDER BY total_plays DESC;


-- 2. Skip reasons among skipped plays
SELECT
    reason_end,
    COUNT(*) AS skipped_plays,
    ROUND(
        100.0 * COUNT(*) /
        NULLIF(SUM(COUNT(*)) OVER (), 0),
        2
    ) AS percentage_of_skips
FROM clean_dataset_spotify
WHERE skipped = 1
GROUP BY reason_end
ORDER BY skipped_plays DESC;


-- 3. Top 5 skip reasons
WITH skip_reasons AS (
    SELECT
        reason_end,
        COUNT(*) AS skipped_plays
    FROM clean_dataset_spotify
    WHERE skipped = 1
    GROUP BY reason_end
),
ranked AS (
    SELECT
        reason_end,
        skipped_plays,
        ROW_NUMBER() OVER (ORDER BY skipped_plays DESC) AS reason_rank
    FROM skip_reasons
)
SELECT
    reason_rank,
    reason_end,
    skipped_plays
FROM ranked
WHERE reason_rank <= 5
ORDER BY reason_rank;


-- 4. Shuffle vs non-shuffle behavior
SELECT
    shuffle,
    COUNT(*) AS total_plays,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS listening_hours,
    ROUND(AVG(ms_played) / 60000.0, 2) AS avg_minutes_per_play,
    ROUND(
        100.0 * SUM(CASE WHEN skipped = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS skip_rate_percentage
FROM clean_dataset_spotify
GROUP BY shuffle
ORDER BY shuffle;


-- 5. Start reason analysis
SELECT
    reason_start,
    COUNT(*) AS total_plays,
    ROUND(
        100.0 * COUNT(*) /
        NULLIF(SUM(COUNT(*)) OVER (), 0),
        2
    ) AS percentage_of_plays
FROM clean_dataset_spotify
GROUP BY reason_start
ORDER BY total_plays DESC;


-- 6. Artist engagement matrix
-- Useful for identifying artists with both high frequency and high listening time.
WITH artist_summary AS (
    SELECT
        artist_name,
        COUNT(*) AS play_frequency,
        SUM(ms_played) / 3600000.0 AS listening_hours
    FROM clean_dataset_spotify
    GROUP BY artist_name
),
thresholds AS (
    SELECT
        AVG(play_frequency * 1.0) AS avg_frequency,
        AVG(listening_hours) AS avg_hours
    FROM artist_summary
)
SELECT
    a.artist_name,
    a.play_frequency,
    ROUND(a.listening_hours, 2) AS listening_hours,
    CASE
        WHEN a.play_frequency >= t.avg_frequency
             AND a.listening_hours >= t.avg_hours
            THEN 'High Frequency / High Listening'
        WHEN a.play_frequency >= t.avg_frequency
             AND a.listening_hours < t.avg_hours
            THEN 'High Frequency / Low Listening'
        WHEN a.play_frequency < t.avg_frequency
             AND a.listening_hours >= t.avg_hours
            THEN 'Low Frequency / High Listening'
        ELSE 'Low Frequency / Low Listening'
    END AS engagement_segment
FROM artist_summary a
CROSS JOIN thresholds t
ORDER BY a.play_frequency DESC;


-- 7. Track-level engagement matrix
WITH track_summary AS (
    SELECT
        track_name,
        artist_name,
        COUNT(*) AS listening_frequency,
        AVG(ms_played) / 60000.0 AS avg_listening_time_minutes
    FROM clean_dataset_spotify
    GROUP BY track_name, artist_name
),
thresholds AS (
    SELECT
        AVG(listening_frequency * 1.0) AS avg_frequency,
        AVG(avg_listening_time_minutes) AS avg_listening_time
    FROM track_summary
)
SELECT
    t.track_name,
    t.artist_name,
    t.listening_frequency,
    ROUND(t.avg_listening_time_minutes, 2) AS avg_listening_time_minutes,
    CASE
        WHEN t.listening_frequency >= th.avg_frequency
             AND t.avg_listening_time_minutes >= th.avg_listening_time
            THEN 'High Frequency / High Listening Time'
        WHEN t.listening_frequency >= th.avg_frequency
             AND t.avg_listening_time_minutes < th.avg_listening_time
            THEN 'High Frequency / Low Listening Time'
        WHEN t.listening_frequency < th.avg_frequency
             AND t.avg_listening_time_minutes >= th.avg_listening_time
            THEN 'Low Frequency / High Listening Time'
        ELSE 'Low Frequency / Low Listening Time'
    END AS listening_segment
FROM track_summary t
CROSS JOIN thresholds th
ORDER BY t.listening_frequency DESC;


-- 8. Year-over-year unique content growth
WITH yearly AS (
    SELECT
        YEAR(ts) AS listening_year,
        COUNT(DISTINCT artist_name) AS unique_artists,
        COUNT(DISTINCT album_name) AS unique_albums,
        COUNT(DISTINCT track_name) AS unique_tracks
    FROM clean_dataset_spotify
    GROUP BY YEAR(ts)
)
SELECT
    listening_year,
    unique_artists,
    unique_albums,
    unique_tracks,
    LAG(unique_artists) OVER (ORDER BY listening_year) AS previous_year_artists,
    LAG(unique_albums) OVER (ORDER BY listening_year) AS previous_year_albums,
    LAG(unique_tracks) OVER (ORDER BY listening_year) AS previous_year_tracks
FROM yearly
ORDER BY listening_year;


-- 9. Most engaged artists by listening time with a minimum play threshold
SELECT TOP 20
    artist_name,
    COUNT(*) AS play_frequency,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS listening_hours,
    ROUND(AVG(ms_played) / 60000.0, 2) AS avg_minutes_per_play
FROM clean_dataset_spotify
GROUP BY artist_name
HAVING COUNT(*) >= 20
ORDER BY listening_hours DESC;
