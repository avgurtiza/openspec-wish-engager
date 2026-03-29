#!/bin/bash
# Install wish-engager into a project.
#
# Usage:
#   ./install.sh                  # Install into current directory
#   ./install.sh /path/to/project # Install into specific project
#
# Supports: macOS (launchd), Linux (cron), Windows WSL (cron)
# This copies skills, commands, scripts, and wish directory structure
# into the target project. Existing files are not overwritten.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"

# Determine project directory
if [ $# -ge 1 ]; then
    PROJECT_DIR="$(cd "$1" && pwd)"
else
    PROJECT_DIR="$(pwd)"
fi

echo "Installing wish-engager into: $PROJECT_DIR"
echo ""

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        *) echo "unknown" ;;
    esac
}

OS="$(detect_os)"
echo "Detected OS: $OS"
echo ""

# Verify it looks like a project directory
if [ ! -d "$PROJECT_DIR/.git" ]; then
    echo "Warning: $PROJECT_DIR does not appear to be a git repository."
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Track what we installed
installed=()
skipped=()

# Helper: copy file if it doesn't exist
copy_if_missing() {
    local src="$1"
    local dst="$2"

    if [ -e "$dst" ]; then
        skipped+=("$dst")
    else
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        installed+=("$dst")
    fi
}

# Helper: portable sed replacement (works on macOS BSD sed and Linux GNU sed)
# Usage: sed_replace 's|pattern|replacement|g' input_file output_file
sed_replace() {
    sed "$1" "$2" > "$3"
}

# 1. Skills
echo "Installing skills..."
copy_if_missing "$SRC_DIR/skills/wish/SKILL.md" "$PROJECT_DIR/.opencode/skills/wish/SKILL.md"
copy_if_missing "$SRC_DIR/skills/fulfill/SKILL.md" "$PROJECT_DIR/.opencode/skills/fulfill/SKILL.md"

# 2. Commands
echo "Installing commands..."
copy_if_missing "$SRC_DIR/commands/wish.md" "$PROJECT_DIR/.opencode/command/wish.md"
copy_if_missing "$SRC_DIR/commands/fulfill.md" "$PROJECT_DIR/.opencode/command/fulfill.md"

# 3. Config
echo "Installing config..."
copy_if_missing "$SRC_DIR/config/wish-engager.yaml.example" "$PROJECT_DIR/.opencode/wish-engager.yaml.example"
copy_if_missing "$SRC_DIR/config/wish-engager.yaml.example" "$PROJECT_DIR/.opencode/wish-engager.yaml"

# 4. Scripts
echo "Installing scripts..."
mkdir -p "$PROJECT_DIR/scripts"
copy_if_missing "$SRC_DIR/scripts/wish-daemon.sh" "$PROJECT_DIR/scripts/wish-daemon.sh"
chmod +x "$PROJECT_DIR/scripts/wish-daemon.sh" 2>/dev/null || true

# Generate scheduler config based on OS
PROJECT_NAME=$(basename "$PROJECT_DIR")

if [ "$OS" = "macos" ]; then
    # macOS: launchd plist
    PLIST_LABEL="com.${PROJECT_NAME}.wish-engager"
    PLIST_DST="$PROJECT_DIR/scripts/${PLIST_LABEL}.plist"

    if [ -e "$PLIST_DST" ]; then
        skipped+=("$PLIST_DST")
    else
        sed_replace \
            "s|__LABEL__|$PLIST_LABEL|g
             s|__SCRIPT_PATH__|$PROJECT_DIR/scripts/wish-daemon.sh|g
             s|__INTERVAL__|1800|g
             s|__PROJECT_DIR__|$PROJECT_DIR|g" \
            "$SRC_DIR/scripts/wish-engager.plist.template" "$PLIST_DST"
        installed+=("$PLIST_DST")
    fi
else
    # Linux / WSL: cron entry
    CRON_DST="$PROJECT_DIR/scripts/wish-engager.cron"

    if [ -e "$CRON_DST" ]; then
        skipped+=("$CRON_DST")
    else
        sed_replace \
            "s|/path/to/your/project|$PROJECT_DIR|g" \
            "$SRC_DIR/scripts/wish-engager.cron.template" "$CRON_DST"
        installed+=("$CRON_DST")
    fi
fi

# 5. Wishes directory
echo "Setting up wishes directory..."
mkdir -p "$PROJECT_DIR/wishes/.completed"
copy_if_missing "$SRC_DIR/wishes/.gitkeep" "$PROJECT_DIR/wishes/.gitkeep"
copy_if_missing "$SRC_DIR/wishes/.completed/.gitkeep" "$PROJECT_DIR/wishes/.completed/.gitkeep"
copy_if_missing "$SRC_DIR/wishes/_example/wish.md" "$PROJECT_DIR/wishes/_example/wish.md"
copy_if_missing "$SRC_DIR/wishes/_example/meta.yaml" "$PROJECT_DIR/wishes/_example/meta.yaml"

# 6. Ensure .worktrees is gitignored
echo "Checking .gitignore..."
GITIGNORE="$PROJECT_DIR/.gitignore"
if [ -f "$GITIGNORE" ]; then
    if ! grep -q '\.worktrees' "$GITIGNORE"; then
        echo "" >> "$GITIGNORE"
        echo "# Git worktrees (wish-engager)" >> "$GITIGNORE"
        echo ".worktrees/" >> "$GITIGNORE"
        installed+=("$GITIGNORE (appended .worktrees/)")
    else
        skipped+=("$GITIGNORE (.worktrees already ignored)")
    fi
else
    echo "# Git worktrees (wish-engager)" > "$GITIGNORE"
    echo ".worktrees/" >> "$GITIGNORE"
    installed+=("$GITIGNORE (created)")
fi

# Summary
echo ""
echo "=========================================="
echo "  Installation complete"
echo "=========================================="
echo ""

if [ ${#installed[@]} -gt 0 ]; then
    echo "Installed (${#installed[@]}):"
    for f in "${installed[@]}"; do
        echo "  + $f"
    done
    echo ""
fi

if [ ${#skipped[@]} -gt 0 ]; then
    echo "Skipped (already exist, ${#skipped[@]}):"
    for f in "${skipped[@]}"; do
        echo "  ~ $f"
    done
    echo ""
fi

echo "Next steps:"
echo "  1. Edit .opencode/wish-engager.yaml to configure lint/test commands"
echo "  2. Restart OpenCode to pick up new skills"
echo "  3. Run /wish to create your first wish"
echo "  4. Run /fulfill to start the pipeline"
echo ""

if [ "$OS" = "macos" ]; then
    echo "To install the daemon (macOS launchd):"
    echo "  cp $PLIST_DST ~/Library/LaunchAgents/"
    echo "  launchctl load ~/Library/LaunchAgents/$(basename "$PLIST_DST")"
else
    echo "To install the daemon (cron):"
    echo "  # Review the cron entry first:"
    echo "  cat $CRON_DST"
    echo "  # Then install it:"
    echo "  (crontab -l 2>/dev/null; cat $CRON_DST) | crontab -"
fi
