#!/bin/bash
# earth-statusline installer

set -e

INSTALL_DIR="$HOME/.earth-statusline"
CLAUDE_DIR="$HOME/.claude"
STATUSLINE_LINK="$CLAUDE_DIR/statusline-command.sh"

echo "installing earth-statusline..."

# check for jq
if ! command -v jq &> /dev/null; then
    echo ""
    echo "jq is required but not installed."
    echo ""
    echo "install it first:"
    echo "  macos:   brew install jq"
    echo "  linux:   sudo apt-get install jq"
    echo "  windows: choco install jq"
    echo ""
    exit 1
fi

# clone or update
if [ -d "$INSTALL_DIR" ]; then
    echo "updating existing installation..."
    cd "$INSTALL_DIR" && git pull
else
    echo "cloning to $INSTALL_DIR..."
    git clone https://github.com/earthnetonline/earth-statusline.git "$INSTALL_DIR"
fi

# create claude dir if needed
mkdir -p "$CLAUDE_DIR"

# symlink
if [ -L "$STATUSLINE_LINK" ]; then
    rm "$STATUSLINE_LINK"
fi
ln -s "$INSTALL_DIR/adapters/claude.sh" "$STATUSLINE_LINK"
echo "linked to $STATUSLINE_LINK"

echo ""
echo "almost done. add this to ~/.claude/settings.json:"
echo ""
echo '  {'
echo '    "statusLine": {'
echo '      "type": "command",'
echo '      "command": "~/.claude/statusline-command.sh"'
echo '    }'
echo '  }'
echo ""
echo "then restart claude code. (°⩊°)"
echo ""
