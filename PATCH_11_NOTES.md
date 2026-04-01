# Patch 11 Notes

## Summary

Added an archive/evidence loop for note reads so the HUD can show recovered evidence and the end screen can recap what the player found.

## What changed

- Added `scripts/systems/archive_log.gd` to track recovered note entries.
- Added a live archive status label to the HUD.
- Recorded first-time note reads into the archive log.
- Summarized recovered notes on the end screen.
- Tuned the test level note text to feel more like records and evidence.

## Validation

- `git diff --check`
- `.\scripts\validate-bootstrap.ps1`
- `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1 --log-file .\godot-patch11.log`

## Watch-outs

- Headless Godot still exits with the familiar resource-leak warnings on this machine, but there were no parse errors or scene-load failures.
- The archive loop currently only captures note reads in the test level, so future evidence sources should reuse the same system rather than creating a second one.
