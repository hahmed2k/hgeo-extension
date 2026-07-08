CREATE OR REPLACE FUNCTION create_hgeo(
    id INTEGER,
    name TEXT,
    level TEXT,
    geometry JSONB DEFAULT NULL,
    metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS hgeo
LANGUAGE sql
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

CREATE OR REPLACE FUNCTION children(obj hgeo)
RETURNS jsonb
LANGUAGE sql
AS $$
    SELECT obj->'children';
$$;

CREATE OR REPLACE FUNCTION add_child(parent hgeo, child hgeo)
RETURNS hgeo
LANGUAGE sql
AS $$
    SELECT jsonb_set(
        parent::jsonb,
        '{children}',
        COALESCE(parent->'children', '[]'::jsonb) || jsonb_build_array(child::jsonb)
    )::hgeo;
$$;

CREATE OR REPLACE FUNCTION add_region(parent hgeo, region hgeo)
RETURNS hgeo
LANGUAGE sql
AS $$
    SELECT add_child(parent, region);
$$;

CREATE OR REPLACE FUNCTION remove_region(obj hgeo, region_name TEXT)
RETURNS hgeo
LANGUAGE sql
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

CREATE OR REPLACE FUNCTION parent(root hgeo, child_name TEXT)
RETURNS hgeo
LANGUAGE plpgsql
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





