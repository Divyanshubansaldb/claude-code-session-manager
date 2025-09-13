#!/bin/bash
# setup-session-aliases.sh - Setup shell aliases for session management

echo "Setting up Claude Code session management aliases..."

# Detect shell
SHELL_RC=""
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    echo "Unsupported shell. Please add aliases manually to your shell profile."
    exit 1
fi

# Backup existing shell rc
if [ -f "$SHELL_RC" ]; then
    cp "$SHELL_RC" "${SHELL_RC}.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Add aliases
cat >> "$SHELL_RC" << 'EOF'

# Claude Code Session Management Aliases
alias session-id='~/.claude/bin/session-id.sh'
alias session-save='~/.claude/bin/session-save.sh'
alias session-update='~/.claude/bin/session-update.sh'
alias session-delete='~/.claude/bin/session-delete.sh'
alias session-retrieve='~/.claude/bin/session-retrieve.sh'
alias session-clean='~/.claude/bin/session-clean.sh'

# Session management helper functions
session-help() {
    echo "Claude Code Session Management Commands:"
    echo "  session-id              - Show current session details"
    echo "  session-save <tag>      - Save current session with tag"
    echo "  session-update <tag>    - Update existing session tag to current session"
    echo "  session-retrieve [n]    - Show recent n sessions"
    echo "  session-delete <tag>    - Delete session (interactive)"
    echo "  session-clean [days]    - Clean sessions older than days"
}
EOF

echo "✓ Aliases added to $SHELL_RC"
echo ""
echo "To activate the aliases, run:"
echo "  source $SHELL_RC"
echo ""
echo "Or restart your terminal."
echo ""
echo "Available commands:"
echo "  session-id, session-save, session-retrieve,"
echo "  session-update, session-delete, session-clean, session-help"