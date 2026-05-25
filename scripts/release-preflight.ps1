param(
    [Parameter(Mandatory = $true)]
    [string]$Version
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-TagFormat {
    param([string]$Value)
    if ($Value -notmatch '^v\d+\.\d+\.\d+$') {
        throw "Version must match vX.Y.Z. Got: $Value"
    }
}

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $root
try {
    Write-Host "Release preflight for $Version"
    Assert-TagFormat -Value $Version
    Write-Host "[ok] version format"

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw "git is required for release preflight."
    }

    $status = git status --porcelain
    if ($status) {
        throw "Working tree is not clean. Commit or stash changes before release."
    }
    Write-Host "[ok] clean working tree"

    $tagExists = git tag --list $Version
    if ($tagExists) {
        throw "Tag already exists: $Version"
    }
    Write-Host "[ok] tag does not exist"

    if (Test-Path "buf.yaml" -and -not (Get-Command buf -ErrorAction SilentlyContinue)) {
        throw "buf.yaml exists but buf CLI is missing."
    }
    Write-Host "[ok] tooling baseline"

    Write-Host "Preflight passed."
} finally {
    Pop-Location
}
