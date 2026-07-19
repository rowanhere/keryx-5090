#!/usr/bin/env bash
set -euo pipefail

apt update
apt install -y aria2 unzip ca-certificates libgomp1

cd /root
aria2c \
  -x 16 \
  -s 16 \
  -k 1M \
  --continue=true \
  --file-allocation=none \
  --summary-interval=15 \
  -o keryx-miner-v0.3.7-OPoI-linux-gnu-amd64.zip \
  https://github.com/Keryx-Labs/keryx-miner/releases/download/v0.3.7-OPoI/keryx-miner-v0.3.7-OPoI-linux-gnu-amd64.zip

rm -rf /root/keryx-official
mkdir -p /root/keryx-official
unzip -q /root/keryx-miner-v0.3.7-OPoI-linux-gnu-amd64.zip -d /root/keryx-official

MINER_DIR="$(dirname "$(find /root/keryx-official -type f -name keryx-miner | head -1)")"
cp "$MINER_DIR"/keryx-miner "$MINER_DIR"/libkeryxcuda.so "$MINER_DIR"/libkeryx-llama.so "$MINER_DIR"/libkeryx-llama-noavx.so /root/keryx-5090-miner-pack/ 2>/dev/null || true
chmod +x /root/keryx-5090-miner-pack/*.sh /root/keryx-5090-miner-pack/keryx-miner

