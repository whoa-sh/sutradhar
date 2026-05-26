# Scripts

Operational helper scripts for local execution.

## Available Scripts

- `dev.ps1`
  - local bootstrap guidance and quick environment checks.
- `dev.sh`
  - Unix-like local bootstrap guidance and quick environment checks.
- `verify.ps1`
  - strict local validation wrapper.
- `verify.sh`
  - Unix-like strict local validation wrapper.
- `smoke-examples.ps1`
  - runs minimal JVM/TypeScript/Go consumer examples.
- `smoke-examples.sh`
  - Unix-like runner for minimal JVM/TypeScript/Go consumer examples.
- `release-preflight.ps1`
  - preflight checks for a release version input in `vX.Y.Z` format.
- `release-preflight.sh`
  - Unix-like preflight checks for a release version input in `vX.Y.Z` format.
- `validate-version.ps1`
  - checks committed Gradle and npm versions match the provided release tag (`vX.Y.Z`).
- `validate-version.sh`
  - Unix-like committed version cross-check for Gradle and npm release versions.

## Preferred Quick Path

Use the root `Makefile` for day-to-day generation and prototyping loops on Unix-like systems, Git Bash, WSL, Linux, or macOS:

```powershell
make dev
make generate
make verify
make smoke-examples
make prototype
make suite-contracts
make suite-examples
make suite-local
```

Use `Makefile.windows` for native PowerShell make flows:

```powershell
make -f Makefile.windows dev
make -f Makefile.windows generate
make -f Makefile.windows verify
make -f Makefile.windows smoke-examples
make -f Makefile.windows prototype
make -f Makefile.windows suite-contracts
make -f Makefile.windows suite-examples
make -f Makefile.windows suite-local
```

## Command Collections (Suites)

- `suite-contracts`
  - contract pipeline group: `proto-lint` + `generate`.
- `suite-examples`
  - example runtime group: `smoke-examples`.
- `suite-local`
  - full local development gate: `suite-contracts` + `verify` + `suite-examples`.

## Usage

Unix-like:

```bash
./scripts/dev.sh
./scripts/verify.sh
./scripts/release-preflight.sh v0.1.0
./scripts/validate-version.sh v0.1.0
```

Windows PowerShell:

```powershell
.\scripts\dev.ps1
.\scripts\verify.ps1
.\scripts\release-preflight.ps1 -Version v0.1.0
.\scripts\validate-version.ps1 -Version v0.1.0
.\scripts\smoke-examples.ps1
```
