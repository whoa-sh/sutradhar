param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $root
try {
    Write-Host "[run] JVM example"
    & .\gradlew.bat --no-daemon -q runM11JvmExample
    if ($LASTEXITCODE -ne 0) { throw "JVM example failed with $LASTEXITCODE" }

    Write-Host "[run] TypeScript example"
    & node examples\typescript\consumer-example.mjs
    if ($LASTEXITCODE -ne 0) { throw "TypeScript example failed with $LASTEXITCODE" }

    Write-Host "[run] Go example"
    Push-Location examples\go
    try {
        & go run .
        if ($LASTEXITCODE -ne 0) { throw "Go example failed with $LASTEXITCODE" }
    } finally {
        Pop-Location
    }

    Write-Host "[ok] example smoke checks"
} finally {
    Pop-Location
}
