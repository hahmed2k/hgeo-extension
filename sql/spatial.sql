-- ==========================================================
-- HGeo PostGIS Spatial Support
-- Phase 4
-- ==========================================================

CREATE OR REPLACE FUNCTION hgeo_geometry(obj hgeo)
RETURNS geometry
LANGUAGE sql
AS $$
    SELECT ST_SetSRID(
        ST_GeomFromGeoJSON((obj->'geometry')::text),
        4326
    );
$$;

CREATE OR REPLACE FUNCTION hgeo_contains(a hgeo, b hgeo)
RETURNS BOOLEAN
LANGUAGE sql
AS $$
    SELECT ST_Contains(
        hgeo_geometry(a),
        hgeo_geometry(b)
    );
$$;

CREATE OR REPLACE FUNCTION hgeo_intersects(a hgeo, b hgeo)
RETURNS BOOLEAN
LANGUAGE sql
AS $$
    SELECT ST_Intersects(
        hgeo_geometry(a),
        hgeo_geometry(b)
    );
$$;

CREATE OR REPLACE FUNCTION hgeo_overlaps(a hgeo, b hgeo)
RETURNS BOOLEAN
LANGUAGE sql
AS $$
    SELECT ST_Overlaps(
        hgeo_geometry(a),
        hgeo_geometry(b)
    );
$$;

CREATE OR REPLACE FUNCTION hgeo_distance(a hgeo, b hgeo)
RETURNS DOUBLE PRECISION
LANGUAGE sql
AS $$
    SELECT ST_Distance(
        hgeo_geometry(a)::geography,
        hgeo_geometry(b)::geography
    );
$$;

CREATE OR REPLACE FUNCTION hgeo_bounding_box(obj hgeo)
RETURNS jsonb
LANGUAGE sql
AS $$
    SELECT ST_AsGeoJSON(
        ST_Envelope(hgeo_geometry(obj))
    )::jsonb;
$$;

CREATE OR REPLACE FUNCTION hgeo_nearest(target hgeo, candidates hgeo[])
RETURNS hgeo
LANGUAGE plpgsql
AS $$
DECLARE
    candidate hgeo;
    nearest_candidate hgeo;
    min_distance DOUBLE PRECISION := NULL;
    current_distance DOUBLE PRECISION;
BEGIN
    FOREACH candidate IN ARRAY candidates
    LOOP
        current_distance := hgeo_distance(target, candidate);

        IF min_distance IS NULL OR current_distance < min_distance THEN
            min_distance := current_distance;
            nearest_candidate := candidate;
        END IF;
    END LOOP;

    RETURN nearest_candidate;
END;
$$;



