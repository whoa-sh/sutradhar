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

    $packagePath = Join-Path $root "packages/typescript/package.json"
    $content = Get-Content $packagePath -Raw
    if ($content -match '"version"\s*:\s*"[^"]+"') {
        $updated = $content -replace '"version"\s*:\s*"[^"]+"', ('"version": "' + $gradleVersion + '"')
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($packagePath, $updated, $utf8NoBom)
        Write-Host "[ok] packages/typescript/package.json version set to $gradleVersion"
    } else {
        throw "[fail] Could not find version field in packages/typescript/package.json"
    }
} finally {
    Pop-Location
}
