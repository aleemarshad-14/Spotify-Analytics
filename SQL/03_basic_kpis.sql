/*
    Spotify Analytics Project
    03 - Basic KPIs
*/

-- 1. Total Plays
SELECT
    COUNT(*) AS total_plays
FROM clean_dataset_spotify;


-- 2. Total Unique Artists
SELECT
    COUNT(DISTINCT artist_name) AS total_artists
FROM clean_dataset_spotify;


-- 3. Total Unique Albums
SELECT
    COUNT(DISTINCT album_name) AS total_albums
FROM clean_dataset_spotify;


-- 4. Total Unique Tracks
SELECT
    COUNT(DISTINCT track_name) AS total_tracks
FROM clean_dataset_spotify;


-- 5. Total Listening Minutes
SELECT
    ROUND(SUM(ms_played) / 60000.0, 2) AS total_listening_minutes
FROM clean_dataset_spotify;


-- 6. Total Listening Hours
SELECT
    ROUND(SUM(ms_played) / 3600000.0, 2) AS total_listening_hours
FROM clean_dataset_spotify;


-- 7. Average listening time per play
SELECT
    ROUND(AVG(ms_played) / 60000.0, 2) AS avg_listening_minutes_per_play
FROM clean_dataset_spotify;


-- 8. Total Shuffle Plays
SELECT
    COUNT(*) AS total_shuffle_plays
FROM clean_dataset_spotify
WHERE shuffle = 1;


-- 9. Shuffle Rate
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN shuffle = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS shuffle_rate_percentage
FROM clean_dataset_spotify;


-- 10. Total Skipped Plays
SELECT
    COUNT(*) AS skipped_plays
FROM clean_dataset_spotify
WHERE skipped = 1;


-- 11. Skip Rate
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN skipped = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS skip_rate_percentage
FROM clean_dataset_spotify;


-- 12. KPI summary
SELECT
    COUNT(*) AS total_plays,
    COUNT(DISTINCT artist_name) AS total_artists,
    COUNT(DISTINCT album_name) AS total_albums,
    COUNT(DISTINCT track_name) AS total_tracks,
    ROUND(SUM(ms_played) / 60000.0, 2) AS listening_minutes,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS listening_hours,
    SUM(CASE WHEN shuffle = 1 THEN 1 ELSE 0 END) AS shuffle_plays,
    SUM(CASE WHEN skipped = 1 THEN 1 ELSE 0 END) AS skipped_plays,
    ROUND(
        100.0 * SUM(CASE WHEN skipped = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    ) AS skip_rate_percentage
FROM clean_dataset_spotify;
