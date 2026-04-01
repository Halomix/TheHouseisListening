# Known Issues

## Repository setup

- The repository does not currently expose a Discord connector in this environment, so automated Discord status updates need the GitHub Actions secret `DISCORD_WEBHOOK_URL` to be configured in repo settings before notifications can post.

## Validation

- Full Godot headless validation is not yet wired to a guaranteed CI runner in this repo.
- The bootstrap workflow currently validates repository continuity files and local scripts, but it is not a substitute for a real scene-load smoke test.
- Discord notifications will be a no-op until `DISCORD_WEBHOOK_URL` exists in the GitHub repository secrets.

## Ownership metadata

- `CODEOWNERS` is intentionally conservative until a real maintainer or team handle is confirmed.
- Replace the placeholder owner with an actual GitHub user or team before relying on branch protection.

## What to watch

- Any future gameplay PR that touches node paths, scene resources, signals, or autoloads should be treated as high risk until validated in Godot.
- If a future run changes the Discord webhook name or routing, update `AGENTS.md`, this file, and the workflow together so the repo keeps one canonical secret name.
