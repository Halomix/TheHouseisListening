# Patch 7 - The House Learns

## Intent
Build directly on Patch 6 and push the prototype away from a one-and-done scare into a repeatable pressure loop.

## What changed
- Added a new **House Memory** system that tracks room habits, safe-room usage, hide-spot repetition, object interest, and noise.
- Added a **House Director** for soft pressure events between hunts so the house keeps acting even when the player is not in a chase.
- Upgraded the **Threat Director** so hunts can return after the key event if tension is high, the player is marked, or the same hiding habit is repeated.
- Repeated use of the same hide spot now becomes a liability instead of a permanent solution.
- The player can now become **Marked**, which makes follow-up pressure and repeat hunts more likely.
- Added actual audio from the uploaded horror sound packs for ambient wind, door creaks, and the hunt stinger.

## New runtime systems
- `scripts/systems/house_memory.gd`
- `scripts/systems/house_director.gd`

## Updated files
- `scenes/main.tscn`
- `scripts/systems/game_state.gd`
- `scripts/systems/threat_director.gd`
- `scripts/player/player.gd`
- `scripts/world/test_level.gd`
- `scripts/world/hide_spot.gd`
- `scripts/world/pickup.gd`
- `scripts/world/searchable_container.gd`
- `scripts/world/door.gd`
- `scripts/world/locked_exit.gd`

## Audio wired in from your packs
- `assets/audio/ambient_wind_01.mp3`
- `assets/audio/door_creak_01.mp3`
- `assets/audio/monster_growl_01.mp3`

## What to test
1. Play normally to the key and confirm the first hunt still works.
2. Hide in the linen closet more than once and confirm the house starts punishing the habit.
3. Linger in the same room after the first hunt and confirm the house creates soft pressure between hunts.
4. Reach high tension and confirm a repeat hunt can happen before the exit.
5. Listen for ambient wind, real door creaks, and the new growl-based stinger.

## Why this patch matters
Patch 6 made the presence readable. Patch 7 makes the house remember.
