#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

WORKLOADS="${KERYX_TUNE_WORKLOADS:-4096 6144 8192 10240 12288 14336 16384}"
SECONDS_PER_TEST="${KERYX_TUNE_SECONDS:-120}"
WARMUP_SECONDS="${KERYX_TUNE_WARMUP:-45}"
STATS_BIND="${KERYX_STATS_BIND:-127.0.0.1}"
STATS_PORT="${KERYX_STATS_PORT:-3338}"
BEST_HASH=0
BEST_WORKLOAD=0
RESULTS="autotune-results.txt"

rm -f "$RESULTS"
touch "$RESULTS"

if pgrep -x keryx-miner >/dev/null 2>&1; then
  echo "Stop the running miner before autotune: pkill -INT keryx-miner"
  exit 1
fi

read_hashrate() {
  curl -fsS "http://${STATS_BIND}:${STATS_PORT}/v1/miner/stats" 2>/dev/null \
    | sed -n 's/.*"total_hashrate_hs"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' \
    | tail -1
}

for workload in $WORKLOADS; do
  log="autotune-${workload}.log"
  echo "== workload ${workload} =="

  KERYX_CUDA_WORKLOAD="$workload" \
  KERYX_STATS_BIND="$STATS_BIND" \
  KERYX_STATS_PORT="$STATS_PORT" \
    timeout --signal=INT "$SECONDS_PER_TEST" ./run-light.sh >"$log" 2>&1 &

  pid="$!"
  sleep "$WARMUP_SECONDS"

  hash="$(read_hashrate || true)"
  hash="${hash:-0}"
  echo "${workload} ${hash}" | tee -a "$RESULTS"

  wait "$pid" >/dev/null 2>&1 || true
  sleep 5

  if [ "$hash" -gt "$BEST_HASH" ]; then
    BEST_HASH="$hash"
    BEST_WORKLOAD="$workload"
  fi

  if grep -qi "Cuda takes longer then block rate" "$log"; then
    echo "workload ${workload}: too high for block rate; stopping search"
    break
  fi
done

cat > best-workload.env <<EOF
export KERYX_CUDA_WORKLOAD=${BEST_WORKLOAD}
export KERYX_ASYNC_WORKERS=${KERYX_ASYNC_WORKERS:-4}
EOF

echo "Best workload: ${BEST_WORKLOAD} (${BEST_HASH} H/s)"
echo "Use:"
echo "  source ./best-workload.env && ./run-light.sh"
