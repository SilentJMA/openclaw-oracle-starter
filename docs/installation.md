# Installation Guide

This guide explains how to use `install.sh` to bring up the full OpenClaw Oracle stack on a fresh Ubuntu VM.

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
```

Optional values:

```bash
TELEGRAM_BOT_TOKEN=
TELEGRAM_ALLOW_FROM=
BRAVE_API_KEY=
FIRECRAWL_API_KEY=
OPENCLAW_GATEWAY_TOKEN=
GATEWAY_BASIC_AUTH_USER=admin
GATEWAY_BASIC_AUTH_PASS=
OPENWEBUI_SECRET_KEY=
```

## Step 3: run the installer

```bash
sudo bash -c 'set -a; source .env; ./install.sh'
```

## Step 4: verify the result

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

## Step 5: post-install tasks

- Verify Oracle security rules are correct
- Log into Open WebUI and confirm Kilo Free is available
- Test the public gateway URL
- Test Telegram if configured
- Rotate any secrets if this was done on a shared machine

## Troubleshooting notes

- If the gateway does not start, run `openclaw doctor`
- If HTTPS fails, verify the domain points to the server and ports `80/443` are open
- If LinkedIn-style pages fail in `web_search`, use the browser fallback path
- If Telegram behaves oddly, inspect:

```bash
sudo journalctl -u openclaw-gateway.service -n 80 --no-pager
```
