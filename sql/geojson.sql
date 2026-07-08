-- ==========================================================
-- HGeo GeoJSON Support
-- Phase 3 ****UPDATED FOR VISUALIZATION PHASE DURING PHASE 6****
-- ==========================================================

CREATE OR REPLACE FUNCTION hgeo_is_valid_geojson(geojson JSONB)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    geojson_type TEXT;
BEGIN
    IF geojson IS NULL THEN
        RETURN TRUE;
    END IF;

    geojson_type := geojson->>'type';

    IF geojson_type IN (
        'Point',
        'LineString',
        'Polygon',
        'MultiPoint',
        'MultiLineString',
        'MultiPolygon',
        'GeometryCollection',
        'Feature'
    ) THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;
END;
$$;


CREATE OR REPLACE FUNCTION hgeo_from_geojson(
    id INTEGER,
    name TEXT,
    level TEXT,
    geojson JSONB,
    metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS hgeo
LANGUAGE plpgsql
AS $$
DECLARE
    geometry JSONB;
    properties JSONB;
BEGIN
    IF NOT hgeo_is_valid_geojson(geojson) THEN
        RAISE EXCEPTION 'Invalid GeoJSON input: %', geojson;
    END IF;

    IF geojson IS NULL THEN
        geometry := NULL;
        properties := '{}'::jsonb;

    ELSIF geojson->>'type' = 'Feature' THEN
        geometry := geojson->'geometry';
        properties := COALESCE(geojson->'properties', '{}'::jsonb);

    ELSE
        geometry := geojson;
        properties := '{}'::jsonb;
    END IF;

    RETURN create_hgeo(
        id,
        name,
        level,
        geometry,
        metadata || properties
    );
END;
$$;


CREATE OR REPLACE FUNCTION hgeo_to_geojson_with_parent(
    obj hgeo,
    parent_name TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    features JSONB := '[]'::jsonb;
    child JSONB;
    child_collection JSONB;
    current_feature JSONB;
BEGIN
    current_feature := jsonb_build_object(
        'type', 'Feature',
        'geometry', obj->'geometry',
        'properties', jsonb_build_object(
            'id', obj->'id',
            'name', obj->'name',
            'level', obj->'level',
            'parent', parent_name,
            'metadata', obj->'metadata',
            'centroid', obj->'centroid',
            'raster', obj->'raster',
            'child_count', jsonb_array_length(obj->'children')
        )
    );

    features := features || jsonb_build_array(current_feature);

    FOR child IN
        SELECT value
        FROM jsonb_array_elements(obj->'children')
    LOOP
        child_collection := hgeo_to_geojson_with_parent(
            child::hgeo,
            obj->>'name'
        );

        features := features || (child_collection->'features');
    END LOOP;

    RETURN jsonb_build_object(
        'type', 'FeatureCollection',
        'features', features
    );
END;
$$;


CREATE OR REPLACE FUNCTION hgeo_to_geojson(obj hgeo)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT hgeo_to_geojson_with_parent(obj, NULL);
$$;












