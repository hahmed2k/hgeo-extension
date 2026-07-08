const hgeoData = {
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Polygon",
        "coordinates": [[
          [-124.48, 32.53],
          [-114.13, 32.53],
          [-114.13, 42.01],
          [-124.48, 42.01],
          [-124.48, 32.53]
        ]]
      },
      "properties": {
        "name": "California",
        "level": "state",
        "parent": null
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Polygon",
        "coordinates": [[
          [-118.1, 33.4],
          [-117.4, 33.4],
          [-117.4, 34.1],
          [-118.1, 34.1],
          [-118.1, 33.4]
        ]]
      },
      "properties": {
        "name": "Orange County",
        "level": "county",
        "parent": "California"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [-117.8265, 33.6846]
      },
      "properties": {
        "name": "Irvine",
        "level": "city",
        "parent": "Orange County"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [-117.9298, 33.6189]
      },
      "properties": {
        "name": "Newport Beach",
        "level": "city",
        "parent": "Orange County"
      }
    }
  ]
};























