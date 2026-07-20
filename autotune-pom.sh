#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

THREADS_LIST="${KERYX_TUNE_THREADS:-128 256 512}"
BATCH_LIST="${KERYX_TUNE_BATCHES:-524288 1048576 2097152}"
SECONDS_PER_TEST="${KERYX_TUNE_SECONDS:-70}"
WARMUP_SECONDS="${KERYX_TUNE_WARMUP:-25}"
STATS_BIND="${KERYX_STATS_BIND:-127.0.0.1}"
STATS_PORT="${KERYX_STATS_PORT:-3338}"
RESULTS="autotune-pom-results.txt"
BEST_HASH=0
BEST_THREADS=256
BEST_BATCH=1048576

if pgrep -x keryx-miner >/dev/null 2>&1; then
  echo "Stop the running miner first: pkill -INT keryx-miner"
  exit 1
fi

read_hashrate() {
  curl -fsS "http://${STATS_BIND}:${STATS_PORT}/v1/miner/stats" 2>/dev/null \
    | sed -n 's/.*"total_hashrate_hs"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' \
    | tail -1
}

: >"$RESULTS"
for threads in $THREADS_LIST; do
  for batch in $BATCH_LIST; do
    log="autotune-pom-${threads}-${batch}.log"
    echo "== threads=${threads} batch=${batch} =="
    KERYX_POM_THREADS="$threads" KERYX_POM_BATCH="$batch" \
      timeout --signal=INT "$SECONDS_PER_TEST" ./run-light.sh >"$log" 2>&1 &
    pid="$!"
    sleep "$WARMUP_SECONDS"

    total=0
    samples=0
    for _ in 1 2 3 4 5; do
      hash="$(read_hashrate || true)"
      if [ -n "${hash:-}" ]; then
        total=$((total + hash))
        samples=$((samples + 1))
      fi
      sleep 5
    done
    wait "$pid" >/dev/null 2>&1 || true
    sleep 3

    if [ "$samples" -eq 0 ]; then
      average=0
    else
      average=$((total / samples))
    fi
    echo "$threads $batch $average" | tee -a "$RESULTS"
    if [ "$average" -gt "$BEST_HASH" ]; then
      BEST_HASH="$average"
      BEST_THREADS="$threads"
      BEST_BATCH="$batch"
    fi
  done
done

{
  echo "export KERYX_POM_THREADS=$BEST_THREADS"
  echo "export KERYX_POM_BATCH=$BEST_BATCH"
} >best-pom.env

echo "Best: threads=$BEST_THREADS batch=$BEST_BATCH hashrate=$BEST_HASH H/s"
echo "Run: source ./best-pom.env && ./run-light-max.sh"
