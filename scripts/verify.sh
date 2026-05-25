#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "Running local verification checks..."

required_files=(
  ".agents/plans/sutradhar-grill-decision-log.md"
  ".agents/plans/sutradhar-comprehensive-implementation-plan.md"
  ".agents/tracker.md"
  "AGENTS.md"
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
    echo "[run] ./gradlew --no-daemon tasks"
    ./gradlew --no-daemon tasks >/dev/null
    echo "[ok] Gradle wrapper execution"
  elif [[ -f "./gradlew" ]]; then
    echo "[run] bash ./gradlew --no-daemon tasks"
    bash ./gradlew --no-daemon tasks >/dev/null
    echo "[ok] Gradle wrapper execution"
  else
    echo "[warn] build.gradle.kts exists but gradlew missing"
  fi
else
  echo "[skip] Gradle checks (build not scaffolded yet)"
fi

echo "Verification completed."
