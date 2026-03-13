# OpenClaw Oracle Starter

[![Private Repo Ready](https://img.shields.io/badge/repo-private_ready-111111?style=flat-square)](https://github.com/SilentJMA/openclaw-oracle-starter)
![Oracle Cloud](https://img.shields.io/badge/platform-Oracle%20Cloud-F80000?style=flat-square)
![Ubuntu](https://img.shields.io/badge/os-Ubuntu%2024.04-E95420?style=flat-square)
![OpenClaw](https://img.shields.io/badge/stack-OpenClaw-0F172A?style=flat-square)
![Open WebUI](https://img.shields.io/badge/ui-Open%20WebUI-2563EB?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-16A34A?style=flat-square)

OpenClaw Oracle Starter is a deployment kit for standing up a full personal OpenClaw server on a fresh Oracle Cloud Ubuntu VM.

It is inspired by the fast, builder-friendly feel of [HKUDS/nanobot](https://github.com/HKUDS/nanobot), but aimed at a practical self-hosted assistant stack with public HTTPS, Telegram access, Open WebUI, OpenClaw Gateway, Kilo Free, and browser fallback for tougher websites.

## Highlights

- One-script Oracle bootstrap with [`install.sh`](./install.sh)
- Open WebUI at `/`
- OpenClaw Gateway at `/gateway`
- Telegram bot support
- Kilo Free as the default model
- Brave-powered `web_search`
- Chromium browser fallback for JS-heavy and anti-bot pages
- env-backed secrets instead of plain config secrets
- Nginx + Let's Encrypt HTTPS

## Repo layout

- [`install.sh`](./install.sh): full Oracle server setup script
- [`.env.example`](./.env.example): installer variables template
- [`docs/installation.md`](./docs/installation.md): step-by-step install and expected outcomes
- [`docs/materials.md`](./docs/materials.md): official source links for every major component
- [`OPENCLAW_REPO_DESCRIPTION.md`](./OPENCLAW_REPO_DESCRIPTION.md): reusable project description copy

## Quick start

```bash
git clone git@github.com:SilentJMA/openclaw-oracle-starter.git
cd openclaw-oracle-starter
cp .env.example .env
sudo bash -c 'set -a; source .env; ./install.sh'
```

Required variables:

- `DOMAIN`
- `EMAIL`
- `KILO_API_KEY`

Common optional variables:

- `TELEGRAM_BOT_TOKEN`
- `TELEGRAM_ALLOW_FROM`
- `BRAVE_API_KEY`
- `FIRECRAWL_API_KEY`
- `OPENCLAW_GATEWAY_TOKEN`
- `GATEWAY_BASIC_AUTH_USER`
- `GATEWAY_BASIC_AUTH_PASS`
- `OPENWEBUI_SECRET_KEY`

## What the installer sets up

1. Base packages, Docker, Node.js, Nginx, Certbot, and Chromium
2. A dedicated `openclaw` Linux user
3. Open WebUI and Ollama under `/opt/openclaw-stack`
4. OpenClaw Gateway under `/home/openclaw/.openclaw`
5. Telegram, Brave search, Kilo Free, and browser fallback defaults
6. systemd services for both the gateway and browser sidecar
7. Nginx routing for `/` and `/gateway`
8. HTTPS certificates with automatic renewal

## Runtime layout

- Open WebUI stack: `/opt/openclaw-stack`
- OpenClaw state: `/home/openclaw/.openclaw`
- Gateway service: `/etc/systemd/system/openclaw-gateway.service`
- Browser service: `/home/openclaw/.config/systemd/user/openclaw-browser.service`

## Documentation

- Setup guide: [`docs/installation.md`](./docs/installation.md)
- Materials and official links: [`docs/materials.md`](./docs/materials.md)

## Notes

- Browser fallback is the heavy-duty path for LinkedIn-style sites and anti-bot pages.
- Firecrawl is included as an env slot in the installer flow. Depending on the exact OpenClaw build, you may need to confirm the supported config shape before enabling it in config.
- The workspace instructions created by the installer are tuned for concise Telegram answers and better long-output formatting.

## Security

- Do not commit real `.env` files
- Do not commit API keys, SSH keys, or passwords
- Keep Oracle ingress rules limited to the ports you actually need
- Rotate gateway and bot secrets if they were ever exposed

## License

MIT
