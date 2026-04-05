<p align="center">
  <img src="https://raw.githubusercontent.com/Clawbuilders/openfang/main/public/assets/openfang-logo.png" width="120" alt="OpenFang Logo" />
</p>

<h1 align="center">openfang-setup</h1>

<p align="center">
  <strong>This repo has been merged into the main OpenFang repository.</strong><br/>
  Everything that was here now lives in <a href="https://github.com/Clawbuilders/openfang"><strong>Clawbuilders/openfang</strong></a>.
</p>

---

## What moved where

| Was here | Now in Clawbuilders/openfang |
|---|---|
| `workshop/.env.example` | [`workshop/.env.example`](https://github.com/Clawbuilders/openfang/blob/main/workshop/.env.example) |
| `workshop/openfang.toml` | [`workshop/openfang.toml`](https://github.com/Clawbuilders/openfang/blob/main/workshop/openfang.toml) |
| `Dockerfile.prebuilt` | [`Dockerfile.prebuilt`](https://github.com/Clawbuilders/openfang/blob/main/Dockerfile.prebuilt) |
| `.github/workflows/build-image.yml` | [`.github/workflows/build-image.yml`](https://github.com/Clawbuilders/openfang/blob/main/.github/workflows/build-image.yml) |

Pre-built images are still published to the same place:

```bash
docker pull ghcr.io/clawbuilders/openfang:latest
```

---

## Quick Start

```bash
git clone https://github.com/Clawbuilders/openfang.git
cd openfang
cp workshop/.env.example workshop/.env
# Edit workshop/.env — add your NVIDIA_API_KEY from https://build.nvidia.com
docker run -d \
  --name openfang \
  -p 4200:4200 \
  -v ./workshop/openfang.toml:/data/config.toml:ro \
  --env-file ./workshop/.env \
  ghcr.io/clawbuilders/openfang:latest
```

Open **http://localhost:4200**

---

## Deploy to Oracle Cloud (Free Tier — 24/7)

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/Clawbuilders/openfang/releases/latest/download/oci-stack.zip)

Runs on Oracle's Always-Free Ampere A1 (ARM64). Access via Tailscale — no public port exposure.

---

➡️ **[Go to Clawbuilders/openfang](https://github.com/Clawbuilders/openfang)**
