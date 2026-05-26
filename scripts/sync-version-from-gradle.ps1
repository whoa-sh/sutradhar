param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $root
try {
    $gradleContent = Get-Content "build.gradle.kts" -Raw
    if ($gradleContent -match '(?m)^\s*version\s*=\s*"([^"]+)"') {
        $gradleVersion = $Matches[1]
    } else {
        throw "[fail] Could not find version in build.gradle.kts`n[fail] remediation: define root project version in build.gradle.kts as version = ""X.Y.Z""."
    }

    $packagePath = "packages/typescript/package.json"
    $packageJson = Get-Content $packagePath -Raw | ConvertFrom-Json
    $packageJson.version = $gradleVersion
    $packageJson | ConvertTo-Json -Depth 10 | Set-Content $packagePath

    Write-Host "[ok] packages/typescript/package.json version set to $gradleVersion"
} finally {
    Pop-Location
}
