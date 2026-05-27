# Release Runbook

## Scope

Immutable production release for Maven Central + GitHub Packages (Maven and npm) using exact `vX.Y.Z` tags.
Release is manual-first and triggered only via workflow dispatch.
Maven Central is release-only and never accepts `-SNAPSHOT` versions.

## Preconditions

1. Release commit is already on `master`.
2. `build.gradle.kts` version equals `X.Y.Z` (source-of-truth).
3. `packages/typescript/package.json` version equals `X.Y.Z` after sync.
4. Target tag `vX.Y.Z` does not already exist.
5. Required repository permissions/secrets are configured for package publish.

Maven Central required secrets:

- `MAVEN_CENTRAL_USERNAME`
- `MAVEN_CENTRAL_PASSWORD`
- `GPG_KEY_CONTENTS`
- `SIGNING_KEY_ID`
- `SIGNING_PASSWORD`

Version sync step before release:

- Unix-like: `make sync-version`
- PowerShell: `make -f Makefile.windows sync-version`

## Execution

1. Trigger workflow:
   - `.github/workflows/release.yml`
2. Provide input:
   - `version = vX.Y.Z`
3. Workflow gates:
   - version format validation
   - full repository verification
   - release preflight checks
   - committed version cross-check
   - Maven publish to GitHub Packages
   - Maven Central publish (signed)
   - npm publish to GitHub Packages
   - Git tag creation and push

## Post-Release Validation

1. Confirm workflow completed successfully.
2. Confirm Git tag exists in remote.
3. Confirm Maven package version appears in GitHub Packages.
4. Confirm npm package version appears in GitHub Packages.
5. Confirm Maven Central deployment appears in Sonatype Central.

## Failure Rules

- Do not mutate files during release workflow.
- Do not reuse an existing version tag.
- On failure, fix source and rerun with a new commit. Keep release immutable.
