# Patch 10 Notes

## Summary

Added GitHub Actions Discord notifications for pull request opened, synchronize, and closed events.

## Discord secret name

- Canonical secret name: `DISCORD_WEBHOOK_URL`
- No existing Discord workflow or alternate secret name was present in the repo, so this branch standardized on that name.

## Validation

- Confirmed the repository had no existing Discord workflow or webhook secret name in docs/config/comments.
- Ran `git diff --check`.
- Parsed the new workflow file as YAML locally.

## Watch-outs

- The workflow is intentionally a no-op until the `DISCORD_WEBHOOK_URL` secret is added in GitHub repository settings.
- If the secret name ever changes, update the workflow and the repo brain docs together.
