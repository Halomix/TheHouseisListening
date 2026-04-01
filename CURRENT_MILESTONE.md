# Current Milestone

## Milestone

Patch 10: GitHub Actions Discord notifications.

## Why this matters

The project needs a lightweight notification path so PR activity posts cleanly to Discord without duplicating existing automation or inventing a second webhook convention.

## Acceptance criteria

- A GitHub Actions workflow posts clean PR-open, update, merge, and close events to Discord.
- The workflow uses the existing `DISCORD_WEBHOOK_URL` secret consistently.
- The repo docs and next task queue reflect that Discord notifications are live for future PR events.
- The next task queue points to the live verification step and then the next gameplay slice.
- Known blockers and missing external setup are documented.

## Status

In progress as of 2026-04-01.

## Owner

Codex acting as autonomous lead developer.

## Last updated

2026-04-01
