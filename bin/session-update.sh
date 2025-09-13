#!/bin/bash
# session-update.sh - Update existing session tag with current session ID

set -e

# Source shared utilities
source "$(dirname "$0")/session-utils.sh"

PROJECT_NAME=$(basename "$(pwd)")
SESSIONS_FILE="$HOME/.claude/sessions/${PROJECT_NAME}.json"

# Parse arguments
TAG_NAME="$1"

# Check if tag argument is provided
if [ -z "$TAG_NAME" ]; then
    echo "Error: Tag name is required."
    echo "Usage: session-update.sh <tag>"
    echo "Example: session-update.sh feature-auth"
    echo ""
    echo "Available sessions:"
    if [ -f "$SESSIONS_FILE" ]; then
        jq -r '.sessions[] | "  \(.tag)"' "$SESSIONS_FILE" 2>/dev/null || echo "  No sessions found"
    else
        echo "  No sessions file found"
    fi
    exit 1
fi

if [ ! -f "$SESSIONS_FILE" ]; then
    echo "No sessions file found for project: $PROJECT_NAME"
    echo "Use /session save to create your first session"
    exit 1
fi

# Get current session ID
CURRENT_SESSION_ID=$(get_session_id)

# Check if provided tag exists
EXISTING_SESSION=$(jq -r --arg tag "$TAG_NAME" '.sessions[] | select(.tag == $tag) | "\(.tag)|\(.id)|\(.timestamp)"' "$SESSIONS_FILE" 2>/dev/null)

if [ -z "$EXISTING_SESSION" ]; then
    echo "Error: Session with tag '$TAG_NAME' doesn't exist."
    echo ""
    echo "Available sessions:"
    jq -r '.sessions[] | "  \(.tag) - \(.id[0:8])... - \(.timestamp)"' "$SESSIONS_FILE" 2>/dev/null || echo "  No sessions found"
    exit 1
fi

# Parse existing session info
IFS='|' read -r tag_name old_session_id timestamp <<< "$EXISTING_SESSION"

# Update the session ID for the provided tag
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
UPDATED=$(jq --arg tag "$TAG_NAME" --arg new_id "$CURRENT_SESSION_ID" --arg ts "$TIMESTAMP" \
    '(.sessions[] | select(.tag == $tag)) |= {id: $new_id, tag: $tag, timestamp: $ts}' \
    "$SESSIONS_FILE")

echo "$UPDATED" > "$SESSIONS_FILE"

echo "✓ Updated session '$TAG_NAME' to current session"
echo "Previous session ID: $old_session_id"
echo "New session ID: $CURRENT_SESSION_ID"
echo "Resume with: claude --resume $CURRENT_SESSION_ID"