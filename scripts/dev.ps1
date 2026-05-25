param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Sutradhar dev bootstrap"
Write-Host "Root: $PSScriptRoot\.."

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $root
try {
    if (Test-Path "README.md") {
        Write-Host "[ok] README found"
    } else {
        Write-Host "[warn] README missing"
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
    Write-Host "1) Run make verify or make -f Makefile.windows verify"
    Write-Host "2) Add Buf and contract manifests before proto generation work"
    Write-Host "3) Keep generated outputs reproducible and checked by local verification"
} finally {
    Pop-Location
}
