# Sutradhar

`sutradhar` is the centralized protobuf contract repository for whoa.sh services.

It owns:

- shared protobuf definitions,
- compatibility policy,
- generated JVM, TypeScript/JavaScript, and Go artifacts,
- contract-level validation rules,
- topic/header constants,
- snapshot and immutable release workflows.

It does not own service runtime behavior, Narada orchestration logic, provider SDK integrations, deployment manifests, or environment-specific authorization policy.

## Current State

The repository is in bootstrap. Read the local planning files before implementation:

- `.agents/plans/sutradhar-grill-decision-log.md`
- `.agents/plans/sutradhar-comprehensive-implementation-plan.md`
- `.agents/tracker.md`

## Local Commands

Unix-like systems, Git Bash, WSL, Linux, and macOS:

```bash
make dev
make verify
make prototype
```

Native Windows PowerShell:

```powershell
make -f Makefile.windows dev
make -f Makefile.windows verify
make -f Makefile.windows prototype
```

## Release Model

Snapshots publish from `master` only for Maven and npm packages.

Immutable releases use a manual `vX.Y.Z` workflow, validate committed package versions, publish Maven/npm artifacts, and create the Git tag for Go module consumption.
