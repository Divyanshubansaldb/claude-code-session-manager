#!/bin/bash
# session-id.sh - Show current session ID

set -e

# Source shared utilities
source "$(dirname "$0")/session-utils.sh"

PROJECT_NAME=$(basename "$(pwd)")

# Get session ID and reconstruct full path
SESSION_ID=$(get_session_id)

# Find the actual session file path for file info
current_dir="$(pwd)"
claude_dirs=(
    "$HOME/.config/claude/projects"
    "$HOME/.claude/projects"
)

SESSION_FILE=""
for claude_dir in "${claude_dirs[@]}"; do
    if [ -d "$claude_dir" ]; then
        converted_path="${current_dir//\//-}"
        converted_path="${converted_path//\./-}"
        project_dir="$claude_dir/$converted_path"

        if [ -d "$project_dir" ] && [ -f "$project_dir/$SESSION_ID.jsonl" ]; then
            SESSION_FILE="$project_dir/$SESSION_ID.jsonl"
            break
        fi

        # Try strategy 2 if strategy 1 didn't work
        project_dir=$(find "$claude_dir" -maxdepth 1 -type d -name "*$(basename "$current_dir")*" | head -1)
        if [ -n "$project_dir" ] && [ -f "$project_dir/$SESSION_ID.jsonl" ]; then
            SESSION_FILE="$project_dir/$SESSION_ID.jsonl"
            break
        fi
    fi
done

# Get file modification time - handle both macOS and Linux
if stat -f %Sm "$SESSION_FILE" > /dev/null 2>&1; then
    # macOS stat command
    LAST_MODIFIED=$(stat -f %Sm "$SESSION_FILE")
else
    # GNU stat command (Linux)
    LAST_MODIFIED=$(stat -c %y "$SESSION_FILE")
fi

echo "Current Session Details:"
echo "Project: $PROJECT_NAME"
echo "Session ID: $SESSION_ID"
echo "Last Activity: $LAST_MODIFIED"
echo "Session File: $SESSION_FILE"
echo ""
echo "Resume command:"
echo "claude --resume $SESSION_ID"