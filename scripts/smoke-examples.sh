#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "[run] JVM example"
if [[ -f "./gradlew" ]]; then
  if [[ -x "./gradlew" ]]; then
    ./gradlew --no-daemon -q runM11JvmExample
  else
    bash ./gradlew --no-daemon -q runM11JvmExample
  fi
else
  echo "[skip] JVM example (gradlew missing)"
fi

echo "[run] TypeScript example"
if command -v node >/dev/null 2>&1; then
  node examples/typescript/consumer-example.mjs
else
  echo "[skip] TypeScript example (node missing)"
fi

echo "[run] Go example"
if command -v go >/dev/null 2>&1; then
  (cd packages/go && go run ./examples/m11)
else
  echo "[skip] Go example (go missing)"
fi

echo "[ok] example smoke checks"
