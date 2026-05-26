#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

required_readme_terms=(
  "make verify"
  "make prototype"
  "scripts/verify.sh"
  "scripts/release-preflight.sh"
)

required_scripts_readme_terms=(
  "verify.ps1"
  "verify.sh"
  "release-preflight.ps1"
  "release-preflight.sh"
)

for term in "${required_readme_terms[@]}"; do
  if ! grep -Fq "$term" README.md; then
    echo "[fail] README.md missing expected term: $term" >&2
    exit 1
  fi
done

for term in "${required_scripts_readme_terms[@]}"; do
  if ! grep -Fq "$term" scripts/README.md; then
    echo "[fail] scripts/README.md missing expected term: $term" >&2
    exit 1
  fi
done

echo "[ok] documentation freshness checks passed"
