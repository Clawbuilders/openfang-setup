# OpenFang Setup Workshop

> Step-by-step guide to running **OpenFang** — the open-source Agent OS — powered by **NVIDIA NIM**.

---

## What You'll Build

A fully running OpenFang instance with:
- NVIDIA's flagship LLM (`nvidia/llama-3.1-nemotron-ultra-253b-v1`) as the backend
- A local dashboard at `http://localhost:4200`
- 7 autonomous AI Hands ready to activate
- OpenAI-compatible API endpoint

**No Rust. No Python. No Node.js required.** You load a pre-built image — no compilation.

---

## Prerequisites

You need **3 things** before starting:

### 1. Git
Download: https://git-scm.com/downloads

Verify:
```bash
git --version
```

### 2. Docker

**Option A — Docker Desktop (recommended, includes GUI)**
Download: https://www.docker.com/products/docker-desktop/

**Option B — Docker Engine (Linux only)**
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker
```

Verify:
```bash
docker --version
```

### 3. NVIDIA API Key (free)

1. Go to https://build.nvidia.com
2. Sign in or create a free account
3. Click **"Get API Key"** in the top right
4. Copy your key — it starts with `nvapi-`

> The free tier includes generous rate limits across all NIM models.

---

## Setup

### Step 1 — Clone This Repo

Everything is pre-configured — config file, `.env` template, and all agent files.

```bash
git clone https://github.com/Clawbuilders/openfang-setup.git
cd openfang-setup
```

---

### Step 2 — Download the Pre-Built Image

**Option A — Pull from GHCR (fastest):**
```bash
docker pull ghcr.io/clawbuilders/openfang:latest
```

**Option B — Load from file:**

Download: **[openfang-image.tar.gz](https://github.com/Clawbuilders/openfang-setup/releases/latest)**

```bash
docker load < openfang-image.tar.gz
```

Verify:
```bash
docker images | grep openfang
```

---

### Step 3 — Add Your NVIDIA API Key

```bash
cp workshop/.env.example workshop/.env
```

Open `workshop/.env` and replace `nvapi-your-key-here` with your actual key:

```
NVIDIA_API_KEY=nvapi-your-actual-key-here
```

> Get your free key at https://build.nvidia.com → click **"Get API Key"**

---

### Step 4 — Run OpenFang

```bash
docker run -d \
  --name openfang \
  -p 4200:4200 \
  -v ./workshop/openfang.toml:/data/config.toml:ro \
  --env-file ./workshop/.env \
  ghcr.io/clawbuilders/openfang:latest
```

---

### Step 5 — Verify It's Running

```bash
curl http://127.0.0.1:4200/api/health
```

You should see a JSON response with `"status": "ok"`.

Open the dashboard in your browser:

```
http://localhost:4200
```

---

## Quick Test — Chat with an Agent

```bash
curl -X POST http://localhost:4200/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "assistant",
    "messages": [{"role": "user", "content": "Hello! What can you do?"}]
  }'
```

---

## Activate an Autonomous Hand

Hands are pre-built agents that run autonomously on schedules — no prompting required.

```bash
# See all available Hands
docker exec openfang openfang hand list

# Activate the Researcher Hand
docker exec openfang openfang hand activate researcher

# Check its progress
docker exec openfang openfang hand status researcher
```

---

## Available NVIDIA NIM Models

Swap the `model` field in `openfang.toml` and restart the container to change models:

| Model | Best For |
|-------|----------|
| `nvidia/llama-3.1-nemotron-ultra-253b-v1` | Flagship reasoning (default) |
| `nvidia/llama-3.3-nemotron-super-49b-v1` | Fast + strong reasoning |
| `meta/llama-3.3-70b-instruct` | Fast, general-purpose |
| `meta/llama-4-maverick-17b-128e-instruct` | Multimodal, 128k context |
| `meta/llama-4-scout-17b-16e-instruct` | Efficient MoE |
| `deepseek-ai/deepseek-r1` | Deep reasoning |
| `mistralai/mistral-large-2-instruct` | Mistral via NIM |
| `qwen/qwq-32b` | Qwen reasoning model |

Browse all models: https://build.nvidia.com/models

---

## Managing the Container

```bash
# Stop
docker stop openfang

# Start again
docker start openfang

# View logs
docker logs openfang

# Follow live logs
docker logs -f openfang

# Remove container (keeps the image)
docker rm openfang
```

---

## Troubleshooting

### `Unable to find image` error
Pull the image first:
```bash
docker pull ghcr.io/clawbuilders/openfang:latest
```

### `curl: (7) Failed to connect to 127.0.0.1 port 4200`
The container may still be starting. Wait 5 seconds and retry. Check logs:
```bash
docker logs openfang
```

### Port 4200 already in use
```bash
# Find what's using it
lsof -i :4200

# Or run on a different port
docker run -d --name openfang -p 4201:4200 ...
# Then access at http://localhost:4201
```

### NVIDIA API errors (401 Unauthorized)
- Verify your key starts with `nvapi-`
- Check `.env` has no quotes or spaces: `NVIDIA_API_KEY=nvapi-xxx`
- Confirm the key is active at https://build.nvidia.com

### Container exits immediately
```bash
docker logs openfang
```
Most common cause: missing or malformed `openfang.toml`. Confirm the file exists in your current directory when running the container.

### Docker Desktop out of memory (Mac/Windows)
Open Docker Desktop → Settings → Resources → increase Memory to at least 4 GB.

---

## Links

- OpenFang GitHub: https://github.com/RightNow-AI/openfang
- OpenFang Docs: https://openfang.sh/docs
- NVIDIA NIM Models: https://build.nvidia.com/models
- Docker Desktop: https://www.docker.com/products/docker-desktop/
- Discord: https://discord.gg/sSJqgNnq6X
