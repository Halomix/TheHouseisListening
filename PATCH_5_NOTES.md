# Patch 5 - Presence and Payoff Pass

This patch is aimed at one problem: the threat worked mechanically, but the house still felt too much like a timer.

## What changed
- Added a **pre-hunt stalk beat** right after the house key is picked up.
- Added **stronger hunt pulses** so the house appears around the level during the search.
- Added a **closet-handle fake** to make hiding feel less abstract.
- Added **post-hunt payoff sequences** that change based on how narrowly you survived:
  - **Clean**: the house clearly recedes.
  - **Shaken**: the house lingers and nearly doubles back.
  - **Barely**: the house was effectively outside the closet with you.
- Added a **Presence** readout to the HUD so the build can communicate hunt aftermath state.
- Tightened threat timings a bit so the encounter feels more urgent and less floaty.

## Design intent
The hunt should now feel like an encounter with a presence moving through the house, not just a countdown.

## What to test
1. Pick up the key and watch for the **pre-hunt visible stalk**.
2. Hide quickly and verify the aftermath feels calmer than before.
3. Delay hiding and verify the aftermath feels more aggressive.
4. Step out too early and confirm the hunt still punishes that.
5. Watch for any script timing issues where flickers, glimpses, or messages overlap badly.

## Known limitations
- This is still a prototype horror slice, so the house is represented with glimpse choreography, lighting, and messages rather than a full AI enemy.
- The patch was built against your uploaded project files, but it was not run live inside the Godot editor here.
