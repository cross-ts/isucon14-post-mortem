SET CHARACTER_SET_CLIENT = utf8mb4;
SET CHARACTER_SET_CONNECTION = utf8mb4;

USE isuride;

alter table chairs add column latitude integer default null;
alter table chairs add column longitude integer default null;
alter table chairs add column total_distance integer not null default 0;
alter table chairs add column total_distance_updated_at datetime(6) default null;

UPDATE chairs c
JOIN (
    SELECT cl.chair_id,
           cl.latitude AS last_latitude,
           cl.longitude AS last_longitude
    FROM chair_locations cl
    JOIN (
        SELECT chair_id, MAX(created_at) AS latest_created_at
        FROM chair_locations
        GROUP BY chair_id
    ) latest ON cl.chair_id = latest.chair_id AND cl.created_at = latest.latest_created_at
) latest_position ON c.id = latest_position.chair_id
SET c.latitude = latest_position.last_latitude,
    c.longitude = latest_position.last_longitude;

UPDATE chairs c
JOIN (
    SELECT chair_id,
           SUM(IFNULL(distance, 0)) AS total_distance,
           MAX(created_at) AS total_distance_updated_at
    FROM (
        SELECT chair_id,
               created_at,
               ABS(latitude - LAG(latitude) OVER (PARTITION BY chair_id ORDER BY created_at)) +
               ABS(longitude - LAG(longitude) OVER (PARTITION BY chair_id ORDER BY created_at)) AS distance
        FROM chair_locations
    ) tmp
    GROUP BY chair_id
) total_distance ON c.id = total_distance.chair_id
SET c.total_distance = total_distance.total_distance,
    c.total_distance_updated_at = total_distance.total_distance_updated_at;
