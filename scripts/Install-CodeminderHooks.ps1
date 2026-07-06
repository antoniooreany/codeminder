param(
    [ValidateSet("hookspath","dotgit")]
    [string]$Mode = "hookspath"
)

$ErrorActionPreference = "Stop"

function Write-Info($Message) {
    Write-Host $Message -ForegroundColor Cyan
}

function Write-ErrMsg($Message) {
    Write-Host "ERROR: $Message" -ForegroundColor Red
    exit 1
}

$repoRoot = git rev-parse --show-toplevel 2>$null
if (-not $repoRoot) {
    Write-ErrMsg "Run this script from inside a git repository."
}
$repoRoot = $repoRoot.Trim()

$hooksDir = Join-Path $repoRoot "hooks"
if (-not (Test-Path $hooksDir)) {
    Write-ErrMsg "hooks directory not found: $hooksDir"
}

if ($Mode -eq "hookspath") {
    git config core.hooksPath hooks
    Write-Info "Configured repository hooks path: hooks"
    Write-Info "Git will now use versioned hooks from the repository."
    exit 0
}

if ($Mode -eq "dotgit") {
    $gitHooksDir = Join-Path $repoRoot ".git\hooks"
    if (-not (Test-Path $gitHooksDir)) {
        Write-ErrMsg ".git\hooks directory not found."
    }

    Copy-Item (Join-Path $hooksDir "pre-commit") (Join-Path $gitHooksDir "pre-commit") -Force
    Copy-Item (Join-Path $hooksDir "pre-push") (Join-Path $gitHooksDir "pre-push") -Force

    Write-Info "Copied pre-commit and pre-push hook launchers into .git\hooks"
    Write-Info "PowerShell hook logic remains in the repository hooks folder."
    exit 0
}