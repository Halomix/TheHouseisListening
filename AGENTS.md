# AGENTS

This repository contains the Godot horror game **The House Is Listening**.

## Read order

1. `AGENTS.md`
2. `CURRENT_MILESTONE.md`
3. `NEXT_TASKS.md`
4. `KNOWN_ISSUES.md`
5. `REVIEW_GUIDANCE.md`
6. `PLAYTEST_NOTES.md`
7. Relevant patch notes or PR discussion

## Operating rules

- Keep every run focused on one safe, reviewable slice.
- Prefer gameplay changes that strengthen the horror loop: explore -> notice signs -> interpret danger -> decide -> suffer consequences or survive -> learn.
- Update the durable docs whenever a run changes project state or reveals a blocker.
- Do not overwrite unrelated user changes.
- Do not use destructive git commands.
- Validate changes with real evidence before calling them done.

## Current continuity targets

- Preserve the patch history in the root notes.
- Keep `CURRENT_MILESTONE.md`, `NEXT_TASKS.md`, and `KNOWN_ISSUES.md` current.
- Use `PLAYTEST_NOTES.md` for any manual observations, even if they are brief.
- Keep PRs small and coherent.

## Useful tools and MCPs

- GitHub connector: use for repository metadata, issues, pull requests, and review follow-up when a real GitHub remote is connected.
- Sentry connector: use for live issue analysis if crash or performance telemetry is available.
- Google Drive / Docs / Sheets / Slides: useful only if design, planning, or external notes live there.
- Notion: useful if the project adopts a planning or task database.
- No Discord connector is currently exposed in this environment, so Discord reporting remains an external/manual step unless a webhook or app is added later.

## Local Codex config

- The project-local Codex defaults live in `.codex/config.toml`.
- Treat that file as the place to record repo-scoped defaults that should survive across wake-ups.

## Validation expectations

- Run the repo bootstrap validation script before finalizing bootstrap changes.
- If Godot headless validation is not available in CI yet, document the exact missing step instead of pretending the check exists.
- Keep `KNOWN_ISSUES.md` honest about anything that still requires manual setup.

## Manual handoff requirement

If a true unattended wake-up loop, Discord reporting path, or GitHub PR path cannot be completed from inside the repo, document the exact remaining step in:

- `AGENTS.md`
- the active PR description
- `KNOWN_ISSUES.md`

Do not leave that dependency implied.
