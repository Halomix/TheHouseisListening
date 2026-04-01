$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$requiredFiles = @(
    "AGENTS.md",
    ".codex/config.toml",
    "CURRENT_MILESTONE.md",
    "NEXT_TASKS.md",
    "KNOWN_ISSUES.md",
    "REVIEW_GUIDANCE.md",
    "PLAYTEST_NOTES.md",
    "CODEOWNERS",
    "project.godot",
    "README_PATCH_7.md"
)

$requiredWorkflow = ".github/workflows/bootstrap-validation.yml"

Write-Host "Validating bootstrap files in $root"

foreach ($relativePath in $requiredFiles) {
    $fullPath = Join-Path $root $relativePath
    if (-not (Test-Path $fullPath)) {
        throw "Missing required bootstrap file: $relativePath"
    }
}

if (-not (Test-Path (Join-Path $root $requiredWorkflow))) {
    throw "Missing required workflow file: $requiredWorkflow"
}

$milestone = Get-Content -Raw (Join-Path $root "CURRENT_MILESTONE.md")
$nextTasks = Get-Content -Raw (Join-Path $root "NEXT_TASKS.md")
$issues = Get-Content -Raw (Join-Path $root "KNOWN_ISSUES.md")

if ($milestone -notmatch "Status") {
    throw "CURRENT_MILESTONE.md does not include a Status section."
}

if ($nextTasks -notmatch "Add a real Godot headless smoke test to CI") {
    throw "NEXT_TASKS.md does not include the CI follow-up task."
}

if ($issues -notmatch "Discord connector") {
    throw "KNOWN_ISSUES.md does not record the missing Discord connector path."
}

Write-Host "Bootstrap validation passed."
