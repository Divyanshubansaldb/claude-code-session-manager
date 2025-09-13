#!/bin/bash
# session-save.sh - Save current Claude Code session

set -e

# Source shared utilities
source "$(dirname "$0")/session-utils.sh"

# Get current project name
PROJECT_NAME=$(basename "$(pwd)")
SESSIONS_FILE="$HOME/.claude/sessions/${PROJECT_NAME}.json"

# Get tag
TAG="$1"
if [ -z "$TAG" ]; then
    echo "Error: Tag is required for saving sessions."
    echo "Usage: session-save.sh <tag>"
    echo "Example: session-save.sh feature-authentication"
    exit 1
fi

# Get session ID
SESSION_ID=$(get_session_id)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Initialize sessions file if it doesn't exist
if [ ! -f "$SESSIONS_FILE" ]; then
    echo '{"sessions": []}' > "$SESSIONS_FILE"
fi

# Check if session with same tag exists
EXISTING=$(jq -r --arg tag "$TAG" '.sessions[] | select(.tag == $tag) | .id' "$SESSIONS_FILE" 2>/dev/null || echo "")

if [ -n "$EXISTING" ]; then
    echo "Error: Session with tag '$TAG' is already registered."
    echo "Existing session ID: $EXISTING"
    echo ""
    echo "Options:"
    echo "  1. Use a different tag name"
    echo "  2. Use 'session-update.sh $TAG' to update the tag for current session"
    echo "  3. Use 'session-delete.sh $TAG' to remove the existing session first"
    exit 1
else
    # Add new session
    jq --arg tag "$TAG" --arg id "$SESSION_ID" --arg ts "$TIMESTAMP" \
       '.sessions += [{id: $id, tag: $tag, timestamp: $ts}]' \
       "$SESSIONS_FILE" > "$SESSIONS_FILE.tmp" && mv "$SESSIONS_FILE.tmp" "$SESSIONS_FILE"
    echo "✓ Saved new session with tag: $TAG"
fi

echo "Session ID: $SESSION_ID"
echo "Resume with: claude --resume $SESSION_ID"