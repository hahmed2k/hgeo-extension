# HGeo Extension Demo Guide

This guide will help demonstrate the primary capabilities of the HGeo extension. It is  assumed the project has already been installed by following the instructions in `docs/installation.md`.

---

# Step 1: Open Project

1. Open **pgAdmin 4**.
2. Connect to your local PostgreSQL server.
3. Expand **Databases** and select the **hgeo_demo** database.
4. Open the **Query Tool**.

All SQL queries in this guide should be executed using the **pgAdmin Query Tool** unless specified.

---

# Step 2: View Hierarchical Geography

Execute the following query:

```sql
SELECT name, object
FROM hgeo_objects;
```

Expected result(s):

- The `United States` hierarchy should be displayed.
- California, Texas, Orange County, Los Angeles County, Irvine, and Newport Beach are nested within the hierarchy.

This demonstrates:

- Recursive HGeo objects
- JSONB-backed storage
- Hierarchical geographic representation

---

# Step 3: Navigate Hierarchy

Retrieve children of the United States:

```sql
SELECT children(object)
FROM hgeo_objects
WHERE name = 'United States';
```

Find parent of Irvine:

```sql
SELECT parent(object, 'Irvine')
FROM hgeo_objects
WHERE name = 'United States';
```

Expected result(s):

- The first query should return California and Texas.
- The second query should return Orange County.

This demonstrates:

- Parent-child navigation
- Recursive hierarchy traversal

---

# Step 4: Export Hierarchy as GeoJSON

Execute:

```sql
SELECT visualize(object)
FROM hgeo_objects
WHERE name = 'United States';
```

Expected result(s):

- A GeoJSON `FeatureCollection` containing the complete hierarchy is returned.

This demonstrates:

- GeoJSON export
- Hierarchy preservation
- Visualization support

---

# Step 5: Execute Spatial Queries

The project includes wrappers around PostGIS spatial functions.

Examples include:

- `hgeo_contains()`
- `hgeo_intersects()`
- `hgeo_overlaps()`
- `hgeo_distance()`
- `hgeo_nearest()`
- `hgeo_bounding_box()`

To see working examples of each function, open the file:

```
examples.sql
```

Execute the desired example(s) via the pgAdmin Query Tool.

Expected result(s):

- Spatial relationships and measurements are computed using PostGIS.

---

# Step 6: Launch Interactive Visualization

Open **Terminal**.

Navigate to the visualization directory:

```bash
cd visualization
```

Start a local web server:

```bash
python3 -m http.server 8000
```

Open web browser and navigate to:

```
http://localhost:8000
```

Expected result(s):

An interactive Leaflet map should be displayed showing the following:

- the United States hierarchy
- polygons
- city markers
- hierarchy sidebar
- popups
- parent highlighting
- color-coded geographic levels

---

# Step 7: Demonstrate the Wildfire Dataset

Return to **pgAdmin**.

Execute:

```sql
SELECT
    event_name,
    severity,
    event_date,
    visualize(affected_region)
FROM wildfire_events;
```

Expected result(s):

- The wildfire events are displayed.
- Each event can be exported as GeoJSON using the `visualize()` function.

This demonstrates that the HGeo Extension supports application-specific geographic datasets in addition to administrative regions.

---

# Step 8: Run the Test Suite (Optional)

To verify the implementation, open:

```
tests/test_all.sql
```

Execute the script using the pgAdmin Query Tool.

Expected result(s):

Each test should return:

```
PASS
```

---

# Demonstration Summary

This demonstration verifies that the HGeo Extension can:

- Create hierarchical geographic objects
- Navigate parent-child relationships
- Import and export GeoJSON
- Execute PostGIS spatial operations
- Visualize geographic hierarchies with Leaflet
- Support real-world application datasets such as wildfire events

---

# Additional Documentation

- `README.md` — Project overview
- `docs/installation.md` — Installation instructions
- `docs/architecture.md` — System architecture
- `docs/examples.sql` — Example SQL queries
- `tests/test_all.sql` — Complete test suite