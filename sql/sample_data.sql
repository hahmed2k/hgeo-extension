-- ==========================================================
-- HGeo Sample data
-- Phase 6
-- ==========================================================

DELETE FROM hgeo_objects;

-- ==========================================================
-- Administrative Geography Hierarchy
-- United States > State > County > City
-- ==========================================================

WITH
usa AS (
    SELECT hgeo_from_geojson(
        1,
        'United States',
        'country',
        '{
            "type":"Polygon",
            "coordinates":[[
                [-125.0, 24.0],
                [-66.0, 24.0],
                [-66.0, 49.5],
                [-125.0, 49.5],
                [-125.0, 24.0]
            ]]
        }'::jsonb,
        '{"description":"Approximate bounding region for the contiguous United States"}'::jsonb
    ) AS obj
),

california AS (
    SELECT hgeo_from_geojson(
        2,
        'California',
        'state',
        '{
            "type":"Polygon",
            "coordinates":[[
                [-124.48, 32.53],
                [-114.13, 32.53],
                [-114.13, 42.01],
                [-124.48, 42.01],
                [-124.48, 32.53]
            ]]
        }'::jsonb,
        '{"country":"United States"}'::jsonb
    ) AS obj
),

texas AS (
    SELECT hgeo_from_geojson(
        3,
        'Texas',
        'state',
        '{
            "type":"Polygon",
            "coordinates":[[
                [-106.65, 25.84],
                [-93.51, 25.84],
                [-93.51, 36.50],
                [-106.65, 36.50],
                [-106.65, 25.84]
            ]]
        }'::jsonb,
        '{"country":"United States"}'::jsonb
    ) AS obj
),

orange_county AS (
    SELECT hgeo_from_geojson(
        4,
        'Orange County',
        'county',
        '{
            "type":"Polygon",
            "coordinates":[[
                [-118.10, 33.40],
                [-117.40, 33.40],
                [-117.40, 34.10],
                [-118.10, 34.10],
                [-118.10, 33.40]
            ]]
        }'::jsonb,
        '{"state":"California"}'::jsonb
    ) AS obj
),

los_angeles AS (
    SELECT hgeo_from_geojson(
        5,
        'Los Angeles County',
        'county',
        '{
            "type":"Polygon",
            "coordinates":[[
                [-119.00, 33.60],
                [-117.60, 33.60],
                [-117.60, 34.90],
                [-119.00, 34.90],
                [-119.00, 33.60]
            ]]
        }'::jsonb,
        '{"state":"California"}'::jsonb
    ) AS obj
),

irvine AS (
    SELECT hgeo_from_geojson(
        6,
        'Irvine',
        'city',
        '{"type":"Point","coordinates":[-117.8265,33.6846]}'::jsonb,
        '{"county":"Orange County"}'::jsonb
    ) AS obj
),

newport AS (
    SELECT hgeo_from_geojson(
        7,
        'Newport Beach',
        'city',
        '{"type":"Point","coordinates":[-117.9298,33.6189]}'::jsonb,
        '{"county":"Orange County"}'::jsonb
    ) AS obj
),

oc_with_cities AS (
    SELECT add_child(
        add_child(orange_county.obj, irvine.obj),
        newport.obj
    ) AS obj
    FROM orange_county, irvine, newport
),

ca_with_counties AS (
    SELECT add_child(
        add_child(california.obj, oc_with_cities.obj),
        los_angeles.obj
    ) AS obj
    FROM california, oc_with_cities, los_angeles
),

usa_full AS (
    SELECT add_child(
        add_child(usa.obj, ca_with_counties.obj),
        texas.obj
    ) AS obj
    FROM usa, ca_with_counties, texas
)

INSERT INTO hgeo_objects(name, object)
SELECT 'United States', obj
FROM usa_full;

-- ==========================================================
-- Wildfire Event Examples
-- ==========================================================

DROP TABLE IF EXISTS wildfire_events;

CREATE TABLE wildfire_events (
    id SERIAL PRIMARY KEY,
    event_name TEXT NOT NULL,
    affected_region hgeo NOT NULL,
    severity TEXT,
    event_date DATE
);

INSERT INTO wildfire_events(event_name, affected_region, severity, event_date)
VALUES
(
    'Orange County Wildfire Zone',
    hgeo_from_geojson(
        100,
        'Orange County Wildfire Zone',
        'wildfire_event',
        '{
            "type":"Polygon",
            "coordinates":[[
                [-117.90, 33.65],
                [-117.70, 33.65],
                [-117.70, 33.85],
                [-117.90, 33.85],
                [-117.90, 33.65]
            ]]
        }'::jsonb,
        '{"event_type":"wildfire","county":"Orange County"}'::jsonb
    ),
    'Moderate',
    '2026-07-01'
),
(
    'Irvine Smoke Impact Point',
    hgeo_from_geojson(
        101,
        'Irvine Smoke Impact Point',
        'wildfire_event',
        '{"type":"Point","coordinates":[-117.8265,33.6846]}'::jsonb,
        '{"event_type":"smoke_impact","city":"Irvine"}'::jsonb
    ),
    'Low',
    '2026-07-02'
);
































