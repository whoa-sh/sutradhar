#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

required_readme_terms=(
  "make verify"
  "make docs-check"
  "make suite-local"
  "make release-check VERSION=vX.Y.Z"
  "make -f Makefile.windows verify"
  "make -f Makefile.windows docs-check"
  "make -f Makefile.windows suite-local"
  "make -f Makefile.windows release-check VERSION=vX.Y.Z"
  "make prototype"
  "scripts/verify.sh"
  "scripts/release-preflight.sh"
)

required_scripts_readme_terms=(
  "verify.ps1"
  "verify.sh"
  "release-preflight.ps1"
  "release-preflight.sh"
  "release-check.ps1"
  "release-check.sh"
  "check-docs.ps1"
  "check-docs.sh"
)

fail() {
  local msg="$1"
  echo "[fail] $msg" >&2
  echo "[fail] remediation: update README.md and scripts/README.md so command/workflow docs match current repository behavior." >&2
  exit 1
}

for term in "${required_readme_terms[@]}"; do
  if ! grep -Fq "$term" README.md; then
    fail "README.md missing expected term: $term"
  fi
done

for term in "${required_scripts_readme_terms[@]}"; do
  if ! grep -Fq "$term" scripts/README.md; then
    fail "scripts/README.md missing expected term: $term"
  fi
done

echo "[ok] documentation freshness checks passed"
