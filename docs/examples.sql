-- ==========================================================
-- Haroon Ahmed
-- DATA 220P
-- Example SQL Queries
-- ==========================================================


-- Example 1: View the stored hierarchy
SELECT name, object
FROM hgeo_objects;


-- Example 2: Retrieve the children of the United States
SELECT children(object)
FROM hgeo_objects
WHERE name = 'United States';


-- Example 3: Find the parent of Irvine
SELECT parent(object, 'Irvine')
FROM hgeo_objects
WHERE name = 'United States';


-- Example 4: Export the hierarchy as GeoJSON
SELECT visualize(object)
FROM hgeo_objects
WHERE name = 'United States';


-- Example 5: Import a GeoJSON point as an HGeo object
SELECT hgeo_from_geojson(
    500,
    'Example Point',
    'point',
    '{
        "type": "Point",
        "coordinates": [-117.8265, 33.6846]
    }'::jsonb,
    '{"description": "Example location"}'::jsonb
);


-- Example 6: Test whether a polygon contains a point
WITH region AS (
    SELECT hgeo_from_geojson(
        600,
        'Example Region',
        'region',
        '{
            "type": "Polygon",
            "coordinates": [[
                [-118.0, 33.5],
                [-117.5, 33.5],
                [-117.5, 34.0],
                [-118.0, 34.0],
                [-118.0, 33.5]
            ]]
        }'::jsonb,
        '{}'::jsonb
    ) AS obj
),
point AS (
    SELECT hgeo_from_geojson(
        601,
        'Example Point',
        'point',
        '{
            "type": "Point",
            "coordinates": [-117.75, 33.75]
        }'::jsonb,
        '{}'::jsonb
    ) AS obj
)
SELECT hgeo_contains(region.obj, point.obj) AS contains_point
FROM region, point;


-- Example 7: Calculate the distance between two points
WITH point1 AS (
    SELECT hgeo_from_geojson(
        700,
        'Point A',
        'point',
        '{
            "type": "Point",
            "coordinates": [-117.8265, 33.6846]
        }'::jsonb,
        '{}'::jsonb
    ) AS obj
),
point2 AS (
    SELECT hgeo_from_geojson(
        701,
        'Point B',
        'point',
        '{
            "type": "Point",
            "coordinates": [-117.9298, 33.6189]
        }'::jsonb,
        '{}'::jsonb
    ) AS obj
)
SELECT hgeo_distance(point1.obj, point2.obj) AS distance_meters
FROM point1, point2;


-- Example 8: Find the nearest candidate
WITH target AS (
    SELECT hgeo_from_geojson(
        800,
        'Target',
        'point',
        '{
            "type": "Point",
            "coordinates": [-117.8, 33.7]
        }'::jsonb,
        '{}'::jsonb
    ) AS obj
),
candidate1 AS (
    SELECT hgeo_from_geojson(
        801,
        'Candidate A',
        'point',
        '{
            "type": "Point",
            "coordinates": [-117.81, 33.71]
        }'::jsonb,
        '{}'::jsonb
    ) AS obj
),
candidate2 AS (
    SELECT hgeo_from_geojson(
        802,
        'Candidate B',
        'point',
        '{
            "type": "Point",
            "coordinates": [-119.0, 35.0]
        }'::jsonb,
        '{}'::jsonb
    ) AS obj
)
SELECT hgeo_nearest(
    target.obj,
    ARRAY[candidate1.obj, candidate2.obj]::hgeo[]
) AS nearest_candidate
FROM target, candidate1, candidate2;


-- Example 9: Compute the bounding box of the United States
SELECT hgeo_bounding_box(object) AS bounding_box
FROM hgeo_objects
WHERE name = 'United States';


-- Example 10: Export wildfire events for visualization
SELECT
    event_name,
    severity,
    event_date,
    visualize(affected_region) AS geojson
FROM wildfire_events;