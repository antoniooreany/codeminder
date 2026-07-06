. "$PSScriptRoot\shared.ps1"

Write-Section "Codeminder pre-commit"

$repoRoot = Get-RepoRoot
Set-Location $repoRoot

$stagedFiles = Get-StagedFiles
if ($stagedFiles.Count -eq 0) {
    Exit-Succeeded "No staged files. Skipping pre-commit checks."
}

Write-Host "Staged files:"
$stagedFiles | ForEach-Object { Write-Host "  - $_" }

$policyFile = Join-Path $repoRoot "automation-policy.yaml"
if (-not (Test-Path $policyFile)) {
    Write-Status "WARN" "automation-policy.yaml not found. Proceeding with default behavior."
}

$localCm = Join-Path $repoRoot "bin\cm.cmd"
if (Test-Path $localCm) {
    Write-Section "Codeminder local checks"
    & $localCm doctor
    if ($LASTEXITCODE -ne 0) {
        Exit-Failed "cm doctor failed."
    }
}

Exit-Succeeded "pre-commit checks passed."