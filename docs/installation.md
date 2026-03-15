# Installation Guide

This guide explains how to use `install.sh` to bring up the full OpenClaw Oracle stack on a fresh Ubuntu VM.

The official OpenClaw Oracle guide recommends a Tailscale-first deployment with the gateway bound to loopback and remote access provided by Tailscale Serve:

- [OpenClaw Oracle Cloud guide](https://docs.openclaw.ai/platforms/oracle)

This repo goes further by layering in Open WebUI, Nginx, HTTPS, Telegram, browser fallback, and optional `n8n-as-code`.

## Prerequisites

- Oracle Cloud Ubuntu server
- Domain pointed to the server IP
- Oracle ingress rules allowing TCP `80` and `443`
- SSH access with sudo
- Kilo API key

Recommended extras:

- Telegram bot token
- Brave Search API key
- Firecrawl API key
- n8n host and API key if you plan to use `n8n-as-code`

Recommended if you want to follow the official Oracle security model first:

- Tailscale account
- a plan for keeping the gateway private until Tailscale access works

## Step 1: clone the repo

```bash
git clone git@github.com:SilentJMA/openclaw-oracle-starter.git
cd openclaw-oracle-starter
```

## Step 2: prepare environment variables

```bash
cp .env.example .env
```

Fill in at least:

```bash
DOMAIN=claw.example.com
EMAIL=you@example.com
KILO_API_KEY=replace_me
ENABLE_N8N_AS_CODE=true
```

Optional values:

```bash
TELEGRAM_BOT_TOKEN=
TELEGRAM_ALLOW_FROM=
BRAVE_API_KEY=
FIRECRAWL_API_KEY=
ENABLE_N8N_AS_CODE=true
OPENCLAW_GATEWAY_TOKEN=
GATEWAY_BASIC_AUTH_USER=admin
GATEWAY_BASIC_AUTH_PASS=
OPENWEBUI_SECRET_KEY=
```

## Step 3: run the installer

```bash
sudo bash -c 'set -a; source .env; ./install.sh'
```

## Step 4: choose your access model

### Official-style secure baseline

- Keep `gateway.bind` on loopback
- Keep token auth enabled
- Use Tailscale or SSH tunneling for admin access
- Avoid opening public Oracle ingress until you need it

### Public web setup from this repo

- Use your domain and Let's Encrypt
- Expose Open WebUI and `/gateway`
- Protect `/gateway` with token auth and optional Nginx auth
- Review Oracle ingress carefully

## Step 5: verify the result

Expected public endpoints:

- `https://YOUR_DOMAIN/`
- `https://YOUR_DOMAIN/gateway/#token=...`

Expected local services:

- Open WebUI on `127.0.0.1:3000`
- OpenClaw Gateway on `127.0.0.1:18789`
- Browser CDP on `127.0.0.1:18800`

Useful checks:

```bash
sudo systemctl status openclaw-gateway.service
sudo -u openclaw -H bash -lc 'source /home/openclaw/.openclaw/.env && openclaw gateway health'
docker ps
```

If you enabled `n8n-as-code`, finish the OpenClaw-side bootstrap:

```bash
sudo -u openclaw -H openclaw n8nac:setup
sudo systemctl restart openclaw-gateway.service
```

## Step 6: post-install tasks

- Verify Oracle security rules are correct
- Log into Open WebUI and confirm Kilo Free is available
- Test the public gateway URL
- Test Telegram if configured
- Run the `n8n-as-code` setup wizard if you enabled it
- Rotate any secrets if this was done on a shared machine

If you want to move closer to the official Oracle doc after installation:

- add Tailscale
- keep the gateway private on loopback
- prefer Tailscale Serve or SSH tunnel for admin access
- reduce Oracle ingress to only what you still need

## Troubleshooting notes

- If the gateway does not start, run `openclaw doctor`
- If HTTPS fails, verify the domain points to the server and ports `80/443` are open
- If LinkedIn-style pages fail in `web_search`, use the browser fallback path
- If `n8n-as-code` needs a clean reset, remove `~/.openclaw/n8nac` and rerun `openclaw n8nac:setup`
- If Telegram behaves oddly, inspect:

```bash
sudo journalctl -u openclaw-gateway.service -n 80 --no-pager
```
