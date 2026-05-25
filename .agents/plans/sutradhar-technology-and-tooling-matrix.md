# Sutradhar Technology And Tooling Matrix

This file defines concrete technology choices, toolchain contracts, and execution scripts for `sutradhar`.

## 1) Core Technology Stack

| Concern | Choice | Why |
|---|---|---|
| Build orchestrator | Gradle (Kotlin DSL) | Single control plane across JVM + protobuf + automation |
| Schema governance | Buf | Linting, compatibility checks, generation orchestration |
| Protobuf compiler | protoc via Buf plugins | Standardized generation pipeline |
| JVM artifact | Maven package (`sutradhar-protos-jvm`) | Narada and JVM consumers |
| TypeScript artifact | npm package (`@whoa-sh/sutradhar-protos`) | Node/web consumers |
| Go artifact | Go module by git tags | Native Go module consumption |
| Contract validation model | Hybrid (manifest + per-language helper impls) | Rule consistency without brittle rule-engine overreach |
| CI | GitHub Actions | Strict PR gates + separate snapshot/release pipelines |

## 2) Language-Specific Strategy

### JVM

- Generate Java protobuf classes at build time.
- Do not commit generated JVM classes.
- Publish Maven artifact to GitHub Packages.
- Kotlin adapters/helpers live as handwritten source.

### TypeScript/JavaScript

- Use `protobuf-es` generation via Buf.
- Commit generated output.
- Publish npm package to GitHub Packages.
- Keep constants/validation helpers in stable package surface.

### Go

- Generate `.pb.go` and commit them.
- Module path: `github.com/whoa-sh/sutradhar/packages/go`.
- Release by SemVer git tags.

## 3) Governance Artifacts

Expected source-of-truth files:

- `contracts/topics.yaml`
- `contracts/headers.yaml`
- `contracts/validation.yaml`
- `contracts/metadata-prefixes.yaml`
- `buf.yaml`
- `buf.gen.yaml`

## 4) Mandatory Quality Gates

1. `buf lint`
2. `buf breaking` against `master` baseline (post-baseline)
3. generation freshness (`git diff --exit-code` after generation)
4. constants freshness (`git diff --exit-code` after constants generation)
5. JVM tests
6. TS tests
7. Go tests

## 5) Operational Scripts (PowerShell)

All scripts live under `scripts/`.

Unix-like scripts:

- `scripts/dev.sh`
- `scripts/verify.sh`
- `scripts/release-preflight.sh`

Windows PowerShell scripts:

- `scripts/dev.ps1`
- `scripts/verify.ps1`
- `scripts/release-preflight.ps1`

Quick command surfaces:

- `Makefile` for Unix-like systems, Git Bash, WSL, Linux, and macOS.
- `Makefile.windows` for native PowerShell make flows.

## 6) Release And Snapshot Contracts

Release:

- Manual workflow input `vX.Y.Z`
- Must match committed package versions
- Must not mutate files in workflow
- Publish Maven + npm
- Create immutable release tag

Snapshots:

- Only from `master`
- Maven `X.Y.Z-SNAPSHOT`
- npm `X.Y.Z-snapshot.<runNumber>`

## 7) Agent Usage Contract

- Always run `make verify` or `make -f Makefile.windows verify` before marking work `DONE`.
- Run `make preflight-release VERSION=vX.Y.Z` or `make -f Makefile.windows preflight-release VERSION=vX.Y.Z` before any release execution.
- Keep `.agents/tracker.md` updated for every state transition.
