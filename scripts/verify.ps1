param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $root
try {
    Write-Host "Running local verification checks..."

    $checks = @(
        ".agents\plans\sutradhar-grill-decision-log.md",
        ".agents\plans\sutradhar-comprehensive-implementation-plan.md",
        ".agents\tracker.md",
        "AGENTS.md"
    )

    foreach ($path in $checks) {
        if (-not (Test-Path $path)) {
            throw "Missing required file: $path"
        }
        Write-Host "[ok] $path"
    }

    if (Test-Path "buf.yaml") {
        if (-not (Get-Command buf -ErrorAction SilentlyContinue)) {
            throw "buf.yaml exists but `buf` CLI is not available."
        }
        Write-Host "[run] buf lint"
        & buf lint
    } else {
        Write-Host "[skip] buf lint (buf.yaml not present yet)"
    }

    if (Test-Path "build.gradle.kts") {
        if (Test-Path "gradlew.bat") {
            Write-Host "[run] .\gradlew.bat --no-daemon tasks"
            & .\gradlew.bat --no-daemon tasks | Out-Null
            Write-Host "[ok] Gradle wrapper execution"
        } else {
            Write-Host "[warn] build.gradle.kts exists but gradlew.bat missing"
        }
    } else {
        Write-Host "[skip] Gradle checks (build not scaffolded yet)"
    }

    Write-Host "Verification completed."
} finally {
    Pop-Location
}
