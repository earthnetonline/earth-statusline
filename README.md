# Earth Status Line

Custom statusline for Claude Code CLI that shows context and session info.

## What it displays

**Line 1 - Repo/Code:**
- Directory name
- Git branch
- Lines added/removed (uncommitted changes)

**Line 2 - Context/Session:**
- Model name
- Context remaining % with mood kaomoji
- Token counts (input/output)

### Mood indicators
- `(°⩊°)` - chill (>50% context remaining)
- `(>⩊<)` - neutral (20-50%)
- `(×⩊×)` - not chill (<20%)

## Installation

The script is symlinked to `~/.claude/statusline-command.sh` and configured in `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "/Users/ocean/.claude/statusline-command.sh"
  }
}
```

## Files

- `statusline-command.sh` - The main script that outputs the statusline
