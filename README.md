# Claude Code Session Manager

A lightweight session management system for Claude Code that adds custom slash commands to save, resume, and organize your coding sessions without consuming AI bandwidth.

## Features

- **Save sessions** with custom tags for easy identification
- **Resume sessions** instantly using saved tags
- **Update existing** tags to point to current session
- **List recent sessions** with timestamps and resume commands
- **Clean up old sessions** and remove orphaned entries
- **Shell scripts + slash commands** for both terminal and Claude Code usage

## Installation

1. **Clone or download** this repository
2. **Run the installation script:**
   ```bash
   ./install-session-management.sh
   ```
3. **Set up aliases** (optional, for terminal usage):
   ```bash
   ./setup-session-aliases.sh
   ```

That's it! The slash commands are now available in Claude Code.

## Usage

### Slash Commands (in Claude Code)

| Command | Description | Example |
|---------|-------------|---------|
| `/session:save <tag>` | Save current session with a tag | `/session:save feature-auth` |
| `/session:retrieve` | List recent sessions | `/session:retrieve` |
| `/session:update <tag>` | Update existing tag to current session | `/session:update feature-auth` |
| `/session:delete <tag>` | Delete a saved session | `/session:delete old-feature` |
| `/session:clean` | Remove orphaned/invalid sessions | `/session:clean` |
| `/session:id` | Show current session details | `/session:id` |

### Terminal Commands (if aliases are set up)

```bash
session-save feature-auth        # Save current session
session-retrieve                 # List sessions
session-update feature-auth      # Update tag to current session
session-delete old-feature       # Delete session
session-clean                    # Clean up orphaned sessions
session-id                       # Show current session info
```

## How It Works

- **Session detection:** Automatically finds your current Claude Code session
- **JSON storage:** Sessions saved in `~/.claude/sessions/<project>.json`
- **Tag system:** Easy-to-remember names instead of UUIDs
- **Cross-platform:** Works on macOS and Linux
- **No AI bandwidth:** Pure shell scripts for routine operations

## File Structure

```
bin/                    # Shell scripts
├── session-utils.sh    # Shared utilities
├── session-save.sh     # Save sessions
├── session-retrieve.sh # List sessions
├── session-update.sh   # Update sessions
├── session-delete.sh   # Delete sessions
├── session-clean.sh    # Clean up sessions
└── session-id.sh       # Show current session

commands/session/       # Claude Code slash commands
├── save.md
├── retrieve.md
├── update.md
├── delete.md
├── clean.md
└── id.md
```

## Requirements

- Claude Code installed
- `jq` command-line JSON processor
- Bash shell
- Basic Unix tools (find, ls, date)

## License

MIT License - Feel free to use, modify, and distribute.