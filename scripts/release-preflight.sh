#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
  echo "Usage: scripts/release-preflight.sh vX.Y.Z" >&2
  exit 1
fi

if [[ ! "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Version must match vX.Y.Z. Got: $VERSION" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "Release preflight for $VERSION"
echo "[ok] version format"

if ! command -v git >/dev/null 2>&1; then
  echo "git is required for release preflight." >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree is not clean. Commit or stash changes before release." >&2
  exit 1
fi
echo "[ok] clean working tree"

if git tag --list "$VERSION" | grep -qx "$VERSION"; then
  echo "Tag already exists: $VERSION" >&2
  exit 1
fi
echo "[ok] tag does not exist"

if [[ -f "buf.yaml" ]] && ! command -v buf >/dev/null 2>&1; then
  echo "buf.yaml exists but buf CLI is missing." >&2
  exit 1
fi
echo "[ok] tooling baseline"

echo "Preflight passed."
