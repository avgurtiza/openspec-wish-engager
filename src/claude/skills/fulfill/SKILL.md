---
name: fulfill
description: Autonomous pipeline to pick a wish, plan it, implement it in a git worktree, and log results. Use when user says "/fulfill" or wants to work on pending wishes.
---

Run the autonomous sprite pipeline.

**Prerequisites**:
- `wishes/` directory with pending wishes
- `.claude/sprite.yaml` config file (optional — uses defaults if missing)

**Input**: Optionally specify:
- `--all` — loop until no pending wishes remain
- `--wish <name>` — work on a specific wish, skip scoring
- No input — run one cycle (pick + implement one wish)

**Steps**

1. **Load configuration**

   Read `.opencode/sprite.yaml` if it exists. Use defaults for any missing keys:

   ```yaml
   # Defaults
   verify:
     lint: "echo 'no lint command configured'"
     test: "echo 'no test command configured'"
   cooldown: 60
   max_time_per_wish: 30
   worktree_dir: ".worktrees"
   skip_example: true
   ```

   Store these values for use throughout the pipeline.

2. **Scan for pending wishes**

   List directories in `wishes/`. For each directory, read `meta.yaml`.

   Filter to `status: pending`.
   Skip `_example` if `skip_example` is true.
   Skip `.completed` directory.

   ```bash
   for dir in wishes/*/; do
     [ -d "$dir" ] || continue
     name=$(basename "$dir")
     [ "$name" = "_example" ] && [ "$skip_example" = "true" ] && continue
     [ "$name" = ".completed" ] && continue
     # Read meta.yaml status
   done
   ```

   **If no pending wishes:**
   > "No pending wishes found. Create one with `/wish`."
   > STOP.

3. **Select a wish**

   **If `--wish <name>` was provided:**
   - Use that specific wish
   - Verify it exists and is pending
   - If not found or not pending, report and STOP

   **Otherwise:**
   - Parse affinity and created date from each `meta.yaml`
   - Sort by: affinity ASC (1 first), then created ASC (oldest first)
   - Pick the first wish in the sorted list
   - Announce: "Selected: \<name\> (affinity: \<N\>, created: \<date\>)"

4. **Create git worktree**

   - Check for `<worktree_dir>/` directory (create if not exists)
   - Verify `<worktree_dir>/` is gitignored (`git check-ignore -q <worktree_dir>`)
   - If not ignored, add to `.gitignore` and commit
   - Create worktree: `git worktree add <worktree_dir>/<name> -b feature/<name>`
   - Run project setup:
     - `composer install` (if `composer.json` exists at project root)
     - `bun install` or `npm install` (if `package.json` exists)
   - Verify baseline: run test command — report failures but proceed

5. **Promote wish to change**

   Read `wishes/<name>/wish.md`.

   Generate these files in `wishes/<name>/`:

   **proposal.md** — structured from wish.md:
   ```markdown
   ## Why
   [From wish's Why section, or "User request" if empty]

   ## What Changes
   [Concrete list derived from wish's What + Constraints]

   ## Capabilities
   [New capabilities this adds]

   ## Impact
   [Files to create/modify based on Constraints and scope]
   ```

   **design.md** — implementation approach:
   ```markdown
   ## Approach
   [How to implement — architecture, data flow]

   ## Components
   [Break down into pieces]

   ## File Structure
   [Which files to create/modify]
   ```

   **tasks.md** — checkbox breakdown:
   ```markdown
   ## 1. [Section Name]

   - [ ] 1.1 [Concrete 2-5 minute task]
   - [ ] 1.2 [Next task]

   ## 2. [Next Section]

   - [ ] 2.1 [Task]
   ```

6. **Update wish status**

   Edit `wishes/<name>/meta.yaml`:
   - Set `status: in_progress`
   - Set `started_at:` to current ISO timestamp

7. **Implement the change**

   Read the generated context files:
   - `proposal.md`
   - `design.md`
   - `tasks.md`

   Loop through tasks in `tasks.md`:

   For each `- [ ]` task:
   - Announce which task is being worked on
   - Implement the code changes (minimal, focused)
   - Mark complete: `- [ ]` → `- [x]`
   - Continue to next task

   **Retry logic:**
   - If a task fails (error, unclear), try a different approach (up to 2 retries)
   - If still failing after retries, skip the task, note it in run-log
   - Continue with remaining tasks
   - Track: total tasks, completed tasks, failed tasks

   **Never:**
   - Force-push or delete branches
   - Merge to main
   - Guess on unclear requirements (skip and note instead)

8. **Verify**

   Run in the worktree directory using commands from config:

   ```bash
   cd <worktree_dir>/<name>

   # Run lint command from config
   <verify.lint>

   # Run test command from config
   <verify.test>
   ```

   If either fails:
   - Attempt to fix (one attempt)
   - If still failing, note in run-log but don't block

9. **Write run-log**

   Create or append to `wishes/<name>/run-log.md`:

   ```markdown
   # Run Log: <name>

   ## Run <N> — <YYYY-MM-DD HH:MM>
   - Status: <completed|blocked>
   - Tasks done: <completed>/<total>
   - Failed: <failed_count>
   - Duration: <minutes>m
   - Summary: <one-line summary of what was accomplished>
   - Branch: feature/<name>
   - Worktree: <worktree_dir>/<name>
   - Verify: lint=<pass|fail>, test=<pass|fail>
   ```

   If a run-log already exists, append a new run section.

10. **Resolve wish**

    **If completed (most tasks done, verify passing):**
    - Update `meta.yaml`: `status: completed`, `completed_at: <ISO timestamp>`
    - Move wish: `mv wishes/<name> wishes/.completed/<name>`
    - Announce: "Wish '\<name\>' completed. Worktree at `<worktree_dir>/<name>` for review."

    **If blocked (>50% tasks failed):**
    - Update `meta.yaml`: `status: blocked`
    - Set `blocker_summary:` to one-line description
    - Leave wish in `wishes/<name>/`
    - Announce: "Wish '\<name\>' blocked. See run-log.md for details."

    **If partially done (<50% failed but not all passing):**
    - Update `meta.yaml`: `status: completed`, `completed_at: <ISO timestamp>`
    - Move to `.completed/`
    - Note partial completion in run-log

11. **Cooldown and repeat**

    Wait `<cooldown>` seconds (from config, default 60s).

    **If `--all` flag:** go back to step 2
    **If single cycle (default):** STOP, show summary

**Output On Completion**

```
## Fulfillment Complete

**Wish:** <name>
**Affinity:** <N>
**Status:** completed
**Tasks:** <done>/<total> done
**Duration:** <minutes>m
**Worktree:** <worktree_dir>/<name>

Review the worktree when ready. Branch is `feature/<name>`.
```

**Output On Blocker**

```
## Fulfillment Blocked

**Wish:** <name>
**Affinity:** <N>
**Status:** blocked
**Tasks:** <done>/<total> done
**Blocker:** <summary>
**Run Log:** wishes/<name>/run-log.md

Wish remains in `wishes/<name>/` for review.
```

**Guardrails**
- Never force-push or delete branches
- Always run lint and test verify commands before declaring complete
- Never merge to main automatically
- Don't pick a wish already in progress (meta.yaml status check)
- If worktree creation fails, report and stop
- Always skip `_example` and `.completed` directories
- If exceeding `max_time_per_wish` minutes on a single wish, flag it in run-log
- Read config at start — don't hardcode project-specific commands
