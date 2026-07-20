# Keryx 5090 Miner Pack

Ready-to-use wrapper pack for the official Keryx miner release, tuned for a 4x RTX 5090 rig mining against a direct `keryxd` gRPC node.

## Defaults

- Node: `grpc://n1.us.clorecloud.net:1921`
- Wallet: `keryx:qqflxjrsvlycdl8ytd2v6xrna6aj8hny0jkprw92wa9c4fxsun0w7n9npdne6`
- Tier: `--light`
- Models: `/root/keryx-models`
- CUDA workload: `8192`
- PoM batch: `1048576` for low template latency
- PoM CUDA block: `256` threads, tunable with `KERYX_POM_THREADS`
- GPU tuning: off by default; set `KERYX_GPU_TUNE=1` to apply clocks/power limits
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

## Custom Patched Miner

The custom release builds the official miner source with a native RTX 5090 `sm_120` PoM kernel.
It replaces repeated 64-bit divisions in the model walk with an exact reciprocal remainder,
uses aligned 32-byte model reads, and exposes the launch geometry for tuning. The executable and
CUDA plugin are built together because the miner's Rust plugin ABI is build-specific.

```bash
curl -L -o keryx-5090-custom-miner.zip \
  https://github.com/rowanhere/keryx-5090/releases/latest/download/keryx-5090-custom-miner-linux-amd64.zip

rm -rf /root/keryx-5090-custom-miner
mkdir -p /root/keryx-5090-custom-miner
unzip -q keryx-5090-custom-miner.zip -d /root/keryx-5090-custom-miner
cd /root/keryx-5090-custom-miner

./run-light-max.sh
```

Confirm the optimized kernel was selected:

```bash
grep -E "native sm_120|PoM CUDA launch" /root/.keryx/stderr.log
```

To apply GPU power/clock tuning only:

```bash
./optimize-gpus.sh
```

Tune the actual PoM kernel on the rented GPU box (about 10 minutes):

```bash
pkill -INT keryx-miner || true
./autotune-pom.sh
source ./best-pom.env
./run-light-max.sh
```

## Override Settings

```bash
KERYX_CUDA_WORKLOAD=3072 ./run-light.sh
KERYX_CUDA_WORKLOAD=12288 ./run-light.sh
KERYX_POM_BATCH=1048576 KERYX_POM_THREADS=256 ./run-light.sh
KERYX_GPU_TUNE=1 ./run-light.sh
KERYX_POWER_LIMIT=450 ./run-light.sh
KERYX_CLOCK_MIN=2400 ./run-light.sh
KERYX_NODE=grpc://YOUR_NODE:22110 ./run-light.sh
KERYX_STATS_BIND=0.0.0.0 ./run-light.sh
```

If the miner prints `Cuda takes longer then block rate`, lower workload:

```text
16384 -> 14336 -> 12288 -> 10240 -> 8192 -> 6144 -> 4096
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
