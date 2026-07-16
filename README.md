# Hierarchical Geography (HGeo) Extension for PostgreSQL

## Overview

The Hierarchical Geography (HGeo) Extension is a PostgreSQL extension that introduces a hierarchical geographic data type that's capable of representing nested geographic regions while leveraging PostGIS for spatial operations.

Unlike traditional geographic objects, the HGeo extension stores entire geographic hierarchies (countries, states, counties, cities) within a single recursive object.

This project was created for Professor Mehrotra and serves as the final project for **DATA 220P**.

---

## Motivation

Many geographic datasets are naturally hierarchical.

- United States
- ---> California
- ------> Orange County
- ---------> Irvine
- ---------> Newport Beach
- ------> Los Angeles County
- ---> Texas

While PostGIS provides excellent support for geometry, it doesn't provide a native hierarchical geographic object.

That's where the extension comes in. HGeo fills this gap by providing:

- recursive geographic objects
- hierarchy navigation
- GeoJSON support
- PostGIS integration
- interactive visualization

---

## Project Phases

- Preliminary Phase: Understanding project instructions/concepts/scope to plan roadmap
- Phase 1: Setting up the environment 
- Phase 2: Implementing the core data type HGeo object 
- Phase 3: GeoJSON Support
- Phase 4: PostGIS integration 
- Phase 5: Visualization function implementation 
- Phase 6: Sample Data/Demo Datasets
- Phase 7: Testing functions
- Phase 8: Documentation
- Phase 9: Final checks

---

## Features

- Hierarchical Geography (HGeo) data type
- Recursive parent-child geographic relationships
- JSONB-backed storage
- GeoJSON import/export
- PostGIS spatial operations
- Interactive Leaflet visualization
- Wildfire demo dataset

---

## Technologies

- PostgreSQL 17
- PostGIS
- JSONB
- PL/pgSQL
- HTML
- CSS
- JavaScript
- VS Code
- Python
- Git
- Github
- Leaflet

---

## Project Structure

```
hgeo-extension/

├── docs/
│   ├── architecture.md
│   ├── demo.md
│   ├── examples.sql
│   ├── hgeo_architecture.png
│   └── installation.md
│
├── sql/
│   ├── functions.sql
│   ├── geojson.sql
│   ├── sample_data.sql
│   ├── schema.sql
│   ├── spatial.sql
│   └── visualize.sql
│
├── tests/
│   ├── test_phase2.sql
│   ├── test_phase3.sql
│   ├── test_phase4.sql
│   └── test_all.sql
│
├── visualization/
│   ├── app.js
│   ├── hgeo-data.js
│   ├── index.html
│   ├── sample.geojson
│   └── style.css
│
├── README.md
├── hgeo--1.0.sql
├── hgeo.control
└── .gitignore
```

---

## Streamlined Project Architecture

```
PostgreSQL
      │
      ▼
 HGeo Extension
      │
      ▼
GeoJSON Export
      │
      ▼
Leaflet Visualization
```

See `docs/architecture.md` for detailed diagram and breakdown.

---

## Example Workflow

```
sample_data.sql

↓

hgeo_objects

↓

SELECT visualize(object)

↓

GeoJSON

↓

Leaflet

↓

Interactive Map
```

---

## Example SQL

Create a hierarchical geography:

```sql
SELECT create_hgeo(...);
```

Export GeoJSON:

```sql
SELECT visualize(object)
FROM hgeo_objects;
```

Find nearest region:

```sql
SELECT hgeo_nearest(...);
```

---

## Testing

The project includes a complete testing script/suite for the following:

- create_hgeo()
- add_region()
- remove_region()
- add_child()
- parent()
- children()
- GeoJSON support
- PostGIS operations
- visualization

---

## Sample Dataset

Administrative hierarchy:

- United States
- California
- Texas
- Orange County
- Los Angeles County
- Irvine
- Newport Beach

Wildfire examples:

- Orange County Wildfire Zone
- Irvine Smoke Impact Point

---

## Visualization

The project includes an interactive Leaflet visualization which displays:

- polygons
- markers
- hierarchy navigation
- parent highlighting
- popups
- GeoJSON exported directly from PostgreSQL

---

## Deliverables Summary

| Deliverable(s) | File(s) |
|--------------|----------|
| PostgreSQL Extension | `hgeo.control`, `hgeo--1.0.sql` |
| Source Code | `sql/`, `visualization/` |
| SQL Scripts | `sql/`, `tests/test_all.sql`, `docs/examples.sql` |
| Documentation | `README.md`, `docs/` |
| Demo | `docs/demo.md`, `visualization/` |
| Example Datasets | `sql/sample_data.sql` |
| Installation Instructions | `docs/installation.md` |

---

## Author

Haroon Ahmed

University of California, Irvine

Master of Data Science (MDS)












