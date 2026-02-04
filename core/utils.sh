#!/bin/bash
# Earth Status Line - Utilities
# Formatting helpers and common functions

# Format tokens (k for thousands, M for millions)
format_tokens() {
    local tokens=${1:-0}
    if [ "$tokens" -ge 1000000 ]; then
        awk -v t="$tokens" 'BEGIN {printf "%.1fM", t/1000000}'
    elif [ "$tokens" -ge 1000 ]; then
        awk -v t="$tokens" 'BEGIN {printf "%.1fk", t/1000}'
    else
        echo "$tokens"
    fi
}

# Get kaomoji based on percentage remaining
# Args: remaining (0-100)
get_mood_kaomoji() {
    local remaining=$1
    if [ "$remaining" -gt 50 ]; then
        echo "(°⩊°)"      # chill
    elif [ "$remaining" -gt 20 ]; then
        echo "(>⩊<)"      # neutral
    else
        echo "(×⩊×)"      # not chill
    fi
}

# Get context color based on percentage remaining
# Args: remaining (0-100)
# Requires colors.sh to be sourced first
get_context_color() {
    local remaining=$1
    if [ "$remaining" -gt 50 ]; then
        echo "$C_CTX_GOOD"
    elif [ "$remaining" -gt 20 ]; then
        echo "$C_CTX_WARN"
    else
        echo "$C_CTX_BAD"
    fi
}
