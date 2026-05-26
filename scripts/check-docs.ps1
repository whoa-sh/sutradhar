param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $root
try {
    $requiredReadmeTerms = @(
        "make verify",
        "make docs-check",
        "make suite-local",
        "make release-check VERSION=vX.Y.Z",
        "make -f Makefile.windows verify",
        "make -f Makefile.windows docs-check",
        "make -f Makefile.windows suite-local",
        "make -f Makefile.windows release-check VERSION=vX.Y.Z",
        "make prototype",
        "scripts/verify.sh",
        "scripts/release-preflight.sh"
    )
    $requiredScriptsReadmeTerms = @(
        "verify.ps1",
        "verify.sh",
        "release-preflight.ps1",
        "release-preflight.sh",
        "release-check.ps1",
        "release-check.sh",
        "check-docs.ps1",
        "check-docs.sh"
    )

    function Fail-DocsCheck([string]$Message) {
        throw "[fail] $Message`n[fail] remediation: update README.md and scripts/README.md so command/workflow docs match current repository behavior."
    }

    $readme = Get-Content README.md -Raw
    foreach ($term in $requiredReadmeTerms) {
        if (-not $readme.Contains($term)) {
            Fail-DocsCheck "README.md missing expected term: $term"
        }
    }

    $scriptsReadme = Get-Content scripts\README.md -Raw
    foreach ($term in $requiredScriptsReadmeTerms) {
        if (-not $scriptsReadme.Contains($term)) {
            Fail-DocsCheck "scripts/README.md missing expected term: $term"
        }
    }

    Write-Host "[ok] documentation freshness checks passed"
} finally {
    Pop-Location
}
