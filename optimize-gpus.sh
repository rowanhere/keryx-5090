#!/usr/bin/env bash
set -euo pipefail

POWER_LIMIT="${KERYX_POWER_LIMIT:-max}"
CLOCK_MIN="${KERYX_CLOCK_MIN:-2400}"

if ! command -v nvidia-smi >/dev/null 2>&1; then
  echo "nvidia-smi not found"
  exit 1
fi

nvidia-smi -pm 1 >/dev/null 2>&1 || true

for gpu in $(nvidia-smi --query-gpu=index --format=csv,noheader,nounits); do
  if [ "$POWER_LIMIT" = "max" ]; then
    power="$(nvidia-smi -i "$gpu" -q -d POWER 2>/dev/null \
      | sed -n 's/.*Max Power Limit[[:space:]]*:[[:space:]]*\([0-9.]*\).*/\1/p' \
      | head -1)"
    power="${power%.*}"
  else
    power="$POWER_LIMIT"
  fi
  [ -z "${power:-}" ] || nvidia-smi -i "$gpu" -pl "$power" >/dev/null 2>&1 || true

  mem_max="$(nvidia-smi -i "$gpu" --query-supported-clocks=memory --format=csv,noheader,nounits 2>/dev/null \
    | sed 's/[^0-9].*//' | sort -nr | head -1)"
  core_max="$(nvidia-smi -i "$gpu" --query-supported-clocks=graphics --format=csv,noheader,nounits 2>/dev/null \
    | sed 's/[^0-9].*//' | sort -nr | head -1)"

  [ -z "${mem_max:-}" ] || nvidia-smi -i "$gpu" -lmc "$mem_max,$mem_max" >/dev/null 2>&1 || true
  [ -z "${core_max:-}" ] || nvidia-smi -i "$gpu" -lgc "$CLOCK_MIN,$core_max" >/dev/null 2>&1 || true
done

nvidia-smi --query-gpu=index,name,power.limit,power.draw,clocks.gr,temperature.gpu --format=csv,noheader,nounits
