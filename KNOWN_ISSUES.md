# Known Issues

## Repository setup

- This snapshot did not include a visible Git root when the bootstrap work started, so the repo still needs a real GitHub remote before Codex can push `codex/bootstrap-autonomy` and open a PR.
- The repository does not currently expose a Discord connector in this environment, so automated Discord status updates still need an external webhook or connector setup.
- `gh` is present but not authenticated here, and there is no `GH_TOKEN` or `GITHUB_TOKEN`, so PR creation is blocked until GitHub auth is supplied.

## Validation

- Full Godot headless validation is not yet wired to a guaranteed CI runner in this repo.
- The bootstrap workflow currently validates repository continuity files and local scripts, but it is not a substitute for a real scene-load smoke test.
- Patch 8 needs a real Godot launch check once the gameplay slice is finalized.

## Ownership metadata

- `CODEOWNERS` is intentionally conservative until a real maintainer or team handle is confirmed.
- Replace the placeholder owner with an actual GitHub user or team before relying on branch protection.

## What to watch

- Any future gameplay PR that touches node paths, scene resources, signals, or autoloads should be treated as high risk until validated in Godot.
- If a future run adds a proper Git remote or Discord integration, this file should be updated with the exact setup steps that were used.
