# Patch 8 - The House Lies Back

## Intent

Make the post-hunt and end-of-run flow feel more personal by letting the house misdirect the player and then recap what it learned.

## What changed

- Added a deceptive objective path in `GameState` so the house can show a lie while preserving the real objective internally.
- Made the key pickup and exit unlock beats use house memory to generate misleading objective text.
- Expanded the win screen to include a short recap of the house's learned preferences.

## Why this matters

Patch 7 taught the house to remember. Patch 8 makes that memory visible in the UI and emotionally legible at the end of the run.

## Files changed

- `scripts/systems/game_state.gd`
- `scripts/systems/house_memory.gd`
- `scripts/world/door.gd`
- `scripts/world/pickup.gd`
- `CURRENT_MILESTONE.md`
- `NEXT_TASKS.md`
- `KNOWN_ISSUES.md`

## Validation target

- Load the main scene in Godot headless.
- Confirm the game still boots.
- Confirm the objective text changes when the key is picked up and the exit unlocks.
- Confirm the end screen includes a learned recap when the player wins.
