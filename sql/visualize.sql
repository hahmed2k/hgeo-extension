-- ==========================================================
-- HGeo Visualization Support
-- Phase 5
-- ==========================================================

CREATE OR REPLACE FUNCTION visualize(obj hgeo)
RETURNS jsonb
LANGUAGE sql
AS $$
    SELECT hgeo_to_geojson(obj);
$$;


