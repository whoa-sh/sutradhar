#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "[run] JVM example"
if [[ -x "./gradlew" ]]; then
  ./gradlew --no-daemon -q runM11JvmExample
else
  bash ./gradlew --no-daemon -q runM11JvmExample
fi

echo "[run] TypeScript example"
node examples/typescript/consumer-example.mjs

echo "[run] Go example"
(cd examples/go && go run .)

echo "[ok] example smoke checks"
