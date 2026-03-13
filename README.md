# OpenClaw Oracle Starter

[![Private Repo Ready](https://img.shields.io/badge/repo-private_ready-111111?style=flat-square)](https://github.com/SilentJMA/openclaw-oracle-starter)
![Oracle Cloud](https://img.shields.io/badge/platform-Oracle%20Cloud-F80000?style=flat-square)
![Ubuntu](https://img.shields.io/badge/os-Ubuntu%2024.04-E95420?style=flat-square)
![OpenClaw](https://img.shields.io/badge/stack-OpenClaw-0F172A?style=flat-square)
![Open WebUI](https://img.shields.io/badge/ui-Open%20WebUI-2563EB?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-16A34A?style=flat-square)

OpenClaw Oracle Starter is a one-command deployment kit for bringing up a personal OpenClaw server on a fresh Oracle Ubuntu VM.

It is inspired by the sharp, practical energy of [HKUDS/nanobot](https://github.com/HKUDS/nanobot), but focused on a real self-hosted assistant stack: public HTTPS, Telegram, Open WebUI, OpenClaw Gateway, Kilo Free, browser fallback, and production-style service wiring.

## What you get

- Open WebUI at `/`
- OpenClaw Gateway at `/gateway`
- Kilo Free as the default model
- Telegram bot support
- Brave-powered `web_search`
- Chromium browser fallback for JS-heavy or anti-bot websites like LinkedIn
- Nginx reverse proxy with Let's Encrypt HTTPS
- dedicated `openclaw` Linux user
- env-backed secrets instead of plain config secrets

## Why this repo

- Fast bootstrap: start from a blank Oracle VM and get a usable assistant online quickly
- Practical defaults: HTTPS, auth, browser fallback, and Telegram-friendly output rules
- Clean operations: systemd services, Dockerized Open WebUI, dedicated runtime user
- Easy to extend: skills, prompts, channels, automations, and model changes all fit naturally

## Architecture

The installer sets up:

- `openclaw` as a dedicated runtime user
- Open WebUI and Ollama with Docker Compose under `/opt/openclaw-stack`
- OpenClaw state under `/home/openclaw/.openclaw`
- OpenClaw Gateway as a systemd service
- headless Chromium as a user-scoped systemd service for browser automation
- Nginx as the public reverse proxy
- Certbot for HTTPS

## Included files

- [`install.sh`](./install.sh): end-to-end server bootstrap script
- [`OPENCLAW_REPO_DESCRIPTION.md`](./OPENCLAW_REPO_DESCRIPTION.md): reusable repo description / intro copy
- [`.env.example`](./.env.example): example installer environment

## Requirements

- A fresh Oracle Cloud Ubuntu server
- A DNS record pointed at the server
- Oracle security rules allowing inbound `80` and `443`
- SSH access as a sudo-capable user
- A Kilo API key

Optional but recommended:

- Telegram bot token
- Brave Search API key
- Firecrawl API key

## Quick start

1. Clone the repo onto your Oracle server.
2. Copy `.env.example` to a real env file.
3. Fill in the required values.
4. Run the installer as root.

Example:

```bash
git clone git@github.com:SilentJMA/openclaw-oracle-starter.git
cd openclaw-oracle-starter
cp .env.example .env
sudo bash -c 'set -a; source .env; ./install.sh'
```

## Installer usage

The installer reads configuration from environment variables.

Required:

- `DOMAIN`
- `EMAIL`
- `KILO_API_KEY`

Optional:

- `TELEGRAM_BOT_TOKEN`
- `TELEGRAM_ALLOW_FROM`
- `BRAVE_API_KEY`
- `FIRECRAWL_API_KEY`
- `OPENCLAW_GATEWAY_TOKEN`
- `GATEWAY_BASIC_AUTH_USER`
- `GATEWAY_BASIC_AUTH_PASS`
- `OPENWEBUI_SECRET_KEY`

### Example `.env`

```bash
DOMAIN=claw.example.com
EMAIL=you@example.com
KILO_API_KEY=replace_me

TELEGRAM_BOT_TOKEN=
TELEGRAM_ALLOW_FROM=
BRAVE_API_KEY=
FIRECRAWL_API_KEY=

OPENCLAW_GATEWAY_TOKEN=
GATEWAY_BASIC_AUTH_USER=admin
GATEWAY_BASIC_AUTH_PASS=
OPENWEBUI_SECRET_KEY=
```

## What `install.sh` does

1. Installs system packages, Docker, Node.js, Nginx, Certbot, and Chromium
2. Creates the dedicated `openclaw` user
3. Starts Open WebUI and Ollama with Docker
4. Installs OpenClaw globally
5. Writes OpenClaw config, workspace instructions, and env-backed secrets
6. Configures Telegram, Brave search, Kilo Free, and browser fallback
7. Creates systemd services for the gateway and browser sidecar
8. Configures Nginx for `/` and `/gateway`
9. Issues HTTPS certificates with Let's Encrypt
10. Prints the final URLs and gateway auth details

## After install

Expected endpoints:

- `https://YOUR_DOMAIN/`
- `https://YOUR_DOMAIN/gateway/#token=...`

Expected runtime locations:

- Open WebUI stack: `/opt/openclaw-stack`
- OpenClaw state: `/home/openclaw/.openclaw`
- Gateway service: `/etc/systemd/system/openclaw-gateway.service`
- Browser service: `/home/openclaw/.config/systemd/user/openclaw-browser.service`

## Notes

- Firecrawl is included as an env slot in the installer flow, but depending on the OpenClaw version you install, you may need to confirm the exact supported config shape before enabling its full config block.
- Browser fallback is the heavy-duty path for anti-bot and JS-heavy pages.
- Telegram output is tuned for concise, cleaner replies instead of duplicated streaming previews.

## Security

- Do not commit real `.env` files
- Do not commit API keys, SSH keys, or passwords
- Rotate gateway tokens and bot tokens if they were ever exposed
- Keep Oracle ingress rules limited to the ports you actually use

## License

MIT
