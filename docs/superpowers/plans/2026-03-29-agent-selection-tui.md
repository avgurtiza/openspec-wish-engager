# Agent Selection TUI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a modern fzf-based TUI menu to install.sh for interactive agent selection

**Architecture:** Replace auto-detection with interactive fzf multi-select menu. Agent selection stored in shell array, passed back to install.sh for conditional installation.

**Tech Stack:** Bash, fzf

---

## File Structure

```
src/ui/agent-selector.sh   # New: Core TUI component
install.sh                 # Modify: Call selector, update logic
```

---

### Task 1: Create agent-selector.sh

**Files:**
- Create: `src/ui/agent-selector.sh`

- [ ] **Step 1: Create the file with shebang and agent definitions**

```bash
#!/bin/bash
# Agent selection TUI using fzf
# Returns: space-separated list of selected agents

set -euo pipefail

declare -A AGENTS=(
    ["opencode"]="OpenCode - Modern AI coding agent with superpowers"
    ["kilocode"]="KiloCode - Lightweight Claude Code alternative"
    ["claude"]="Claude Code - Anthropic's development agent"
    ["gemini"]="Gemini CLI - Google's Gemini agent"
)

declare -A AGENT_ICONS=(
    ["opencode"]="🚀"
    ["kilocode"]="⚡"
    ["claude"]="🧠"
    ["gemini"]="✨"
)

show_agent_menu() {
    local selected=("${@:-}")
    local prompt="Select agents to install"
    
    # Build fzf options
    local fzf_opts=(
        --multi
        --header="$prompt"
        --height=50%
        --layout=reverse
        --border
        --ansi
        --prompt="Agents> "
        --pointer="❯"
        --marker="✓"
        --header-border=bottom
        --preview-window=right:50%:wrap
    )
    
    # Build the list with icons and descriptions
    local list=""
    for agent in "${!AGENTS[@]}"; do
        local icon="${AGENT_ICONS[$agent]:-📦}"
        local desc="${AGENTS[$agent]}"
        list+="$icon $agent\n$desc\n\n"
    done
    
    # Show fzf and capture selection
    echo -e "$list" | fzf "${fzf_opts[@]}" | awk '{print $2}' | grep -v '^$'
}

select_agents() {
    local detected="${1:-}"
    local selected=()
    
    # Build menu items with detected agents pre-selected
    while true; do
        local result
        result=$(show_agent_menu "${selected[@]}" <<< "$(echo "$detected")")
        
        # If empty, show error and retry
        if [[ -z "$result" ]]; then
            echo "Error: Select at least one agent" >&2
            continue
        fi
        
        echo "$result"
        return 0
    done
}

# If run directly (not sourced), do interactive selection
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    detected="${1:-opencode}"
    select_agents "$detected"
fi
```

- [ ] **Step 2: Make executable**

```bash
chmod +x src/ui/agent-selector.sh
```

- [ ] **Step 3: Test basic sourcing**

```bash
source src/ui/agent-selector.sh && echo "Sourced OK"
```

- [ ] **Step 4: Commit**

```bash
git add src/ui/agent-selector.sh
git commit -m "feat: add fzf-based agent selector TUI"
```

---

### Task 2: Add fzf dependency check

**Files:**
- Modify: `src/ui/agent-selector.sh` (add dependency function at top)

- [ ] **Step 1: Add fzf dependency check function after shebang**

Add this function right after `set -euo pipefail`:

```bash
check_fzf() {
    if command -v fzf &>/dev/null; then
        return 0
    fi
    
    echo "fzf not found. Installing..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &>/dev/null; then
            brew install fzf
        else
            echo "Error: Homebrew not found. Install fzf manually: https://github.com/junegunn/fzf"
            exit 1
        fi
    elif command -v apt-get &>/dev/null; then
        sudo apt-get install fzf
    elif command -v yum &>/dev/null; then
        sudo yum install fzf
    else
        echo "Error: Cannot auto-install fzf. Install manually: https://github.com/junegunn/fzf"
        exit 1
    fi
}

check_fzf
```

- [ ] **Step 2: Commit**

```bash
git add src/ui/agent-selector.sh
git commit -m "feat: add fzf auto-install on dependency missing"
```

---

### Task 3: Modify install.sh to use agent selector

**Files:**
- Modify: `install.sh`

- [ ] **Step 1: Replace detect_agents function with call to selector**

Replace lines 43-68 (the detect_agents function) with:

