#!/bin/bash
# Earth Status Line - Claude Code Adapter
# Statusline for Claude Code CLI
#
# Line 1: Repo/code context
# Line 2: Session/context info

set -euo pipefail

# Resolve paths relative to this script's location (following symlinks)
SCRIPT_PATH="${BASH_SOURCE[0]}"
[ -L "$SCRIPT_PATH" ] && SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
CORE_DIR="$(dirname "$SCRIPT_DIR")/core"

# Source core components
source "$CORE_DIR/colors.sh"
source "$CORE_DIR/git.sh"
source "$CORE_DIR/utils.sh"

# Claude auto-compacts context around 22% remaining, so we normalize
# the mood indicators against this threshold (treat it as "0%")
AUTOCOMPACT_THRESHOLD=22

# Read JSON input from Claude Code
input=$(cat)

# Extract data from JSON with safe defaults
dir=$(echo "$input" | jq -r '.workspace.current_dir // ""')
dir_name=$(basename "$dir")
model=$(echo "$input" | jq -r '.model.display_name // .model.id // "unknown"')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# Get git info
gather_git_info "$dir"

# Context window calculation
usage=$(echo "$input" | jq '.context_window.current_usage // null')
if [ "$usage" != "null" ]; then
    current=$(echo "$usage" | jq '(.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)')
    size=$(echo "$input" | jq '.context_window.context_window_size // 1')
    [ "$size" -eq 0 ] && size=1  # prevent division by zero
    remaining=$((100 - (current * 100 / size)))

    # Normalize remaining % against auto-compact threshold for mood/color
    # This maps [threshold, 100] → [0, 100] so mood reflects proximity to auto-compact
    effective_remaining=$(( (remaining - AUTOCOMPACT_THRESHOLD) * 100 / (100 - AUTOCOMPACT_THRESHOLD) ))
    [ "$effective_remaining" -lt 0 ] && effective_remaining=0

    ctx_color=$(get_context_color "$effective_remaining")
    ctx="${remaining}%"
    kaomoji=$(get_mood_kaomoji "$effective_remaining")
else
    ctx=''
    ctx_color=''
    kaomoji=''
fi

# Format tokens
input_fmt=$(format_tokens "$total_input")
output_fmt=$(format_tokens "$total_output")

# ============================================================
# LINE 1: Repo/Code
# ============================================================
line1=$(printf "${C_DIR}%s${C_RESET}" "$dir_name")
if [ -n "$branch" ]; then
    line1="$line1 $(printf "${C_DIM}>${C_RESET} ${C_BRANCH}%s${C_RESET}" "$branch")"
fi
# Show staged changes (if any) then unstaged changes
if [ "$staged_added" != "0" ] || [ "$staged_removed" != "0" ]; then
    line1="$line1 $(printf "${C_DIM}│${C_RESET} ${C_STAGED}✔+%s -%s${C_RESET}" "$staged_added" "$staged_removed")"
fi
if [ "$lines_added" != "0" ] || [ "$lines_removed" != "0" ]; then
    line1="$line1 $(printf "${C_DIM}│${C_RESET} ${C_ADD}+%s${C_RESET} ${C_DEL}-%s${C_RESET}" "$lines_added" "$lines_removed")"
fi

# ============================================================
# LINE 2: Context/Session
# ============================================================
line2=$(printf "${C_MODEL}%s${C_RESET}" "$model")
if [ -n "$ctx" ]; then
    line2="$line2 $(printf "${C_DIM}│${C_RESET} ${ctx_color}%s %s${C_RESET}" "$kaomoji" "$ctx")"
fi
if [ "$total_input" != "0" ] || [ "$total_output" != "0" ]; then
    line2="$line2 $(printf "${C_DIM}│${C_RESET} ${C_TOKENS}↓%s${C_RESET} ${C_DIM}/${C_RESET} ${C_TOKENS}↑%s${C_RESET}" "$input_fmt" "$output_fmt")"
fi

# Output with blank line separator
printf '%b\n\n%b' "$line1" "$line2"
