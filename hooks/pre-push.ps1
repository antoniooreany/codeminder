. "$PSScriptRoot\shared.ps1"

Write-Section "Codeminder pre-push"

$repoRoot = Get-RepoRoot
Set-Location $repoRoot

$localCm = Join-Path $repoRoot "bin\cm.cmd"

if (Test-Path $localCm) {
    Write-Section "Codeminder pre-push checks"
    Write-Host "Running: cm doctor"
    & $localCm doctor
    if ($LASTEXITCODE -ne 0) {
        Exit-Failed "cm doctor failed."
    }

    Write-Status "WARN" "Test automation is not implemented yet in this skeleton."
    Exit-Succeeded "pre-push checks passed."
} else {
    Write-Status "WARN" "Local cm launcher not found. Skipping Codeminder pre-push checks."
    Exit-Succeeded "pre-push completed with warnings."
}