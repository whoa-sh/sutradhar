# Sutradhar Comprehensive Implementation Plan

## 1) Purpose And Execution Intent

`sutradhar` is the centralized contract platform for whoa.sh notification architecture. It owns protobuf schema definitions, compatibility policy, generated SDK outputs (JVM, TypeScript/JavaScript, Go), validation standards, and release discipline.

This plan translates accepted decisions from `sutradhar-grill-decision-log.md` into an execution roadmap that an intern can follow safely with high quality and minimal ambiguity.

Primary goals:

- Deliver a strict, reproducible, enterprise-grade contract repository.
- Keep contract governance stronger than service-local DTO evolution.
- Guarantee cross-language parity across JVM, TS/JS, and Go.
- Preserve backward compatibility discipline through Buf and version policy.

## 2) Scope Boundary

In scope:

- Protobuf contract definitions for notification platform domains.
- Contract-level validation manifests and helper SDK APIs.
- Generated artifacts and constants for all target languages.
- CI gates, snapshot flow, immutable release flow.
- Documentation required for producers and integrators.

Out of scope:

- Narada runtime orchestration logic.
- Provider SDK implementation details.
- Environment-specific deployment manifests outside contract CI/release.
- Preference ownership or template authoring runtime behavior.

## 3) Architectural Decisions Baseline

The plan follows these fixed anchors from the decision log:

- Separate sibling repository at `C:\Users\subhro\scm\whoash\sutradhar`.
- Default branch is `master`.
- Single Gradle root orchestrator.
- Buf mandatory from day one.
- First-class targets: JVM, TypeScript/JavaScript, Go.
- Publish Maven + npm via GitHub Packages; Go via SemVer tags/module path.
- One shared release version across targets.
- TS/Go generated outputs committed; JVM generated classes not committed.
- Strict freshness checks for generated content and constants.
- Structured validation error model, collect-all mode.
- Lifecycle envelope with event lineage and actor attribution.
- Policy-driven sensitive raw destinations and PII-aware models.

## 4) Repository Design

Target repository layout:

```text
sutradhar/
  .agents/plans/
  .github/workflows/
  contracts/
    topics.yaml
    headers.yaml
    validation.yaml
    metadata-prefixes.yaml
  proto/
    sh/whoa/sutradhar/common/v1/
    sh/whoa/sutradhar/notification/v1/
    sh/whoa/sutradhar/template/v1/
    sh/whoa/sutradhar/provider/v1/
    sh/whoa/sutradhar/preference/v1/
  packages/
    jvm/
    typescript/
    go/
  src/test/
  gradle/
  buf.yaml
  buf.gen.yaml
  build.gradle.kts
  settings.gradle.kts
```

## 5) Engineering Philosophy (How To Think While Implementing)

The contract repo is a policy system, not only a schema folder. Treat every schema edit as an API governance decision.

Core principles:

- Contract-first over implementation-first.
- Explicitness over clever implicit conventions.
- Stable normalized enums with optional provider-native detail.
- Typed structure over free-form strings when the domain is known.
- Policy and validation manifests as first-class artifacts.
- Reproducible generation over manual edits.

Decision handling style:

- If a question is already resolved in the decision log, implement directly.
- If unresolved but low-risk, choose the strict option that improves compatibility discipline.
- Ask only when there is a true architecture split with major quality/reliability impact.
- Update the decision log whenever a new decision is made.

## 6) Milestone Roadmap

### Milestone 0: Repository Bootstrap And Governance

Objective:
Create a runnable repository foundation with deterministic build orchestration and policy files.

Work:

- Initialize Git repository and baseline branch workflow assumptions.
- Create Gradle root, version catalog, wrapper, and dependency locking.
- Add repository docs: README, LICENSE, NOTICE, contribution guardrails.
- Add `.editorconfig`, `.gitignore`, and local tooling conventions.

Definition of done:

- `./gradlew tasks` runs successfully.
- Root project resolves and lockfiles can be generated.
- Basic docs and legal files exist and are coherent.

Acceptance criteria:

- New contributor can clone and run bootstrap commands from README.
- No manual hidden setup is required.

### Milestone 1: Contract Governance Core (Buf + Manifests)

Objective:
Establish schema governance before high-volume proto authoring.

Work:

- Add `buf.yaml` and `buf.gen.yaml` with pinned plugin versions.
- Add manifests in `contracts/`: topics, headers, validation, metadata prefixes.
- Add Gradle tasks: `protoLint`, `protoGenerate`, `protoCheckFreshness`.

Definition of done:

- `buf lint` runs from CI and local command path.
- Generation can run deterministically from one command entrypoint.
- Freshness gate fails on stale generated outputs.

Acceptance criteria:

- CI catches contract lint violations and stale generation drift.
- No generated file requires manual hand edits.

### Milestone 2: Common Contracts (`common.v1`)

Objective:
Deliver reusable primitives used across all domain packages.

Work:

