#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

export KERYX_CUDA_WORKLOAD="${KERYX_CUDA_WORKLOAD:-8192}"
export KERYX_POM_BATCH="${KERYX_POM_BATCH:-1048576}"
export KERYX_POM_THREADS="${KERYX_POM_THREADS:-256}"
export KERYX_ASYNC_WORKERS="${KERYX_ASYNC_WORKERS:-4}"
export KERYX_GPU_TUNE="${KERYX_GPU_TUNE:-1}"

exec ./run-light.sh "$@"
