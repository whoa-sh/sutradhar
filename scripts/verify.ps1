param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $root
try {
    Write-Host "Running local verification checks..."

    $checks = @(
        "README.md",
        "LICENSE.txt",
        "NOTICE",
        "Makefile",
        "Makefile.windows",
        "scripts\README.md"
    )

    foreach ($path in $checks) {
        if (-not (Test-Path $path)) {
            throw "[fail] Missing required file: $path`n[fail] remediation: restore the missing repository file before running verify."
        }
        Write-Host "[ok] $path"
    }

    if (Test-Path "buf.yaml") {
        if (-not (Get-Command buf -ErrorAction SilentlyContinue)) {
            throw "[fail] buf.yaml exists but `buf` CLI is not available.`n[fail] remediation: install buf and ensure it is on PATH."
        }
        Write-Host "[run] buf lint"
        & buf lint
        if ($LASTEXITCODE -ne 0) { throw "buf lint failed with exit code $LASTEXITCODE" }
    } else {
        Write-Host "[skip] buf lint (buf.yaml not present yet)"
    }

    if ((Test-Path "build.gradle.kts") -and (Test-Path "gradlew.bat")) {
        Write-Host "[run] .\gradlew.bat --no-daemon clean test --tests sh.whoa.sutradhar.sdk.v1.ValidationParityTest"
        & .\gradlew.bat --no-daemon clean test --tests sh.whoa.sutradhar.sdk.v1.ValidationParityTest
        if ($LASTEXITCODE -ne 0) { throw "gradlew test failed with exit code $LASTEXITCODE" }
        Write-Host "[ok] JVM parity test"
    } else {
        Write-Host "[skip] Gradle checks (build not scaffolded yet)"
    }

    if ((Get-Command node -ErrorAction SilentlyContinue) -and (Test-Path "packages/typescript/src/sdk/parity.test.mjs")) {
        Write-Host "[run] node --test src/sdk/parity.test.mjs"
        Push-Location "packages/typescript"
        try {
            & node --test src/sdk/parity.test.mjs
            if ($LASTEXITCODE -ne 0) { throw "TypeScript parity test failed with exit code $LASTEXITCODE" }
            Write-Host "[ok] TypeScript parity test"
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "[skip] TypeScript parity test (node or test file missing)"
    }
    if ((Get-Command node -ErrorAction SilentlyContinue) -and (Test-Path "packages/typescript/src/sdk/upgrade-parity.test.mjs")) {
        Write-Host "[run] node --test src/sdk/upgrade-parity.test.mjs"
        Push-Location "packages/typescript"
        try {
            & node --test src/sdk/upgrade-parity.test.mjs
            if ($LASTEXITCODE -ne 0) { throw "TypeScript upgrade parity failed with exit code $LASTEXITCODE" }
            Write-Host "[ok] TypeScript upgrade parity test"
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "[skip] TypeScript upgrade parity test (node or test file missing)"
    }

    if ((Get-Command go -ErrorAction SilentlyContinue) -and (Test-Path "packages/go/sh/whoa/sutradhar/sdk/v1/parity_test.go")) {
        Write-Host "[run] go test ./sh/whoa/sutradhar/sdk/v1"
        Push-Location "packages/go"
        try {
            & go test ./sh/whoa/sutradhar/sdk/v1
            if ($LASTEXITCODE -ne 0) { throw "Go parity test failed with exit code $LASTEXITCODE" }
            Write-Host "[ok] Go parity test"
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "[skip] Go parity test (go or test file missing)"
    }

    Write-Host "[run] .\scripts\smoke-examples.ps1"
    & .\scripts\smoke-examples.ps1
    if ($LASTEXITCODE -ne 0) { throw "example smoke checks failed with exit code $LASTEXITCODE" }

    Write-Host "[ok] verification completed"
} finally {
    Pop-Location
}
