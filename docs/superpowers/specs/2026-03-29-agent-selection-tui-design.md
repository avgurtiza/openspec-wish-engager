# Agent Selection TUI - Design Spec
**Date:** 2026-03-29  
**Status:** Draft  
**Author:** Claude

## Overview

Add a modern, interactive TUI menu to `install.sh` that lets users select which agents to install (OpenCode, KiloCode, Claude, Gemini) using fzf with multi-select checkboxes.

## Design

### Visual Style
- **Color scheme:** Dracula-inspired (cyan, magenta, green on dark)
- **Header:** Banner with "Select Agents to Install" title
- **Agent items:** Icon + name + brief description
  - `[ ]` OpenCode - OpenCode agent with superpowers
  - `[ ]` KiloCode - Lightweight Claude Code alternative  
  - `[ ]` Claude - Anthropic's Claude Code
  - `[ ]` Gemini - Google Gemini CLI
- **Footer:** "Press SPACE to select, ENTER to confirm, ESC to cancel"
- **Preview pane:** Shows selected count and agent details

### Interaction Flow
```
1. install.sh starts
2. Check for fzf dependency (install if missing, or warn)
3. Display fzf multi-select menu with agent list
4. User toggles agents with SPACE
5. User presses ENTER to confirm
6. install.sh proceeds with selected agents only
7. Summary shows what was installed/skipped
```

### Behavior
- **Default selection:** All detected agents pre-selected
- **Empty selection:** Error "Select at least one agent"
- **Cancel (ESC/q):** Exit with "Installation cancelled"
- **All deselected:** Shows warning before confirming

## Architecture

### Files
- `src/ui/agent-selector.sh` - Core fzf menu function
- `install.sh` - Modified to call agent selector

### Interface
```bash
# Returns space-separated list of selected agents
select_agents "opencode kilocode claude gemini"

# Exit codes:
# 0 - success, agents selected
# 1 - cancelled
# 2 - no agents selected (error)
```

### Dependency Handling
```bash
check_fzf() {
    if command -v fzf &>/dev/null; then
        return 0
    fi
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "fzf not found. Installing via Homebrew..."
        brew install fzf
    else
        echo "fzf not found. Installing via apt..."
        sudo apt install fzf
    fi
}
```

## Component Details

### fzf Options
```bash
fzf --multi \
    --header="Select agents to install" \
    --header-border \
    --height=50% \
    --layout=reverse \
    --border \
    --ansi \
    --preview-window=right:50% \
    --prompt="Agents> " \
    --pointer=">" \
    --marker="[x]"
```

### Agent Data Structure
```bash
declare -A AGENTS=(
    ["opencode"]="OpenCode - Modern AI coding agent with superpowers"
    ["kilocode"]="KiloCode - Lightweight Claude alternative"
    ["claude"]="Claude Code - Anthropic's development agent"
    ["gemini"]="Gemini CLI - Google's Gemini agent"
)
```

## Error Handling

| Scenario | Behavior |
|----------|----------|
| fzf not installed | Offer auto-install or exit with instructions |
| No agents available | Show "No agents detected" message |
| User cancels | Clean exit, no changes |
| All deselected | Confirm "No agents selected, continue anyway?" |

## Testing

```bash
# Test without actually installing
./install.sh --dry-run

# Verify TUI works standalone
source src/ui/agent-selector.sh
select_agents "opencode claude"
```

## Future Enhancements (Out of Scope)
- Agent configuration during selection
- Per-agent lint/test command setup
- Wizard mode with multiple steps
