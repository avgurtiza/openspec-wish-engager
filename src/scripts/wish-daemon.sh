#!/bin/bash
# Wish Engager Daemon
# Runs autonomously via launchd/cron. Picks up pending wishes and implements them.

set -euo pipefail

# Resolve project directory: parent of the scripts/ directory this script lives in
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
WISHES_DIR="$PROJECT_DIR/wishes"
LOG_FILE="$PROJECT_DIR/storage/logs/wish-daemon.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Check for pending wishes (excluding _example and dot directories)
pending_count=0
for dir in "$WISHES_DIR"/*/; do
    [ -d "$dir" ] || continue
    dir_name=$(basename "$dir")
    [[ "$dir_name" == .* ]] && continue
    [ "$dir_name" = "_example" ] && continue

    if [ -f "$dir/meta.yaml" ]; then
        status=$(grep '^status:' "$dir/meta.yaml" | awk '{print $2}')
        if [ "$status" = "pending" ]; then
            pending_count=$((pending_count + 1))
        fi
    fi
done

if [ "$pending_count" -eq 0 ]; then
    log "No pending wishes. Exiting."
    exit 0
fi

log "Found $pending_count pending wish(es). Starting fulfillment."

# Run opencode engage
cd "$PROJECT_DIR"
opencode run "Run the fulfill skill to implement the next pending wish." 2>&1 >> "$LOG_FILE"

log "Fulfillment cycle complete."
