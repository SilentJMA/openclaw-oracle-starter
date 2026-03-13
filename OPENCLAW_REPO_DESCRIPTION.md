# OpenClaw Oracle Starter

OpenClaw Oracle Starter is a one-command deployment kit for spinning up a personal OpenClaw stack on a fresh Oracle Ubuntu server.

It is inspired by the clear, fast-moving style of [HKUDS/nanobot](https://github.com/HKUDS/nanobot), but this setup is aimed at a production-ready personal assistant stack rather than a minimal research clone.

## Suggested repo description

OpenClaw Oracle Starter: one-command deployment for a personal OpenClaw server with Open WebUI, Telegram, Kilo Free, browser fallback, HTTPS, and Nginx.

## README intro draft

# OpenClaw Oracle Starter

OpenClaw Oracle Starter is a lightweight deployment kit for running your own personal AI assistant on Oracle Cloud.

It installs a complete stack from a clean Ubuntu server:

- Open WebUI at `/`
- OpenClaw Gateway at `/gateway`
- Telegram bot support
- Kilo Free as the default model
- Brave-powered web search
- Browser fallback for JS-heavy or anti-bot sites like LinkedIn
- Nginx reverse proxy with HTTPS

## Why this repo

- Fast to deploy: start from a blank Oracle VM and bring the full stack online with one script.
- Practical defaults: HTTPS, gateway auth, browser fallback, Telegram-friendly formatting, and env-backed secrets.
- Easy to extend: add your own OpenClaw skills, prompts, channels, and automations without redesigning the stack.

## What makes it different

This repo focuses on the real-world self-hosting path:

- clean server bootstrap
- repeatable systemd services
- Dockerized Open WebUI
- dedicated `openclaw` runtime user
- reverse proxy setup that is ready for public access

It is meant for builders who want a hosted personal AI assistant, not just a demo.

## Included in `install.sh`

- Docker + Open WebUI + Ollama
- OpenClaw installation and gateway service
- Telegram channel configuration
- Kilo Free model wiring
- Brave web search setup
- Chromium browser sidecar for blocked websites
- Nginx + Let's Encrypt HTTPS
- gateway auth token generation
- env-backed secret handling

## Environment variables expected by the installer

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
