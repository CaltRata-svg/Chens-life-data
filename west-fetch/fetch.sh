#!/bin/bash
set -u
mkdir -p data; cd data
MIR=("https://overpass-api.de" "https://overpass.kumi.systems" "https://overpass.private.coffee")
i=0
for bb in 6.21,46.2355,6.232,46.2675 6.232,46.2355,6.254,46.2675 6.21,46.2675,6.232,46.2995 6.232,46.2675,6.254,46.2995 6.21,46.2995,6.254,46.331 6.32,46.183,6.345,46.2355; do
  f="osm_w$i.xml"; ok=0
  for round in 1 2; do for m in "${MIR[@]}"; do
    curl -sS -m 200 -o "$f" "$m/api/map?bbox=$bb" && head -c 300 "$f" | grep -q "<osm" && ok=1 && break
    sleep 10
  done; [ $ok = 1 ] && break; done
  echo "$f ok=$ok $(stat -c %s "$f" 2>/dev/null)"
  [ $ok = 1 ] && xz -T0 -6 -f "$f" || rm -f "$f"
  i=$((i+1)); sleep 5
done
get(){ # name W S E N
  s=0; i=0
  while [ $i -lt 10 ]; do
    curl -sS -m 250 -g -o $1_$i.json "https://data.geopf.fr/wfs/ows?SERVICE=WFS&VERSION=2.0.0&REQUEST=GetFeature&TYPENAMES=BDTOPO_V3:batiment&OUTPUTFORMAT=application/json&SORTBY=cleabs&COUNT=3000&STARTINDEX=$s&BBOX=$2,$3,$4,$5,EPSG:4326" || true
    n=$(python3 -c "import json;print(len(json.load(open('$1_$i.json'))['features']))" 2>/dev/null || echo -1)
    echo "$1_$i features=$n"
    if [ "$n" -le 0 ]; then rm -f $1_$i.json; break; fi
    xz -T0 -6 -f $1_$i.json; i=$((i+1)); s=$((s+3000))
  done
}
get bd_w 6.21 46.2355 6.254 46.331
get bd_e 6.32 46.183 6.345 46.2355
ls -l .
