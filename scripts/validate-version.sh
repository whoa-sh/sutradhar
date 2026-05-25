#!/usr/bin/env bash
set -euo pipefail

VERSION_TAG="${1:-}"
if [[ ! "$VERSION_TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Version must match vX.Y.Z. Got: $VERSION_TAG" >&2
  exit 1
fi
VERSION="${VERSION_TAG#v}"

GRADLE_VERSION="$(grep -E '^version = ' build.gradle.kts | sed -E 's/version = "([^"]+)"/\1/')"
NPM_VERSION="$(node -p "require('./packages/typescript/package.json').version")"

if [[ "$GRADLE_VERSION" != "$VERSION" ]]; then
  echo "Gradle version mismatch: expected $VERSION, found $GRADLE_VERSION" >&2
  exit 1
fi
if [[ "$NPM_VERSION" != "$VERSION" ]]; then
  echo "NPM version mismatch: expected $VERSION, found $NPM_VERSION" >&2
  exit 1
fi
echo "[ok] committed versions match $VERSION"
