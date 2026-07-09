-- ==========================================================
-- HGeo PostgreSQL Extension
-- ==========================================================
-- Haroon Ahmed
-- DATA 220P
-- Project: Hierarchical Geography Data Type for PostgreSQL
-- Purpose: Suite for Phase 7 Testing (all functions)
-- ==========================================================

-- Test 1: create_hgeo()
SELECT
    'create_hgeo()' AS test_name,
    CASE
        WHEN create_hgeo(
            999,
            'Test Region',
            'region',
            NULL,
            '{"test":"true"}'::jsonb
        )->>'name' = 'Test Region'
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result;


-- Test 2: children()
SELECT
    'children()' AS test_name,
    CASE
        WHEN jsonb_array_length(children(object)) = 2
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM hgeo_objects
WHERE name = 'United States';


-- Test 3: parent()
SELECT
    'parent()' AS test_name,
    CASE
        WHEN parent(object, 'Irvine')->>'name' = 'Orange County'
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM hgeo_objects
WHERE name = 'United States';


-- Test 4: add_child()
WITH
parent_obj AS (
    SELECT create_hgeo(200, 'Parent Region', 'region', NULL, '{}'::jsonb) AS obj
),
child_obj AS (
    SELECT create_hgeo(201, 'Child Region', 'region', NULL, '{}'::jsonb) AS obj
),
combined AS (
    SELECT add_child(parent_obj.obj, child_obj.obj) AS obj
    FROM parent_obj, child_obj
)
SELECT
    'add_child()' AS test_name,
    CASE
        WHEN jsonb_array_length(combined.obj->'children') = 1
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM combined;


-- Test 5: add_region()
WITH
parent_obj AS (
    SELECT create_hgeo(202, 'Parent Region', 'region', NULL, '{}'::jsonb) AS obj
),
region_obj AS (
    SELECT create_hgeo(203, 'Added Region', 'region', NULL, '{}'::jsonb) AS obj
),
combined AS (
    SELECT add_region(parent_obj.obj, region_obj.obj) AS obj
    FROM parent_obj, region_obj
)
SELECT
    'add_region()' AS test_name,
    CASE
        WHEN combined.obj->'children'->0->>'name' = 'Added Region'
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM combined;


-- Test 6: remove_region()
WITH
parent_obj AS (
    SELECT create_hgeo(204, 'Parent Region', 'region', NULL, '{}'::jsonb) AS obj
),
child_obj AS (
    SELECT create_hgeo(205, 'Remove Me', 'region', NULL, '{}'::jsonb) AS obj
),
combined AS (
    SELECT add_child(parent_obj.obj, child_obj.obj) AS obj
    FROM parent_obj, child_obj
),
removed AS (
    SELECT remove_region(combined.obj, 'Remove Me') AS obj
    FROM combined
)
SELECT
    'remove_region()' AS test_name,
    CASE
        WHEN jsonb_array_length(removed.obj->'children') = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM removed;


-- Test 7: hgeo_from_geojson()
SELECT
    'hgeo_from_geojson()' AS test_name,
    CASE
        WHEN hgeo_from_geojson(
            300,
            'GeoJSON Point',
            'point',
            '{"type":"Point","coordinates":[-117.8265,33.6846]}'::jsonb,
            '{}'::jsonb
        )->'geometry'->>'type' = 'Point'
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result;


-- Test 8: hgeo_to_geojson()
SELECT
    'hgeo_to_geojson()' AS test_name,
    CASE
        WHEN hgeo_to_geojson(object)->>'type' = 'FeatureCollection'
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM hgeo_objects
WHERE name = 'United States';


-- Test 9: hgeo_contans()
WITH
region AS (
    SELECT hgeo_from_geojson(
        400,
        'Test Box',
        'region',
        '{
            "type":"Polygon",
            "coordinates":[[
                [-118.0,33.5],
                [-117.5,33.5],
                [-117.5,34.0],
                [-118.0,34.0],
                [-118.0,33.5]
            ]]
        }'::jsonb,
        '{}'::jsonb
    ) AS obj
),
point AS (
    SELECT hgeo_from_geojson(
        401,
        'Inside Point',
        'point',
        '{"type":"Point","coordinates":[-117.75,33.75]}'::jsonb,
        '{}'::jsonb
    ) AS obj
)
SELECT
    'hgeo_contains()' AS test_name,
    CASE
        WHEN hgeo_contains(region.obj, point.obj) = true
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM region, point;


-- Test 10: hgeo_intersects()
WITH
region AS (
    SELECT hgeo_from_geojson(
        402,
        'Test Box',
        'region',
        '{
            "type":"Polygon",
            "coordinates":[[
                [-118.0,33.5],
                [-117.5,33.5],
                [-117.5,34.0],
                [-118.0,34.0],
                [-118.0,33.5]
            ]]
        }'::jsonb,
        '{}'::jsonb
    ) AS obj
),
point AS (
    SELECT hgeo_from_geojson(
        403,
        'Inside Point',
        'point',
        '{"type":"Point","coordinates":[-117.75,33.75]}'::jsonb,
        '{}'::jsonb
    ) AS obj
)
SELECT
    'hgeo_intersects()' AS test_name,
    CASE
        WHEN hgeo_intersects(region.obj, point.obj) = true
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM region, point;


-- Test 11: hgeo_nearest()
WITH
target AS (
    SELECT hgeo_from_geojson(
        500,
        'Target',
        'point',
        '{"type":"Point","coordinates":[-117.8,33.7]}'::jsonb,
        '{}'::jsonb
    ) AS obj
),
near_candidate AS (
    SELECT hgeo_from_geojson(
        501,
        'Near Candidate',
        'point',
        '{"type":"Point","coordinates":[-117.81,33.71]}'::jsonb,
        '{}'::jsonb
    ) AS obj
),
far_candidate AS (
    SELECT hgeo_from_geojson(
        502,
        'Far Candidate',
        'point',
        '{"type":"Point","coordinates":[-119.0,35.0]}'::jsonb,
        '{}'::jsonb
    ) AS obj
)
SELECT
    'hgeo_nearest()' AS test_name,
    CASE
        WHEN hgeo_nearest(
            target.obj,
            ARRAY[near_candidate.obj, far_candidate.obj]::hgeo[]
        )->>'name' = 'Near Candidate'
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM target, near_candidate, far_candidate;


-- Test 12: visualize()
SELECT
    'visualize()' AS test_name,
    CASE
        WHEN visualize(object)->>'type' = 'FeatureCollection'
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM hgeo_objects
WHERE name = 'United States';