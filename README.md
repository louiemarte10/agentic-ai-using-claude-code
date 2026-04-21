# louieDevAgent - Agentic AI Using Claude Code

A **multi-tenant AI agent system** powered by **Claude Code**, accessible via **Telegram**. Built on the [ClaudeClaw](https://github.com/earlyaidopters/claudeclaw) architecture and inspired by [OpenClaw](https://github.com/openclaw/openclaw) -- giving Claude a persistent body you can talk to from your pocket.

## What Is This?

louieDevAgent is a multi-agent command center that turns your existing Claude Code subscription into a team of specialized AI agents, each with their own Telegram bot, personality, workspace, and memory. One manager bot coordinates everything, specialist tenant bots handle domain-specific work.

**No extra API costs.** All agents use your existing Claude Code session/subscription.

## Multi-Tenant Architecture

```
User (Telegram)
    |
    v
louieDevAgent (Manager Bot)
    |-- Receives all messages
    |-- Classifies intent
    |-- Can handle general queries directly
    |-- Routes/delegates to specialist tenants
    |
    +---> Dev Agent (Tenant)      -- code, debugging, architecture
    +---> Comms Agent (Tenant)    -- emails, marketing, customer comms
    +---> Content Agent (Tenant)  -- writing, research, documentation
    +---> Ops Agent (Tenant)      -- devops, deployments, monitoring
    +---> Research Agent (Tenant) -- deep analysis, competitive intel
```

### How Tenants Work

Each tenant agent is an **isolated specialist** with:

| Property | Isolation |
|----------|-----------|
| **Telegram Bot** | Each tenant has its own @bot -- message directly |
| **Personality** | Own `CLAUDE.md` with role-specific instructions |
| **Workspace** | Own working directory under `workspaces/` |
| **Sessions** | Isolated session store per agent + chat |
| **Model** | Can use different Claude models (Opus for deep work, Haiku for quick tasks) |
| **Scheduler** | Own cron jobs that fire from the tenant's process |
| **Shared Memory** | All agents read/write to the same hive mind for cross-agent awareness |

### Delegation Methods

From the Manager bot, delegate to any tenant:

```
# @mention syntax
@dev: fix the auth bug in my FastAPI project

# Slash command
/delegate dev write a Python script that scrapes product prices

# Natural language (Manager routes via mission tasks)
"have dev build me a REST API for user authentication"
```

### Hive Mind (Shared Awareness)

All agents log completed tasks to a shared `hive_mind` table in SQLite. Any agent can query what others have been doing:

```
You: "what has dev been working on?"
Manager: checks hive_mind table, returns dev's recent activity
```

## Single-Agent Architecture

Each individual agent (manager or tenant) follows this flow:

```
Telegram Message (your phone)
    |
    v
Grammy Bot (receives via long-poll)
    |
    v
Claude Agent SDK (spawns claude CLI subprocess)
    |
    v
Claude Code (your subscription - Opus/Sonnet/Haiku)
    |-- Bash, File System, Web Search, MCP Servers
    |-- CLAUDE.md personality + instructions
    |-- ~/.claude/skills/ (Gmail, Calendar, etc.)
    |
    v
Response formatted + sent back to Telegram
    |
    v
SQLite logs: conversation, tokens, cost, memories
```

## Features

### Core
- **Multi-tenant architecture** -- manager bot + specialist tenant bots
- **Telegram interface** -- message any agent from anywhere
- **Full Claude Code power** -- bash, file editing, web search, browser automation
- **Session persistence** -- conversations continue across messages (no lost context)
- **Chat ID security** -- only your Telegram account can use any bot

### Memory System (5-Layer)
- **Session resumption** -- Claude remembers within a conversation
- **Persistent SQLite memory** -- facts, preferences, and context extracted automatically
- **Full-text search** -- find anything from past conversations
- **Memory consolidation** -- patterns detected across memories every 30 minutes
- **Automatic decay** -- old context fades, important facts persist

### Multi-Agent Productivity
- **Inter-agent delegation** -- manager routes tasks to the right specialist
- **Hive mind** -- shared activity log across all agents
- **Mission tasks** -- async task queue between agents
- **Per-agent scheduling** -- each tenant has its own cron jobs
- **Orchestrator** -- auto-discovers tenant agents at startup

### General Productivity
- **Scheduled tasks** -- cron-based scheduling ("every Monday at 9am, summarize AI news")
- **File sending** -- Claude creates files and sends them as Telegram attachments
- **Voice messages** -- send voice notes, get text responses (requires Groq API key)
- **Web dashboard** -- live monitoring at localhost:3141

### Integrations (Optional)
- Gmail management
- Google Calendar
- Google Drive
- Slack bridge
- WhatsApp bridge
- Custom MCP servers

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Runtime | Node.js 20+ |
| Language | TypeScript |
| AI Engine | Claude Code CLI via Agent SDK |
| Telegram | Grammy (long-polling) |
| Database | SQLite (better-sqlite3) |
| Dashboard | Hono + SSE |
| Orchestrator | Custom multi-agent router |
| Memory | Gemini Flash (classification) |
| Voice | Groq Whisper (STT), ElevenLabs (TTS) |

## Quick Setup

### Prerequisites
- Node.js 20+
- Claude Code CLI installed and authenticated (`npm i -g @anthropic-ai/claude-code && claude login`)
- A Telegram account

### Step 1: Clone and Install

```bash
git clone https://github.com/louiemarte10/agentic-ai-using-claude-code.git
cd agentic-ai-using-claude-code
npm install
```

### Step 2: Create Telegram Bots

Create one bot for the manager and one for each tenant you want:

1. Open Telegram, search for **@BotFather**
2. Send `/newbot` for each bot
3. Copy each bot token

### Step 3: Configure

```bash
cp .env.example .env
```

Edit `.env`:
```bash
# Manager bot
TELEGRAM_BOT_TOKEN=your_manager_bot_token
ALLOWED_CHAT_ID=your_telegram_chat_id

# Tenant bots (add as needed)
TELEGRAM_BOT_TOKEN_DEV=your_dev_bot_token
TELEGRAM_BOT_TOKEN_COMMS=your_comms_bot_token
TELEGRAM_BOT_TOKEN_CONTENT=your_content_bot_token
```

### Step 4: Build

```bash
npm run build
```

### Step 5: Start the Manager Bot

```bash
node dist/index.js
```

Send `/chatid` to the bot, paste the ID into `ALLOWED_CHAT_ID`, restart.

### Step 6: Start Tenant Agents

Each tenant runs as a separate process:

```bash
# Start dev agent
node dist/index.js --agent dev

# Start comms agent
node dist/index.js --agent comms

# Start content agent
node dist/index.js --agent content
```

### Important: Nested Session Fix

If starting bots from within a Claude Code session, prefix with `CLAUDECODE=`:

```bash
CLAUDECODE= node dist/index.js
CLAUDECODE= node dist/index.js --agent dev
```

This prevents the "Claude Code subprocess failed to start" error caused by nested session detection.

## Adding a New Tenant Agent

### Option 1: Use the CLI

```bash
npm run agent:create
```

### Option 2: Manual Setup

1. Create a directory under `agents/`:
```bash
mkdir agents/mytenant
```

2. Create `agents/mytenant/agent.yaml`:
```yaml
name: My Tenant
description: What this tenant specializes in
telegram_bot_token_env: TELEGRAM_BOT_TOKEN_MYTENANT
model: claude-sonnet-4-6
```

3. Create `agents/mytenant/CLAUDE.md` with the tenant's personality and instructions.

4. Add the bot token to `.env`:
```bash
TELEGRAM_BOT_TOKEN_MYTENANT=your_token_here
```

5. Rebuild and start:
```bash
npm run build
node dist/index.js --agent mytenant
```

## Current Tenant Roster

| Agent | Role | Model | Status |
|-------|------|-------|--------|
| **louieDevAgent** (Manager) | Triage, delegation, cross-agent planning | Opus | Active |
| **Dev** | Code, debugging, architecture, full-stack engineering | Opus | Active |
| Comms | Emails, marketing, customer communication | -- | Available |
| Content | Writing, research, documentation | -- | Available |
| Ops | DevOps, deployments, monitoring | -- | Available |
| Research | Deep analysis, competitive intel | -- | Available |

## Bot Commands

| Command | Description |
|---------|-------------|
| `/help` | List all commands |
| `/chatid` | Show your Telegram chat ID |
| `/newchat` | Start a fresh Claude session |
| `/respin` | Reload last 20 turns into new session |
| `/stop` | Cancel running query |
| `/model` | Switch model (haiku/sonnet/opus) |
| `/memory` | Show stored memories |
| `/forget` | Clear current session |
| `/voice` | Toggle voice replies |
| `/dashboard` | Open web dashboard |
| `/delegate` | Route a task to a tenant agent |
| `convolife` | Check context window usage |
| `checkpoint` | Save session summary to memory |

## Project Structure

```
louieDevAgent/
|-- CLAUDE.md                    # Manager personality and instructions
|-- .env                         # API keys and tokens (gitignored)
|-- src/
|   |-- index.ts                 # Entry point (supports --agent flag)
|   |-- bot.ts                   # Telegram message handler
|   |-- agent.ts                 # Claude Code subprocess runner
|   |-- agent-config.ts          # Tenant agent config loader
|   |-- orchestrator.ts          # Multi-agent delegation and routing
|   |-- db.ts                    # SQLite schema and queries
|   |-- memory.ts                # 5-layer context injection
|   |-- memory-ingest.ts         # Gemini extraction
|   |-- dashboard.ts             # Web UI
|   |-- scheduler.ts             # Cron jobs
|   +-- voice.ts                 # STT/TTS
|-- agents/
|   |-- _template/               # Template for new tenants
|   |-- dev/                     # Dev tenant (agent.yaml + CLAUDE.md)
|   |-- comms/                   # Comms tenant
|   |-- content/                 # Content tenant
|   |-- ops/                     # Ops tenant
|   +-- research/                # Research tenant
|-- workspaces/
|   +-- dev/                     # Dev tenant working directory
|-- skills/                      # Gmail, Calendar, Slack, Drive
|-- scripts/                     # Setup, status, utilities
|-- store/                       # SQLite DB, sessions (gitignored)
+-- dist/                        # Compiled JS (gitignored)
```

## Dashboard (Vue.js Mission Control)

A separate Vue.js dashboard for monitoring all agents from anywhere.

**Repo:** [louie-agent-dashboard](https://github.com/louiemarte10/louie-agent-dashboard)

### Features
- System health overview (context %, turns, Telegram status)
- Agent status grid (manager + all tenants, running/offline, costs)
- Hive mind activity feed (cross-agent awareness)
- Memory browser (stats, fading memories, top accessed)
- Task management (scheduled cron jobs + mission tasks)
- Dark theme, auto-refresh every 30s

### Deployment
1. Deploy [louie-agent-dashboard](https://github.com/louiemarte10/louie-agent-dashboard) to **Vercel** (free)
2. Expose localhost:3141 via **Cloudflare Tunnel** (free) -- see [Tunnel Setup Guide](docs/cloudflare-tunnel.md)
3. Set the tunnel URL as the API URL in the dashboard Settings page

### Remote Access (Cloudflare Tunnel)

Quick start:
```bash
# Download cloudflared (no install needed)
curl -kL -o cloudflared.exe https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe

# Temporary tunnel (URL changes on restart)
cloudflared tunnel --url http://localhost:3141

# For a permanent URL, set up a named tunnel -- see docs/cloudflare-tunnel.md
```

Full guide: [docs/cloudflare-tunnel.md](docs/cloudflare-tunnel.md)

## Security

- **Chat ID restriction** -- only your Telegram account can interact with any bot
- **Private chat only** -- rejects group messages
- **Audit logging** -- all actions timestamped in SQLite
- **.env gitignored** -- secrets never committed
- **Per-agent session isolation** -- tenants can't access each other's sessions
- **Optional PIN lock** -- requires PIN after idle timeout
- **Optional kill phrase** -- emergency stop for all agents

## Credits

- Built on [ClaudeClaw](https://github.com/earlyaidopters/claudeclaw) by EarlyAIDopters
- Powered by [Claude Code](https://claude.ai/claude-code) by Anthropic
- Inspired by [OpenClaw](https://github.com/openclaw/openclaw)

## License

MIT
