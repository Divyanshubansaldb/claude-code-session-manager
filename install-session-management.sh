#!/bin/bash
# install-session-management.sh

echo "Installing Claude Code session management with shell scripts..."

# Create directories
mkdir -p ~/.claude/bin
mkdir -p ~/.claude/commands/session
mkdir -p ~/.claude/sessions

# Make scripts executable
chmod +x ~/.claude/bin/session-*.sh

echo "✓ Session management installed!"
echo ""
echo "Available commands:"
echo "  /session save <tag>           - Save current session"
echo "  /session update <tag>         - Update existing session tag to current session"
echo "  /session delete <tag-or-id>   - Delete a session"
echo "  /session retrieve [count]     - List recent sessions"
echo "  /session clean [days]         - Clean up old sessions"
echo "  /session id                   - Show current session ID"