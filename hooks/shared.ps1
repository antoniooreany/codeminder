$ErrorActionPreference = "Stop"

function Write-Section($Title) {
    Write-Host ""
    Write-Host "== $Title ==" -ForegroundColor Cyan
}

function Write-Status($Status, $Message) {
    switch ($Status) {
        "AUTO_FIXED" {
            Write-Host "[AUTO_FIXED] $Message" -ForegroundColor Green
        }
        "WARN" {
            Write-Host "[WARN] $Message" -ForegroundColor Yellow
        }
        "MANUAL_REVIEW_REQUIRED" {
            Write-Host "[MANUAL_REVIEW_REQUIRED] $Message" -ForegroundColor Red
        }
        default {
            Write-Host "[$Status] $Message"
        }
    }
}

function Exit-Failed($Message) {
    Write-Host "ERROR: $Message" -ForegroundColor Red
    exit 1
}

function Exit-Succeeded($Message) {
    Write-Host $Message -ForegroundColor Green
    exit 0
}

function Test-Command($CommandName) {
    return [bool](Get-Command $CommandName -ErrorAction SilentlyContinue)
}

function Get-RepoRoot {
    $root = git rev-parse --show-toplevel 2>$null
    if (-not $root) {
        Exit-Failed "Could not determine repository root."
    }
    return $root.Trim()
}

function Get-StagedFiles {
    $files = git diff --cached --name-only --diff-filter=ACMR
    return @($files | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}