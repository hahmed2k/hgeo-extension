-- ==========================================================
-- HGeo PostgreSQL Extension
-- ==========================================================
-- Haroon Ahmed
-- DATA 220P
-- Project: "Hierarchical Geography Data Type for PostgreSQL"
-- Purpose: Suite for Phase 2 Regression Testing
-- ==========================================================


-- Clear existing test data
DELETE FROM hgeo_objects;

-- Test 1: Create a single HGeo object
SELECT create_hgeo(
    1,
    'California',
    'state',
    NULL,
    '{"country":"United States"}'::jsonb
);

-- Test 2: Create and insert sample hierarchy
WITH
usa AS (
    SELECT create_hgeo(1, 'United States', 'country', NULL, '{}'::jsonb) AS obj
),
california AS (
    SELECT create_hgeo(2, 'California', 'state', NULL, '{"country":"United States"}'::jsonb) AS obj
),
texas AS (
    SELECT create_hgeo(3, 'Texas', 'state', NULL, '{"country":"United States"}'::jsonb) AS obj
),
orange_county AS (
    SELECT create_hgeo(4, 'Orange County', 'county', NULL, '{"state":"California"}'::jsonb) AS obj
),
los_angeles AS (
    SELECT create_hgeo(5, 'Los Angeles County', 'county', NULL, '{"state":"California"}'::jsonb) AS obj
),
irvine AS (
    SELECT create_hgeo(6, 'Irvine', 'city', NULL, '{"county":"Orange County"}'::jsonb) AS obj
),
newport AS (
    SELECT create_hgeo(7, 'Newport Beach', 'city', NULL, '{"county":"Orange County"}'::jsonb) AS obj
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

-- Test 3: View full hierarchy
SELECT name, object
FROM hgeo_objects;

-- Test 4: View direct children of United States
SELECT children(object)
FROM hgeo_objects
WHERE name = 'United States';

-- Test 5: Find parent of Irvine
SELECT parent(object, 'Irvine')
FROM hgeo_objects
WHERE name = 'United States';

-- Test 6: Remove Texas from United States direct children
UPDATE hgeo_objects
SET object = remove_region(object, 'Texas')
WHERE name = 'United States';

-- Test 7: Confirm Texas was removed
SELECT children(object)
FROM hgeo_objects
WHERE name = 'United States';