/*
    Spotify Analytics Project
    02 - Data Cleaning & Validation
    Table: clean_dataset_spotify

    Note:
    The project uses a cleaned Spotify listening-history table.
    These queries validate and standardize the analytical fields without
    overwriting the source table.
*/

-- 1. Check for NULLs in important fields
SELECT
    SUM(CASE WHEN artist_name IS NULL OR LTRIM(RTRIM(artist_name)) = '' THEN 1 ELSE 0 END) AS missing_artist,
    SUM(CASE WHEN album_name IS NULL OR LTRIM(RTRIM(album_name)) = '' THEN 1 ELSE 0 END) AS missing_album,
    SUM(CASE WHEN track_name IS NULL OR LTRIM(RTRIM(track_name)) = '' THEN 1 ELSE 0 END) AS missing_track,
    SUM(CASE WHEN ts IS NULL THEN 1 ELSE 0 END) AS missing_timestamp,
    SUM(CASE WHEN ms_played IS NULL THEN 1 ELSE 0 END) AS missing_ms_played,
    SUM(CASE WHEN platform IS NULL OR LTRIM(RTRIM(platform)) = '' THEN 1 ELSE 0 END) AS missing_platform
FROM clean_dataset_spotify;


-- 2. Check for invalid negative listening durations
SELECT
    COUNT(*) AS negative_duration_records
FROM clean_dataset_spotify
WHERE ms_played < 0;


-- 3. Check for zero-duration records
SELECT
    COUNT(*) AS zero_duration_records
FROM clean_dataset_spotify
WHERE ms_played = 0;


-- 4. Check for duplicate listening records
SELECT
    ts,
    artist_name,
    album_name,
    track_name,
    ms_played,
    COUNT(*) AS duplicate_count
FROM clean_dataset_spotify
GROUP BY
    ts,
    artist_name,
    album_name,
    track_name,
    ms_played
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- 5. Standardized text view/query
-- Use this pattern when creating a reporting table/view.
SELECT
    LTRIM(RTRIM(album_name)) AS album_name,
    LTRIM(RTRIM(artist_name)) AS artist_name,
    ms_played,
    LTRIM(RTRIM(platform)) AS platform,
    LTRIM(RTRIM(reason_start)) AS reason_start,
    LTRIM(RTRIM(reason_end)) AS reason_end,
    shuffle,
    skipped,
    spotify_track_uri,
    LTRIM(RTRIM(track_name)) AS track_name,
    ts,
    track_play_time,
    track_sound_date
FROM clean_dataset_spotify;


-- 6. Validate date/time consistency
SELECT
    COUNT(*) AS records_with_date_mismatch
FROM clean_dataset_spotify
WHERE
    track_sound_date IS NOT NULL
    AND CAST(ts AS DATE) <> CAST(track_sound_date AS DATE);


-- 7. Inspect unexpected categorical values
SELECT DISTINCT platform
FROM clean_dataset_spotify
ORDER BY platform;

SELECT DISTINCT reason_start
FROM clean_dataset_spotify
ORDER BY reason_start;

SELECT DISTINCT reason_end
FROM clean_dataset_spotify
ORDER BY reason_end;


-- 8. Clean analytical dataset pattern
-- This is a SELECT statement for creating a reporting view/table if needed.
SELECT
    LTRIM(RTRIM(album_name)) AS album_name,
    LTRIM(RTRIM(artist_name)) AS artist_name,
    ms_played,
    platform,
    reason_start,
    reason_end,
    shuffle,
    skipped,
    spotify_track_uri,
    LTRIM(RTRIM(track_name)) AS track_name,
    ts,
    track_play_time,
    track_sound_date,
    ms_played / 3600000.0 AS listening_time_hours,
    ms_played / 60000.0 AS listening_time_minutes
FROM clean_dataset_spotify
WHERE ms_played >= 0;
