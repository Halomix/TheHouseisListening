# Playtest Notes

## Current status

Patch 11 received a headless Godot startup check on 2026-04-01.

Observed result:

- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1 --log-file .\godot-patch11.log` launched the engine and reached shutdown cleanly.
- The log only showed the familiar exit warnings on this machine: `ObjectDB instances leaked at exit` and `1 resources still in use at exit`.
- No GDScript parse errors or scene-load failures surfaced in the captured output.
- The new archive HUD and note-capture path still need a real in-game read-through, since this run only proved the project still boots.

Patch 10 Discord notifications should now be active on future PR events because `DISCORD_WEBHOOK_URL` already exists in the repo secret store.

## What to log next

- Scene that was tested.
- Steps that were taken.
- What felt scary, confusing, or broken.
- Any resource, signal, or prompt failures.
- Whether the change improved the core horror loop.

## Reporting format

Use short bullets and include concrete evidence when available. Keep the note readable enough for the next wake-up to act on it immediately.
