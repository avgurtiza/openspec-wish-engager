# sprite

An agent-agnostic pipeline for autonomous software development. Place feature requirements (wishes) into a directory, and an AI agent handles the planning, implementation in isolated git worktrees, and verification.

**Compatible agents:** OpenCode, KiloCode, Claude Code, Gemini CLI
**Platforms:** macOS, Linux, Windows WSL

## Workflow

1. **Request:** Run `/wish` to describe a feature. The agent brainstorms requirements and creates a structured `wish.md`.
2. **Prioritize:** Set an affinity score (1-3) to indicate how much you want the feature.
3. **Execute:** Run `/fulfill` (or let the background daemon run). The agent:
   - Selects the highest-affinity pending wish.
   - Creates a new git branch in a dedicated worktree.
   - Generates a proposal, design, and task list.
   - Implements changes task-by-task.
   - Runs linting and tests to verify.
   - Logs the entire process to `run-log.md`.

## Agent Compatibility

The installation script detects available agents and configures them accordingly:

| Agent | Skills Location | Method |
|-------|----------------|--------|
| OpenCode | `.opencode/skills/` | File copy |
| KiloCode | `.opencode/skills/` | File copy |
| Claude Code | `.claude/skills/` | File copy |
| Gemini CLI | `~/.agents/skills/` | `gemini skills install` |

## Installation

Install into your project directory:

```bash
git clone https://github.com/avgurtiza/sprite.git /tmp/sprite
cd /tmp/sprite
./install.sh /path/to/your/project
```

## Configuration

The agent reads configuration from a `sprite.yaml` file located in the agent's specific directory (e.g., `.opencode/sprite.yaml` or `.claude/sprite.yaml`).

```yaml
verify:
  lint: "npm run lint"
  test: "npm test"
cooldown: 60
max_time_per_wish: 30
worktree_dir: ".worktrees"
skip_example: true
```

## Commands

### /wish
Guided brainstorming to capture feature intent. Converts a vague idea into a structured markdown file.

### /fulfill
Starts the autonomous implementation pipeline.
- `/fulfill`: Run one cycle.
- `/fulfill --all`: Process all pending wishes.
- `/fulfill --wish <name>`: Process a specific wish.

## Daemon Mode

The background daemon checks for pending wishes every 30 minutes and executes fulfillment cycles automatically.

**macOS (launchd):**
```bash
cp scripts/com.*.sprite.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.*.sprite.plist
```

**Linux / WSL (cron):**
```bash
(crontab -l 2>/dev/null; cat scripts/sprite.cron) | crontab -
```

## File Structure

```
project-root/
├── .opencode/           # or .claude/, .gemini/
│   ├── skills/          # Sprite skill definitions
│   ├── command/         # Sprite slash commands
│   └── sprite.yaml      # Configuration
├── wishes/              # Feature requirements and logs
│   ├── add-dark-mode/
│   │   ├── wish.md      # Requirement spec
│   │   ├── proposal.md  # Generated plan
│   │   ├── tasks.md     # Checkbox progress
│   │   └── run-log.md   # Implementation history
│   └── .completed/      # Finished wishes
└── .worktrees/          # Isolated implementation environments
```

## License
MIT
