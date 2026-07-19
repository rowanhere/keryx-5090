#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

NODE="${KERYX_NODE:-grpc://n1.us.clorecloud.net:1921}"
ADDRESS="${KERYX_ADDRESS:-keryx:qqflxjrsvlycdl8ytd2v6xrna6aj8hny0jkprw92wa9c4fxsun0w7n9npdne6}"
MODELS_DIR="${KERYX_MODELS_DIR:-/root/keryx-models}"
WORKLOAD="${KERYX_CUDA_WORKLOAD:-4096}"
ASYNC_WORKERS="${KERYX_ASYNC_WORKERS:-4}"
STATS_BIND="${KERYX_STATS_BIND:-127.0.0.1}"

nvidia-smi -pm 1 >/dev/null 2>&1 || true

KERYX_ASYNC_WORKERS="$ASYNC_WORKERS" \
./keryx-miner \
  --keryxd-address "$NODE" \
  --mining-address "$ADDRESS" \
  --models-dir "$MODELS_DIR" \
  --light \
  --cuda-workload "$WORKLOAD" \
  --stats-bind "$STATS_BIND"

