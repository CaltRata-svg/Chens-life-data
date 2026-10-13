#!/bin/bash
set -u
mkdir -p data; cd data
B="46.283,6.254,46.331,6.338"
for U in "https://overpass-api.de/api/map?bbox=6.254,46.283,6.338,46.331" "https://overpass.kumi.systems/api/map?bbox=6.254,46.283,6.338,46.331" "https://overpass.private.coffee/api/map?bbox=6.254,46.283,6.338,46.331"; do
  for i in 1 2 3; do
    curl -sS -m 300 -o osm.xml "$U" && head -c 200 osm.xml | grep -q "<osm" && break 2
    sleep 15
  done
done
ls -l osm.xml || true
i=0; s=0
while [ $i -lt 8 ]; do
  curl -sS -m 200 -g -o bd_$i.json "https://data.geopf.fr/wfs/ows?SERVICE=WFS&VERSION=2.0.0&REQUEST=GetFeature&TYPENAMES=BDTOPO_V3:batiment&OUTPUTFORMAT=application/json&SORTBY=cleabs&COUNT=3000&STARTINDEX=$s&BBOX=6.254,46.283,6.338,46.331,EPSG:4326" || true
  n=$(python3 -c "import json;print(len(json.load(open('bd_$i.json'))['features']))" 2>/dev/null || echo -1)
  echo "bd_$i features=$n"
  if [ "$n" -le 0 ]; then break; fi
  i=$((i+1)); s=$((s+3000))
done
curl -sS -m 200 -g -o elev.bil "https://data.geopf.fr/wms-r/wms?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&LAYERS=ELEVATION.ELEVATIONGRIDCOVERAGE&STYLES=&FORMAT=image%2Fx-bil%3Bbits%3D32&CRS=EPSG:4326&BBOX=$B&WIDTH=325&HEIGHT=267" || true
ls -l elev.bil
