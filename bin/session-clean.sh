#!/bin/bash
# session-clean.sh - Clean up old sessions

set -e

PROJECT_NAME=$(basename "$(pwd)")
SESSIONS_FILE="$HOME/.claude/sessions/${PROJECT_NAME}.json"

# Parse arguments
FORCE_DELETE=false
DAYS="30"

for arg in "$@"; do
    case $arg in
        -y|--force)
            FORCE_DELETE=true
            ;;
        *)
            if [[ "$arg" =~ ^[0-9]+$ ]]; then
                DAYS="$arg"
            fi
            ;;
    esac
done

if [ ! -f "$SESSIONS_FILE" ]; then
    echo "No sessions file found for project: $PROJECT_NAME"
    exit 0
fi

# Calculate cutoff date - handle both macOS and Linux date commands
CUTOFF_DATE=""
if date -v-1d > /dev/null 2>&1; then
    # macOS date command
    CUTOFF_DATE=$(date -v-${DAYS}d -u +"%Y-%m-%dT%H:%M:%SZ")
else
    # GNU date command (Linux)
    CUTOFF_DATE=$(date -d "$DAYS days ago" -u +"%Y-%m-%dT%H:%M:%SZ")
fi

echo "Finding sessions older than $DAYS days (before $CUTOFF_DATE):"

OLD_SESSIONS=$(jq -r --arg cutoff "$CUTOFF_DATE" \
    '.sessions[] | select(.timestamp < $cutoff) | "\(.tag) - \(.timestamp)"' \
    "$SESSIONS_FILE")

if [ -z "$OLD_SESSIONS" ]; then
    echo "No old sessions found"
    exit 0
fi

echo "$OLD_SESSIONS"

if [ "$FORCE_DELETE" = true ]; then
    # Delete without confirmation
    UPDATED=$(jq --arg cutoff "$CUTOFF_DATE" \
        '.sessions = [.sessions[] | select(.timestamp >= $cutoff)]' \
        "$SESSIONS_FILE")
    echo "$UPDATED" > "$SESSIONS_FILE"
    echo "✓ Old sessions cleaned up"
else
    # Ask for confirmation
    echo ""
    read -p "Delete these sessions? (y/N): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        UPDATED=$(jq --arg cutoff "$CUTOFF_DATE" \
            '.sessions = [.sessions[] | select(.timestamp >= $cutoff)]' \
            "$SESSIONS_FILE")
        echo "$UPDATED" > "$SESSIONS_FILE"
        echo "✓ Old sessions cleaned up"
    else
        echo "Cancelled"
    fi
fi