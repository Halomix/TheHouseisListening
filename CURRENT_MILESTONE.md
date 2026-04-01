# Current Milestone

## Milestone

Patch 9: Godot headless smoke test CI.

## Why this matters

The project needs a repeatable runtime check on every push and PR so startup regressions, scene-load failures, and script parse errors stop earlier in the loop.

## Acceptance criteria

- A dedicated GitHub Actions workflow boots `res://scenes/main.tscn` headlessly on push and PR.
- The workflow uses a real Godot install and fails on startup regressions.
- Repo docs describe the remaining manual gaps, if any, without claiming unsupported validation.
- The next task queue points to the next gameplay slice after CI hardening.

## Status

In progress as of 2026-04-01.

## Owner

Codex acting as autonomous lead developer.

## Last updated

2026-04-01
