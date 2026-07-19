#!/usr/bin/env bash
set -euo pipefail

POWER_LIMIT="${KERYX_POWER_LIMIT:-max}"
CLOCK_RANGE="${KERYX_CLOCK_RANGE:-2600,3200}"

if ! command -v nvidia-smi >/dev/null 2>&1; then
  echo "nvidia-smi not found"
  exit 1
fi

nvidia-smi -pm 1 >/dev/null 2>&1 || true

if [ "$POWER_LIMIT" = "max" ]; then
  power="$(nvidia-smi -q -d POWER 2>/dev/null \
    | sed -n 's/.*Max Power Limit[[:space:]]*:[[:space:]]*\([0-9.]*\).*/\1/p' \
    | head -1)"
  power="${power%.*}"
else
  power="$POWER_LIMIT"
fi

if [ -n "${power:-}" ]; then
  nvidia-smi -pl "$power" >/dev/null 2>&1 || true
fi

nvidia-smi -lgc "$CLOCK_RANGE" >/dev/null 2>&1 || true
nvidia-smi --query-gpu=index,name,power.limit,power.draw,clocks.gr,temperature.gpu --format=csv,noheader,nounits
