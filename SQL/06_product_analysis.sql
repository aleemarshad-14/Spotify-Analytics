/*
    Spotify Analytics Project
    06 - Content Analysis
    Equivalent of product analysis for the Spotify project.
*/

-- 1. Artist-level summary
SELECT
    artist_name,
    COUNT(*) AS total_plays,
    COUNT(DISTINCT album_name) AS albums_played,
    COUNT(DISTINCT track_name) AS tracks_played,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS listening_hours
FROM clean_dataset_spotify
GROUP BY artist_name
ORDER BY total_plays DESC;


-- 2. Album-level summary
SELECT
    album_name,
    COUNT(DISTINCT artist_name) AS artists,
    COUNT(DISTINCT track_name) AS tracks,
    COUNT(*) AS total_plays,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS listening_hours
FROM clean_dataset_spotify
GROUP BY album_name
ORDER BY total_plays DESC;


-- 3. Track-level summary
SELECT
    track_name,
    artist_name,
    album_name,
    COUNT(*) AS track_frequency,
    ROUND(SUM(ms_played) / 60000.0, 2) AS listening_minutes,
    ROUND(AVG(ms_played) / 60000.0, 2) AS avg_play_minutes,
    SUM(CASE WHEN skipped = 1 THEN 1 ELSE 0 END) AS skipped_plays
FROM clean_dataset_spotify
GROUP BY
    track_name,
    artist_name,
    album_name
ORDER BY track_frequency DESC;


-- 4. Top 10 tracks by frequency
SELECT TOP 10
    track_name,
    artist_name,
    COUNT(*) AS track_frequency
FROM clean_dataset_spotify
GROUP BY track_name, artist_name
ORDER BY track_frequency DESC;


-- 5. Top 10 tracks by listening time
SELECT TOP 10
    track_name,
    artist_name,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS listening_hours
FROM clean_dataset_spotify
GROUP BY track_name, artist_name
ORDER BY listening_hours DESC;


-- 6. Top 10 most skipped tracks
SELECT TOP 10
    track_name,
    artist_name,
    COUNT(*) AS skipped_plays
FROM clean_dataset_spotify
WHERE skipped = 1
GROUP BY track_name, artist_name
ORDER BY skipped_plays DESC;


-- 7. Track skip rate (minimum 10 plays)
SELECT TOP 25
    track_name,
    artist_name,
    COUNT(*) AS total_plays,
    SUM(CASE WHEN skipped = 1 THEN 1 ELSE 0 END) AS skipped_plays,
    ROUND(
        100.0 * SUM(CASE WHEN skipped = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS skip_rate_percentage
FROM clean_dataset_spotify
GROUP BY track_name, artist_name
HAVING COUNT(*) >= 10
ORDER BY skip_rate_percentage DESC;


-- 8. Content depth by artist
SELECT TOP 25
    artist_name,
    COUNT(DISTINCT album_name) AS unique_albums,
    COUNT(DISTINCT track_name) AS unique_tracks,
    COUNT(*) AS total_plays
FROM clean_dataset_spotify
GROUP BY artist_name
ORDER BY unique_tracks DESC;
