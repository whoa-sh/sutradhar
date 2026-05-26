#!/usr/bin/env bash
set -euo pipefail

VERSION_TAG="${1:-}"
if [[ ! "$VERSION_TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Version must match vX.Y.Z. Got: $VERSION_TAG" >&2
  exit 1
fi
VERSION="${VERSION_TAG#v}"

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

if [[ "$GRADLE_VERSION" != "$VERSION" ]]; then
  echo "Gradle version mismatch: expected $VERSION, found $GRADLE_VERSION" >&2
  exit 1
fi
if [[ "$NPM_VERSION" != "$VERSION" ]]; then
  echo "NPM version mismatch: expected $VERSION, found $NPM_VERSION" >&2
  exit 1
fi
echo "[ok] committed versions match $VERSION"
