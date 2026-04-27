# louieDevAgent — Startup Guide (After PC Shutdown)

Use this every time you restart your computer and need to bring everything back online.

---

## Prerequisites (one-time checks)

- Node.js 20+ installed
- Claude Code CLI authenticated (`claude login`)
- `.env` file exists with all tokens filled in
- `cloudflared.exe` exists at `C:\Users\Callbox\cloudflared.exe`

---

## Step-by-Step Startup

### Terminal 1 — Manager Bot (louieDevAgent)

Open **Git Bash** or **PowerShell** and run:

```bash
cd ~/louieDevAgent
node dist/index.js
```

Wait until you see something like:
```
✓ louieDevAgent bot started (polling)
✓ Dashboard running on http://localhost:3141
```

Test it: Send `/start` or `/help` to your manager bot on Telegram.

---

### Terminal 2 — Dev Agent

Open a **second terminal** and run:

```bash
cd ~/louieDevAgent
node dist/index.js --agent dev
```

Wait for it to confirm the bot is polling.

> **Note:** If you're running these from inside a Claude Code session, prefix each command with `CLAUDECODE=1` to avoid nested session errors:
> ```bash
> CLAUDECODE=1 node dist/index.js
> CLAUDECODE=1 node dist/index.js --agent dev
> ```

---

### Terminal 3 — Cloudflare Tunnel (for remote dashboard)

Open a **third terminal** and run:

```bash
cd ~
./cloudflared.exe tunnel --config config.yml run
```

Once it connects, your Vue dashboard at louiedevagent.pages.dev (or your Vercel URL) will be able to reach the local dashboard on port 3141.

---

## Quick Checklist

| # | What | Command | Expected |
|---|------|---------|----------|
| 1 | Manager bot | `node dist/index.js` | Bot responds to Telegram messages |
| 2 | Dev agent | `node dist/index.js --agent dev` | Dev bot polling |
| 3 | Cloudflare tunnel | `./cloudflared.exe tunnel --config config.yml run` | Tunnel connected |
| 4 | Dashboard | Open `http://localhost:3141` | Dashboard loads |

---

## Troubleshooting

### Bot doesn't respond
1. Check the terminal — look for errors like `invalid token` or `connection refused`
2. Verify `.env` has the correct `TELEGRAM_BOT_TOKEN` and `ALLOWED_CHAT_ID`
3. Make sure only one instance is running per bot (kill duplicate processes)

```bash
# Kill all node processes if needed (Git Bash)
taskkill //F //IM node.exe
```

### "Nested claude session" error
You're running inside Claude Code. Add the prefix:
```bash
CLAUDECODE=1 node dist/index.js
```

### Build is outdated (code changes aren't taking effect)
Rebuild before starting:
```bash
cd ~/louieDevAgent
npm run build
node dist/index.js
```

### Cloudflare tunnel won't connect
- Make sure `config.yml` is in `C:\Users\Callbox\config.yml`
- Check that your tunnel ID in `config.yml` matches your Cloudflare dashboard

### Dashboard shows no data
- The manager bot must be running first — the dashboard reads from the same SQLite DB
- Check `http://localhost:3141` is accessible locally before checking remote

---

## Starting Other Agents (Optional)

Only start these if you need them:

```bash
node dist/index.js --agent comms
node dist/index.js --agent content
node dist/index.js --agent ops
node dist/index.js --agent research
```

Each needs its own terminal.

---

## Shutdown (Clean Stop)

When you're done or about to shut down, press `Ctrl+C` in each terminal. The bots stop gracefully. SQLite data is automatically persisted — no manual save needed.

---

## Full Restart Order Summary

```
Terminal 1:  cd ~/louieDevAgent && node dist/index.js
Terminal 2:  cd ~/louieDevAgent && node dist/index.js --agent dev
Terminal 3:  cd ~ && ./cloudflared.exe tunnel --config config.yml run
```
