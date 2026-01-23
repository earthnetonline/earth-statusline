#!/bin/bash
# Earth Status Line - Git Info
# Functions to gather git repository information

# Get git info for a directory
# Sets: branch, lines_added, lines_removed
gather_git_info() {
    local dir="$1"

    branch=''
    lines_added=0
    lines_removed=0

    if cd "$dir" 2>/dev/null; then
        branch=$(git -c core.useBuiltinFSMonitor=false branch --show-current 2>/dev/null)
        diff_stats=$(git -c core.useBuiltinFSMonitor=false diff --shortstat 2>/dev/null)
        if [ -n "$diff_stats" ]; then
            lines_added=$(echo "$diff_stats" | sed -n 's/.* \([0-9]*\) insertion.*/\1/p')
            lines_removed=$(echo "$diff_stats" | sed -n 's/.* \([0-9]*\) deletion.*/\1/p')
            [ -z "$lines_added" ] && lines_added=0
            [ -z "$lines_removed" ] && lines_removed=0
        fi
    fi
}
