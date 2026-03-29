#!/bin/bash
# Update sprite to the latest version.
#
# Usage:
#   ./update.sh                  # Update in current directory
#   ./update.sh /path/to/project # Update specific project

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ $# -ge 1 ]; then
    PROJECT_DIR="$(cd "$1" && pwd)"
else
    PROJECT_DIR="$(pwd)"
fi

echo "Updating sprite..."
cd "$SCRIPT_DIR"
git pull
echo "Running install..."
"$SCRIPT_DIR/install.sh" "$PROJECT_DIR"
echo "Update complete."
