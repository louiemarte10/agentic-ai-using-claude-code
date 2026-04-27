# Cloudflare Tunnel Setup

Exposes your local bot dashboard (port 3141) to the internet so the Vercel-hosted dashboard can connect to it.

## Quick Start (New Machine)

1. **Download cloudflared** (if not present):
   ```
   winget install cloudflare.cloudflared
   ```
   Or download manually from https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/

2. **Start the tunnel**:
   ```
   start-tunnel.bat
   ```
   A random URL like `https://xyz-abc.trycloudflare.com` will appear in the terminal.

3. **Update the dashboard** at https://louie-agent-dashboard.vercel.app:
   - Go to **Settings**
   - Click **"Load Tunnel URL"** — it auto-fills from the running bot
   - OR paste the URL manually into the API URL field
   - Click **Save Configuration**, then **Test Connection**

## How It Works

```
Vercel Dashboard  →  Cloudflare Tunnel  →  localhost:3141  →  louieDevAgent bot
```

- `start-tunnel.ps1` starts a Quick Tunnel and saves the URL to `store/current-tunnel-url.txt`
- The bot exposes `/api/tunnel-url` which reads that file
- The dashboard **Load Tunnel URL** button fetches it automatically

## Changing Cloudflare Accounts

If you switch to a different Cloudflare account or machine:

1. Run `start-tunnel.bat` — new URL is generated and saved automatically
2. In the dashboard Settings, click **Load Tunnel URL**
3. Click Save → Test Connection

No manual URL hunting needed.

## Startup Auto-Launch

To start the tunnel automatically with Windows:

1. Copy `start-tunnel.bat` to your Windows Startup folder:
   ```
   C:\Users\Callbox\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\
   ```
   Or run the tunnel from the same terminal/session as the bot.

## Persistent Named Tunnel (Optional)

For a permanent, non-changing URL (requires a Cloudflare account + domain):

```bash
cloudflared tunnel login
cloudflared tunnel create louie-api
cloudflared tunnel route dns louie-api api.yourdomain.com
cloudflared tunnel run louie-api
```

Then set the fixed URL in `.env`:
```
DASHBOARD_URL=https://api.yourdomain.com
```

## Troubleshooting

| Problem | Fix |
|---|---|
| `Failed to fetch` in dashboard | Tunnel is not running — run `start-tunnel.bat` |
| URL works but auth fails | Check `DASHBOARD_TOKEN` in `.env` matches dashboard Settings |
| Tunnel starts but URL not saved | Check `store/` folder exists |
| `cloudflared.exe not found` | Move `cloudflared.exe` to `C:\Users\Callbox\` or update path in `start-tunnel.ps1` |
