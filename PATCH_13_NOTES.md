# Patch 13 Notes

## Summary

Added visible room mutation so the house actively tightens around its learned focus during soft events and post-hunt resolution.

## What changed

- Added `mutate_focus_room()` to the test level.
- Had the house director invoke room mutation when the house is obsessed, marked, or settling into a room.
- Had the threat director pulse the current target zone again when a hunt resolves.
- Kept the house-focus HUD and deceptive objectives from Patch 12 intact.

## Validation

- `git diff --check`
- `.\scripts\validate-bootstrap.ps1`
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1 --log-file .\godot-patch13.log`

## Watch-outs

- The new room-mutation beat still needs a real playtest to confirm it feels authored and readable instead of noisy.
- Headless Godot still exits with the familiar resource-leak warnings on this machine, but there were no parse errors or scene-load failures.
