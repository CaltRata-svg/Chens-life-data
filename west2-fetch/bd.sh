#!/bin/bash
set -u
mkdir -p data; cd data
get(){ s=0; i=0
  while [ $i -lt 10 ]; do
    curl -sS -m 250 -g -o $1_$i.json "https://data.geopf.fr/wfs/ows?SERVICE=WFS&VERSION=2.0.0&REQUEST=GetFeature&TYPENAMES=BDTOPO_V3:batiment&OUTPUTFORMAT=application/json&SORTBY=cleabs&COUNT=3000&STARTINDEX=$s&BBOX=$2,$3,$4,$5,EPSG:4326" || true
    n=$(python3 -c "import json;print(len(json.load(open('$1_$i.json'))['features']))" 2>/dev/null || echo -1)
    echo "$1_$i features=$n"
    if [ "$n" -le 0 ]; then rm -f $1_$i.json; break; fi
    xz -T0 -6 -f $1_$i.json; i=$((i+1)); s=$((s+3000))
  done; }
get bd_w 6.20 46.2355 6.254 46.331
get bd_e 6.32 46.17 6.345 46.2355
