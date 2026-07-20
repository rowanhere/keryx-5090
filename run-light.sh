#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

NODE="${KERYX_NODE:-grpc://n1.us.clorecloud.net:1921}"
ADDRESS="${KERYX_ADDRESS:-keryx:qqflxjrsvlycdl8ytd2v6xrna6aj8hny0jkprw92wa9c4fxsun0w7n9npdne6}"
MODELS_DIR="${KERYX_MODELS_DIR:-/root/keryx-models}"
WORKLOAD="${KERYX_CUDA_WORKLOAD:-8192}"
POM_BATCH="${KERYX_POM_BATCH:-1048576}"
POM_THREADS="${KERYX_POM_THREADS:-256}"
POM_CONTIGUOUS="${KERYX_POM_CONTIGUOUS:-1}"
ASYNC_WORKERS="${KERYX_ASYNC_WORKERS:-4}"
STATS_BIND="${KERYX_STATS_BIND:-127.0.0.1}"
STATS_PORT="${KERYX_STATS_PORT:-3338}"

if [ "${KERYX_GPU_TUNE:-0}" = "1" ]; then
  ./optimize-gpus.sh >/dev/null 2>&1 || true
fi

KERYX_ASYNC_WORKERS="$ASYNC_WORKERS" \
KERYX_POM_BATCH="$POM_BATCH" \
KERYX_POM_THREADS="$POM_THREADS" \
KERYX_POM_CONTIGUOUS="$POM_CONTIGUOUS" \
./keryx-miner \
  --keryxd-address "$NODE" \
  --mining-address "$ADDRESS" \
  --models-dir "$MODELS_DIR" \
  --light \
  --cuda-workload "$WORKLOAD" \
  --stats-bind "$STATS_BIND" \
  --stats-port "$STATS_PORT"
