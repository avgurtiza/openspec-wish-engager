# opencode-wish-engager

An autonomous AI development pipeline for [OpenCode](https://opencode.ai). Drop feature wishes into a folder, and an agent picks them up, plans them, implements them in git worktrees, and logs results — without human intervention.

**Depends on:** [OpenSpec](https://github.com/anthropics/openspec) CLI.

**Platforms:** macOS, Linux, Windows WSL.

## How It Works

```
You: "I want dark mode"
         ↓
   /opsx-wish (guided brainstorming)
         ↓
   openspec/wishes/add-dark-mode/
     wish.md    ← your mini PRD
     meta.yaml  ← affinity: 1, status: pending
         ↓
   /opsx-engage (or daemon picks it up)
         ↓
   openspec/changes/add-dark-mode/
     proposal.md, design.md, tasks.md
         ↓
   .worktrees/add-dark-mode/
     (agent implements here, isolated)
         ↓
   openspec/changes/add-dark-mode/run-log.md
     (what happened, how long, pass/fail)
```

## Affinity, Not Priority

This is a wish list, not a task queue. Each wish has an **affinity score**:

| Score | Meaning |
|-------|---------|
| 1     | I really want this |
| 2     | Would be nice |
| 3     | Someday maybe |

The agent picks by affinity (1 first), then oldest. Higher affinity = higher probability, not a guarantee.

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/opencode-wish-engager.git /tmp/wish-engager
cd /tmp/wish-engager
./install.sh /path/to/your/project
```

Or install into the current directory:

```bash
./install.sh
```

This installs:
- `.opencode/skills/openspec-wish/` — guided wish creation
- `.opencode/skills/openspec-engage/` — autonomous pipeline
- `.opencode/command/opsx-wish.md` — `/opsx-wish` command
- `.opencode/command/opsx-engage.md` — `/opsx-engage` command
- `.opencode/wish-engager.yaml` — config (lint/test commands)
- `scripts/wish-daemon.sh` — daemon for autonomous runs
- `openspec/wishes/` — wish directory with example

## Configuration

Edit `.opencode/wish-engager.yaml`:

```yaml
verify:
  lint: "vendor/bin/pint --dirty"    # Your lint command
  test: "php artisan test"            # Your test command
cooldown: 60                          # Seconds between runs
max_time_per_wish: 30                 # Minutes before flagging
worktree_dir: ".worktrees"            # Where worktrees go
```

## Usage

### Create a wish

```
/opsx-wish
```

The agent asks what you want, asks 2-3 clarifying questions, writes a structured `wish.md`, and asks for your affinity score.

### Run one cycle

```
/opsx-engage
```

Picks the highest-affinity pending wish, implements it, logs results.

### Run until empty

```
/opsx-engage --all
```

Loops through all pending wishes.

### Work on a specific wish

```
/opsx-engage --wish add-dark-mode
```

### Daemon mode

The install script detects your OS and generates the right scheduler config.

**macOS (launchd):**

```bash
cp scripts/com.*.wish-engager.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.*.wish-engager.plist
```

**Linux / WSL (cron):**

```bash
# Review the generated cron entry:
cat scripts/wish-engager.cron

# Install it:
(crontab -l 2>/dev/null; cat scripts/wish-engager.cron) | crontab -
```

Runs every 30 minutes. Exits immediately if no pending wishes.

## Uninstallation

```bash
./uninstall.sh /path/to/your/project
```

Removes skills, commands, and scripts. Preserves your wishes, changes, and config.

To remove the daemon scheduler:

```bash
# macOS
launchctl unload ~/Library/LaunchAgents/com.*.wish-engager.plist
rm ~/Library/LaunchAgents/com.*.wish-engager.plist

# Linux / WSL
crontab -e    # then delete the wish-daemon.sh line
```

## What the Agent Does

1. **Scans** `openspec/wishes/` for pending items
2. **Selects** by affinity (1→2→3), then oldest
3. **Creates** a git worktree (isolated branch)
4. **Promotes** wish to an OpenSpec change (proposal + design + tasks)
5. **Implements** tasks with retry logic (2 retries per task, then skip)
6. **Verifies** with your lint/test commands
7. **Logs** results to `run-log.md`
8. **Resolves** — moves completed wishes to `.completed/`, leaves blocked ones for review
9. **Cooldown** — waits, then repeats (if `--all` or daemon)

## File Structure

```
your-project/
├── .opencode/
│   ├── skills/
│   │   ├── openspec-wish/SKILL.md
│   │   └── openspec-engage/SKILL.md
│   ├── command/
│   │   ├── opsx-wish.md
│   │   └── opsx-engage.md
│   └── wish-engager.yaml
├── openspec/
│   ├── wishes/
│   │   ├── _example/
│   │   ├── .completed/
│   │   └── your-wish-here/
│   └── changes/
│       └── (agent promotes wishes here)
├── .worktrees/
│   └── (agent creates isolated workspaces here)
└── scripts/
    ├── wish-daemon.sh
    ├── com.yourproject.wish-engager.plist   # macOS
    └── wish-engager.cron                     # Linux/WSL
```

## License

MIT
