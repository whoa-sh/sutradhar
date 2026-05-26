#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  echo "[fail] Usage: scripts/release-check.sh vX.Y.Z" >&2
  echo "[fail] remediation: pass an immutable release tag input, for example v0.1.0." >&2
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

./scripts/release-preflight.sh "$VERSION"

if ! command -v buf >/dev/null 2>&1; then
  echo "[fail] buf CLI is required for release checks." >&2
  echo "[fail] remediation: install buf and ensure it is on PATH." >&2
  exit 1
fi

for cmd in node go java; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[fail] $cmd is required for full release validation." >&2
    echo "[fail] remediation: install $cmd and ensure it is on PATH to avoid silently skipping parity tests." >&2
    exit 1
  fi
done

echo "[run] buf lint"
buf lint
echo "[run] buf generate + freshness check"
buf generate
git diff --exit-code -- packages/go packages/typescript/src/generated

echo "[run] verify"
./scripts/verify.sh
echo "[ok] release-check completed"
