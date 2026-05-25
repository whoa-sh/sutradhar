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

    $releaseVersion = $Version.Substring(1)
    $gradleVersionLine = (Get-Content build.gradle.kts | Select-String -Pattern '^\s*version\s*=' | Select-Object -First 1).Line
    $gradleVersion = [regex]::Match($gradleVersionLine, '"([^"]+)"').Groups[1].Value
    $npmPackage = Get-Content packages/typescript/package.json -Raw | ConvertFrom-Json
    $npmVersion = $npmPackage.version

    if ($gradleVersion -ne $releaseVersion -or $npmVersion -ne $releaseVersion) {
        throw "Committed versions do not match release version $releaseVersion."
    }
    Write-Host "[ok] committed versions match release input"

    $mavenMetadataUrl = $env:MAVEN_METADATA_URL
    if ($mavenMetadataUrl) {
        $headers = @{}
        if ($env:GITHUB_TOKEN) {
            $headers["Authorization"] = "Bearer $($env:GITHUB_TOKEN)"
        }
        $metadata = Invoke-WebRequest -Uri $mavenMetadataUrl -Headers $headers -UseBasicParsing
        if ($metadata.Content -match "<version>$releaseVersion</version>") {
            throw "Maven version already exists in registry: $releaseVersion"
        }
        Write-Host "[ok] Maven registry version does not exist"
    }

    $npmPackageName = $env:NPM_PACKAGE_NAME
    if ($npmPackageName) {
        & npm view "$npmPackageName@$releaseVersion" version *> $null
        if ($LASTEXITCODE -eq 0) {
            throw "NPM version already exists in registry: $npmPackageName@$releaseVersion"
        }
        Write-Host "[ok] NPM registry version does not exist"
    }

    Write-Host "Preflight passed."
} finally {
    Pop-Location
}
