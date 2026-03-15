# OpenClaw Oracle Starter

[![Private Repo Ready](https://img.shields.io/badge/repo-private_ready-111111?style=flat-square)](https://github.com/SilentJMA/openclaw-oracle-starter)
![Oracle Cloud](https://img.shields.io/badge/platform-Oracle%20Cloud-F80000?style=flat-square)
![Ubuntu](https://img.shields.io/badge/os-Ubuntu%2024.04-E95420?style=flat-square)
![OpenClaw](https://img.shields.io/badge/stack-OpenClaw-0F172A?style=flat-square)
![Open WebUI](https://img.shields.io/badge/ui-Open%20WebUI-2563EB?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-16A34A?style=flat-square)

OpenClaw Oracle Starter is a deployment kit for standing up a full personal OpenClaw server on a fresh Oracle Cloud Ubuntu VM.

It is inspired by the fast, builder-friendly feel of [HKUDS/nanobot](https://github.com/HKUDS/nanobot), but aimed at a practical self-hosted assistant stack with OpenClaw Gateway, Open WebUI, Telegram access, Kilo Free, and browser fallback for tougher websites.

The repo is now documented against the official [OpenClaw Oracle Cloud guide](https://docs.openclaw.ai/platforms/oracle). That official guide recommends a Tailscale-first, loopback-only gateway on Oracle Always Free ARM. This starter keeps that baseline in mind, but extends it with an opinionated public web stack for people who also want:

- Open WebUI at `/`
- a public `/gateway`
- Nginx and Let's Encrypt
- Telegram bot access
- optional `n8n-as-code`

## Highlights

- One-script Oracle bootstrap with [`install.sh`](./install.sh)
- Open WebUI at `/`
- OpenClaw Gateway at `/gateway`
- Telegram bot support
- Kilo Free as the default model
- Brave-powered `web_search`
- Chromium browser fallback for JS-heavy and anti-bot pages
- Optional `n8n-as-code` plugin install for n8n workflow work inside OpenClaw
- env-backed secrets instead of plain config secrets
- Nginx + Let's Encrypt HTTPS

## Official Oracle baseline

The upstream OpenClaw Oracle doc recommends this baseline:

1. Create an Oracle Always Free ARM VM (`VM.Standard.A1.Flex`, Ubuntu 24.04).
2. Install Tailscale and enable `tailscale up --ssh`.
3. Install OpenClaw directly on the VM.
4. Keep `gateway.bind=loopback`.
5. Use `gateway.auth.mode=token`.
6. Expose access through Tailscale Serve instead of public Internet ingress.
7. Lock Oracle VCN ingress down after Tailscale is working.

Official reference:
- [OpenClaw Oracle Cloud](https://docs.openclaw.ai/platforms/oracle)

This repo differs on purpose:

- It keeps the gateway on loopback and token auth, matching the official guidance.
- It also adds Nginx, HTTPS, and public access for people who want browser access without depending only on Tailscale.
- It adds Open WebUI, Telegram, Brave web search, browser fallback, and `n8n-as-code`.

If you want the strictest security posture, follow the official Tailscale-only access pattern first, then add public exposure only if you actually need it.

## Repo layout

- [`install.sh`](./install.sh): full Oracle server setup script
- [`.env.example`](./.env.example): installer variables template
- [`docs/installation.md`](./docs/installation.md): step-by-step install and expected outcomes
- [`docs/materials.md`](./docs/materials.md): official source links for every major component
- [`docs/n8n-as-code.md`](./docs/n8n-as-code.md): OpenClaw + n8n-as-code setup and workflow commands
- [`OPENCLAW_REPO_DESCRIPTION.md`](./OPENCLAW_REPO_DESCRIPTION.md): reusable project description copy

## Quick start

```bash
git clone git@github.com:SilentJMA/openclaw-oracle-starter.git
cd openclaw-oracle-starter
cp .env.example .env
sudo bash -c 'set -a; source .env; ./install.sh'
```

For a Tailscale-first deployment, read the official Oracle guide before exposing anything publicly:

- [OpenClaw Oracle Cloud guide](https://docs.openclaw.ai/platforms/oracle)

Required variables:

- `DOMAIN`
- `EMAIL`
- `KILO_API_KEY`

Common optional variables:

- `ENABLE_N8N_AS_CODE`
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
6. Optional `n8n-as-code` OpenClaw plugin install
7. systemd services for both the gateway and browser sidecar
8. Nginx routing for `/` and `/gateway`
9. HTTPS certificates with automatic renewal

## Access models

You can use this repo in two ways:

### 1. Official-style private access

- Keep Oracle ingress tight
- Prefer Tailscale for remote admin access
- Keep the gateway loopback-only with token auth
- Use SSH or Tailscale to reach the Control UI

### 2. Public web stack

- Use a domain, Nginx, and Let's Encrypt
- Expose Open WebUI and `/gateway` publicly
- Add extra auth layers at Nginx and in OpenClaw
- Be more deliberate about Oracle security rules and credential rotation

## Runtime layout

- Open WebUI stack: `/opt/openclaw-stack`
- OpenClaw state: `/home/openclaw/.openclaw`
- Gateway service: `/etc/systemd/system/openclaw-gateway.service`
- Browser service: `/home/openclaw/.config/systemd/user/openclaw-browser.service`

## Documentation

- Setup guide: [`docs/installation.md`](./docs/installation.md)
- Materials and official links: [`docs/materials.md`](./docs/materials.md)
- n8n workflow integration: [`docs/n8n-as-code.md`](./docs/n8n-as-code.md)

## Notes

- The official OpenClaw Oracle guide is Tailscale-first and more conservative than this repo's default public-web setup.
- Browser fallback is the heavy-duty path for LinkedIn-style sites and anti-bot pages.
- `n8n-as-code` is installed by the bootstrap script when `ENABLE_N8N_AS_CODE=true`, then finished with `openclaw n8nac:setup`.
- Firecrawl is included as an env slot in the installer flow. Depending on the exact OpenClaw build, you may need to confirm the supported config shape before enabling it in config.
- The workspace instructions created by the installer are tuned for concise Telegram answers and better long-output formatting.

## Security

- The upstream recommendation is: loopback gateway + token auth + Tailscale Serve + locked-down Oracle VCN.
- Do not commit real `.env` files
- Do not commit API keys, SSH keys, or passwords
- Keep Oracle ingress rules limited to the ports you actually need
- Rotate gateway and bot secrets if they were ever exposed

## License

MIT
