param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Sutradhar dev bootstrap"
Write-Host "Root: $PSScriptRoot\.."

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $root
try {
    if (Test-Path ".agents\plans\sutradhar-grill-decision-log.md") {
        Write-Host "[ok] decision log found"
    } else {
        Write-Host "[warn] decision log missing"
    }

    if (Get-Command rg -ErrorAction SilentlyContinue) {
        Write-Host "[ok] rg available"
    } else {
        Write-Host "[warn] rg not found"
    }

    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Host "[ok] git available"
        git status --short --branch
    } else {
        Write-Host "[warn] git not found"
    }

    Write-Host ""
    Write-Host "Next:"
    Write-Host "1) Read .agents/plans/sutradhar-grill-decision-log.md"
    Write-Host "2) Read .agents/plans/sutradhar-comprehensive-implementation-plan.md"
    Write-Host "3) Update .agents/tracker.md item to IN_PROGRESS before changes"
} finally {
    Pop-Location
}
