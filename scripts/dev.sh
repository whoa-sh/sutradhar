#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "Sutradhar dev bootstrap"
echo "Root: $ROOT"

if [[ -f "README.md" ]]; then
  echo "[ok] README found"
else
  echo "[warn] README missing"
fi

if command -v rg >/dev/null 2>&1; then
  echo "[ok] rg available"
else
  echo "[warn] rg not found"
fi

if command -v git >/dev/null 2>&1; then
  echo "[ok] git available"
  git status --short --branch || true
else
  echo "[warn] git not found"
fi

cat <<'NEXT'

Next:
1. Run make verify or make -f Makefile.windows verify
2. Add Buf and contract manifests before proto generation work
3. Keep generated outputs reproducible and checked by local verification
NEXT
