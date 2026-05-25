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

## Repository Layout

Contract source:

- `proto/sh/whoa/sutradhar/<domain>/vN/*.proto`

Current domains:

- `common/v1`
- `notification/v1` (planned)
- `template/v1` (planned)
- `provider/v1` (planned)
- `preference/v1` (planned)

Governance manifests:

- `contracts/topics.yaml`
- `contracts/headers.yaml`
- `contracts/validation.yaml`
- `contracts/metadata-prefixes.yaml`

Generated outputs:

- Go: `packages/go/...` (committed)
- TypeScript: `packages/typescript/src/generated/...` (committed)
- JVM Java protobuf output: `packages/jvm/src/main/java/...` (not committed)

## Where To Add Proto Files

When adding a new contract:

1. Pick the correct domain and version namespace:
   - Example: `proto/sh/whoa/sutradhar/notification/v1/notification_request.proto`
2. Keep package names aligned with path:
   - `package sh.whoa.sutradhar.notification.v1;`
3. Set language options:
   - `java_package`
   - `go_package`
4. Reuse common contracts from `common/v1` instead of redefining shared fields.

When making a breaking change:

- Do not break `v1` in-place.
- Create a new version namespace (`v2`) and keep old version contracts available until deprecation policy says otherwise.

## Editing And Generating Workflow

Use this flow for every schema change:

1. Edit or add `.proto` files under `proto/...`.
2. Update manifests in `contracts/` if topics/headers/validation rules change.
3. Run lint and generation:
   - `buf lint`
   - `buf generate`
4. Run repository verification:
   - `make verify` (Unix-like)
   - `make -f Makefile.windows verify` (native PowerShell)
5. Commit:
   - proto changes
   - manifest changes
   - generated TS/Go outputs
   - never generated JVM outputs

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

## Design And Review Process

Design direction:

- Contract-first and compatibility-first.
- Typed, explicit fields over ambiguous free-form values.
- Additive evolution in existing version namespaces.
- New package version (`v2`, `v3`, ...) for wire-breaking changes.

Before merging contract changes:

1. Confirm package/path/version alignment.
2. Confirm rule IDs and constraints in `contracts/validation.yaml`.
3. Confirm generated outputs are in sync (no stale generation drift).
4. Confirm no agent-local references (`.agents`, `AGENTS.md`) are added to tracked files.

## Ongoing Maintenance Plan

How this stays maintainable over time:

1. Keep each domain in its own `proto/.../<domain>/vN/` folder.
2. Keep shared primitives in `common/vN` and import them.
3. Keep manifests authoritative for topics/headers/validation metadata.
4. Run lint and generation on every change before commit.
5. Publish snapshots from `master` for early integration.
6. Publish immutable releases from validated `vX.Y.Z` input only.

Recommended commit boundaries:

- `feat(<domain>): add or evolve contracts`
- `build(validation): update rule IDs and regenerate outputs`
- `docs: update contributor guidance when process changes`

## Release Model

Snapshots publish from `master` only for Maven and npm packages.

Immutable releases use a manual `vX.Y.Z` workflow, validate committed package versions, publish Maven/npm artifacts, and create the Git tag for Go module consumption.

Release invariants:

- Publish workflows never mutate project version files.
- Release input must be `vX.Y.Z`.
- `build.gradle.kts` version and `packages/typescript/package.json` version must already match `X.Y.Z` before release workflow runs.
- Go release remains tag-driven (`vX.Y.Z`); no Go snapshot publishing lane.

## CI Hardening

GitHub Actions workflows:

- `.github/workflows/ci.yml`
  - runs on PRs and `master`,
  - enforces `buf lint`,
  - enforces generated output freshness (`buf generate` + `git diff --exit-code`),
  - runs JVM/TypeScript/Go parity tests.
- `.github/workflows/snapshot.yml`
  - separate snapshot lane from `master` / manual dispatch,
  - runs strict repo verification before publish steps,
  - publishes Maven and npm snapshots to GitHub Packages.
- `.github/workflows/release.yml`
  - manual immutable release lane,
  - requires `version` input in `vX.Y.Z`,
  - validates full preflight before creating/pushing the exact tag.
  - validates committed cross-ecosystem versions before publish,
  - publishes Maven and npm releases to GitHub Packages.

Local equivalent before opening PR:

- Unix-like: `./scripts/verify.sh`
- PowerShell: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\verify.ps1`

## Documentation Map

Integration and operations docs:

- `docs/integration/producer-consumer-onboarding.md`
- `docs/runbooks/release-runbook.md`
- `docs/runbooks/rollback-runbook.md`
- `docs/governance/sensitivity-and-pii.md`
