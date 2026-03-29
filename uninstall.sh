#!/bin/bash
# Uninstall sprite from a project.
#
# Usage:
#   ./uninstall.sh                  # Uninstall from current directory
#   ./uninstall.sh /path/to/project # Uninstall from specific project
#
# Supports: macOS (launchd), Linux (cron), Windows WSL (cron)
# This removes installed files. Wishes and run-logs are preserved.
# Config file is preserved (remove manually if needed).

set -euo pipefail

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

# Determine project directory
if [ $# -ge 1 ]; then
    PROJECT_DIR="$(cd "$1" && pwd)"
else
    PROJECT_DIR="$(pwd)"
fi

echo "Uninstalling sprite from: $PROJECT_DIR"
echo ""

removed=()
preserved=()

# Remove skills
for skill in wish fulfill; do
    target="$PROJECT_DIR/.opencode/skills/$skill/SKILL.md"
    if [ -f "$target" ]; then
        rm "$target"
        rmdir "$PROJECT_DIR/.opencode/skills/$skill" 2>/dev/null || true
        removed+=("$target")
    fi
done

# Remove commands
for cmd in wish fulfill; do
    target="$PROJECT_DIR/.opencode/command/$cmd.md"
    if [ -f "$target" ]; then
        rm "$target"
        removed+=("$target")
    fi
done

# Remove scripts
if [ -f "$PROJECT_DIR/scripts/wish-daemon.sh" ]; then
    rm "$PROJECT_DIR/scripts/wish-daemon.sh"
    removed+=("$PROJECT_DIR/scripts/wish-daemon.sh")
fi

# Remove plist in scripts/ (not in LaunchAgents — user manages that)
for plist in "$PROJECT_DIR/scripts/"*.sprite.plist; do
    [ -f "$plist" ] || continue
    rm "$plist"
    removed+=("$plist")
done

# Remove cron file in scripts/ (not in user's crontab — user manages that)
for cron in "$PROJECT_DIR/scripts/"*.sprite.cron; do
    [ -f "$cron" ] || continue
    rm "$cron"
    removed+=("$cron")
done

# Remove config files from all possible locations
for cfg in ".opencode/sprite.yaml" ".claude/sprite.yaml" ".gemini/sprite.yaml"; do
    if [ -f "$PROJECT_DIR/$cfg" ]; then
        rm "$PROJECT_DIR/$cfg"
        removed+=("$PROJECT_DIR/$cfg")
    fi
done

# Preserved items
preserved+=("$PROJECT_DIR/wishes/ (your wishes)")
preserved+=("$PROJECT_DIR/.worktrees/ (your worktrees)")

# Check if .gitignore entry should be removed
if [ -f "$PROJECT_DIR/.gitignore" ] && grep -q '\.worktrees' "$PROJECT_DIR/.gitignore"; then
    preserved+=("$PROJECT_DIR/.gitignore (.worktrees entry)")
fi

# Summary
echo ""
echo "=========================================="
echo "  Uninstall complete"
echo "=========================================="
echo ""

if [ ${#removed[@]} -gt 0 ]; then
    echo "Removed (${#removed[@]}):"
    for f in "${removed[@]}"; do
        echo "  - $f"
    done
    echo ""
fi

echo "Preserved:"
for f in "${preserved[@]}"; do
    echo "  ~ $f"
done
echo ""

echo "To remove the daemon scheduler:"
if [ "$OS" = "macos" ]; then
    echo "  launchctl unload ~/Library/LaunchAgents/com.*.sprite.plist"
    echo "  rm ~/Library/LaunchAgents/com.*.sprite.plist"
else
    echo "  crontab -e    # then delete the wish-daemon.sh line"
fi
