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
$gradleLine = Select-String -Path "build.gradle.kts" -Pattern '^version = "(.+)"$'
$gradleVersion = $gradleLine.Matches[0].Groups[1].Value
$npmVersion = node -p "require('./packages/typescript/package.json').version"

if ($gradleVersion -ne $normalized) {
    throw "Gradle version mismatch: expected $normalized, found $gradleVersion"
}
if ($npmVersion -ne $normalized) {
    throw "NPM version mismatch: expected $normalized, found $npmVersion"
}
Write-Host "[ok] committed versions match $normalized"
