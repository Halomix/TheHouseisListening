# Patch 12 Notes

## Summary

Added a visible house-focus cue in the HUD and made post-hunt and soft-event objectives rewrite themselves as deceptive lies based on the house's learned room focus.

## What changed

- Added `get_focus_label()` to house memory.
- Added a live `House focus:` HUD label that follows house-memory changes.
- Upgraded hunt resolution and soft events to prefer deceptive objectives when the game state supports them.
- Kept the archive loop intact from Patch 11.

## Validation

- `git diff --check`
- `.\scripts\validate-bootstrap.ps1`
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1 --log-file .\godot-patch12-fixed.log`

## Watch-outs

- The house-focus label and deceptive objectives are now live, but they still need an interactive playtest to confirm they feel readable instead of noisy.
- Headless Godot still exits with the familiar resource-leak warnings on this machine, but there were no parse errors or scene-load failures after the type-inference fix.
