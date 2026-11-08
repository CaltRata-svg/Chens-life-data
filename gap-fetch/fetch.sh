#!/bin/bash
set -u
mkdir -p data; cd data
MIR=("https://overpass-api.de" "https://overpass.kumi.systems" "https://overpass.private.coffee")
i=0
for bb in 6.28,46.2027,6.30,46.2191 6.30,46.2027,6.32,46.2191 6.28,46.2191,6.30,46.2355 6.30,46.2191,6.32,46.2355; do
  f="osm_g$i.xml"; ok=0
  for round in 1 2 3; do for m in "${MIR[@]}"; do
    curl -sS -m 200 -o "$f" "$m/api/map?bbox=$bb" && head -c 300 "$f" | grep -q "<osm" && ok=1 && break
    sleep 10
  done; [ $ok = 1 ] && break; done
  echo "$f ok=$ok $(stat -c %s "$f" 2>/dev/null)"
  [ $ok = 1 ] && xz -T0 -6 -f "$f" || rm -f "$f"
  i=$((i+1)); sleep 5
done
