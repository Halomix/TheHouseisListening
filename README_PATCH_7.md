# The House Is Listening - Patch 7 Integration

This zip is a full project snapshot built on top of your uploaded Patch 6 baseline.

## Main upgrade
Patch 7 turns the prototype into a more modern horror loop:
- first hunt still anchors the run
- the house remembers habits after that hunt
- safe behavior gets exploited
- pressure comes in waves instead of one spike

## Open this scene
- `res://scenes/main.tscn`

## What is new
### Systems
- `HouseMemory` stores room pressure, hide usage, noise, and obsession data.
- `HouseDirector` fires soft events during calm windows.
- `ThreatDirector` can now bring the threat back instead of ending after one resolution.

### Gameplay feel
- repeated closet use becomes dangerous
- the house can mark the player after a sloppy survival
- rooms the player trusts become targets
- the house keeps nudging the run even outside the chase

### Audio
Selected sounds from your uploaded horror packs are already copied into `assets/audio` and used in-game.

## Best testing route
1. read the entry note
2. open the first door
3. restore power
4. search the bedroom drawer
5. take the key
6. survive the first hunt
7. keep relying on the same safe behavior and see if the house adapts

## If something feels too aggressive
Open `scripts/systems/threat_director.gd` and tune these first:
- `repeat_hunt_min_delay`
- `repeat_hunt_max_delay`
- `min_tension_for_repeat_hunt`
- `max_repeat_hunts`
- `active_threat_duration`

## If you want the next patch after testing
Best next step is **Patch 8: clearer recap + real objective deception + more room mutations**.
