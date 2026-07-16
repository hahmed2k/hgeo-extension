-- ==========================================================
-- HGeo PostgreSQL Extension
-- ==========================================================
-- Haroon Ahmed
-- DATA 220P
-- Project: Hierarchical Geography Data Type for PostgreSQL
-- Purpose: Suite for Phsae 3 Regression Testing
-- ==========================================================

-- Test 1: Import a Point GeoJSON object into HGeo
SELECT hgeo_from_geojson(
    10,
    'UC Irvine',
    'point',
    '{"type":"Point","coordinates":[-117.8427,33.6405]}'::jsonb,
    '{"description":"UC Irvine campus"}'::jsonb
);

-- Test 2: Import a Polygon GeoJSON object into HGeo
SELECT hgeo_from_geojson(
    11,
    'Sample Region',
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
    '{"description":"Sample polygon region"}'::jsonb
);

-- Test 3: Validate invalid GeoJSON
SELECT hgeo_is_valid_geojson(
    '{"type":"InvalidShape","coordinates":[]}'::jsonb
);

-- Test 4: Export existing HGeo hierarchy to GeoJSON
SELECT hgeo_to_geojson(object)
FROM hgeo_objects
WHERE name = 'United States';