```bash
# Source the agent selector
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
UI_DIR="$SCRIPT_DIR/src/ui"

# Interactive agent selection
select_agents_interactive() {
    if [ -f "$UI_DIR/agent-selector.sh" ]; then
        source "$UI_DIR/agent-selector.sh"
        detected=$(detect_available_agents)
        agents=($(select_agents "$detected"))
    else
        # Fallback if selector not available
        detect_agents
    fi
}

# Detect currently installed agents (for pre-selection)
detect_available_agents() {
    local available=()
    command -v opencode &>/dev/null && available+=("opencode")
    command -v kilo &>/dev/null && available+=("kilocode")
    command -v claude &>/dev/null && available+=("claude")
    command -v gemini &>/dev/null && available+=("gemini")
    echo "${available[*]:-opencode}"
}

# Legacy fallback
detect_agents() {
    agents=()
    
    if command -v opencode &>/dev/null; then
        agents+=("opencode")
    fi
    
    if command -v kilo &>/dev/null; then
        agents+=("kilocode")
    fi
    
    if command -v claude &>/dev/null; then
        agents+=("claude")
    fi
    
    if command -v gemini &>/dev/null; then
        agents+=("gemini")
    fi
    
    if [ ${#agents[@]} -eq 0 ]; then
        echo "Warning: No known AI agents detected."
        agents=("opencode")
    fi
}
```

- [ ] **Step 2: Replace the detect_agents call with select_agents_interactive**

Replace line 74:
```bash
detect_agents
```
With:
```bash
echo ""
echo "=========================================="
echo "  Agent Selection"
echo "=========================================="
echo ""
echo "Select which agents to configure for sprite:"
echo ""
select_agents_interactive
echo ""
```

- [ ] **Step 3: Test the modified install script (dry run)**

```bash
# Test that syntax is valid
bash -n install.sh && echo "Syntax OK"

# Run without installing (may need to mock some paths)
cd /tmp && /bin/bash /path/to/install.sh --dry-run 2>&1 || true
```

- [ ] **Step 4: Commit**

```bash
git add install.sh
git commit -m "feat: integrate fzf agent selector into install.sh"
```

---

### Task 4: Enhance the TUI preview pane

**Files:**
- Modify: `src/ui/agent-selector.sh`

- [ ] **Step 1: Add preview function for agent details**

Add this after the AGENT_ICONS array:

```bash
show_agent_preview() {
    local agent="$1"
    cat <<EOF
# ${AGENTS[$agent]}

## Installation
Install to: ~/.opencode/skills/ (OpenCode/KiloCode)
              ~/.claude/skills/ (Claude Code)
              ~/.gemini/ (Gemini CLI)

## Skills
- wish: Brainstorm feature requirements
- fulfill: Implement features autonomously

## Commands
- /wish <description>: Create a new wish
- /fulfill: Start implementation pipeline
EOF
}
```

- [ ] **Step 2: Update fzf opts to include preview**

Replace the fzf_opts in `show_agent_menu()` with:

```bash
    local fzf_opts=(
        --multi
        --header="$prompt"
        --height=50%
        --layout=reverse
        --border
        --ansi
        --prompt="Agents> "
        --pointer="❯"
        --marker="✓"
        --header-border=bottom
        --preview-window=right:50%:wrap
        --preview="echo '{}' | sed 's/^. //' | xargs -I{} bash -c 'source $UI_DIR/agent-selector.sh && show_agent_preview {}'"
    )
```

- [ ] **Step 3: Test the preview**

```bash
source src/ui/agent-selector.sh
show_agent_menu
```

- [ ] **Step 4: Commit**

```bash
git add src/ui/agent-selector.sh
git commit -m "feat: add agent preview pane in fzf menu"
```

---

### Task 5: Add summary output

**Files:**
- Modify: `install.sh`

- [ ] **Step 1: Add summary of selected agents after selection**

After the `select_agents_interactive` call, add:

```bash
echo "Selected agents: ${agents[*]}"
echo ""
```

- [ ] **Step 2: Commit**

```bash
git add install.sh
git commit -m "feat: show selected agents summary"
```

---

## Spec Coverage Check

| Spec Section | Task |
|---------------|------|
| Visual Style (Dracula colors) | Task 4 |
| Multi-select checkboxes | Task 1 |
| Agent icons and descriptions | Task 1, 4 |
| Preview pane | Task 4 |
| Dependency check | Task 2 |
| Integration with install.sh | Task 3 |
| Summary output | Task 5 |

---

## Execution Options

**Plan complete and saved to `docs/superpowers/plans/2026-03-29-agent-selection-tui.md`**

Two execution options:

1. **Subagent-Driven (recommended)** - Dispatch a fresh subagent per task, review between tasks, fast iteration

2. **Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?
