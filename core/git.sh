#!/bin/bash
# Earth Status Line - Git Info
# Functions to gather git repository information

# Get git info for a directory
# Sets: branch, lines_added, lines_removed, staged_added, staged_removed
gather_git_info() {
    local dir="$1"

    branch=''
    lines_added=0
    lines_removed=0
    staged_added=0
    staged_removed=0

    # Use subshell to avoid changing working directory
    local git_output
    git_output=$(
        cd "$dir" 2>/dev/null || exit 1

        local b a r sa sr
        b=$(git -c core.useBuiltinFSMonitor=false branch --show-current 2>/dev/null || echo '')

        # Unstaged changes
        local diff_stats
        diff_stats=$(git -c core.useBuiltinFSMonitor=false diff --shortstat 2>/dev/null || echo '')
        if [ -n "$diff_stats" ]; then
            a=$(echo "$diff_stats" | sed -n 's/.* \([0-9]*\) insertion.*/\1/p')
            r=$(echo "$diff_stats" | sed -n 's/.* \([0-9]*\) deletion.*/\1/p')
        fi

        # Staged changes
        local staged_stats
        staged_stats=$(git -c core.useBuiltinFSMonitor=false diff --staged --shortstat 2>/dev/null || echo '')
        if [ -n "$staged_stats" ]; then
            sa=$(echo "$staged_stats" | sed -n 's/.* \([0-9]*\) insertion.*/\1/p')
            sr=$(echo "$staged_stats" | sed -n 's/.* \([0-9]*\) deletion.*/\1/p')
        fi

        echo "${b:-}|${a:-0}|${r:-0}|${sa:-0}|${sr:-0}"
    ) || true

    if [ -n "$git_output" ]; then
        IFS='|' read -r branch lines_added lines_removed staged_added staged_removed <<< "$git_output"
    fi
}
