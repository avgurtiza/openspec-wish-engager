---
name: wish
description: Create a new feature wish with guided brainstorming. Invoke with a description: /wish <feature description> (e.g. "/wish add dark mode").
argument-hint: <feature description>
---

Guide the user through creating a structured feature wish.

The user has invoked `/wish` with: $ARGUMENTS

If $ARGUMENTS is empty, ask: "What feature do you want? Describe it in your own words." and wait.

Otherwise, use $ARGUMENTS as the initial description and proceed directly to clarifying questions.

**Note:** Due to how Gemini CLI loads skills, `/wish` alone will not start the conversation. Users must provide a description: `/wish <feature description>`.

## Steps

1. **Clarifying questions** — Ask 1-2 focused questions, one at a time:
   - Technical constraints? (libraries, CSS approach, etc.)
   - Where in the app does this live?
   - What's out of scope?
   - How will we know it's done?

2. **Write wish.md** — Convert answers into:
   ```markdown
   ## What
   [Clear description]

   ## Why
   [User's reason, or "User request."]

   ## Constraints
   [Technical boundaries]

   ## Acceptance Criteria
   [Testable conditions]

   ## Out of Scope
   [Explicitly excluded]
   ```
   Show preview, ask "Does this look right?"

3. **Get affinity**
   > "What's your affinity for this?
   > 1 — I really want this
   > 2 — Would be nice
   > 3 — Someday maybe"

4. **Create the wish** — Derive a kebab-case name. Create `wishes/<name>/`:
   - `wish.md`
   - `meta.yaml`:
     ```yaml
     affinity: <1|2|3>
     created: <YYYY-MM-DD>
     status: pending
     started_at:
     completed_at:
     blocker_summary:
     ```

5. **Confirm** — Show wish name, location, affinity. Say "Wish created. Run `/fulfill` to start implementation."

**Guardrails**
- Never create without user approval
- Always ask for affinity
- If name exists, append a number (e.g., `feature-2`)
- Skip `_example` directories
- Max 3 clarifying questions
