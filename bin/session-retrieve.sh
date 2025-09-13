#!/bin/bash
# session-retrieve.sh - List recent sessions

set -e

PROJECT_NAME=$(basename "$(pwd)")
SESSIONS_FILE="$HOME/.claude/sessions/${PROJECT_NAME}.json"
LIMIT="${1:-10}"

if [ ! -f "$SESSIONS_FILE" ]; then
    echo "No sessions found for project: $PROJECT_NAME"
    echo "Use /session save to create your first session"
    exit 0
fi

echo "Recent sessions for $PROJECT_NAME (last $LIMIT):"
echo ""

jq -r --argjson limit "$LIMIT" \
    '.sessions | sort_by(.timestamp) | reverse | .[0:$limit][] | 
    "Tag: \(.tag)\nTime: \(.timestamp)\nID: \(.id[0:12])...\nResume: claude --resume \(.id)\n"' \
    "$SESSIONS_FILE"