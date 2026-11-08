#!/bin/bash
set -u
mkdir -p data; cd data
W=6.20; E=6.32; S=46.170; N=46.2355
COLS=(6.20 6.24 6.28 6.32); ROWS=(46.170 46.2027 46.2355)
MIR=("https://overpass-api.de" "https://overpass.kumi.systems" "https://overpass.private.coffee")
for r in 0 1; do for c in 0 1 2; do
  bb="${COLS[$c]},${ROWS[$r]},${COLS[$((c+1))]},${ROWS[$((r+1))]}"
  f="osm_${r}${c}.xml"; ok=0
  for round in 1 2; do for m in "${MIR[@]}"; do
    curl -sS -m 300 -o "$f" "$m/api/map?bbox=$bb" && head -c 300 "$f" | grep -q "<osm" && ok=1 && break
    sleep 15
  done; [ $ok = 1 ] && break; done
  echo "$f ok=$ok $(stat -c %s "$f" 2>/dev/null)"
  [ $ok = 1 ] && xz -T0 -6 -f "$f"
  sleep 8
done; done
s=0; i=0
while [ $i -lt 25 ]; do
  curl -sS -m 250 -g -o bd_$i.json "https://data.geopf.fr/wfs/ows?SERVICE=WFS&VERSION=2.0.0&REQUEST=GetFeature&TYPENAMES=BDTOPO_V3:batiment&OUTPUTFORMAT=application/json&SORTBY=cleabs&COUNT=3000&STARTINDEX=$s&BBOX=$W,$S,$E,$N,EPSG:4326" || true
  n=$(python3 -c "import json;print(len(json.load(open('bd_$i.json'))['features']))" 2>/dev/null || echo -1)
  echo "bd_$i features=$n"
  if [ "$n" -le 0 ]; then rm -f bd_$i.json; break; fi
  xz -T0 -6 -f bd_$i.json
  i=$((i+1)); s=$((s+3000))
done
# elevation for the union box W6.20..6.40 S46.17..N46.331 (20 m pixels)
curl -sS -m 250 -g -o elev.bil "https://data.geopf.fr/wms-r/wms?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&LAYERS=ELEVATION.ELEVATIONGRIDCOVERAGE&STYLES=&FORMAT=image%2Fx-bil%3Bbits%3D32&CRS=EPSG:4326&BBOX=46.170,6.20,46.331,6.40&WIDTH=770&HEIGHT=895" || true
ls -l .
