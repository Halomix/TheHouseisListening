# Playtest Notes

## Current status

Patch 8 received a headless Godot startup check on 2026-04-01.

Observed result:

- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1` launched the engine but reported only environment-level certificate/logging warnings on exit.
- No GDScript parse errors or scene-load failures surfaced in the captured output.

Patch 9 has not yet been observed in GitHub Actions from this local run.

## What to log next

- Scene that was tested.
- Steps that were taken.
- What felt scary, confusing, or broken.
- Any resource, signal, or prompt failures.
- Whether the change improved the core horror loop.

## Reporting format

Use short bullets and include concrete evidence when available. Keep the note readable enough for the next wake-up to act on it immediately.
