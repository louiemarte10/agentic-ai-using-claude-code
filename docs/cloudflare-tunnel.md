# Cloudflare Tunnel Setup Guide

Expose your louieDevAgent API (localhost:3141) to the internet so the Vercel dashboard and your phone can connect.

## Quick Tunnel (Temporary URL)

The fastest way to get started. URL changes every time you restart.

### 1. Download cloudflared

**Windows (no admin needed):**
```bash
curl -kL -o cloudflared.exe https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe
```

**Linux:**
```bash
curl -L -o cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared
```

**macOS:**
```bash
brew install cloudflared
```

### 2. Start the tunnel

```bash
cloudflared tunnel --url http://localhost:3141
```

You'll get a URL like:
```
https://random-words-here.trycloudflare.com
```

### 3. Use it

Paste the tunnel URL into your Vercel dashboard Settings as the **API URL**.

**Limitation:** the URL changes every restart. For a permanent URL, use a named tunnel below.

---

## Named Tunnel (Permanent URL - Free)

A named tunnel gives you a **permanent, stable URL** that never changes. Requires a free Cloudflare account.

### 1. Login to Cloudflare

```bash
cloudflared tunnel login
```

This opens your browser. Sign up or log in at [cloudflare.com](https://dash.cloudflare.com/sign-up) (free tier works).

After login, a certificate is saved to `~/.cloudflared/cert.pem`.

### 2. Create a named tunnel

```bash
cloudflared tunnel create louie-dashboard
```

Output:
```
Created tunnel louie-dashboard with id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

Save the tunnel ID -- you'll need it.

### 3. Create the config file

Create `~/.cloudflared/config.yml`:

```yaml
tunnel: YOUR_TUNNEL_ID
credentials-file: ~/.cloudflared/YOUR_TUNNEL_ID.json

ingress:
  - hostname: louie-dashboard.YOUR_DOMAIN.com
    service: http://localhost:3141
  - service: http_status:404
```

**If you don't have a domain**, use Cloudflare's free `cfargotunnel.com` subdomain:

```yaml
tunnel: YOUR_TUNNEL_ID
credentials-file: ~/.cloudflared/YOUR_TUNNEL_ID.json

ingress:
  - service: http://localhost:3141
```

### 4. Route DNS (if using your own domain)

```bash
cloudflared tunnel route dns louie-dashboard louie-dashboard.YOUR_DOMAIN.com
```

Skip this step if you don't have a custom domain.

### 5. Start the tunnel

```bash
cloudflared tunnel run louie-dashboard
```

The tunnel URL is now permanent. Use it in your Vercel dashboard settings.

### 6. Auto-start on boot

**Windows (Task Scheduler):**
```bash
cloudflared service install
```

**Linux (systemd):**
```bash
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

**macOS (launchd):**
```bash
sudo cloudflared service install
```

---

## Alternative: ngrok (Free, Simpler)

If you prefer ngrok over Cloudflare:

### 1. Sign up

Go to [ngrok.com](https://ngrok.com) and create a free account.

### 2. Install

```bash
# Windows
choco install ngrok
# or download from https://ngrok.com/download

# Linux/macOS
brew install ngrok
```

### 3. Authenticate

```bash
ngrok config add-authtoken YOUR_AUTH_TOKEN
```

### 4. Start

```bash
ngrok http 3141
```

Free tier gives you a **static domain** like `https://your-name.ngrok-free.app`.

---

## Security Notes

- The dashboard API is protected by a **token** (`DASHBOARD_TOKEN` in `.env`). Without it, all requests return 401.
- The tunnel only exposes port 3141 (the dashboard API), not your entire machine.
- For production use, consider adding [Cloudflare Access](https://developers.cloudflare.com/cloudflare-one/) (free for up to 50 users) for an extra authentication layer.
- Never share your tunnel URL publicly -- anyone with the URL + token can view your dashboard.

## Architecture

```
Your Phone / Any Browser
    |
    v
Vue.js Dashboard (Vercel - HTTPS)
    |
    v
Cloudflare Tunnel (HTTPS) or ngrok
    |
    v
louieDevAgent API (localhost:3141)
    |
    v
SQLite DB (agents, memory, tasks, hive mind)
```

## Troubleshooting

| Issue | Solution |
|-------|---------|
| "Failed to fetch" in dashboard | Check tunnel is running, URL is correct in Settings |
| Mixed content error | Make sure you're using the HTTPS tunnel URL, not http://localhost |
| Tunnel URL changed | Restart cloudflared, update URL in dashboard Settings |
| Connection refused | Make sure the bot is running (`node dist/index.js`) |
| Slow responses | Normal -- requests go through the tunnel. Latency adds ~100-200ms |
