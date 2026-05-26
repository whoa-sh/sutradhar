#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  echo "Usage: scripts/release-check.sh vX.Y.Z" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

./scripts/release-preflight.sh "$VERSION"

if command -v buf >/dev/null 2>&1; then
  echo "[run] buf lint"
  buf lint
  echo "[run] buf generate + freshness check"
  buf generate
  git diff --exit-code -- packages/go packages/typescript/src/generated
fi

echo "[run] verify"
./scripts/verify.sh
echo "[ok] release-check completed"
