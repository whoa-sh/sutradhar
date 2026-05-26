param(
    [Parameter(Mandatory = $true)]
    [string]$Version
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $root
try {
    & .\scripts\release-preflight.ps1 -Version $Version
    if ($LASTEXITCODE -ne 0) { throw "release-preflight failed: $LASTEXITCODE" }

    if (-not (Get-Command buf -ErrorAction SilentlyContinue)) {
        throw "buf CLI is required for release checks."
    }
    & buf lint
    if ($LASTEXITCODE -ne 0) { throw "buf lint failed: $LASTEXITCODE" }
    & buf generate
    if ($LASTEXITCODE -ne 0) { throw "buf generate failed: $LASTEXITCODE" }
    & git diff --exit-code -- packages/go packages/typescript/src/generated
    if ($LASTEXITCODE -ne 0) { throw "generated output drift detected" }

    & .\scripts\verify.ps1
    if ($LASTEXITCODE -ne 0) { throw "verify failed: $LASTEXITCODE" }
    Write-Host "[ok] release-check completed"
} finally {
    Pop-Location
}
