// ==========================================================
// HGeo Leaflet Visualization Demo
// Loads exported GeoJSON and renders hierarchy-aware map
// ==========================================================

// Initialize map near California
const map = L.map("map").setView([36.5, -119.5], 6);

// Add OpenStreetMap basemap
L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    maxZoom: 19,
    attribution: "© OpenStreetMap contributors"
}).addTo(map);

// Lookup tables for map layers and hierarchy relationships
const layersByName = {};
const parentByName = {};
let geoJsonLayer;
let activeSelection = null;

// Color by hierarchy level
function getColor(level) {
    if (level === "state") return "#2980b9";
    if (level === "county") return "#27ae60";
    if (level === "city") return "#c0392b";
    return "#7f8c8d";
}

// Load GeoJSON exported from PostgreSQL visualize()
fetch("sample.geojson")
    .then(response => response.json())
    .then(data => {
        renderMap(data);
        buildHierarchy(data);
    })
    .catch(error => {
        console.error("Error loading GeoJSON:", error);
    });

// Render GeoJSON on the map
function renderMap(data) {
    geoJsonLayer = L.geoJSON(data, {
        style: feature => ({
            color: getColor(feature.properties.level),
            fillColor: getColor(feature.properties.level),
            weight: 3,
            fillOpacity: 0.15
        }),

        pointToLayer: (feature, latlng) => {
            return L.circleMarker(latlng, {
                radius: 8,
                color: getColor(feature.properties.level),
                fillColor: getColor(feature.properties.level),
                fillOpacity: 0.85
            });
        },

        onEachFeature: (feature, layer) => {
            const props = feature.properties;

            layersByName[props.name] = layer;
            parentByName[props.name] = props.parent;

            layer.bindPopup(`
                <strong>${props.name}</strong><br>
                Level: ${props.level}<br>
                Parent: ${props.parent || "None"}
            `);

            layer.on("click", () => {
                highlightHierarchy(props.name);
            });
        }
    }).addTo(map);

    map.fitBounds(geoJsonLayer.getBounds());
}

// Reset all layer styles
function resetStyles() {
    geoJsonLayer.eachLayer(layer => {
        const level = layer.feature.properties.level;

        if (layer.setStyle) {
            layer.setStyle({
                color: getColor(level),
                fillColor: getColor(level),
                weight: 3,
                fillOpacity: level === "city" ? 0.85 : 0.15
            });
        }
    });
}

// Highlight one feature
function highlightSingle(name) {
    const layer = layersByName[name];

    if (!layer || !layer.setStyle) return;

    layer.setStyle({
        color: "black",
        fillColor: "yellow",
        weight: 6,
        fillOpacity: 0.45
    });

    if (layer.bringToFront) {
        layer.bringToFront();
    }
}

// Highlight selected feature and all ancestors.
// Clicking the same feature again clears the highlight.
function highlightHierarchy(name) {
    if (activeSelection === name) {
        resetStyles();
        activeSelection = null;
        return;
    }

    resetStyles();
    activeSelection = name;

    let current = name;

    while (current) {
        highlightSingle(current);
        current = parentByName[current];
    }

    if (layersByName[name]) {
        layersByName[name].openPopup();
    }
}

// Dynamically build hierarchy sidebar from GeoJSON parent links
function buildHierarchy(data) {
    const hierarchy = document.getElementById("hierarchy");
    const childrenByParent = {};

    data.features.forEach(feature => {
        const props = feature.properties;
        const parent = props.parent || "root";

        if (!childrenByParent[parent]) {
            childrenByParent[parent] = [];
        }

        childrenByParent[parent].push(props);
    });

    function buildList(parentName) {
        const children = childrenByParent[parentName] || [];
        let html = "<ul>";

        children.forEach(child => {
            html += `
                <li class="${child.level}" onclick="highlightHierarchy('${child.name}')">
                    ${child.name}
                </li>
            `;

            html += buildList(child.name);
        });

        html += "</ul>";
        return html;
    }

    hierarchy.innerHTML = buildList("root");
}