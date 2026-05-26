#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

GRADLE_VERSION="$(sed -nE 's/^[[:space:]]*version[[:space:]]*=[[:space:]]*"([^"]+)".*$/\1/p' build.gradle.kts | head -n1)"
if [[ -z "$GRADLE_VERSION" ]]; then
  echo "[fail] Could not find version in build.gradle.kts" >&2
  echo "[fail] remediation: define root project version in build.gradle.kts as version = \"X.Y.Z\"." >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "[fail] node is required to update packages/typescript/package.json safely." >&2
  echo "[fail] remediation: install Node.js and ensure it is on PATH." >&2
  exit 1
fi

echo "[run] sync package.json version from Gradle version $GRADLE_VERSION"
node -e "const fs=require('fs'); const p='packages/typescript/package.json'; const j=JSON.parse(fs.readFileSync(p,'utf8')); j.version='${GRADLE_VERSION}'; fs.writeFileSync(p, JSON.stringify(j,null,2)+'\n');"
echo "[ok] packages/typescript/package.json version set to $GRADLE_VERSION"
