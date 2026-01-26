# earth-statusline

custom statusline for claude code that shows context + meow.

```
my-project > main │ +12 -3

Opus 4.5 │ (°⩊°) 73% │ ↓2.1k / ↑340
```

## install

requires jq. [install jq](#installing-jq) if u dont have it.

```bash
curl -fsSL https://raw.githubusercontent.com/earthnetonline/earth-statusline/main/install.sh | bash
```

then add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline-command.sh"
  }
}
```

restart claude code. done.

## what it shows

**line 1** - directory, git branch, uncommitted changes

**line 2** - model, context % with mood kaomoji, tokens in/out

## mood kaomoji

| face | mood |
|------|------|
| `(°⩊°)` | happy (>50% context) |
| `(>⩊<)` | not so happy (20-50%) |
| `(×⩊×)` | not happy (<20%) |

moods are normalized against claudes 22% auto-compact threshold.

## files

```
├── adapters/claude.sh    # parses json, formats output
└── core/
    ├── colors.sh         # muted 24-bit palette
    ├── git.sh            # branch + diff
    └── utils.sh          # formatting, mood logic
```

## installing jq

**macos:** `brew install jq`

**linux:** `sudo apt-get install jq` or `sudo pacman -S jq`

**windows:** `choco install jq`

## troubleshooting

**not showing** - restart claude code, check symlink exists, verify jq installed

**weird characters** - terminal doesnt support 24-bit color. try iterm2/kitty/alacritty

**no git info** - ur not in a git repo

## license

mit

## credits

made by [earth](https://x.com/earth________) 𓈒 [links.earthnet.online](https://links.earthnet.online)

follow me ( °⩊°)⸝[@earth________](https://x.com/earth________)
