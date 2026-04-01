# Known Issues

## Repository setup

- The repository does not currently expose a Discord connector in this environment, so direct Discord status updates remain manual even though GitHub Actions PR notifications use the existing `DISCORD_WEBHOOK_URL` secret.

## Validation

- Full Godot headless validation is not yet wired to a guaranteed CI runner in this repo.
- The bootstrap workflow currently validates repository continuity files and local scripts, but it is not a substitute for a real scene-load smoke test.
- Discord notifications are expected to work on future PR events now that `DISCORD_WEBHOOK_URL` exists; if they fail, inspect the workflow logs before changing the secret name.
- The archive log currently records note reads from the test level only; future evidence sources should reuse the same archive system instead of adding a second one.

## Ownership metadata

- `CODEOWNERS` is intentionally conservative until a real maintainer or team handle is confirmed.
- Replace the placeholder owner with an actual GitHub user or team before relying on branch protection.

## What to watch

- Any future gameplay PR that touches node paths, scene resources, signals, or autoloads should be treated as high risk until validated in Godot.
- If a future run changes the Discord webhook name or routing, update `AGENTS.md`, this file, and the workflow together so the repo keeps one canonical secret name.
- If more evidence sources are added later, keep the HUD/archive summary concise so it stays useful under streamer pressure.
