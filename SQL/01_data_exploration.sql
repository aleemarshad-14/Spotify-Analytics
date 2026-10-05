/*
    Spotify Analytics Project
    01 - Data Exploration
    Table: clean_dataset_spotify

    Purpose:
    - Understand dataset size, structure, date range and data quality
    - Explore listening activity, artists, albums, tracks and platforms
*/

-- 1. Total rows / listening events
SELECT
    COUNT(*) AS total_listening_records
FROM clean_dataset_spotify;


-- 2. Preview the dataset
SELECT TOP 20 *
FROM clean_dataset_spotify
ORDER BY ts;


-- 3. Date range
SELECT
    MIN(ts) AS first_listening_timestamp,
    MAX(ts) AS last_listening_timestamp,
    MIN(track_sound_date) AS first_listening_date,
    MAX(track_sound_date) AS last_listening_date
FROM clean_dataset_spotify;


-- 4. Unique artists, albums and tracks
SELECT
    COUNT(DISTINCT artist_name) AS unique_artists,
    COUNT(DISTINCT album_name) AS unique_albums,
    COUNT(DISTINCT track_name) AS unique_tracks
FROM clean_dataset_spotify;


-- 5. Platform distribution
SELECT
    platform,
    COUNT(*) AS total_plays,
    ROUND(
        100.0 * COUNT(*) / NULLIF(SUM(COUNT(*)) OVER (), 0),
        2
    ) AS play_percentage
FROM clean_dataset_spotify
GROUP BY platform
ORDER BY total_plays DESC;


-- 6. Shuffle distribution
SELECT
    shuffle,
    COUNT(*) AS total_plays,
    ROUND(
        100.0 * COUNT(*) / NULLIF(SUM(COUNT(*)) OVER (), 0),
        2
    ) AS play_percentage
FROM clean_dataset_spotify
GROUP BY shuffle
ORDER BY total_plays DESC;


-- 7. Skipped vs non-skipped plays
SELECT
    skipped,
    COUNT(*) AS total_plays,
    ROUND(
        100.0 * COUNT(*) / NULLIF(SUM(COUNT(*)) OVER (), 0),
        2
    ) AS play_percentage
FROM clean_dataset_spotify
GROUP BY skipped
ORDER BY skipped;


-- 8. Listening duration statistics
SELECT
    COUNT(*) AS total_records,
    SUM(ms_played) AS total_ms_played,
    ROUND(SUM(ms_played) / 60000.0, 2) AS total_listening_minutes,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS total_listening_hours,
    ROUND(AVG(ms_played) / 60000.0, 2) AS avg_listening_minutes_per_record
FROM clean_dataset_spotify;


-- 9. Most played artists
SELECT TOP 20
    artist_name,
    COUNT(*) AS play_count
FROM clean_dataset_spotify
GROUP BY artist_name
ORDER BY play_count DESC;


-- 10. Most played tracks
SELECT TOP 20
    track_name,
    artist_name,
    COUNT(*) AS play_count
FROM clean_dataset_spotify
GROUP BY track_name, artist_name
ORDER BY play_count DESC;
