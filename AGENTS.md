# AGENTS.md

This repository is a contract platform (`sutradhar`) for protobuf schema governance and multi-language SDK outputs.

## Mission

Build and maintain strict, compatible, reproducible contracts for JVM, TypeScript/JavaScript, and Go consumers.

## First Files To Read

1. `.agents/plans/sutradhar-grill-decision-log.md`
2. `.agents/plans/sutradhar-comprehensive-implementation-plan.md`
3. `.agents/tracker.md`

If there is any conflict:

- Decision log is the authority.
- Then update plan/tracker in the same task.

## Anchors (Use-Case Navigation)

Use these anchors whenever you lose context or need the canonical file quickly.

### A1: Architecture And Policy Decisions

- File: `.agents/plans/sutradhar-grill-decision-log.md`
- Use when:
  - deciding schema shape,
  - handling compatibility/versioning choices,
  - resolving policy ambiguity.

### A2: End-To-End Implementation Roadmap

- File: `.agents/plans/sutradhar-comprehensive-implementation-plan.md`
- Use when:
  - planning milestone execution,
  - validating DoD/acceptance criteria,
  - sequencing work for intern execution.

### A3: Live Progress And Ownership

- File: `.agents/tracker.md`
- Use when:
  - starting a task (`TODO -> IN_PROGRESS`),
  - updating progress or blockers,
  - proving completion evidence (`DONE` state).

### A4: Technology And Tooling Contract

- File: `.agents/plans/sutradhar-technology-and-tooling-matrix.md`
- Use when:
  - selecting toolchain patterns,
  - checking language-target expectations,
  - validating CI/release tooling assumptions.

### A5: Planning Index

- File: `.agents/plans/00-sutradhar-plan-index.md`
- Use when:
  - onboarding a new agent,
  - finding canonical plan files quickly.

### A6: Script Entry Points

- File: `scripts/README.md`
- Use when:
  - running local bootstrap,
  - running verification,
  - running release preflight checks.

### A8: Quick Command Surface

- File: `Makefile`
- Use when:
  - running quick generation loops,
  - prototyping without release workflow,
  - standardizing local commands across agents.
- Unix-like systems, Git Bash, WSL, Linux, and macOS use `Makefile`.
- Native PowerShell flows use `Makefile.windows`.

### A7: Agent Operating Rules

- File: `AGENTS.md`
- Use when:
  - uncertain about process discipline,
  - uncertain about multi-agent coordination,
  - uncertain about release/quality gate rules.

## Working Flavor (Mandatory)

- Contract-first and policy-first.
- Strong compatibility discipline (Buf + review checklist).
- Deterministic generation and freshness checks.
- Cross-language parity is required.
- Meaningful small commits over giant mixed changes.

## Tracker Discipline (Mandatory)

Before starting any task:

1. Locate item in `.agents/tracker.md` work queue.
2. Move it to `IN_PROGRESS`.
3. Add an in-progress log entry with date/owner/summary.

When finishing:

1. Add verification evidence (commands/tests/workflow runs).
2. Move item to `DONE`.
3. Add completion log entry.
4. Update milestone board status and notes.

If blocked:

1. Move item to `BLOCKED`.
2. Add a blocker entry immediately.
3. State required dependency/decision explicitly.

If progress context is lost:

1. Open anchor `A3` (`.agents/tracker.md`) and find current `IN_PROGRESS`/`BLOCKED` items.
2. Open anchor `A2` for the current milestone's DoD and acceptance criteria.
3. Open anchor `A1` for final architecture decision authority.

## Decision Handling Rules

- If decision already exists in the decision log, implement directly.
- If unresolved and low-risk, choose stricter compatibility-safe option.
- Ask user only for true architecture splits with major resilience/compliance/operability impact.
- Add every new accepted decision to the decision log and keep plan/tracker aligned.

## Implementation Order

1. M0 Bootstrap
2. M1 Governance Core (Buf + manifests + generation wiring)
3. M2..M6 Contract packages (`common`, `notification`, `template`, `provider`, `preference`)
4. M7 SDK surfaces + parity fixtures
5. M8 CI hardening
6. M9 Snapshot/release pipelines
7. M10 Integrator docs and runbooks

## Multi-Agent Strategy

Use parallel tracks defined in `.agents/tracker.md` Multi-Agent Coordination Board:

- Track A: proto schema authoring
- Track B: Gradle + Buf automation
- Track C: TS/Go package + fixture parity
- Track D: CI and release workflows
- Track E: docs/runbooks

Rules for parallel work:

- One owner per track at a time.
- Track dependencies must be documented before start.
- Hand-off artifact is mandatory for each track.
- Rebase/merge only after freshness gates pass.

## Quality Gates (Never Skip)

- `buf lint`
- compatibility checks against baseline (`master`) once established
- generation freshness checks (no diff after generation)
- JVM tests
- TS tests
- Go tests
- lint/format checks for all languages

## Fast Local Loop (Non-Release)

Default Unix-like local command flow:

1. `make dev`
2. `make generate`
3. `make verify`

Unix-like single-command prototype loop:

- `make prototype`

Native Windows PowerShell command flow:

1. `make -f Makefile.windows dev`
2. `make -f Makefile.windows generate`
3. `make -f Makefile.windows verify`

Native Windows prototype loop:

- `make -f Makefile.windows prototype`

## Contract Modeling Guardrails

- No breaking changes in `v1` packages.
- Breaking changes require new package namespace (`v2` etc.).
- Use typed structures over free-form strings when domain is known.
- Raw sensitive destination fields are policy-controlled and explicitly classified.
- Failure messages are sanitized; raw details must be separately classified.
- Lifecycle events require lineage and actor attribution fields.

## Release Model

- Snapshots: from `master` only (Maven + npm).
- Releases: manual input `vX.Y.Z`, immutable, preflight validated.
- Release workflow must not mutate tracked version files.

## Done Criteria For Any Task

A task is complete only when:

- code/config/docs change is implemented,
- tracker entries are updated,
- verification evidence is recorded,
- no unresolved drift remains between decision log, plan, and tracker.
