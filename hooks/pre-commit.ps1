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

if (Test-Path (Join-Path $repoRoot "README.md")) {
    Write-Status "WARN" "Docs automation is not implemented yet in this skeleton."
}

$exceptionRelated = $stagedFiles | Where-Object {
    $_ -match '\.(py|ps1|ts|tsx|js|jsx|cs|java|go)$'
}

if ($exceptionRelated.Count -gt 0) {
    foreach ($file in $exceptionRelated) {
        $fullPath = Join-Path $repoRoot $file
        if (Test-Path $fullPath) {
            $content = Get-Content $fullPath -Raw

            $hasCatch = $content -match '\bcatch\b' -or $content -match '\bexcept\b'
            $hasLog = $content -match 'logger\.' -or $content -match 'Write-Error' -or $content -match 'console\.error'
            $hasRaiseOrThrow = $content -match '\braise\b' -or $content -match '\bthrow\b'

            if ($hasCatch -and $hasRaiseOrThrow -and -not $hasLog) {
                Write-Host ""
                Write-Host "[CODEMINDER][MANUAL_REVIEW_REQUIRED]" -ForegroundColor Red
                Write-Host "Rule: require-exception-policy"
                Write-Host "File: $file"
                Write-Host "Reason: detected a potentially unsafe block without an explicit exception strategy"
                Write-Host "Why not auto-fix: cannot safely decide between wrap/rethrow/domain-specific exception"
                Write-Host "Required action:"
                Write-Host "  1. Choose the appropriate exception type manually"
                Write-Host "  2. Add a contextual log before the rethrow/wrap"
                Write-Host "  3. Retry the commit"
                Write-Host ""
                Write-Host "Suggested template:"
                Write-Host '  except ExternalApiError as e:'
                Write-Host '      logger.exception("Payment sync failed", extra={"order_id": order_id})'
                Write-Host '      raise PaymentSyncError(order_id) from e'
                exit 1
            }
        }
    }
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