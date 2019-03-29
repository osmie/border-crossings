border-posts.zip: border-posts.geojson
	-rm -f border-posts.zip
	zip border-posts.zip border-posts.geojson

#border-posts.geojson: .imported_into_postgres Makefile
#	psql -At -c "with points as (select st_centroid(st_intersection(roads.way, border_segments.way)) as point from planet_osm_line as roads join border_segments on (st_intersects(roads.way, border_segments.way)) where roads.highway is not null), features as ( select 'Feature' as \"type\", ST_AsGeoJSON(points.point)::json as \"geometry\" from points) select row_to_json(fc) from ( select 'FeatureCollection' as \"type\", array_to_json(array_agg(features)) as \"features\" from features ) as fc;" > border-posts.geojson
#
border-posts.csv: .imported_into_postgres Makefile
	(echo "lat,lon" ; psql -At -F, -c "select st_y(point) as lat, st_x(point) as lon from (select st_centroid(st_intersection(roads.way, border_segments.way)) as point from planet_osm_line as roads join border_segments on (st_intersects(roads.way, border_segments.way)) where roads.highway is not null and roads.highway NOT IN ('path', 'track')) as points" ) > border-posts.csv

border-posts.geojson: border-posts.csv
	ogr2ogr -F GeoJSON border-posts.geojson border-posts.csv -oo X_POSSIBLE_NAMES=lon -oo Y_POSSIBLE_NAMES=lat


.imported_into_postgres: border-region.osm.pbf border-crossings.style
	psql -c "DROP TABLE IF EXISTS border_segments;"
	osm2pgsql -l -S border-crossings.style border-region.osm.pbf
	psql -c "DELETE FROM planet_osm_polygon WHERE admin_level IS NULL OR admin_level != '2'"
	psql -c "DELETE FROM planet_osm_line WHERE highway IS NULL"
	psql -c "CREATE TABLE border_segments AS select ST_subdivide(st_exteriorring(way), 20) as way from planet_osm_polygon where admin_level = '2';"
	psql -c "CREATE INDEX border_segments_geom on border_segments USING gist (way);"
	touch .imported_into_postgres

border-region.osm.pbf: ireland-sorted.osm.pbf border-region.geojson
	osmium extract -s smart -S types=multipolygon,boundary -p border-region.geojson --overwrite ireland-sorted.osm.pbf -o border-region.osm.pbf

ireland-and-northern-ireland-latest.osm.pbf:
	-rm ireland-and-northern-ireland-latest.osm.pbf
	wget https://download.geofabrik.de/europe/ireland-and-northern-ireland-latest.osm.pbf

ireland-sorted.osm.pbf: ireland-and-northern-ireland-latest.osm.pbf
	osmium sort --overwrite ireland-and-northern-ireland-latest.osm.pbf -o ireland-sorted.osm.pbf

graphhopper-web-0.12.0.jar:
	wget https://graphhopper.com/public/releases/graphhopper-web-0.12.0.jar 

config-example.yml:
	wget https://raw.githubusercontent.com/graphhopper/graphhopper/master/config-example.yml

border-region.osm-gh/properties: config-example.yml border-region.osm.pbf graphhopper-web-0.12.0.jar
	-rm -rf border-region.osm-gh/
	java -Dgraphhopper.datareader.file=border-region.osm.pbf -jar *.jar import config-example.yml

run-graphhopper: border-region.osm-gh/properties
	java -Dgraphhopper.datareader.file=border-region.osm.pbf -jar *.jar server config-example.yml

WARRENPORT=54.11110,-6.27838
MUFF=55.06747,-7.26925
BALLYCONNELL=54.116125,-7.583871
