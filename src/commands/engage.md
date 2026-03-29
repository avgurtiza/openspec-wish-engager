---
description: Run the autonomous wish-engager pipeline
---

Run the autonomous wish-engager pipeline.

**Input**: Optionally specify:
- `/engage` — run one cycle (pick + implement one wish)
- `/engage --all` — loop until no pending wishes
- `/engage --wish <name>` — work on a specific wish

**Steps**

Invoke the `engage` skill. Pass any flags as input.

**Output**
The skill handles all output. This command is a thin wrapper.
