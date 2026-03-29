---
name: wish
description: Create a new feature wish with guided brainstorming. Use when user wants to add a feature and says "/wish" or describes something they want.
disable-model-invocation: true
---

Guide the user through creating a high-quality wish for the autonomous agent pipeline.

**Input**: Optionally, arguments after `/wish` describing what they want. If provided, skip the initial question.

**Prerequisites**: Project must have `wishes/` directory. Run `install.sh` from the sprite repo if not present.

**Steps**

1. **Get the idea**

   If no input was provided, ask:
   > "What feature do you want? Describe it in your own words."

   Wait for the user's response.

2. **Ask 2-3 clarifying questions**

   Based on what they described, ask focused questions:
   - Technical constraints? (CSS approach, libraries to use/avoid)
   - Where in the app does this live?
   - What should NOT be included? (scope boundaries)
   - How will we know it's done? (acceptance criteria)

   Ask one question at a time. Don't overwhelm.

3. **Write the structured wish.md**

   Convert their answers into a structured `wish.md` with these sections:

   ```markdown
   ## What
   [Clear, specific description of the feature]

   ## Why
   [User's reason, if provided. Otherwise note "User request."]

   ## Constraints
   [Technical boundaries, libraries, approaches]

   ## Acceptance Criteria
   [Specific, testable conditions for "done"]

   ## Out of Scope
   [What this wish explicitly does NOT cover]
   ```

   Show the user the preview and ask:
   > "Does this look right? I can revise any section."

   Wait for approval.

4. **Get affinity**

   Ask:
   > "What's your affinity for this?
   > 1 — I really want this
   > 2 — Would be nice
   > 3 — Someday maybe"

5. **Create the wish**

   Derive a kebab-case name from the feature description.
   Create the directory and files:

   ```bash
   mkdir -p wishes/<name>
   ```

   Write `wish.md` with the approved content.
   Write `meta.yaml`:

   ```yaml
   affinity: <1|2|3>
   created: <YYYY-MM-DD>
   status: pending
   started_at:
   completed_at:
   blocker_summary:
   ```

6. **Confirm**

   Show:
   - Wish name and location
   - Affinity level
   - Summary of what's in the wish
   - Prompt: "Wish created. The agent will pick this up on the next fulfillment cycle. Run `/fulfill` to start immediately, or leave it for the daemon."

**Guardrails**
- Never create a wish without user approval of the content
- Always ask for affinity — don't default or assume
- If a wish with that name already exists, append a number (e.g., `add-dark-mode-2`)
- Skip `_example` directories when checking for existing names
- Keep the brainstorming brief — 3 questions max, not a full design session
- The goal is a clear wish.md, not a complete design doc
