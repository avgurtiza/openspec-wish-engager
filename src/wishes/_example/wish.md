## What
Add a dark mode toggle to the settings page.

## Why
Users working late report eye strain from the bright UI.

## Constraints
- Use CSS custom properties, not hard-coded colors
- Persist preference in localStorage
- Don't break existing light mode

## Acceptance Criteria
- Toggle exists in settings page
- Preference persists across sessions
- All pages respect the theme

## Out of Scope
- System preference detection
- Per-component theme overrides
