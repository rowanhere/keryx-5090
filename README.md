# Keryx 5090 Miner Pack

Ready-to-use wrapper pack for the official Keryx miner release, tuned for a 4x RTX 5090 rig mining against a direct `keryxd` gRPC node.

## Defaults

- Node: `grpc://n1.us.clorecloud.net:1921`
- Wallet: `keryx:qqflxjrsvlycdl8ytd2v6xrna6aj8hny0jkprw92wa9c4fxsun0w7n9npdne6`
- Tier: `--light`
- Models: `/root/keryx-models`
- CUDA workload: `4096`
- Stats API: `127.0.0.1:3338`

## Install On GPU Host

```bash
apt update
apt install -y curl unzip ca-certificates libgomp1

curl -L -o keryx-5090-miner-pack.zip \
  https://github.com/rowanhere/keryx-5090/releases/latest/download/keryx-5090-miner-pack-linux-amd64.zip

rm -rf /root/keryx-5090-miner-pack
mkdir -p /root/keryx-5090-miner-pack
unzip -q keryx-5090-miner-pack.zip -d /root/keryx-5090-miner-pack
cd /root/keryx-5090-miner-pack

./run-light.sh
```

## Override Settings

```bash
KERYX_CUDA_WORKLOAD=3072 ./run-light.sh
KERYX_NODE=grpc://YOUR_NODE:22110 ./run-light.sh
KERYX_STATS_BIND=0.0.0.0 ./run-light.sh
```

If the miner prints `Cuda takes longer then block rate`, lower workload:

```text
4096 -> 3072 -> 2560 -> 2048
```

## Model Folder

The light tier expects:

```text
/root/keryx-models/Mistral-7B-v0.3/
```

Download from:

```text
https://keryx-labs.com/Mistral-7B-v0.3.zip
```
