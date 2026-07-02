DROP TABLE IF EXISTS hgeo_objects;
DROP DOMAIN IF EXISTS hgeo;

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