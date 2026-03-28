---
description: Run the autonomous wish-engager pipeline (OPSX)
---

Run the autonomous wish-engager pipeline.

**Input**: Optionally specify:
- `/opsx-engage` — run one cycle (pick + implement one wish)
- `/opsx-engage --all` — loop until no pending wishes
- `/opsx-engage --wish <name>` — work on a specific wish

**Steps**

Invoke the `openspec-engage` skill. Pass any flags as input.

**Output**
The skill handles all output. This command is a thin wrapper.
