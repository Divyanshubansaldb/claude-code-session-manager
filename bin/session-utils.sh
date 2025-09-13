#!/bin/bash
# session-utils.sh - Shared utility functions for session management

# Function to get current Claude Code session ID
get_session_id() {
    local current_dir="$(pwd)"

    # Check both current and legacy Claude Code directories
    local claude_dirs=(
        "$HOME/.config/claude/projects"
        "$HOME/.claude/projects"
    )

    for claude_dir in "${claude_dirs[@]}"; do
        if [ -d "$claude_dir" ]; then
            # Strategy 1: Try to find project directory by converting current path
            # Replace / with - and . with -- (double dash)
            local converted_path="${current_dir//\//-}"
            converted_path="${converted_path//\./-}"
            local project_dir="$claude_dir/$converted_path"

            if [ -d "$project_dir" ]; then
                # Find the most recently modified .jsonl file
                local latest_session=$(find "$project_dir" -name "*.jsonl" -type f -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -1)
                if [ -n "$latest_session" ]; then
                    basename "$latest_session" .jsonl
                    return 0
                fi
            fi

            # Strategy 2: Search for directories containing parts of the current path
            local project_dir=$(find "$claude_dir" -maxdepth 1 -type d -name "*$(basename "$current_dir")*" | head -1)

            if [ -n "$project_dir" ]; then
                # Find the most recently modified .jsonl file
                local latest_session=$(find "$project_dir" -name "*.jsonl" -type f -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -1)
                if [ -n "$latest_session" ]; then
                    basename "$latest_session" .jsonl
                    return 0
                fi
            fi
        fi
    done

    echo "Error: No Claude Code project found for current directory: $current_dir" >&2
    echo "Checked directories:" >&2
    for dir in "${claude_dirs[@]}"; do
        if [ -d "$dir" ]; then
            echo "  $dir ($(ls "$dir" | wc -l) projects found)" >&2
        else
            echo "  $dir (not found)" >&2
        fi
    done
    exit 1
}