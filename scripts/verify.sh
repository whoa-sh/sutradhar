#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "Running local verification checks..."

required_files=(
  "README.md"
  "LICENSE.txt"
  "NOTICE"
  "Makefile"
  "Makefile.windows"
  "scripts/README.md"
)

for path in "${required_files[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "Missing required file: $path" >&2
    exit 1
  fi
  echo "[ok] $path"
done

if [[ -f "buf.yaml" ]]; then
  if ! command -v buf >/dev/null 2>&1; then
    echo "buf.yaml exists but buf CLI is not available." >&2
    exit 1
  fi
  echo "[run] buf lint"
  buf lint
else
  echo "[skip] buf lint (buf.yaml not present yet)"
fi

if [[ -f "build.gradle.kts" ]]; then
  if [[ -x "./gradlew" ]]; then
    echo "[run] ./gradlew --no-daemon clean test --tests sh.whoa.sutradhar.sdk.v1.ValidationParityTest"
    ./gradlew --no-daemon clean test --tests sh.whoa.sutradhar.sdk.v1.ValidationParityTest >/dev/null
    echo "[ok] JVM parity test"
  elif [[ -f "./gradlew" ]]; then
    echo "[run] bash ./gradlew --no-daemon clean test --tests sh.whoa.sutradhar.sdk.v1.ValidationParityTest"
    bash ./gradlew --no-daemon clean test --tests sh.whoa.sutradhar.sdk.v1.ValidationParityTest >/dev/null
    echo "[ok] JVM parity test"
  else
    echo "[warn] build.gradle.kts exists but gradlew missing"
  fi
else
  echo "[skip] Gradle checks (build not scaffolded yet)"
fi

if command -v node >/dev/null 2>&1 && [[ -f "packages/typescript/src/sdk/parity.test.mjs" ]]; then
  echo "[run] node --test src/sdk/parity.test.mjs"
  (cd packages/typescript && node --test src/sdk/parity.test.mjs)
  echo "[ok] TypeScript parity test"
else
  echo "[skip] TypeScript parity test (node or test file missing)"
fi

if command -v node >/dev/null 2>&1 && [[ -f "packages/typescript/src/sdk/upgrade-parity.test.mjs" ]]; then
  echo "[run] node --test src/sdk/upgrade-parity.test.mjs"
  (cd packages/typescript && node --test src/sdk/upgrade-parity.test.mjs)
  echo "[ok] TypeScript upgrade parity test"
else
  echo "[skip] TypeScript upgrade parity test (node or test file missing)"
fi

if command -v go >/dev/null 2>&1 && [[ -f "packages/go/sh/whoa/sutradhar/sdk/v1/parity_test.go" ]]; then
  echo "[run] go test ./sh/whoa/sutradhar/sdk/v1"
  (cd packages/go && go test ./sh/whoa/sutradhar/sdk/v1)
  echo "[ok] Go parity test"
else
  echo "[skip] Go parity test (go or test file missing)"
fi

if command -v node >/dev/null 2>&1 && command -v go >/dev/null 2>&1 && [[ -f "./gradlew" ]]; then
  echo "[run] ./scripts/smoke-examples.sh"
  ./scripts/smoke-examples.sh
else
  echo "[skip] example smoke checks (toolchain missing)"
fi

echo "Verification completed."
