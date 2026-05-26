param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $root
try {
    $requiredReadmeTerms = @(
        "make verify",
        "make prototype",
        "scripts/verify.sh",
        "scripts/release-preflight.sh"
    )
    $requiredScriptsReadmeTerms = @(
        "verify.ps1",
        "verify.sh",
        "release-preflight.ps1",
        "release-preflight.sh"
    )

    $readme = Get-Content README.md -Raw
    foreach ($term in $requiredReadmeTerms) {
        if (-not $readme.Contains($term)) {
            throw "[fail] README.md missing expected term: $term"
        }
    }

    $scriptsReadme = Get-Content scripts\README.md -Raw
    foreach ($term in $requiredScriptsReadmeTerms) {
        if (-not $scriptsReadme.Contains($term)) {
            throw "[fail] scripts/README.md missing expected term: $term"
        }
    }

    Write-Host "[ok] documentation freshness checks passed"
} finally {
    Pop-Location
}
