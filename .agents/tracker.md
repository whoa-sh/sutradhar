# Sutradhar Execution Tracker

This is the live execution tracker for `sutradhar`.

## Status Legend

- `TODO`: not started
- `IN_PROGRESS`: actively being worked
- `BLOCKED`: cannot continue without dependency/decision
- `DONE`: completed and verified

## Current Flavor Of Working

- Contract-first, policy-first execution.
- Strict CI and deterministic generation.
- Cross-language parity is mandatory (JVM, TS/JS, Go).
- Decision log is authoritative for architecture choices.
- Prefer small meaningful commits with runnable checkpoints.

## Primary References

- Decision log: `.agents/plans/sutradhar-grill-decision-log.md`
- Comprehensive roadmap: `.agents/plans/sutradhar-comprehensive-implementation-plan.md`
- Plans index: `.agents/plans/00-sutradhar-plan-index.md`

## Milestone Progress Board

| Milestone | Status | Owner | Started | Updated | Evidence/Notes |
|---|---|---|---|---|---|
| M0 Bootstrap | DONE | codex | 2026-05-25 | 2026-05-25 | Verified with `.\scripts\verify.ps1`, `.\gradlew.bat --no-daemon tasks`, and `.\gradlew.bat --no-daemon check` |
| M1 Governance Core | TODO | unassigned | - | - | - |
| M2 Common Contracts | TODO | unassigned | - | - | - |
| M3 Notification Contracts | TODO | unassigned | - | - | - |
| M4 Template Contracts | TODO | unassigned | - | - | - |
| M5 Provider Contracts | TODO | unassigned | - | - | - |
| M6 Preference Contracts | TODO | unassigned | - | - | - |
| M7 SDK + Fixtures | TODO | unassigned | - | - | - |
| M8 CI Hardening | TODO | unassigned | - | - | - |
| M9 Snapshot + Release | TODO | unassigned | - | - | - |
| M10 Docs + Runbooks | TODO | unassigned | - | - | - |

## Active Work Queue

| Item ID | Item | Milestone | Status | Owner | Notes |
|---|---|---|---|---|---|
| WQ-001 | Initialize Gradle root, wrapper, and version catalog | M0 | DONE | codex | Gradle root, wrapper, and version catalog created; wrapper executable bit staged for Unix |
| WQ-002 | Add repo governance files (`README`, `LICENSE`, `NOTICE`, `.gitignore`) | M0 | DONE | codex | Governance baseline created |
| WQ-003 | Add Buf configs and manifest files under `contracts/` | M1 | TODO | unassigned | - |
| WQ-004 | Implement generation + freshness tasks in Gradle | M1 | TODO | unassigned | - |
| WQ-005 | Create `common.v1` contracts and validation rules | M2 | TODO | unassigned | - |
| WQ-006 | Create `notification.v1` contracts + lifecycle envelope | M3 | TODO | unassigned | - |
| WQ-007 | Create `template.v1` contracts + content ref models | M4 | TODO | unassigned | - |
| WQ-008 | Create `provider.v1` contracts + status normalization | M5 | TODO | unassigned | - |
| WQ-009 | Create `preference.v1` contracts | M6 | TODO | unassigned | - |
| WQ-010 | Generate constants + validator surfaces in all targets | M7 | TODO | unassigned | - |
| WQ-011 | Add JVM/TS/Go minimal parity tests and fixtures | M7 | TODO | unassigned | - |
| WQ-012 | Add strict PR CI + snapshot + release workflows | M8/M9 | TODO | unassigned | - |
| WQ-013 | Add producer docs and runbooks | M10 | TODO | unassigned | - |
| WQ-014 | Add root Makefile quick loop for generation/prototyping (non-release) | M0/M1 | DONE | codex | Added `Makefile` with `dev`, `proto-lint`, `generate`, `verify`, `prototype`, `preflight-release` |
| WQ-015 | Add Unix-like scripts and native Windows make parity | M0/M1 | DONE | codex | Added `dev.sh`, `verify.sh`, `release-preflight.sh`, Unix-first `Makefile`, and `Makefile.windows` |

## In-Progress Log

Append one line whenever an item enters `IN_PROGRESS` or changes state.

| Date (UTC) | Item ID | From -> To | Owner | Summary |
|---|---|---|---|---|
| 2026-05-25 | WQ-001 | TODO -> IN_PROGRESS | codex | Started Gradle root, wrapper, and version catalog bootstrap |
| 2026-05-25 | WQ-002 | TODO -> IN_PROGRESS | codex | Started governance file baseline |
| 2026-05-25 | WQ-001 | IN_PROGRESS -> DONE | codex | Verified Gradle wrapper and planning-file check |
| 2026-05-25 | WQ-002 | IN_PROGRESS -> DONE | codex | Governance files added and included in verification |

## Blockers

| Blocker ID | Item ID | Description | Opened | Owner | Resolution |
|---|---|---|---|---|---|
| - | - | - | - | - | - |

## Completion Log

| Date (UTC) | Item ID | Milestone | Verification | Commit/Ref |
|---|---|---|---|---|
| 2026-05-25 | WQ-001 | M0 | `.\scripts\verify.ps1`; `.\gradlew.bat --no-daemon tasks`; `.\gradlew.bat --no-daemon check` | initial bootstrap commit |
| 2026-05-25 | WQ-002 | M0 | `.\scripts\verify.ps1`; `.\gradlew.bat --no-daemon check` | initial bootstrap commit |

## Multi-Agent Coordination Board

Use this table when parallel agents work on separate tracks.

| Track | Scope | Assigned Agent | Dependencies | Status | Hand-off Artifact |
|---|---|---|---|---|---|
| A | Proto schema authoring (`common/notification/template`) | unassigned | M0,M1 | TODO | PR/patch notes |
| B | Build + generation automation (Gradle + Buf) | unassigned | M0 | TODO | task output log |
| C | TS/Go package scaffolds + fixtures | unassigned | M1 | TODO | test report |
| D | CI/release workflows | unassigned | M0,M1,M7 | TODO | workflow evidence |
| E | Docs/runbooks + onboarding | unassigned | M0..M9 | TODO | docs checklist |

## Update Rules (Mandatory)

1. Move an item to `IN_PROGRESS` before editing code/files for that item.
2. Update `Updated` timestamp and notes each time progress is made.
3. Add a line in `In-Progress Log` for every state transition.
4. Add verification evidence when marking `DONE` (commands/tests/workflow names).
5. Never mark `DONE` without runnable verification evidence.
6. If blocked, move item to `BLOCKED` and add blocker entry immediately.
7. If architecture changes, update decision log first, then this tracker.

## Daily Checkpoint Template

```text
Date:
Owner:
Items progressed:
Items completed:
New blockers:
Commands/tests run:
Next planned item:
```
