#!/usr/bin/env bash
set -euo pipefail

MODELS_DIR="${KERYX_MODELS_DIR:-/root/keryx-models}"

apt update
apt install -y aria2 p7zip-full ca-certificates

cd /root
aria2c \
  -x 16 \
  -s 16 \
  -k 1M \
  --min-split-size=1M \
  --continue=true \
  --file-allocation=none \
  --summary-interval=15 \
  -o Mistral-7B-v0.3.zip \
  https://keryx-labs.com/Mistral-7B-v0.3.zip

rm -rf /root/mistral-extract
mkdir -p /root/mistral-extract "$MODELS_DIR"
7z x -mmt=on /root/Mistral-7B-v0.3.zip -o/root/mistral-extract

rm -rf "$MODELS_DIR/Mistral-7B-v0.3"
mv /root/mistral-extract/Mistral-7B-v0.3 "$MODELS_DIR/"

find "$MODELS_DIR/Mistral-7B-v0.3" -maxdepth 2 -type f | head

