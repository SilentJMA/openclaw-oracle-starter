#!/usr/bin/env bash
set -Eeuo pipefail

log() {
  printf "\n[%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

die() {
  printf "\n[error] %s\n" "$*" >&2
  exit 1
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    die "Run this script as root."
  fi
}

rand_hex() {
  python3 - <<'PY'
import secrets
print(secrets.token_hex(32))
PY
}

rand_text() {
  python3 - <<'PY'
import secrets
print(secrets.token_urlsafe(32))
PY
}

require_var() {
  local name="$1"
  [[ -n "${!name:-}" ]] || die "Missing required environment variable: ${name}"
}

write_file() {
  local path="$1"
  shift
  install -d "$(dirname "$path")"
  cat >"$path"
}

main() {
  require_root

  require_var DOMAIN
  require_var EMAIL
  require_var KILO_API_KEY

  local repo_dir="/opt/openclaw-stack"
  local openclaw_user="openclaw"
  local openclaw_home="/home/${openclaw_user}"
  local openclaw_state="${openclaw_home}/.openclaw"
  local openclaw_workspace="${openclaw_state}/workspace"
  local gateway_token="${OPENCLAW_GATEWAY_TOKEN:-$(rand_hex)}"
  local webui_secret="${OPENWEBUI_SECRET_KEY:-$(rand_text)}"
  local gateway_basic_user="${GATEWAY_BASIC_AUTH_USER:-admin}"
  local gateway_basic_pass="${GATEWAY_BASIC_AUTH_PASS:-$(rand_text)}"
  local enable_n8n_as_code="${ENABLE_N8N_AS_CODE:-true}"
  local telegram_allow_from="${TELEGRAM_ALLOW_FROM:-}"
  local telegram_bot_token="${TELEGRAM_BOT_TOKEN:-}"
  local brave_api_key="${BRAVE_API_KEY:-}"
  local firecrawl_api_key="${FIRECRAWL_API_KEY:-}"

  export DEBIAN_FRONTEND=noninteractive

  log "Installing base packages"
  apt-get update
  apt-get install -y \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq \
    nginx \
    certbot \
    python3-certbot-nginx \
    apache2-utils \
    snapd \
    ufw \
    unzip

  log "Installing Docker"
  if ! command -v docker >/dev/null 2>&1; then
    install -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    . /etc/os-release
    printf \
      "deb [arch=%s signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu %s stable\n" \
      "$(dpkg --print-architecture)" \
      "${VERSION_CODENAME}" \
      >/etc/apt/sources.list.d/docker.list
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  fi
  systemctl enable --now docker

  log "Installing Node.js 22"
  if ! command -v node >/dev/null 2>&1 || [[ "$(node -v | cut -d. -f1 | tr -d v)" -lt 22 ]]; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt-get install -y nodejs
  fi

  log "Creating ${openclaw_user} user"
  if ! id -u "${openclaw_user}" >/dev/null 2>&1; then
    adduser --disabled-password --gecos "" "${openclaw_user}"
  fi
  usermod -aG docker "${openclaw_user}"
  loginctl enable-linger "${openclaw_user}" || true

  log "Preparing Open WebUI stack"
  install -d -o root -g root "${repo_dir}"
  write_file "${repo_dir}/docker-compose.yml" <<'EOF'
services:
  openwebui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: openclaw
    restart: unless-stopped
    ports:
      - "127.0.0.1:3000:8080"
    env_file:
      - .env
    volumes:
      - ./data/openwebui:/app/backend/data

  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    restart: unless-stopped
    volumes:
      - ./data/ollama:/root/.ollama
EOF

  write_file "${repo_dir}/.env" <<EOF
WEBUI_SECRET_KEY=${webui_secret}
OPENAI_API_BASE_URLS=https://api.kilo.ai/api/gateway
OPENAI_API_KEYS=${KILO_API_KEY}
DEFAULT_MODELS=kilo-auto/free
EOF
  chmod 600 "${repo_dir}/.env"
  docker compose -f "${repo_dir}/docker-compose.yml" up -d

  log "Installing OpenClaw"
  npm install -g openclaw@latest

  log "Preparing OpenClaw directories"
  install -d -o "${openclaw_user}" -g "${openclaw_user}" \
    "${openclaw_state}" \
    "${openclaw_workspace}" \
    "${openclaw_state}/skills" \
    "${openclaw_home}/.config/systemd/user" \
    "${openclaw_home}/snap/chromium/common/openclaw-profile"

  write_file "${openclaw_state}/.env" <<EOF
OPENCLAW_GATEWAY_TOKEN=${gateway_token}
BRAVE_API_KEY=${brave_api_key}
TELEGRAM_BOT_TOKEN=${telegram_bot_token}
FIRECRAWL_API_KEY=${firecrawl_api_key}
KILO_API_KEY=${KILO_API_KEY}
EOF
  chown "${openclaw_user}:${openclaw_user}" "${openclaw_state}/.env"
  chmod 600 "${openclaw_state}/.env"

  log "Writing OpenClaw config"
  write_file "${openclaw_state}/openclaw.json" <<EOF
{
  "models": {
    "mode": "merge",
    "providers": {
      "kilocode": {
        "baseUrl": "https://api.kilo.ai/api/gateway/",
        "api": "openai-completions",
        "apiKey": "\${KILO_API_KEY}",
        "models": [
          {
            "id": "kilo-auto/free",
            "name": "Kilo Auto Free",
            "reasoning": true,
            "input": ["text"],
            "cost": {
              "input": 0,
              "output": 0,
              "cacheRead": 0,
              "cacheWrite": 0
            },
            "contextWindow": 204800,
            "maxTokens": 131072
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "kilocode/kilo-auto/free"
      },
      "models": {
        "kilocode/kilo-auto/free": {
          "alias": "Kilo Free"
        }
      },
      "workspace": "${openclaw_workspace}"
    }
  },
  "tools": {
    "profile": "coding",
    "web": {
      "search": {
        "enabled": true,
        "provider": "brave"
      }
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "allowlist",
      "allowFrom": $(python3 - <<PY
import json
value = """${telegram_allow_from}""".strip()
items = [x.strip() for x in value.split(",") if x.strip()]
print(json.dumps(items))
PY
),
      "groupPolicy": "allowlist",
      "streaming": "off",
      "streamMode": "off"
    }
  },
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "loopback",
    "auth": {
      "mode": "token"
    },
    "trustedProxies": ["127.0.0.1", "::1"],
    "controlUi": {
      "allowedOrigins": ["https://${DOMAIN}"]
    }
  },
  "plugins": {
    "entries": {
      "telegram": {
        "enabled": true
      }
    }
  },
  "browser": {
    "enabled": true,
    "defaultProfile": "openclaw",
    "attachOnly": true,
    "headless": true,
    "noSandbox": true,
    "executablePath": "/snap/bin/chromium"
  }
}
EOF
  chown "${openclaw_user}:${openclaw_user}" "${openclaw_state}/openclaw.json"
  chmod 600 "${openclaw_state}/openclaw.json"

  log "Writing workspace instructions"
  write_file "${openclaw_workspace}/AGENTS.md" <<'EOF'
# OpenClaw Workspace

This workspace powers a personal OpenClaw deployment behind Telegram, web, and browser fallback tools.

## Web behavior

- Use `web_search` for quick discovery and current-news lookup.
- If a site is JS-heavy, anti-bot, or known to break `web_search` / `web_fetch` (for example LinkedIn, Instagram, Facebook, and many job boards), switch to the `browser` tool automatically.
- If browser access still hits a login wall or private content boundary, say that clearly.

## Formatting

- Prefer a one-line answer first, then 3-5 bullets max.
- Keep Telegram answers concise and readable.
- Avoid markdown tables in chat replies.
- If several links are needed, place each on its own line.
- For long outputs, give a compact summary first and only then the details.
EOF
  chown -R "${openclaw_user}:${openclaw_user}" "${openclaw_workspace}"

  log "Installing Chromium"
  snap install chromium || true

  log "Writing OpenClaw browser sidecar service"
  write_file "${openclaw_home}/.config/systemd/user/openclaw-browser.service" <<'EOF'
[Unit]
Description=OpenClaw Browser (Chromium CDP)
After=network.target

[Service]
ExecStart=/snap/bin/chromium --headless --no-sandbox --disable-gpu --remote-debugging-port=18800 --user-data-dir=%h/snap/chromium/common/openclaw-profile about:blank
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF
  chown -R "${openclaw_user}:${openclaw_user}" "${openclaw_home}/.config"
  su - "${openclaw_user}" -s /bin/bash -c \
    "XDG_RUNTIME_DIR=/run/user/$(id -u "${openclaw_user}") DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u "${openclaw_user}")/bus systemctl --user daemon-reload && \
     XDG_RUNTIME_DIR=/run/user/$(id -u "${openclaw_user}") DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u "${openclaw_user}")/bus systemctl --user enable --now openclaw-browser.service"

  log "Writing OpenClaw gateway service"
  write_file "/etc/systemd/system/openclaw-gateway.service" <<EOF
[Unit]
Description=OpenClaw Gateway
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${openclaw_user}
Group=${openclaw_user}
WorkingDirectory=${openclaw_home}
Environment=HOME=${openclaw_home}
Environment=TMPDIR=/run/openclaw
Environment=PATH=/usr/local/bin:/usr/bin:/bin
EnvironmentFile=-${openclaw_state}/.env
ExecStart=/usr/bin/node /usr/lib/node_modules/openclaw/dist/index.js gateway --port 18789
Restart=always
RestartSec=5
TimeoutStopSec=30
TimeoutStartSec=30
SuccessExitStatus=0 143
KillMode=control-group
NoNewPrivileges=true
ProtectSystem=full
ProtectHome=false
RuntimeDirectory=openclaw
RuntimeDirectoryMode=0750
ReadWritePaths=${openclaw_state} /run/openclaw

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  systemctl enable --now openclaw-gateway.service

  if [[ "${enable_n8n_as_code}" == "true" ]]; then
    if su - "${openclaw_user}" -s /bin/bash -c \
      "HOME=${openclaw_home} openclaw plugins list 2>/dev/null | grep -Fq '@n8n-as-code/openclaw-plugin'"; then
      log "n8n-as-code OpenClaw plugin already installed"
    else
      log "Installing n8n-as-code OpenClaw plugin"
      su - "${openclaw_user}" -s /bin/bash -c \
        "HOME=${openclaw_home} openclaw plugins install @n8n-as-code/openclaw-plugin"
      systemctl restart openclaw-gateway.service
    fi
  fi

  log "Writing Nginx config"
  htpasswd -bc /etc/nginx/.htpasswd-openclaw-gateway "${gateway_basic_user}" "${gateway_basic_pass}"
  write_file "/etc/nginx/sites-available/openclaw.conf" <<EOF
map \$http_upgrade \$connection_upgrade {
  default upgrade;
  '' close;
}

server {
  listen 80;
  listen [::]:80;
  server_name ${DOMAIN};

  location / {
    proxy_pass http://127.0.0.1:3000;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }

  location /gateway {
    auth_basic "OpenClaw Gateway";
    auth_basic_user_file /etc/nginx/.htpasswd-openclaw-gateway;
    proxy_pass http://127.0.0.1:18789;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \$connection_upgrade;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }

  location /gateway/ {
    auth_basic "OpenClaw Gateway";
    auth_basic_user_file /etc/nginx/.htpasswd-openclaw-gateway;
    proxy_pass http://127.0.0.1:18789/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \$connection_upgrade;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}
EOF
  ln -sf /etc/nginx/sites-available/openclaw.conf /etc/nginx/sites-enabled/openclaw.conf
  rm -f /etc/nginx/sites-enabled/default
  nginx -t
  systemctl enable --now nginx
  systemctl reload nginx

  log "Configuring firewall"
  ufw allow OpenSSH || true
  ufw allow 80/tcp || true
  ufw allow 443/tcp || true
  ufw --force enable || true

  log "Issuing HTTPS certificate"
  certbot --nginx --non-interactive --agree-tos --email "${EMAIL}" --redirect -d "${DOMAIN}"

  log "Waiting for OpenClaw to finish startup"
  sleep 60

  log "Health checks"
  su - "${openclaw_user}" -s /bin/bash -c \
    "source ${openclaw_state}/.env && openclaw gateway health"
  docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

  cat <<EOF

Setup complete.

Open WebUI:
  https://${DOMAIN}/

Gateway:
  https://${DOMAIN}/gateway/#token=${gateway_token}

Gateway basic auth:
  user: ${gateway_basic_user}
  pass: ${gateway_basic_pass}

Notes:
- Oracle Cloud security lists / NSGs must allow inbound 80 and 443.
- Firecrawl is env-ready but only activates once FIRECRAWL_API_KEY is provided.
- Telegram only starts cleanly if TELEGRAM_BOT_TOKEN is set.
- If n8n-as-code was installed, finish its workspace bootstrap as the openclaw user:
    sudo -u ${openclaw_user} -H openclaw n8nac:setup
  Then reload the gateway:
    sudo systemctl restart openclaw-gateway.service
EOF
}

main "$@"
