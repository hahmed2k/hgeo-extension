-- ==========================================================
-- HGeo PostgreSQL Extension
-- Version: 1.0
--
-- Hierarchical Geography data type with:
--   - JSONB-backed hierarchy storage
--   - GeoJSON import and export
--   - PostGIS spatial operations
--   - Leaflet-ready visualization output
-- ==========================================================


-- ==========================================================
-- Core HGeo domain and storage table
-- ==========================================================

CREATE DOMAIN hgeo AS jsonb
CHECK (
    VALUE ? 'id'
    AND VALUE ? 'name'
    AND VALUE ? 'level'
    AND VALUE ? 'geometry'
    AND VALUE ? 'centroid'
    AND VALUE ? 'raster'
    AND VALUE ? 'metadata'
    AND VALUE ? 'children'
);

CREATE TABLE hgeo_objects (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    object hgeo NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ==========================================================
-- Core hierarchy functions
-- ==========================================================

CREATE FUNCTION create_hgeo(
    id INTEGER,
    name TEXT,
    level TEXT,
    geometry JSONB DEFAULT NULL,
    metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS hgeo
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT jsonb_build_object(
        'id', id,
        'name', name,
        'level', level,
        'geometry', geometry,
        'centroid', NULL,
        'raster', NULL,
        'metadata', metadata,
        'children', '[]'::jsonb
    )::hgeo;
$$;


CREATE FUNCTION children(obj hgeo)
RETURNS jsonb
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT obj->'children';
$$;


CREATE FUNCTION add_child(parent hgeo, child hgeo)
RETURNS hgeo
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT jsonb_set(
        parent::jsonb,
        '{children}',
        COALESCE(parent->'children', '[]'::jsonb)
            || jsonb_build_array(child::jsonb)
    )::hgeo;
$$;


CREATE FUNCTION add_region(parent hgeo, region hgeo)
RETURNS hgeo
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT add_child(parent, region);
$$;


CREATE FUNCTION remove_region(obj hgeo, region_name TEXT)
RETURNS hgeo
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT jsonb_set(
        obj::jsonb,
        '{children}',
        COALESCE(
            (
                SELECT jsonb_agg(child)
                FROM jsonb_array_elements(obj->'children') AS child
                WHERE child->>'name' <> region_name
            ),
            '[]'::jsonb
        )
    )::hgeo;
$$;


CREATE FUNCTION parent(root hgeo, child_name TEXT)
RETURNS hgeo
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    child jsonb;
    result hgeo;
BEGIN
    FOR child IN
        SELECT value
        FROM jsonb_array_elements(root->'children')
    LOOP
        IF child->>'name' = child_name THEN
            RETURN root;
        END IF;

        result := parent(child::hgeo, child_name);

        IF result IS NOT NULL THEN
            RETURN result;
        END IF;
    END LOOP;

    RETURN NULL;
END;
$$;


-- ==========================================================
-- GeoJSON validation, import, and export
-- ==========================================================

CREATE FUNCTION hgeo_is_valid_geojson(geojson JSONB)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
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


CREATE FUNCTION hgeo_from_geojson(
    id INTEGER,
    name TEXT,
    level TEXT,
    geojson JSONB,
    metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS hgeo
LANGUAGE plpgsql
IMMUTABLE
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
        properties := COALESCE(
            geojson->'properties',
            '{}'::jsonb
        );

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


CREATE FUNCTION hgeo_to_geojson_with_parent(
    obj hgeo,
    parent_name TEXT DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    features jsonb := '[]'::jsonb;
    child jsonb;
    child_collection jsonb;
    current_feature jsonb;
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
            'child_count',
                jsonb_array_length(obj->'children')
        )
    );

    features := features
        || jsonb_build_array(current_feature);

    FOR child IN
        SELECT value
        FROM jsonb_array_elements(obj->'children')
    LOOP
        child_collection :=
            hgeo_to_geojson_with_parent(
                child::hgeo,
                obj->>'name'
            );

        features := features
            || child_collection->'features';
    END LOOP;

    RETURN jsonb_build_object(
        'type', 'FeatureCollection',
        'features', features
    );
END;
$$;


CREATE FUNCTION hgeo_to_geojson(obj hgeo)
RETURNS jsonb
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT hgeo_to_geojson_with_parent(obj, NULL);
$$;


-- ==========================================================
-- PostGIS integration
-- ==========================================================

CREATE FUNCTION hgeo_geometry(obj hgeo)
RETURNS geometry
LANGUAGE sql
IMMUTABLE
STRICT
AS $$
    SELECT ST_SetSRID(
        ST_GeomFromGeoJSON((obj->'geometry')::text),
        4326
    );
$$;


CREATE FUNCTION hgeo_contains(a hgeo, b hgeo)
RETURNS BOOLEAN
LANGUAGE sql
IMMUTABLE
STRICT
AS $$
    SELECT ST_Contains(
        hgeo_geometry(a),
        hgeo_geometry(b)
    );
$$;


CREATE FUNCTION hgeo_intersects(a hgeo, b hgeo)
RETURNS BOOLEAN
LANGUAGE sql
IMMUTABLE
STRICT
AS $$
    SELECT ST_Intersects(
        hgeo_geometry(a),
        hgeo_geometry(b)
    );
$$;


CREATE FUNCTION hgeo_overlaps(a hgeo, b hgeo)
RETURNS BOOLEAN
LANGUAGE sql
IMMUTABLE
STRICT
AS $$
    SELECT ST_Overlaps(
        hgeo_geometry(a),
        hgeo_geometry(b)
    );
$$;


CREATE FUNCTION hgeo_distance(a hgeo, b hgeo)
RETURNS DOUBLE PRECISION
LANGUAGE sql
IMMUTABLE
STRICT
AS $$
    SELECT ST_Distance(
        hgeo_geometry(a)::geography,
        hgeo_geometry(b)::geography
    );
$$;


CREATE FUNCTION hgeo_bounding_box(obj hgeo)
RETURNS jsonb
LANGUAGE sql
IMMUTABLE
STRICT
AS $$
    SELECT ST_AsGeoJSON(
        ST_Envelope(hgeo_geometry(obj))
    )::jsonb;
$$;


CREATE FUNCTION hgeo_nearest(
    target hgeo,
    candidates hgeo[]
)
RETURNS hgeo
LANGUAGE plpgsql
IMMUTABLE
STRICT
AS $$
DECLARE
    candidate hgeo;
    nearest_candidate hgeo;
    minimum_distance DOUBLE PRECISION := NULL;
    current_distance DOUBLE PRECISION;
BEGIN
    FOREACH candidate IN ARRAY candidates
    LOOP
        current_distance :=
            hgeo_distance(target, candidate);

        IF minimum_distance IS NULL
           OR current_distance < minimum_distance
        THEN
            minimum_distance := current_distance;
            nearest_candidate := candidate;
        END IF;
    END LOOP;

    RETURN nearest_candidate;
END;
$$;


-- ==========================================================
-- Visualization
-- ==========================================================

CREATE FUNCTION visualize(obj hgeo)
RETURNS jsonb
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT hgeo_to_geojson(obj);
$$;


-- ==========================================================
-- Object descriptions
-- ==========================================================

COMMENT ON DOMAIN hgeo IS
'JSONB-backed hierarchical geography object';

COMMENT ON TABLE hgeo_objects IS
'Stores root HGeo objects and complete geographic hierarchies';

COMMENT ON FUNCTION create_hgeo(
    INTEGER,
    TEXT,
    TEXT,
    JSONB,
    JSONB
) IS
'Constructs a new HGeo object';

COMMENT ON FUNCTION visualize(hgeo) IS
'Exports an HGeo hierarchy as a GeoJSON FeatureCollection';