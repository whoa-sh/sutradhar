#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "Sutradhar dev bootstrap"
echo "Root: $ROOT"

if [[ -f ".agents/plans/sutradhar-grill-decision-log.md" ]]; then
  echo "[ok] decision log found"
else
  echo "[warn] decision log missing"
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
1. Read .agents/plans/sutradhar-grill-decision-log.md
2. Read .agents/plans/sutradhar-comprehensive-implementation-plan.md
3. Update .agents/tracker.md item to IN_PROGRESS before changes
NEXT
