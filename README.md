<p align="center">
  <img src="https://raw.githubusercontent.com/RightNow-AI/openfang/main/public/assets/openfang-logo.png" width="160" alt="OpenFang Logo" />
</p>

<h1 align="center">OpenFang Setup</h1>
<h3 align="center">The easiest way to run OpenFang</h3>

<p align="center">
  Pre-built Docker image · No Rust · No compilation · Works on any machine
</p>

<p align="center">
  <a href="https://github.com/RightNow-AI/openfang">Source (RightNow-AI/openfang)</a> &bull;
  <a href="https://openfang.sh/docs">Docs</a> &bull;
  <a href="https://discord.gg/sSJqgNnq6X">Discord</a>
</p>

---

## Option 1 — Local (Docker Desktop)

**Requirements:** [Docker](https://www.docker.com/products/docker-desktop/) · NVIDIA API key (free at [build.nvidia.com](https://build.nvidia.com))

```bash
# 1. Clone this repo
git clone https://github.com/Clawbuilders/openfang-setup.git
cd openfang-setup

# 2. Add your NVIDIA API key
cp workshop/.env.example workshop/.env
# Open workshop/.env and replace nvapi-your-key-here with your actual key

# 3. Pull and run
docker pull ghcr.io/clawbuilders/openfang:latest
docker run -d \
  --name openfang \
  -p 4200:4200 \
  -v ./workshop/openfang.toml:/data/config.toml:ro \
  --env-file ./workshop/.env \
  ghcr.io/clawbuilders/openfang:latest

# 4. Open the dashboard
open http://localhost:4200
```

---

## Option 2 — Oracle Cloud Free Tier (24/7, always-on)

Run OpenFang permanently on Oracle's **Always-Free Ampere A1** instance (ARM64, up to 4 OCPUs / 24 GB RAM — free forever). Access via [Tailscale](https://tailscale.com) — port 4200 is never exposed to the public internet.

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/Clawbuilders/openfang-setup/releases/latest/download/oci-stack.zip)

**Before clicking, have these ready:**
| What | Where to get it |
|------|----------------|
| Oracle Cloud account | [oracle.com/cloud/free](https://www.oracle.com/cloud/free/) — no credit card for Always Free |
| Tailscale auth key | [login.tailscale.com/admin/settings/keys](https://login.tailscale.com/admin/settings/keys) — reusable, ephemeral, tag:server |
| NVIDIA API key | [build.nvidia.com](https://build.nvidia.com) — free |

**What happens after you click:**
1. Oracle Resource Manager opens a wizard — fill in your keys and SSH public key
2. One click deploys the full stack: VCN, Ampere A1 instance, Docker, Tailscale, OpenFang
3. ~4 minutes later your dashboard is live at `http://<tailscale-ip>:4200`

---

## Offline Install (no internet on the target machine)

Download the tar.gz for your architecture from the [latest release](https://github.com/Clawbuilders/openfang-setup/releases/latest):

```bash
# Apple Silicon / Oracle Ampere A1 (ARM64):
docker load < openfang-image-arm64.tar.gz

# Intel / AMD:
docker load < openfang-image-amd64.tar.gz

# Then run as normal
docker run -d --name openfang -p 4200:4200 \
  -v ./workshop/openfang.toml:/data/config.toml:ro \
  --env-file ./workshop/.env \
  ghcr.io/clawbuilders/openfang:latest
```

---

## Available NVIDIA NIM Models

Edit `workshop/openfang.toml` and change the `model` field:

| Model | Best for |
|-------|----------|
| `nvidia/llama-3.1-nemotron-ultra-253b-v1` | Flagship reasoning (default) |
| `nvidia/llama-3.3-nemotron-super-49b-v1` | Fast + strong reasoning |
| `meta/llama-3.3-70b-instruct` | Fast, general-purpose |
| `meta/llama-4-maverick-17b-128e-instruct` | Multimodal, 128k context |
| `deepseek-ai/deepseek-r1` | Deep reasoning |
| `qwen/qwen3-coder-480b-a35b-instruct` | Coding specialist |

Browse all models at [build.nvidia.com/models](https://build.nvidia.com/models).

---

## Managing the Container

```bash
docker stop openfang       # Stop
docker start openfang      # Start again
docker logs -f openfang    # Follow live logs
docker rm openfang         # Remove container (keeps image)
```

---

## Troubleshooting

**Port 4200 already in use**
```bash
lsof -i :4200              # Find what's using it
docker run -p 4201:4200 …  # Or use a different port
```

**NVIDIA API errors (401)**
- Key must start with `nvapi-`
- No quotes or spaces in `.env`: `NVIDIA_API_KEY=nvapi-xxx`
- Check it's active at [build.nvidia.com](https://build.nvidia.com)

**Container exits immediately**
```bash
docker logs openfang       # Check for config errors
```

---

## Links

- **OpenFang source:** [github.com/RightNow-AI/openfang](https://github.com/RightNow-AI/openfang)
- **Docs:** [openfang.sh/docs](https://openfang.sh/docs)
- **Discord:** [discord.gg/sSJqgNnq6X](https://discord.gg/sSJqgNnq6X)
- **NVIDIA NIM Models:** [build.nvidia.com/models](https://build.nvidia.com/models)
