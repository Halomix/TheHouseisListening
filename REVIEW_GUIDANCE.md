# Review Guidance

Use this as the default review lens for Codex and human reviewers.

## Priority order

1. Startup failures, broken scenes, missing resources, and crashes.
2. Softlocks, broken interactions, or progression blockers.
3. Enemy logic that removes tension or consequence.
4. HUD, prompt, and objective regressions.
5. Audio or pacing changes that weaken the horror loop.
6. Maintainability, docs, and automation improvements.

## What to verify on every gameplay PR

- `project.godot` still points at the intended entry scene.
- Scene and script paths still match.
- Exported variables still exist and still bind correctly.
- Signals still connect to live nodes.
- Interaction prompts still appear at the right times.
- Threat and tension changes still produce readable consequences.
- Any new memory or director logic still preserves the explore -> interpret -> risk -> consequence loop.

## Evidence expectations

- Prefer real validation over reasoning alone.
- Capture command output, editor logs, screenshots, or playtest notes when possible.
- If a check cannot be run, explain exactly why and record the missing step in `KNOWN_ISSUES.md`.

## Review style

- Keep findings specific.
- State the file and the exact failure mode.
- Separate real bugs from polish suggestions.
- If nothing is broken, say so clearly and mention any remaining validation gaps.
