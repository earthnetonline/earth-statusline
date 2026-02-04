# earth-statusline

custom statusline for claude code that shows context + meow.

```
my-project > main │ ●+5 -2 │ +12 -3

Opus 4.5 │ (°⩊°) 73% │ ↓2.1k / ↑340
```

## install

### macos / linux

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

### windows

requires [Windows Terminal](https://aka.ms/terminal) for colors. run in powershell:

```powershell
iwr -useb https://raw.githubusercontent.com/earthnetonline/earth-statusline/main/install.ps1 | iex
```

then add to `%USERPROFILE%\.claude\settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "pwsh -NoProfile -File '%USERPROFILE%\\.claude\\statusline-command.ps1'"
  }
}
```

restart claude code. done.

## what it shows

**line 1** - directory, git branch, staged changes (●), unstaged changes

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
├── adapters/
│   ├── claude.sh         # bash version (macos/linux)
│   └── claude.ps1        # powershell version (windows)
├── core/                 # shared logic (bash)
│   ├── colors.sh
│   ├── git.sh
│   └── utils.sh
├── install.sh            # bash installer
└── install.ps1           # powershell installer
```

## installing jq

**macos:** `brew install jq`

**linux:** `sudo apt-get install jq` or `sudo pacman -S jq`

## troubleshooting

**not showing** - restart claude code, check symlink exists, verify jq installed

**weird characters** - terminal doesnt support 24-bit color. try iterm2/kitty/alacritty

**no git info** - ur not in a git repo

**windows colors broken** - use [Windows Terminal](https://aka.ms/terminal), not cmd.exe

## license

mit

## credits

made by earth 𓈒 [links.earthnet.online](https://links.earthnet.online)

follow me ( °⩊°)⸝[@earth________](https://x.com/earth________)
