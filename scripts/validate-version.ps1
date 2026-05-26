param(
    [Parameter(Mandatory = $true)]
    [string]$Version
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($Version -notmatch '^v\d+\.\d+\.\d+$') {
    throw "Version must match vX.Y.Z. Got: $Version"
}

$normalized = $Version.Substring(1)
$gradleContent = Get-Content "build.gradle.kts" -Raw
if ($gradleContent -match '(?m)^\s*version\s*=\s*"([^"]+)"') {
    $gradleVersion = $Matches[1]
} else {
    throw "Could not find version in build.gradle.kts"
}
$npmVersion = (Get-Content "packages/typescript/package.json" -Raw | ConvertFrom-Json).version

if ($gradleVersion -ne $normalized) {
    throw "Gradle version mismatch: expected $normalized, found $gradleVersion"
}
if ($npmVersion -ne $normalized) {
    throw "NPM version mismatch: expected $normalized, found $npmVersion"
}
Write-Host "[ok] committed versions match $normalized"
