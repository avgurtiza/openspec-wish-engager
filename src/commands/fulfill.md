---
description: Run the autonomous wish-engager pipeline
---

Run the autonomous wish-engager pipeline.

**Input**: Optionally specify:
- `/fulfill` — run one cycle (pick + implement one wish)
- `/fulfill --all` — loop until no pending wishes
- `/fulfill --wish <name>` — work on a specific wish

**Steps**

Invoke the `fulfill` skill. Pass any flags as input.

**Output**
The skill handles all output. This command is a thin wrapper.
