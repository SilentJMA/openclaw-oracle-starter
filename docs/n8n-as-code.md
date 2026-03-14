# n8n-as-code With OpenClaw

This starter can install the `@n8n-as-code/openclaw-plugin` package so your OpenClaw server can work against an n8n workspace using the same `n8nac` model documented upstream.

## What gets added

When `ENABLE_N8N_AS_CODE=true`, the installer adds the published OpenClaw plugin:

```bash
openclaw plugins install @n8n-as-code/openclaw-plugin
```

That gives your OpenClaw deployment:

- the `n8nac` tool surface inside OpenClaw
- the `openclaw n8nac:setup` bootstrap wizard
- a dedicated OpenClaw workspace under `~/.openclaw/n8nac`
- generated `AGENTS.md` workflow instructions after setup

## Finish the setup on the server

After `install.sh` completes, connect to the server and run:

```bash
sudo -u openclaw -H openclaw n8nac:setup
sudo systemctl restart openclaw-gateway.service
```

The setup wizard will walk you through the upstream flow:

1. Save your n8n host and API key.
2. Select the active n8n project.
3. Generate the `AGENTS.md` workflow instructions.
4. Point OpenClaw at the initialized `~/.openclaw/n8nac` workspace.

## Common commands

```bash
sudo -u openclaw -H openclaw n8nac:setup
sudo -u openclaw -H openclaw n8nac:status
sudo -u openclaw -H npx --yes n8nac list
sudo -u openclaw -H npx --yes n8nac pull <workflow-id>
sudo -u openclaw -H npx --yes n8nac push <file>
sudo -u openclaw -H npx --yes n8nac update-ai
```

## Reset flow

If you want to rebuild the `n8n-as-code` workspace from scratch:

```bash
sudo -u openclaw -H rm -rf /home/openclaw/.openclaw/n8nac
sudo -u openclaw -H openclaw n8nac:setup
sudo systemctl restart openclaw-gateway.service
```

## Source material

- Upstream repo: [EtienneLescot/n8n-as-code](https://github.com/EtienneLescot/n8n-as-code)
- OpenClaw plugin docs: [n8n-as-code OpenClaw usage](https://n8nascode.dev/docs/usage/openclaw/)
- Getting started: [n8n-as-code docs](https://n8nascode.dev/docs/getting-started/)
