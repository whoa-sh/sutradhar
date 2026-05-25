# Scripts

Operational helper scripts for local execution and agent workflows.

## Available Scripts

- `dev.ps1`
  - local bootstrap guidance and quick environment checks.
- `dev.sh`
  - Unix-like local bootstrap guidance and quick environment checks.
- `verify.ps1`
  - strict local validation wrapper; use before marking tracker items `DONE`.
- `verify.sh`
  - Unix-like strict local validation wrapper; use before marking tracker items `DONE`.
- `release-preflight.ps1`
  - preflight checks for a release version input in `vX.Y.Z` format.
- `release-preflight.sh`
  - Unix-like preflight checks for a release version input in `vX.Y.Z` format.

## Preferred Quick Path

Use the root `Makefile` for day-to-day generation and prototyping loops on Unix-like systems, Git Bash, WSL, Linux, or macOS:

```powershell
make dev
make generate
make verify
make prototype
```

Use `Makefile.windows` for native PowerShell make flows:

```powershell
make -f Makefile.windows dev
make -f Makefile.windows generate
make -f Makefile.windows verify
make -f Makefile.windows prototype
```

## Usage

Unix-like:

```bash
./scripts/dev.sh
./scripts/verify.sh
./scripts/release-preflight.sh v0.1.0
```

Windows PowerShell:

```powershell
.\scripts\dev.ps1
.\scripts\verify.ps1
.\scripts\release-preflight.ps1 -Version v0.1.0
```
