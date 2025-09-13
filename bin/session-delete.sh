#!/bin/bash
# session-delete.sh - Delete a session by tag or ID

set -e

PROJECT_NAME=$(basename "$(pwd)")
SESSIONS_FILE="$HOME/.claude/sessions/${PROJECT_NAME}.json"

# Parse arguments
FORCE_DELETE=false
SEARCH_TERM=""

for arg in "$@"; do
    case $arg in
        -y|--force)
            FORCE_DELETE=true
            ;;
        *)
            if [ -z "$SEARCH_TERM" ]; then
                SEARCH_TERM="$arg"
            fi
            ;;
    esac
done

if [ ! -f "$SESSIONS_FILE" ]; then
    echo "No sessions file found for project: $PROJECT_NAME"
    exit 1
fi

if [ -z "$SEARCH_TERM" ]; then
    echo "Available sessions:"
    jq -r '.sessions[] | "\(.tag) - \(.id[0:8])... - \(.timestamp)"' "$SESSIONS_FILE"
    echo ""
    echo "Usage: /session delete [tag-or-session-id] [-y|--force]"
    echo "  -y, --force    Delete without confirmation"
    exit 0
fi

# Find session by tag or ID
FOUND=$(jq -r --arg search "$SEARCH_TERM" \
    '.sessions[] | select(.tag == $search or .id == $search) | "\(.tag)|\(.id)|\(.timestamp)"' \
    "$SESSIONS_FILE")

if [ -z "$FOUND" ]; then
    echo "Session not found: $SEARCH_TERM"
    exit 1
fi

IFS='|' read -r tag session_id timestamp <<< "$FOUND"

echo "Found session:"
echo "  Tag: $tag"
echo "  ID: $session_id"
echo "  Created: $timestamp"

if [ "$FORCE_DELETE" = true ]; then
    # Delete without confirmation
    jq --arg search "$SEARCH_TERM" \
        '.sessions = [.sessions[] | select(.tag != $search and .id != $search)]' \
        "$SESSIONS_FILE" > "$SESSIONS_FILE.tmp" && mv "$SESSIONS_FILE.tmp" "$SESSIONS_FILE"
    echo "✓ Session deleted: $tag"
else
    # Ask for confirmation
    echo ""
    read -p "Delete this session? (y/N): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        jq --arg search "$SEARCH_TERM" \
            '.sessions = [.sessions[] | select(.tag != $search and .id != $search)]' \
            "$SESSIONS_FILE" > "$SESSIONS_FILE.tmp" && mv "$SESSIONS_FILE.tmp" "$SESSIONS_FILE"
        echo "✓ Session deleted: $tag"
    else
        echo "Cancelled"
    fi
fi