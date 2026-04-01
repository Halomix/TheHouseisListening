# Patch 9 - Headless Godot Smoke Test CI

## Intent

Add a small, reliable GitHub Actions job that boots the main Godot scene headlessly on every push and pull request.

## What changed

- Added `.github/workflows/godot-smoke-test.yml`.
- The workflow installs Godot 4.6.1 with `chickensoft-games/setup-godot@v2`.
- The workflow boots `res://scenes/main.tscn` in headless mode and writes a log artifact.
- Updated the repo brain docs to mark CI hardening as the current milestone and to point the next task queue at the next gameplay slice.

## Why this matters

This catches scene-load regressions, resource failures, and script parse problems earlier than manual playtesting alone.

## Validation

- Ran `godot.exe --headless --path . --scene res://scenes/main.tscn --quit-after 1 --log-file .\godot-smoke-test.log`.
- The project booted headlessly and only emitted environment-level warnings on exit.
- No scene-load or script-parse failure appeared in the captured output.

## Watch-outs

- The workflow should be observed in GitHub Actions after it lands so any runner-specific warnings are documented.
- If future engine upgrades change the supported install version, the workflow pin should be updated with the project’s Godot line.
