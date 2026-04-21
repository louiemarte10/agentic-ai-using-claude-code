# louieDevAgent - Agentic AI Using Claude Code

A personal AI dev agent powered by **Claude Code**, accessible via **Telegram**. Built on the [ClaudeClaw](https://github.com/earlyaidopters/claudeclaw) architecture -- giving Claude a persistent body you can talk to from your pocket.

## What Is This?

louieDevAgent turns your existing Claude Code subscription into a 24/7 personal AI assistant that lives in Telegram. You message it like a colleague, and it executes tasks on your machine using the full power of Claude Code -- file editing, bash commands, web search, code generation, and more.

**No extra API costs.** It uses your existing Claude Code session/subscription.

## Architecture

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
- **Telegram interface** -- message your AI agent from anywhere
- **Full Claude Code power** -- bash, file editing, web search, browser automation
- **Session persistence** -- conversations continue across messages (no lost context)
- **Chat ID security** -- only your Telegram account can use the bot

### Memory System (5-Layer)
- **Session resumption** -- Claude remembers within a conversation
- **Persistent SQLite memory** -- facts, preferences, and context extracted automatically
- **Full-text search** -- find anything from past conversations
- **Memory consolidation** -- patterns detected across memories every 30 minutes
- **Automatic decay** -- old context fades, important facts persist

### Productivity
- **Scheduled tasks** -- cron-based scheduling ("every Monday at 9am, summarize AI news")
- **Multi-agent delegation** -- route tasks to specialist agents (research, comms, content, ops)
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

### Step 2: Create Telegram Bot

1. Open Telegram, search for **@BotFather**
2. Send `/newbot`
3. Name it whatever you want (e.g., "louieDevAgent")
4. Copy the bot token

### Step 3: Configure

Copy the example env and fill in your bot token:

```bash
cp .env.example .env
```

Edit `.env`:
```
TELEGRAM_BOT_TOKEN=your_bot_token_here
ALLOWED_CHAT_ID=
```

### Step 4: Build and Start

```bash
npm run build
node dist/index.js
```

### Step 5: Get Your Chat ID

1. Open Telegram, find your bot
2. Send `/chatid`
3. Copy the number, paste into `ALLOWED_CHAT_ID` in `.env`
4. Restart the bot

### Important: Nested Session Fix

If you start the bot from within a Claude Code session, you may get "Claude Code subprocess failed to start". This is because Claude Code detects nested sessions. The fix is already applied in `src/agent.ts` -- it removes the `CLAUDECODE` environment variable before spawning the subprocess.

If running from outside Claude Code, start normally:
```bash
node dist/index.js
```

If running from inside a Claude Code session:
```bash
CLAUDECODE= node dist/index.js
```

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
| `convolife` | Check context window usage |
| `checkpoint` | Save session summary to memory |

## Customization

### Personality (CLAUDE.md)

Edit `CLAUDE.md` to customize your agent's personality, knowledge about you, available skills, and behavior rules. This file is loaded into every Claude session.

### Multi-Agent Setup

Create specialist agents with their own Telegram bots and personalities:

```bash
npm run agent:create
```

Or manually copy `agents/_template/` and configure.

## Project Structure

```
louieDevAgent/
|-- CLAUDE.md              # Agent personality and instructions
|-- .env                   # API keys (gitignored)
|-- src/
|   |-- index.ts           # Entry point
|   |-- bot.ts             # Telegram message handler
|   |-- agent.ts           # Claude Code subprocess runner
|   |-- db.ts              # SQLite schema and queries
|   |-- memory.ts          # 5-layer context injection
|   |-- memory-ingest.ts   # Gemini extraction
|   |-- dashboard.ts       # Web UI
|   |-- scheduler.ts       # Cron jobs
|   +-- voice.ts           # STT/TTS
|-- agents/                # Multi-agent configs
|-- skills/                # Gmail, Calendar, Slack, Drive
|-- scripts/               # Setup, status, utilities
|-- store/                 # SQLite DB, sessions (gitignored)
+-- dist/                  # Compiled JS (gitignored)
```

## Security

- **Chat ID restriction** -- only your Telegram account can interact
- **Private chat only** -- rejects group messages
- **Audit logging** -- all actions timestamped in SQLite
- **.env gitignored** -- secrets never committed
- **Optional PIN lock** -- requires PIN after idle timeout
- **Optional kill phrase** -- emergency stop for all agents

## Credits

- Built on [ClaudeClaw](https://github.com/earlyaidopters/claudeclaw) by EarlyAIDopters
- Powered by [Claude Code](https://claude.ai/claude-code) by Anthropic
- Inspired by [OpenClaw](https://github.com/openclaw/openclaw)

## License

MIT
