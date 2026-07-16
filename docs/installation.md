# Project Installation Guide

These instructions will explain how to install and run the HGeo extension.

---

# System Requirements

- macOS (Project created & tested on macOS)
- Homebrew
- PostgreSQL 17
- PostGIS
- pgAdmin 4
- Visual Studio Code
- Git
- Python 3

---

# 1. Install Homebrew

If Homebrew is not already installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Verify installation:

```bash
brew --version
```

---

# 2. Install PostgreSQL

Install PostgreSQL:

```bash
brew install postgresql@17
```

Start PostgreSQL:

```bash
brew services start postgresql@17
```

Verify installation:

```bash
psql --version
```

Expected output:

```
psql (PostgreSQL) 17.x
```

---

# 3. Install PostGIS

```bash
brew install postgis
```

---

# 4. Install pgAdmin

Download and install pgAdmin 4.

Connect to local PostgreSQL server.

Create a database and name it:

```
hgeo_demo
```

---

# 5. Enable PostGIS

In pgAdmin, open Query Tool within hgeo_demo and run:

```sql
CREATE EXTENSION postgis;
```

Verify installation:

```sql
SELECT PostGIS_Version();
```

---

# 6. Clone the Repository

```bash
git clone <repository-url>
```

Open the project:

```bash
cd hgeo-extension
```

---

# 7. Load SQL Files

Execute the SQL scripts in the following order.

### Step 1

```sql
\i sql/schema.sql
```

### Step 2

```sql
\i sql/functions.sql
```

### Step 3

```sql
\i sql/geojson.sql
```

### Step 4

```sql
\i sql/spatial.sql
```

### Step 5

```sql
\i sql/visualize.sql
```

### Step 6

```sql
\i sql/sample_data.sql
```

---

# 8. Verify Installation

Run:

```sql
SELECT name
FROM hgeo_objects;
```

Expected result:

```
United States
```

Run:

```sql
SELECT visualize(object)
FROM hgeo_objects
WHERE name='United States';
```

A GeoJSON FeatureCollection should return.

---

# 9. Launch the Visualization

Open Terminal.

Navigate to the visualization directory:

```bash
cd visualization
```

Start local web server by running:

```bash
python3 -m http.server 8000
```

Open a browser and enter:

```
http://localhost:8000
```

The interactive Leaflet map should then appear.

---

# 10. Run the Test Suite

Open pgAdmin.

Execute:

```sql
\i tests/test_all.sql
```

Each of the 12 tests should return:

```
PASS
```

---

# Project Directory

```
hgeo-extension/

docs/
sql/
tests/
visualization/

.gitignore
hgeo--1.0.sql
hgeo.control
README.md
```

---

# Troubleshooting

## PostgreSQL is not running

Start PostgreSQL:

```bash
brew services start postgresql@17
```

---

## PostGIS extension not found

Run:

```sql
CREATE EXTENSION postgis;
```

inside the hgeo_demo database.

---

## Leaflet page is blank

Ensure local HTTP server is running:

```bash
python3 -m http.server 8000
```

Then refresh:

```
http://localhost:8000
```

---

## GeoJSON not updating

Re-export the hierarchy:

```sql
SELECT visualize(object)
FROM hgeo_objects
WHERE name='United States';
```

Copy the output into:

```
visualization/sample.geojson
```

Refresh the browser.

---

# Installation Complete

The HGeo Extension should now be ready to use.

You may begin executing SQL queries, running the visualization, and exploring the hierarchical geography data type.