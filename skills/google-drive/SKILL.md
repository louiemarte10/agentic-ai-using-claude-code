---
name: google-drive
description: Read Google Docs, search Drive, download/upload files, and share from Claude Code.
allowed-tools: Bash(CLAUDECLAW_DIR=* python3 ~/.config/drive/gdrive.py *), Bash(CLAUDECLAW_DIR=* python ~/.config/drive/gdrive.py *)
---

# Google Drive Skill

## Purpose

Search, read, download, upload, and share files on Google Drive. Reads Google Docs as plain text so you can summarize, analyze, or reference them inline.

## Environment

The Drive CLI reads credential paths from environment variables, loaded from ClaudeClaw's `.env` via `CLAUDECLAW_DIR`. Every command MUST use this prefix:

```
CLAUDECLAW_DIR=/path/to/claudeclaw
```

Your `.env` should contain:

```
GOOGLE_CREDS_PATH=~/.config/gmail/credentials.json
GDRIVE_TOKEN_PATH=~/.config/drive/token.json
```

If these aren't set, the script falls back to `~/.config/gmail/credentials.json` (shared with Gmail/Calendar) and `~/.config/drive/token.json`.

## Commands

### List files

```bash
CLAUDECLAW_DIR=/path/to/claudeclaw python ~/.config/drive/gdrive.py list
```

Returns the 20 most recently modified files. Options:
- `--folder <ID>` list contents of a specific folder
- `--type doc|sheet|slide|pdf|folder` filter by file type
- `--max N` max results (default 20)

### Search files

```bash
CLAUDECLAW_DIR=/path/to/claudeclaw python ~/.config/drive/gdrive.py search "quarterly report"
```

Full-text search across file names and contents.

### Read a Google Doc

```bash
CLAUDECLAW_DIR=/path/to/claudeclaw python ~/.config/drive/gdrive.py read <file_id>
```

Returns the full text content of a Google Doc. Also works for Sheets (exported as CSV), Slides (plain text), and Drawings (as PNG info). Binary files return metadata only.

### Get file info

```bash
CLAUDECLAW_DIR=/path/to/claudeclaw python ~/.config/drive/gdrive.py info <file_id>
```

Returns metadata: name, type, owner, timestamps, sharing status, link.

### Download a file

```bash
CLAUDECLAW_DIR=/path/to/claudeclaw python ~/.config/drive/gdrive.py download <file_id> /tmp/
```

Downloads the file to a local path. Google Workspace files are auto-exported (Docs to .txt, Sheets to .csv, etc).

### Upload a file

```bash
CLAUDECLAW_DIR=/path/to/claudeclaw python ~/.config/drive/gdrive.py upload /path/to/file.pdf --folder <folder_id>
```

Uploads a local file. Optional `--folder` to specify destination.

### Share a file

```bash
CLAUDECLAW_DIR=/path/to/claudeclaw python ~/.config/drive/gdrive.py share <file_id> person@example.com --role writer
```

Shares with an email. Roles: `reader` (default), `writer`, `commenter`. Sends email notification.

### Re-authenticate

```bash
CLAUDECLAW_DIR=/path/to/claudeclaw python ~/.config/drive/gdrive.py auth
```

## Workflow

1. If the user asks to find a file, use `search` or `list`
2. To read a document's contents, use `read <file_id>`
3. To send a file to the user via Telegram, `download` it first then use `[SEND_FILE:/path]`
4. When sharing, confirm the email and role before executing

## Confirmation Before Sharing

Always show the user what you're about to share before running:
- File name
- Recipient email
- Permission level (reader/writer/commenter)

Then ask for confirmation.

## One-Time Setup

Uses the same Google Cloud project as Gmail and Calendar. You also need to enable these APIs:
- Google Drive API: https://console.cloud.google.com/apis/library/drive.googleapis.com
- Google Docs API: https://console.cloud.google.com/apis/library/docs.googleapis.com

If `token.json` is missing:

```bash
CLAUDECLAW_DIR=/path/to/claudeclaw python ~/.config/drive/gdrive.py auth
```

Browser opens, sign in, approve Drive access, done.

## Error Handling

- If `credentials.json` missing, point to Gmail setup (same file)
- If `token.json` missing, run auth automatically
- If file not found, show error and suggest searching
- Large files (>50MB) cannot be sent via Telegram
