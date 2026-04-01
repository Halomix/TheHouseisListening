# PATCH 4 - threat consequence pass

## What changed
- The active threat after the house key now has a real fail state.
- Staying exposed too long during the hunt triggers an attack sequence and fail screen.
- Leaving the closet too early becomes dangerous much faster than the first hide window.
- Added restart flow from the fail screen with `R`.
- Cleaned up duplicate hide/leave messaging so feedback is sharper.

## Result
The game loop is now:
- take key
- house begins search
- hide quickly
- stay hidden long enough
- leave only after the search passes
- unlock exit
- leave

Ignoring the threat or stepping out too early can now end the run.

## What to test
1. Grab the house key and stay in the open:
   - you should get escalating warnings
   - you should then get attacked and fail
2. Hide immediately and stay put:
   - threat should resolve
   - objective should switch back to unlocking the exit
3. Hide, then step out early:
   - you should get very little recovery time before being attacked
4. On fail screen:
   - `R` should restart
   - `Esc` should quit
