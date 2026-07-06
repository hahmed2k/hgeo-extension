-- ==========================================================
-- HGeo PostgreSQL Extension
-- ==========================================================
-- Haroon Ahmed
-- DATA 220P
-- Project: Hierarchical Geography Data Type for PostgreSQL
-- Purpose: Suite for Phase 4 Regression Testing
-- ==========================================================

-- Test 1: Create polygon and point HGeo objects
WITH
region AS (
    SELECT hgeo_from_geojson(
        100,
        'Sample Box',
        'region',
        '{
            "type":"Polygon",
            "coordinates":[
                [
                    [-118.0,33.5],
                    [-117.5,33.5],
                    [-117.5,34.0],
                    [-118.0,34.0],
                    [-118.0,33.5]
                ]
            ]
        }'::jsonb,
        '{"description":"Test polygon"}'::jsonb
    ) AS obj
),
inside_point AS (
    SELECT hgeo_from_geojson(
        101,
        'Inside Point',
        'point',
        '{"type":"Point","coordinates":[-117.75,33.75]}'::jsonb,
        '{}'::jsonb
    ) AS obj
),
outside_point AS (
    SELECT hgeo_from_geojson(
        102,
        'Outside Point',
        'point',
        '{"type":"Point","coordinates":[-119.0,35.0]}'::jsonb,
        '{}'::jsonb
    ) AS obj
)
SELECT
    hgeo_contains(region.obj, inside_point.obj) AS contains_inside,
    hgeo_contains(region.obj, outside_point.obj) AS contains_outside,
    hgeo_intersects(region.obj, inside_point.obj) AS intersects_inside,
    hgeo_distance(inside_point.obj, outside_point.obj) AS distance_meters
FROM region, inside_point, outside_point;

-- Test 2: Bounding box
SELECT hgeo_bounding_box(
    hgeo_from_geojson(
        103,
        'Sample Box',
        'region',
        '{
            "type":"Polygon",
            "coordinates":[
                [
                    [-118.0,33.5],
                    [-117.5,33.5],
                    [-117.5,34.0],
                    [-118.0,34.0],
                    [-118.0,33.5]
                ]
            ]
        }'::jsonb,
        '{}'::jsonb
    )
);

-- Test 3: Overlap between two polygons
WITH
box1 AS (
    SELECT hgeo_from_geojson(
        104,
        'Box 1',
        'region',
        '{
            "type":"Polygon",
            "coordinates":[
                [
                    [-118.0,33.5],
                    [-117.5,33.5],
                    [-117.5,34.0],
                    [-118.0,34.0],
                    [-118.0,33.5]
                ]
            ]
        }'::jsonb,
        '{}'::jsonb
    ) AS obj
),
box2 AS (
    SELECT hgeo_from_geojson(
        105,
        'Box 2',
        'region',
        '{
            "type":"Polygon",
            "coordinates":[
                [
                    [-117.75,33.75],
                    [-117.25,33.75],
                    [-117.25,34.25],
                    [-117.75,34.25],
                    [-117.75,33.75]
                ]
            ]
        }'::jsonb,
        '{}'::jsonb
    ) AS obj
)
SELECT
    hgeo_intersects(box1.obj, box2.obj) AS intersects,
    hgeo_overlaps(box1.obj, box2.obj) AS overlaps
FROM box1, box2;

-- Test 4: Nearest HGeo
WITH
target AS (
    SELECT hgeo_from_geojson(
        106,
        'Target',
        'point',
        '{"type":"Point","coordinates":[-117.8,33.7]}'::jsonb,
        '{}'::jsonb
    ) AS obj
),
candidate1 AS (
    SELECT hgeo_from_geojson(
        107,
        'Near Candidate',
        'point',
        '{"type":"Point","coordinates":[-117.81,33.71]}'::jsonb,
        '{}'::jsonb
    ) AS obj
),
candidate2 AS (
    SELECT hgeo_from_geojson(
        108,
        'Far Candidate',
        'point',
        '{"type":"Point","coordinates":[-119.0,35.0]}'::jsonb,
        '{}'::jsonb
    ) AS obj
)
SELECT hgeo_nearest(
    target.obj,
    ARRAY[candidate1.obj, candidate2.obj]::hgeo[]
)
FROM target, candidate1, candidate2;