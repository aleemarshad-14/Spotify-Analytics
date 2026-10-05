/*
    Spotify Analytics Project
    04 - Listening / Playback Analysis

    File name retained from the standard project structure.
    Spotify equivalent of sales analysis = listening activity and playback behavior.
*/

-- 1. Top 20 artists by number of plays
SELECT TOP 20
    artist_name,
    COUNT(*) AS total_plays,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS listening_hours
FROM clean_dataset_spotify
GROUP BY artist_name
ORDER BY total_plays DESC;


-- 2. Top 20 tracks by play frequency
SELECT TOP 20
    track_name,
    artist_name,
    COUNT(*) AS track_frequency,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS listening_hours
FROM clean_dataset_spotify
GROUP BY track_name, artist_name
ORDER BY track_frequency DESC;


-- 3. Top 20 albums by play frequency
SELECT TOP 20
    album_name,
    COUNT(*) AS total_plays,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS listening_hours
FROM clean_dataset_spotify
GROUP BY album_name
ORDER BY total_plays DESC;


-- 4. Most listened artists by total listening time
SELECT TOP 20
    artist_name,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS listening_hours
FROM clean_dataset_spotify
GROUP BY artist_name
ORDER BY listening_hours DESC;


-- 5. Most listened tracks by total listening time
SELECT TOP 20
    track_name,
    artist_name,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS listening_hours
FROM clean_dataset_spotify
GROUP BY track_name, artist_name
ORDER BY listening_hours DESC;


-- 6. Artist engagement: plays vs listening hours
SELECT TOP 25
    artist_name,
    COUNT(*) AS play_frequency,
    ROUND(SUM(ms_played) / 3600000.0, 2) AS listening_hours,
    ROUND(AVG(ms_played) / 60000.0, 2) AS avg_minutes_per_play
FROM clean_dataset_spotify
GROUP BY artist_name
ORDER BY listening_hours DESC;


-- 7. Skipped plays by artist
SELECT TOP 20
    artist_name,
    COUNT(*) AS skipped_plays
FROM clean_dataset_spotify
WHERE skipped = 1
GROUP BY artist_name
ORDER BY skipped_plays DESC;


-- 8. Skip rate by artist (minimum 20 plays)
SELECT TOP 20
    artist_name,
    COUNT(*) AS total_plays,
    SUM(CASE WHEN skipped = 1 THEN 1 ELSE 0 END) AS skipped_plays,
    ROUND(
        100.0 * SUM(CASE WHEN skipped = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS skip_rate_percentage
FROM clean_dataset_spotify
GROUP BY artist_name
HAVING COUNT(*) >= 20
ORDER BY skip_rate_percentage DESC;
