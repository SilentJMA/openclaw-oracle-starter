# OpenClaw Oracle Starter

![Oracle Cloud](https://img.shields.io/badge/platform-Oracle%20Cloud-F80000?style=flat-square)
![Ubuntu](https://img.shields.io/badge/os-Ubuntu%2024.04-E95420?style=flat-square)
![OpenClaw](https://img.shields.io/badge/stack-OpenClaw-0F172A?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-16A34A?style=flat-square)

This repository installs a self-hosted OpenClaw server on an Oracle Cloud Ubuntu VM.

It is for people who want one script that sets up:

- OpenClaw Gateway
- Open WebUI
- HTTPS with Nginx and Let's Encrypt
- Telegram access
- Kilo Free as the default model
- Brave web search
- Browser fallback for sites that block basic fetch tools
- Optional `n8n-as-code`

## What this repository does

The installer sets up a working OpenClaw host with a dedicated `openclaw` user and a predictable file layout.

It also prepares a public web path for:

- Open WebUI at `/`
- OpenClaw Gateway at `/gateway`

This is an opinionated setup. It extends the official Oracle deployment guide with a public web stack and extra integrations.

## What this repository does not do

- It does not create Oracle Cloud resources for you.
- It does not create DNS records for you.
- It does not issue API keys for you.
- It does not hide the need to review your own security settings.

## Before you start

You need:

- An Oracle Cloud Ubuntu 24.04 VM
- A domain name that points to the server
- SSH access to the server
- A Kilo API key

You may also want:

- A Telegram bot token
- A Brave Search API key
- An `n8n` instance and API key

Read the official Oracle guide first:

- [OpenClaw on Oracle Cloud](https://docs.openclaw.ai/platforms/oracle)

## Quick start

Clone the repository, create an environment file, review the values, and run the installer:

```bash
git clone git@github.com:SilentJMA/openclaw-oracle-starter.git
cd openclaw-oracle-starter
cp .env.example .env
sudo bash -c 'set -a; source .env; ./install.sh'
```

## Required settings

Set these values in `.env` before you run the installer:

- `DOMAIN`
- `EMAIL`
- `KILO_API_KEY`

Common optional settings:

- `ENABLE_N8N_AS_CODE`
- `TELEGRAM_BOT_TOKEN`
- `TELEGRAM_ALLOW_FROM`
- `BRAVE_API_KEY`
- `FIRECRAWL_API_KEY`
- `OPENCLAW_GATEWAY_TOKEN`
- `GATEWAY_BASIC_AUTH_USER`
- `GATEWAY_BASIC_AUTH_PASS`
- `OPENWEBUI_SECRET_KEY`

Use [`.env.example`](./.env.example) as the reference.

## What gets installed

The installer sets up:

1. Base packages, Docker, Node.js, Nginx, Certbot, and Chromium
2. A dedicated `openclaw` user
3. Open WebUI and Ollama
4. OpenClaw Gateway
5. Kilo Free as the default model
6. Brave-powered web search
7. Browser fallback for difficult websites
8. Optional `n8n-as-code`
9. System services for the gateway and browser sidecar
10. HTTPS and certificate renewal

## Access options

This repository supports two common ways to access the server.

### Private access

Use the official Oracle guide approach:

- keep the gateway on loopback
- use token auth
- use Tailscale or another private access layer
- keep Oracle ingress limited

### Public access

This repository also supports a public HTTPS setup with:

- Nginx
- Let's Encrypt
- Open WebUI at `/`
- Gateway UI at `/gateway`

If you use the public path, review your Oracle network rules and authentication settings carefully.

## File layout

Important paths after install:

- Open WebUI stack: `/opt/openclaw-stack`
- OpenClaw state: `/home/openclaw/.openclaw`
- Gateway service: `/etc/systemd/system/openclaw-gateway.service`
- Browser service: `/home/openclaw/.config/systemd/user/openclaw-browser.service`

## Repository layout

- [`install.sh`](./install.sh): main installer
- [`.env.example`](./.env.example): environment variables template
- [`docs/installation.md`](./docs/installation.md): installation steps and expected results
- [`docs/materials.md`](./docs/materials.md): source links for the stack
- [`docs/n8n-as-code.md`](./docs/n8n-as-code.md): `n8n-as-code` setup notes
- [`OPENCLAW_REPO_DESCRIPTION.md`](./OPENCLAW_REPO_DESCRIPTION.md): short project description text

## After install

After the installer finishes, confirm:

1. The domain resolves to the server
2. HTTPS works
3. Open WebUI loads
4. The gateway loads
5. The default model is `kilo-auto/free`
6. Telegram works, if enabled

## Notes

- The official OpenClaw Oracle guide is more conservative than this repository. This project adds a public web stack by design.
- Browser fallback is intended for JavaScript-heavy or anti-bot sites where simple fetch tools are not enough.
- `n8n-as-code` is optional. If enabled, it still needs its own workspace setup after install.
- Firecrawl can be prepared through environment values, but support depends on the OpenClaw build you install.

## Documentation

- [Installation guide](./docs/installation.md)
- [Materials and source links](./docs/materials.md)
- [`n8n-as-code` guide](./docs/n8n-as-code.md)

## License

MIT
