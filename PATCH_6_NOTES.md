# Patch 6 - Audio + Encounter Polish + More Realistic Presence

## Intent
This patch shifts the hunt from a dramatic timer into a more believable search encounter.

## New gameplay consequences
- Flashlight is now dangerous during the hunt.
- If you stay hidden with the flashlight on too long, the entity can find you.
- If you stay exposed with the flashlight on, your allowed reaction time is shorter.

## Encounter upgrades
- The presence now moves through search passes instead of only instant pop-ins.
- The silhouette is reshaped in code to feel taller and less human.
- Small glowing eyes are added at runtime for brief readable sightings.
- Closet checks and post-hunt aftermaths are more authored.

## Audio
Added generated placeholder positional audio:
- `assets/audio/presence_step.wav`
- `assets/audio/presence_breath.wav`
- `assets/audio/closet_rattle.wav`
- `assets/audio/presence_stinger.wav`

These are placeholders meant to make the encounter readable now.
You can later replace them with custom sound design without changing the logic.

## Files changed
- `scripts/systems/game_state.gd`
- `scripts/systems/threat_director.gd`
- `scripts/world/test_level.gd`
- `scripts/player/player.gd`
- `assets/audio/presence_step.wav`
- `assets/audio/presence_breath.wav`
- `assets/audio/closet_rattle.wav`
- `assets/audio/presence_stinger.wav`

## What to test
1. Take the key and keep the flashlight on in the open.
2. Hide correctly with the flashlight off.
3. Hide with the flashlight on and confirm it becomes dangerous.
4. Watch whether the search passes feel more like movement through the house.
5. Check the attack transition and whether the silhouette reads better now.

## What would help next
If you want the entity to feel even more specific, the best next inputs from you are:
- one sentence describing the entity personality
- whether it should feel more ghostly, more human, or more inhuman
- whether you want me to generate a custom silhouette concept next
