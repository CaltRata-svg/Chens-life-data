#!/bin/bash
# usage: fetch.sh NAME W S E N   (one OSM tile)
set -u
mkdir -p data; cd data
f="osm_$1.xml"; bb="$2,$3,$4,$5"; ok=0
MIR=("https://overpass.kumi.systems" "https://overpass-api.de" "https://overpass.private.coffee" "https://maps.mail.ru/osm/tools/overpass")
for round in 1 2 3 4; do for m in "${MIR[@]}"; do
  curl -sS -m 150 -A "chens-life-fetch/1.0" -o "$f" "$m/api/map?bbox=$bb" && head -c 300 "$f" | grep -q "<osm" && ok=1 && break
  sleep 5
done; [ $ok = 1 ] && break; done
echo "$f ok=$ok $(stat -c %s "$f" 2>/dev/null)"
[ $ok = 1 ] && xz -T0 -6 -f "$f" || rm -f "$f"
