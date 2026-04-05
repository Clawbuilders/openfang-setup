#cloud-config
# OpenFang — Oracle Free Tier bootstrap (community setup)
# Pulls the pre-built ghcr.io/clawbuilders/openfang image — no Rust compile needed.
# Runs once on first boot as root. Takes ~3-5 minutes.

package_update: true
package_upgrade: true

packages:
  - git
  - dnf-plugins-core
  - iptables-services

write_files:
  - path: /opt/openfang/.env
    permissions: "0600"
    owner: root:root
    content: |
      ${llm_env_var}=${llm_api_key}
      OPENFANG_API_KEY=${openfang_api_key}
      TS_AUTHKEY=${tailscale_auth_key}
      OPENFANG_LISTEN=0.0.0.0:4200

  - path: /opt/openfang/openfang.toml
    permissions: "0644"
    owner: root:root
    content: |
      [default_model]
      %{ if llm_base_url != "" ~}
      provider    = "${llm_driver}"
      model       = "${llm_model}"
      api_key_env = "${llm_env_var}"
      base_url    = "${llm_base_url}"
      %{ else ~}
      provider    = "${llm_driver}"
      model       = "${llm_model}"
      api_key_env = "${llm_env_var}"
      %{ endif ~}

      [memory]
      decay_rate = 0.05

      [network]
      listen_addr = "0.0.0.0:4200"

  - path: /opt/openfang/docker-compose.yml
    permissions: "0644"
    owner: root:root
    content: |
      services:
        tailscale:
          image: tailscale/tailscale:latest
          container_name: openfang-tailscale
          hostname: openfang
          environment:
            - TS_AUTHKEY=${tailscale_auth_key}
            - TS_STATE_DIR=/var/lib/tailscale
            - TS_USERSPACE=false
          volumes:
            - tailscale-state:/var/lib/tailscale
            - /dev/net/tun:/dev/net/tun
          cap_add:
            - NET_ADMIN
          restart: unless-stopped

        openfang:
          image: ghcr.io/clawbuilders/openfang:latest
          container_name: openfang
          network_mode: service:tailscale
          depends_on:
            - tailscale
          volumes:
            - openfang-data:/data
            - /opt/openfang/openfang.toml:/data/config.toml:ro
          env_file:
            - /opt/openfang/.env
          restart: unless-stopped

      volumes:
        tailscale-state:
        openfang-data:

runcmd:
  # ── 1. Docker Engine ─────────────────────────────────────────────────────────
  - dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
  - dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  - systemctl enable --now docker
  - usermod -aG docker opc

  # ── 2. Tailscale ─────────────────────────────────────────────────────────────
  - dnf config-manager --add-repo https://pkgs.tailscale.com/stable/rhel/9/tailscale.repo
  - dnf install -y tailscale
  - systemctl enable --now tailscaled
  - tailscale up --authkey=${tailscale_auth_key} --accept-dns=false --hostname=openfang

  # ── 3. Pull pre-built image ───────────────────────────────────────────────────
  - docker pull ghcr.io/clawbuilders/openfang:latest

  # ── 4. Firewall: lock port 4200 to Tailscale interface only ──────────────────
  - iptables -A INPUT -p tcp --dport 4200 -i tailscale0 -j ACCEPT
  - iptables -A INPUT -p tcp --dport 4200 -j DROP
  - service iptables save

  # ── 5. Start OpenFang ─────────────────────────────────────────────────────────
  - cd /opt/openfang && docker compose up -d 2>&1 | tee /var/log/openfang-init.log

final_message: |
  ============================================================
  OpenFang is live!
  Dashboard (Tailscale only): http://$(tailscale ip -4):4200
  Logs: docker compose -f /opt/openfang/docker-compose.yml logs -f
  ============================================================
