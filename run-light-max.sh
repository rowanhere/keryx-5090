#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

export KERYX_CUDA_WORKLOAD="${KERYX_CUDA_WORKLOAD:-12288}"
export KERYX_ASYNC_WORKERS="${KERYX_ASYNC_WORKERS:-4}"

exec ./run-light.sh "$@"
