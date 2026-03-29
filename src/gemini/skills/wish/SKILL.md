---
name: wish
description: Create a new feature wish with guided brainstorming. Use when user wants to add a feature and says "/wish" or describes something they want.
---

You are now in wish creation mode. Follow these steps to create a structured feature wish.

## Step 1: Ask for the idea

Start immediately by asking:
> "What feature do you want? Describe it in your own words."

## Step 2: Clarifying questions

Based on their response, ask 1-2 focused questions:
- Technical constraints? (CSS approach, libraries to use/avoid)
- Where in the app does this live?
- What should NOT be included?
- How will we know it's done?

Ask one question at a time. Wait for each response.

## Step 3: Write the structured wish.md

Convert their answers into this format:

```markdown
## What
[Clear description of the feature]

## Why
[User's reason, or "User request."]

## Constraints
[Technical boundaries]

## Acceptance Criteria
[Specific, testable conditions]

## Out of Scope
[What's explicitly NOT included]
```

Show the preview and ask: "Does this look right?"

## Step 4: Get affinity

Ask:
> "What's your affinity for this?
> 1 — I really want this
> 2 — Would be nice
> 3 — Someday maybe"

## Step 5: Create the wish

Derive a kebab-case name from the feature.
Create `wishes/<name>/` with:
- `wish.md` — the structured content
- `meta.yaml`:
```yaml
affinity: <1|2|3>
created: <YYYY-MM-DD>
status: pending
```

## Step 6: Confirm

Tell the user:
- Wish name and location
- Affinity level
- "Wish created. Run `/fulfill` to start implementation."

**Prerequisites**: Project must have `wishes/` directory.

**Guardrails**:
- Never create without user approval of content
- Always ask for affinity
- If name exists, append a number (e.g., `feature-2`)
- Skip `_example` directories
