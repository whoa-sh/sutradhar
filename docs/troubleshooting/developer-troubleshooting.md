# Developer Troubleshooting

## `buf` Not Found

Symptoms:
- `buf.yaml exists but buf CLI is not available`

Fix:
1. Install Buf locally.
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
