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

MAVEN_VERSION="${VERSION#v}"
GRADLE_VERSION="$(sed -nE 's/^[[:space:]]*version[[:space:]]*=[[:space:]]*"([^"]+)".*$/\1/p' build.gradle.kts | head -n1)"
NPM_VERSION="$(sed -nE 's/^[[:space:]]*"version"[[:space:]]*:[[:space:]]*"([^"]+)".*$/\1/p' packages/typescript/package.json | head -n1)"

if [[ -z "$GRADLE_VERSION" ]]; then
  echo "Could not find version in build.gradle.kts" >&2
  exit 1
fi
if [[ -z "$NPM_VERSION" ]]; then
  echo "Could not find version in packages/typescript/package.json" >&2
  exit 1
fi

if [[ "$GRADLE_VERSION" != "$MAVEN_VERSION" || "$NPM_VERSION" != "$MAVEN_VERSION" ]]; then
  echo "Committed versions do not match release version $MAVEN_VERSION." >&2
  exit 1
fi
echo "[ok] committed versions match release input"

# Optional registry preflight checks (enabled in CI via env vars).
if [[ -n "${MAVEN_METADATA_URL:-}" ]]; then
  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required for Maven registry preflight check." >&2
    exit 1
  fi
  HTTP_STATUS="$(curl -sS -o /tmp/maven-metadata.xml -w "%{http_code}" -H "Authorization: Bearer ${GITHUB_TOKEN:-}" "$MAVEN_METADATA_URL" || true)"
  if [[ "$HTTP_STATUS" == "200" ]]; then
    if grep -Fq "<version>$MAVEN_VERSION</version>" /tmp/maven-metadata.xml; then
      echo "Maven version already exists in registry: $MAVEN_VERSION" >&2
      exit 1
    fi
  elif [[ "$HTTP_STATUS" == "404" ]]; then
    :
  else
    echo "Maven registry check failed with HTTP status: $HTTP_STATUS" >&2
    exit 1
  fi
  echo "[ok] Maven registry version does not exist"
fi

if [[ -n "${NPM_PACKAGE_NAME:-}" ]]; then
  if ! command -v npm >/dev/null 2>&1; then
    echo "npm is required for npm registry preflight check." >&2
    exit 1
  fi
  if npm view "${NPM_PACKAGE_NAME}@${MAVEN_VERSION}" version >/dev/null 2>&1; then
    echo "NPM version already exists in registry: ${NPM_PACKAGE_NAME}@${MAVEN_VERSION}" >&2
    exit 1
  fi
  echo "[ok] NPM registry version does not exist"
fi

echo "Preflight passed."
