# Developer Troubleshooting

## First 15 Minutes Recovery Flow

Use this sequence when setting up a new machine or after a long gap:

1. Run docs and baseline verification:
   - Unix-like: `make docs-check && make verify`
   - PowerShell: `make -f Makefile.windows docs-check` then `make -f Makefile.windows verify`
2. If verification fails, fix in this order:
   - missing toolchain (`buf`, JDK, Node, Go),
   - version mismatch (`build.gradle.kts` or `packages/typescript/package.json`),
   - generated output drift (`buf generate` + commit).
3. Re-run `verify`.
4. Before release work, run release validation:
   - Unix-like: `make release-check VERSION=vX.Y.Z`
   - PowerShell: `make -f Makefile.windows release-check VERSION=vX.Y.Z`

## `buf` Not Found

Symptoms:
- `buf.yaml exists but buf CLI is not available`

Fix:
1. Install Buf locally.
2. Confirm `buf` is on PATH:
   - Unix-like: `buf --version`
   - PowerShell: `buf --version`
2. Re-run:
   - `make proto-lint`
   - `make verify`

## `make` Not Found In Windows PowerShell

Symptoms:
- `make : The term 'make' is not recognized`

Fix:
1. Use script entrypoints directly:
   - `.\scripts\verify.ps1`
   - `.\scripts\release-check.ps1 -Version vX.Y.Z`
2. Or install GNU make and use:
   - `make -f Makefile.windows verify`

## Generated Output Drift

Symptoms:
- CI/local freshness check fails after `buf generate`.

Fix:
1. Run `buf generate`.
2. Commit updated files under:
   - `packages/go`
   - `packages/typescript/src/generated`
3. Do not commit generated JVM protobuf output.

## Node/Go/JDK Toolchain Missing

Symptoms:
- TypeScript parity or smoke checks are skipped/failed.
- Go parity or smoke checks are skipped/failed.
- Gradle/JVM parity test fails before test execution.

Fix:
1. Install required toolchains:
   - JDK 21,
   - Node.js 22,
   - Go 1.22+.
2. Re-run:
   - Unix-like: `make verify`
   - PowerShell: `make -f Makefile.windows verify`

## Release Version Mismatch

Symptoms:
- `Committed versions do not match release version X.Y.Z`
- `Gradle version mismatch` or `NPM version mismatch`

Fix:
1. Ensure committed versions match intended release:
   - `build.gradle.kts` -> `version = "X.Y.Z"`
   - `packages/typescript/package.json` -> `"version": "X.Y.Z"`
2. Commit version updates first.
3. Re-run release validation:
   - `make release-check VERSION=vX.Y.Z`

## Snapshot Version Shape Looks Wrong

Symptoms:
- Snapshot publish generates duplicated suffixes like `0.1.0-snapshot-snapshot.6`.

Fix:
1. Keep committed base version release-like (for example `0.1.0`).
2. Let snapshot workflow append snapshot suffix.
3. Do not pre-embed `-snapshot` in committed package version when workflow already appends snapshot metadata.

## Release Preflight Fails On Version

Symptoms:
- Version rejected due to format or existing tag.

Fix:
1. Use exact format: `vX.Y.Z`.
2. Ensure tag does not already exist:
   - `git tag --list vX.Y.Z`
3. Run:
   - Unix-like: `make release-check VERSION=vX.Y.Z`
   - PowerShell: `make -f Makefile.windows release-check VERSION=vX.Y.Z`

## Do Not Bypass Safety Gates

Do not skip these checks to “unblock quickly”:

- `buf lint`
- generated freshness checks
- parity tests
- release preflight

If one fails, fix root cause and re-run `verify`/`release-check`.