- Create `TraceContext`, `TenantContext`, `FailureContext`, `FailureCode`, `RetryHint`.
- Create `Metadata` and `MetadataEntry` with typed oneof values.
- Create `SensitivityClass` enum.
- Create `IdempotencyContext` with `dedupe_scope`.
- Add validation metadata for required fields and sensitivity rules.

Definition of done:

- Common package compiles and generates SDK outputs.
- Rule IDs exist for all common-level validations.
- Timestamp fields use `google.protobuf.Timestamp` consistently.

Acceptance criteria:

- Domain packages import common contracts without local duplication.
- Tenant mismatch and identity validation rules are expressible in helper validators.

### Milestone 3: Notification Contracts (`notification.v1`)

Objective:
Define canonical notification intake and lifecycle communication shapes.

Work:

- Build `NotificationRequest` with priority/channel and topic-consistency assumptions.
- Add structured `RecipientRef`.
- Add `NotificationTarget` with oneof variants:
  - email, sms, push, webhook.
- Add policy-aware raw destination variants:
  - webhook `endpoint_ref` vs `url`,
  - push `device_ref` vs `device_token`.
- Add lifecycle envelope:
  - `event_id`, `sequence_number`, `causation_event_id`,
  - actor attribution (`actor_type`, `actor_id`),
  - typed details oneof.

Definition of done:

- Request and lifecycle messages compile across all language targets.
- Lifecycle model supports audit lineage and replay traceability.

Acceptance criteria:

- Producers can construct valid recipient-level requests without Narada source code.
- Lifecycle consumers can answer “what happened and why” from event payload alone.

### Milestone 4: Template Contracts (`template.v1`)

Objective:
Define robust async rendering contract shapes.

Work:

- Implement `TemplateRef` with explicit version selector oneof.
- Implement `LatestActiveTemplate` with required `reason` and optional `max_age_seconds`.
- Define render command/result structures.
- Add rendered payload model:
  - inline default,
  - structured `ContentRef` alternative.

Definition of done:

- Render command/result support all channels through typed oneof payloads.
- Exact template version used is present in render result.

Acceptance criteria:

- Integrators can choose exact-version or latest-active mode explicitly.
- Render audit can reconstruct version resolution decisions.

### Milestone 5: Provider Contracts (`provider.v1`)

Objective:
Normalize provider delivery semantics while preserving provider-native diagnostics.

Work:

- Define governed provider identity enum with optional sub-id.
- Define normalized provider status enum.
- Include optional provider-native status code.
- Include provider message identifiers and timing fields.
- Define failure and retry hint integration with provider events.

Definition of done:

- Provider command/event model compiles and validates.
- Status normalization map can be documented per provider.

Acceptance criteria:

- Narada can drive state machine transitions from normalized statuses only.
- Operations can debug with provider-native status detail when needed.

### Milestone 6: Preference Contracts (`preference.v1`)

Objective:
Support preference projection and fallback decision patterns.

Work:

- Define preference event and decision schemas.
- Reuse recipient and tenant identity primitives.
- Include audit timestamps and decision source fields.

Definition of done:

- Preference contracts compile and integrate with common identity shapes.

Acceptance criteria:

- Narada can express suppression rationale without owning preference records.

### Milestone 7: Constants, Validation SDK Surfaces, And Fixtures

Objective:
Deliver cross-language helper surfaces and parity tests.

Work:

- Generate topic/header constants from manifests.
- Implement language helper validators (hybrid model).
- Add shared fixture sets for valid/invalid messages.
- Map rule IDs and docs links in validation outputs.

Definition of done:

- JVM/TS/Go validation outputs expose equivalent error structures.
- Collect-all behavior is default across all helpers.

Acceptance criteria:

- Same invalid fixture yields semantically equivalent rule IDs in all targets.

### Milestone 8: CI Hardening

Objective:
Enforce strict quality gates and compatibility guarantees.

Work:

- PR workflow:
  - wrapper validation,
  - build and tests,
  - `buf lint`,
  - breaking check against `master` baseline after baseline exists,
  - freshness checks.
- Formatting/lint pipelines:
  - Kotlin/Gradle lint,
  - TypeScript lint/format checks,
  - Go `gofmt`/`go vet`.

Definition of done:

- CI fails on any contract drift, generation drift, or compatibility violations.

Acceptance criteria:

- Pull requests cannot merge with stale generated assets or manifest mismatch.

### Milestone 9: Snapshot And Release Pipelines

Objective:
Enable controlled development consumption and immutable production releases.

Work:

- Snapshot workflow from `master` only:
  - Maven snapshot publish,
  - npm snapshot publish.
- Release workflow (manual):
  - input validation `vX.Y.Z`,
  - committed version match checks,
  - full preflight matrix,
  - publish Maven/npm,
  - create release tag.

Definition of done:

- Snapshot and release paths are fully separated.
- Release workflow never mutates repository files.

Acceptance criteria:

- Release fails safely on version collisions or preflight mismatches.
- Published artifacts are reproducible from tagged commit state.

