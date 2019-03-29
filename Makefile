border-region.osm.pbf: ireland-sorted.osm.pbf border-region.geojson
	osmium extract -p border-region.geojson --overwrite ireland-sorted.osm.pbf -o border-region.osm.pbf

ireland-and-northern-ireland-latest.osm.pbf:
	wget https://download.geofabrik.de/europe/ireland-and-northern-ireland-latest.osm.pbf

ireland-sorted.osm.pbf: ireland-and-northern-ireland-latest.osm.pbf
	osmium sort --overwrite ireland-and-northern-ireland-latest.osm.pbf -o ireland-sorted.osm.pbf


graphhopper-web-0.12.0.jar:
	wget https://graphhopper.com/public/releases/graphhopper-web-0.12.0.jar 

config-example.yml:
	wget https://raw.githubusercontent.com/graphhopper/graphhopper/master/config-example.yml