### Milestone 10: Producer/Consumer Documentation And Runbooks

Objective:
Make integration executable for newcomers and maintainable for operators.

Work:

- Write contract onboarding docs:
  - required headers,
  - topic map,
  - idempotency model,
  - validation error handling.
- Write release and rollback runbooks.
- Document sensitivity and PII handling expectations.

Definition of done:

- Documentation covers all critical integration workflows.

Acceptance criteria:

- New integrator can publish/consume contracts without reading internal service code.

## 7) Definition Of Done (Global)

The project is complete when:

- All milestones through CI and release are implemented and passing.
- All first-class languages have generated outputs and test coverage.
- Compatibility policy is enforced by both tooling and process.
- Decision log and implementation plan are synchronized.
- Newcomer integration docs are complete and technically accurate.

## 8) Acceptance Criteria (Global)

Technical acceptance:

- `buf lint` passes.
- Breaking checks pass against baseline.
- Generation freshness checks pass.
- JVM/TS/Go tests pass.
- Snapshot workflow succeeds from `master`.
- Release workflow succeeds with valid `vX.Y.Z`.

Contract acceptance:

- All required notification platform contract packages exist in `v1`.
- Structured validation and rule IDs are exposed in all targets.
- Lifecycle and provider diagnostics support audit and replay analysis.

Operational acceptance:

- CI blocks drift and incompatibility.
- Release process is immutable and reproducible.

## 9) Intern Execution Protocol

Execution order:

1. Read decision log.
2. Read this implementation plan.
3. Execute one milestone at a time.
4. At milestone close:
   - run full validation commands,
   - update plan progress section,
   - append any new decision to decision log.

Mandatory behavior:

- Never hand-edit generated TS/Go files.
- Never commit generated JVM classes.
- Never bypass CI/freshness gates.
- Never ship unresolved compatibility concerns without explicit escalation.

Escalate only if:

- A design split changes compatibility boundaries.
- A security/sensitivity model conflicts with policy assumptions.
- Cross-language parity cannot be achieved with current generation approach.

## 10) Quality Gate Matrix

| Gate | Enforced By | Fail Condition |
|---|---|---|
| Protobuf lint | Buf | Schema lint violation |
| Compatibility | Buf breaking | Breaking change in existing package version |
| Generation freshness | CI script | Diff after generation |
| Constants freshness | CI script | Diff after constants generation |
| JVM tests | Gradle test | Test failure |
| TS tests | npm test | Test failure |
| Go tests | go test | Test failure |
| Formatting/lint | language-specific | Any lint/format failure |
| Release preflight | release workflow | Version/tag/registry mismatch |

## 11) Risk Register

Top risks:

- Drift between manifests and generated constants.
- Inconsistent validation behavior across languages.
- Provider-specific status mapping entropy.
- Uncontrolled sensitivity leakage into logs.
- Hidden breaking changes due to human review gaps.

Mitigations:

- Freshness gates and fixture parity tests.
- Stable validation rule IDs.
- Provider mapping documentation and normalized enum discipline.
- Explicit sensitivity model and sanitization policies.
- PR checklist plus automated Buf breaking checks.

## 12) Milestone Progress Tracker (Initial)

| Milestone | Status | Owner | Notes |
|---|---|---|---|
| M0 Bootstrap | Pending | TBD | Initialize repo and root build |
| M1 Governance Core | Pending | TBD | Buf + manifests + generation tasks |
| M2 Common Contracts | Pending | TBD | Core shared schema primitives |
| M3 Notification | Pending | TBD | Request/target/lifecycle envelope |
| M4 Template | Pending | TBD | Version selector + content ref |
| M5 Provider | Pending | TBD | Status normalization and diagnostics |
| M6 Preference | Pending | TBD | Projection and decision schema |
| M7 SDK + Fixtures | Pending | TBD | Constants + validators + parity tests |
| M8 CI Hardening | Pending | TBD | Strict PR gates |
| M9 Snapshot/Release | Pending | TBD | Separate workflows and preflights |
| M10 Docs/Runbooks | Pending | TBD | Integrator and operator docs |

## 13) First Commit Sequence (Recommended)

1. `chore(repo): bootstrap sutradhar gradle root and governance files`
2. `build(proto): add buf configs and contract manifests`
3. `feat(common): add common v1 proto contracts and generation wiring`
4. `feat(notification): add notification v1 request target lifecycle contracts`
5. `feat(template-provider-preference): add v1 domain contract packages`
6. `feat(sdk): add constants generation and validation helper scaffolds`
7. `test(parity): add cross-language fixture and smoke tests`
8. `ci(strict): add pr, snapshot, and release workflows with preflights`
9. `docs: add integration guides and release runbooks`

## 14) Plan Maintenance Rule

Whenever a new accepted decision is added to `sutradhar-grill-decision-log.md`, update this implementation plan in the same task if it changes milestone scope, DoD, acceptance criteria, or risk posture.
