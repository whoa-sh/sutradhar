# Sutradhar Protobuf Platform Decision Log

This file tracks the design questions answered during the Sutradhar planning grill. Keep it updated as decisions are resolved so future implementation agents can continue from the current shared understanding without replaying the whole conversation.

## Decision Mode

- Auto-accept mode is enabled.
- Recommended answers are accepted by default and written into this tracker.
- Ask the user only when there is a genuine architecture split that materially changes resilience, compliance, or long-term operability tradeoffs.

## Project Boundary

### Decision 1: Repository Placement

Question: Should `sutradhar` be a separate sibling repository at `C:\Users\subhro\scm\whoash\sutradhar`, rather than a folder or module inside `narada`?

Answer: Yes. `sutradhar` is a separate centralized protobuf contract project.

Rationale: `sutradhar` owns shared `.proto` contracts and generated artifacts for multiple services. Keeping it separate prevents Narada implementation concerns from becoming the contract ownership boundary.

Implications:

- Local path: `C:\Users\subhro\scm\whoash\sutradhar`
- Intended remote: `github.com/whoa-sh/sutradhar`
- Narada consumes `sutradhar` artifacts instead of copying generated code.

### Decision 2: Repository Bootstrap

Question: Should `sutradhar` be bootstrapped as a fresh Git repository immediately?

Answer: Yes. Initialize it as a fresh Git repository immediately, then create meaningful runnable commits.

Rationale: Git metadata should exist from day one because GitHub Actions, package publishing, tags, and release history are part of the core project design.

Implications:

- Initialize Git before scaffold implementation.
- Make meaningful commits rather than one large unreviewable dump.
- Each commit should leave the repository runnable or move it toward a clearly runnable state.

### Decision 3: Default Branch

Question: Should the default branch be `master` or `main`?

Answer: Use `master`.

Rationale: Snapshot publishing is expected to run from `master`, and CI should encode that branch name directly.

Implications:

- PR CI targets `master`.
- Snapshot publishing runs only from `master`.
- Buf breaking checks compare against `master` after the first baseline exists.

## Build And Package Strategy

### Decision 4: Build Orchestrator

Question: Should `sutradhar` be a single Gradle root project orchestrating all targets, or should each language use its native toolchain as the primary build?

Answer: Use a single Gradle root project as the orchestrator.

Rationale: Gradle gives one entry point for validation, generation, tests, compatibility checks, and CI coordination. Native tooling remains present for each ecosystem where needed.

Implications:

- Gradle orchestrates Buf, JVM build, TypeScript checks, Go checks, validation tests, and publishing tasks.
- npm and Go tooling still exist for package metadata and language-native tests.
- The repository should remain runnable through one primary command path.

### Decision 5: First-Class Language Targets

Question: Should the first scaffold publish only JVM artifacts, or include TypeScript/JavaScript and Go too?

Answer: JVM, TypeScript/JavaScript, and Go are all first-class from day one.

Rationale: These are the target consumer languages for the platform. CI and release design must prove all three are usable before publishing.

Implications:

- JVM publishes to GitHub Packages Maven.
- TypeScript/JavaScript publishes to GitHub Packages npm.
- Go is released as a versioned Go module in the repository by SemVer Git tag.

### Decision 6: Go Module Path

Question: Which Go module path should generated Go consumers use?

Answer: `github.com/whoa-sh/sutradhar/packages/go`.

Rationale: This path works with the monorepo-style package layout while preserving a single release version across targets.

Implications:

- `packages/go/go.mod` uses module path `github.com/whoa-sh/sutradhar/packages/go`.
- Go consumers use Git tags for released versions.

### Decision 7: TypeScript Code Generator

Question: Which protobuf generation style should TypeScript/JavaScript use?

Answer: Use Buf `protobuf-es` from day one.

Rationale: `protobuf-es` is TypeScript-first, modern, Buf-friendly, and better suited to a new contract package than older CommonJS-oriented generators.

Implications:

- npm package name: `@whoa-sh/sutradhar-protos`.
- Generated TypeScript lives under the TypeScript package.
- Handwritten TypeScript helpers live separately from generated output.

### Decision 8: JVM API Shape

Question: Which JVM protobuf API should be published?

Answer: Publish Java protobuf classes plus Kotlin helper/adaptor layers, not Kotlin-only generated APIs.

Rationale: Java protobuf classes provide stable JVM interoperability, while Kotlin helpers can improve ergonomics for Kotlin/Spring services.

Implications:

- Generated JVM protobuf classes are build outputs, not committed source.
- Kotlin constants, validators, and adapters are handwritten/generated package helpers.
- Maven artifact coordinates are planned as `sh.whoa.sutradhar:sutradhar-protos-jvm`.

## Source Layout And Generated Output

### Decision 9: Generated Code Commit Policy

Question: Should generated code be committed?

Answer: Commit generated TypeScript and Go outputs, but do not commit generated JVM build outputs.

Rationale: npm and Go consumers benefit from committed/generated package source. JVM generated classes should be produced during Gradle build and published inside the Maven artifact.

Implications:

- `proto/` remains the source of truth.
- TypeScript generated output is committed.
- Go generated `.pb.go` output is committed.
- JVM generated classes are not committed.

### Decision 10: Generated Freshness

Question: Should CI enforce generated output freshness?

Answer: Yes.

Rationale: Stale generated TypeScript or Go output would make published language packages diverge from `.proto` sources.

Implications:

- CI runs generation.
- CI fails if `git diff --exit-code` detects stale generated files.
- Generated constants and validators should follow the same freshness policy where generated.

### Decision 11: Versioned Generated Packages

Question: Should generated output be managed by versions?

Answer: Yes. Generated packages are versioned through the single repository release version.

Rationale: Consumers need to reason about one Sutradhar version across languages.

Implications:

- One repo release version, for example `v0.1.0`.
- Maven/npm package version: `0.1.0`.
- Go module version: Git tag `v0.1.0`.
- Protobuf package suffixes such as `.v1` are independent wire compatibility namespaces.

### Decision 12: Single Version Across Targets

Question: Should JVM, npm, and Go be independently versioned?

Answer: No. Use one release version for all targets.

Rationale: This is a contract repository. Cross-language consumers should be able to say they are all using `sutradhar vX.Y.Z`.

Implications:

- Release workflow validates all package versions match the input tag.
- No per-language version drift.

## CI And Publishing

### Decision 13: Strict CI And Separate Publish Workflow

Question: Should everything be in CI with strict checks and a separate publish workflow?

Answer: Yes.

Rationale: Contract repositories must fail fast on compatibility, generation drift, style drift, invalid versions, and broken language packages.

Implications:

- PR CI runs strict validation.
- Publish workflow is separate from PR CI.
- Publish workflow requires SemVer input in the form `vX.Y.Z`.
- Publish workflow validates the input before publishing.

### Decision 14: GitHub Packages Targets

Question: Should all targets use GitHub Packages?

Answer: Maven and npm use GitHub Packages. Go is released by Git tag because GitHub Packages does not provide a Go module registry.

Rationale: GitHub Packages supports Maven/Gradle and npm package registries, but Go module consumption is normally Git tag based.

Implications:

- JVM: GitHub Packages Maven.
- TypeScript/JavaScript: GitHub Packages npm.
- Go: versioned module in the same repository, consumed by Git tag.
- The release may optionally attach archives to a GitHub Release, but Go package consumption should use Git tags.

### Decision 15: Release Workflow Tag Creation

Question: Should the initial release workflow create the Git tag itself or require an existing tag?

Answer: The manual workflow creates the tag after all validation and preflight checks pass.

Rationale: Failed validation should not leave a bad release tag. The workflow should only create immutable release state after the repository has been proven releasable.

Implications:

- User enters `version = vX.Y.Z`.
- Workflow validates SemVer format.
- Workflow ensures tag does not already exist.
- Workflow ensures Maven/npm package versions do not already exist.
- Workflow runs full strict checks.
- Workflow creates tag `vX.Y.Z` on the validated commit.
- Workflow publishes Maven and npm.
- Workflow creates a GitHub Release.

### Decision 16: Publish Workflow Version Mutation

Question: Should the publish workflow update package version files automatically?

Answer: No. It must require matching committed versions and must not mutate files.

Rationale: Release artifacts should come from reviewed source, not from CI-generated release commits.

Implications:

- Release commit already contains exact `X.Y.Z` versions.
- Workflow input `vX.Y.Z` must match committed package versions.
- Publish fails on version drift.

### Decision 17: Tag Authority For Releases

Question: What represents exact release versions?

Answer: Tags are the exact release version authority.

Rationale: Go requires SemVer tags for released module versions, and tags provide an immutable cross-language release anchor.

Implications:

- `master` may carry next development or snapshot versions.
- Release commit must contain exact non-snapshot package versions.
- Manual publish input creates `vX.Y.Z` tag on that commit.
- Maven/npm publish as `X.Y.Z`.
- Go consumers use tag `vX.Y.Z`.

### Decision 18: Snapshot Publishing

Question: Should snapshot publishing exist?

Answer: Yes. Allow snapshots only from `master` with a separate snapshot workflow. Keep release publishing immutable.

Rationale: Narada feature branches may need early contract artifacts, but snapshot publishing must not weaken immutable release discipline.

Implications:

- Snapshot workflow runs only from `master`.
- Release workflow remains manually dispatched and immutable.
- Snapshot publishing does not create release tags.

### Decision 19: Snapshot Targets

Question: Should snapshot publishing include Go?

Answer: No. Snapshot publishing is Maven and npm only.

Rationale: Go development consumption should use commit pseudo-versions rather than fake snapshot tags.

Implications:

- Maven snapshots publish as `X.Y.Z-SNAPSHOT`.
- npm snapshots publish with a prerelease pattern such as `X.Y.Z-snapshot.<runNumber>` or `X.Y.Z-dev.<sha>`.
- Go development consumers can depend on a commit from `master`.

## Compatibility And Protobuf Policy

### Decision 20: Buf From Day One

Question: Should Buf be mandatory from day one?

Answer: Yes.

Rationale: Buf is the right tool for protobuf linting, breaking-change checks, module layout, and consistent generation across languages.

Implications:

- Include `buf.yaml`.
- Include `buf.gen.yaml`.
- Wire `buf lint` into CI.
- Wire `buf breaking` into CI after the first baseline exists.
- Gradle exposes tasks such as `protoLint`, `protoGenerate`, and compatibility checks.

### Decision 21: Buf Breaking Baseline

Question: Should PR CI enforce Buf breaking checks against `master`?

Answer: Yes, after the first baseline lands.

Rationale: `master` becomes the compatibility baseline for existing published contracts.

Implications:

- Before initial baseline: lint, generate, tests.
- After initial baseline: `buf breaking --against master` becomes mandatory for proto changes.

### Decision 22: Breaking Changes

Question: Should breaking changes be allowed only by adding new protobuf package versions?

Answer: Yes.

Rationale: Existing consumers must remain safe. New wire-incompatible contracts belong in new package namespaces.

Implications:

- No breaking edits to existing `*.v1` messages.
- Additive compatible changes stay in the existing package version.
- Breaking redesigns go into package namespaces such as `notification.v2`.
- Old package versions remain generated and published until documented deprecation/removal.

### Decision 23: Artifact SemVer Versus Proto Package Version

Question: Should artifact versions and protobuf package versions be separate?

Answer: Yes.

Rationale: Artifact SemVer describes package release cadence. Protobuf package suffixes define wire compatibility boundaries.

Implications:

- Artifact/package versions can move from `0.1.0` to `0.2.0` while proto packages remain `.v1`.
- New `.v2` proto packages are required only for breaking wire changes.

## Contract Scope

### Decision 24: Initial Contract Scope

Question: Should the initial repo include only Narada notification-platform contracts or broader whoa.sh platform contracts?

Answer: Cover all aspects required by the Narada plan, plus reusable common primitives. Do not add speculative unrelated contracts.

Rationale: The first release should be complete for Narada and companion services without turning Sutradhar into a dumping ground for future ideas.

Implications:

- `common.v1`: trace, tenant, failure, metadata, idempotency primitives where appropriate.
- `notification.v1`: notification request, target, lifecycle, enums.
- `template.v1`: template reference, render command/result, enums.
- `provider.v1`: delivery command/event, enums.
- `preference.v1`: preference event/decision.

## Constants And Manifests

### Decision 25: Topic And Header Constants

Question: Should Kafka topic names and header names be generated constants or only documented?

Answer: Generate constants from day one, but keep them outside `.proto` messages as language package helpers.

Rationale: Narada depends on exact topic/header names. Constants reduce drift, but topic/header names are operational conventions rather than protobuf payload schemas.

Implications:

- JVM exposes topic/header constants.
- TypeScript exposes topic/header constants.
- Go exposes topic/header constants.
- Docs still explain ownership, partition keys, and usage.

### Decision 26: Constants Source Of Truth

Question: Should constants be handwritten per language or generated from a shared manifest?

Answer: Generate per-language constants from a single manifest.

Rationale: Hand-maintaining constants in JVM, TypeScript, and Go would drift.

Implications:

- Source manifests such as `contracts/topics.yaml` and `contracts/headers.yaml`.
- Generated constants in JVM, TypeScript, and Go packages.
- CI fails if generated constants are stale.

## Validation Policy

### Decision 27: Validation Ownership

Question: What should own message validation rules?

Answer: Put structural constraints in protobuf shape, and publish lightweight validation helpers per language generated or implemented from a shared validation manifest.

Rationale: Protobuf does not enforce many business-required fields in proto3. Contract-level validators prevent bad producers without moving Narada orchestration logic into Sutradhar.

Implications:

- `.proto` uses strong structure, enums, `oneof`, typed messages, and comments.
- `contracts/validation.yaml` records validation rule metadata.
- JVM, TypeScript, and Go expose validation helpers.
- Narada can layer stricter service-specific validation on top.

### Decision 28: Validation Error Shape

Question: Should validation failures use a shared structured error model?

Answer: Yes. Define an extensive enterprise-grade language-neutral validation error shape in manifests/docs and expose equivalent types in each package.

Rationale: Producer teams and service consumers need consistent error reporting across languages.

Implications:

- Validation errors use equivalent types in JVM, TypeScript, and Go.
- Errors are contract-level, not Narada operational decisions.
- DLQ routing, retryability, and suppression remain service logic.

Recommended fields:

- `code`
- `message`
- `path`
- `severity`
- `category`
- `ruleId`
- `expected`
- `actual`
- `constraint`
- `documentationUrl`

Recommended result shape:

- `valid`
- `errors[]`
- `warnings[]`

### Decision 29: Validation Collection Mode

Question: Should validation be fail-fast or collect-all by default?

Answer: Collect all errors by default. Optional fail-fast mode can be added later.

Rationale: Complete feedback is better for producer CI and onboarding. Runtime services can still stop after any errors are returned.

Implications:

- Validators return all discovered errors and warnings.
- Tests should assert sets of expected error codes for invalid fixtures.

### Decision 30: Validation Implementation Model

Question: Should validators be generated entirely from `validation.yaml` or manually implemented per language?

Answer: Use a hybrid model.

Rationale: A full YAML rules engine is too much too early, but a shared manifest still prevents drift in rule IDs and documentation.

Implications:

- `contracts/validation.yaml` is source of truth for rule IDs, paths, severities, categories, and documentation.
- Validators are manually implemented per language initially.
- Shared JSON fixtures define valid and invalid cases.
- CI runs equivalent validation fixture tests for JVM, TypeScript, and Go.

### Decision 31: Language Test Coverage

Question: Should initial scaffolding include real contract tests for all three languages?

Answer: Yes. Include minimal real tests for JVM, TypeScript/JavaScript, and Go from day one.

Rationale: All target packages are first-class, so CI must prove each package is usable before release.

Implications:

- JVM: protobuf round-trip tests and validator fixture tests.
- TypeScript/JavaScript: generated import smoke test and validator fixture tests.
- Go: compile/import smoke test and validator fixture tests.

## Formatting, Locking, And Source Hygiene

### Decision 32: Lockfiles

Question: Should generated artifacts and lockfiles be committed?

Answer: Commit lockfiles for every ecosystem that supports them cleanly.

Rationale: Reproducible generation and publishing matters more than minimizing lockfile diffs.

Implications:

- Gradle lockfile is committed.
- npm package lockfile is committed.
- Go `go.sum` is committed when dependencies exist.
- Buf plugin versions are pinned in config.

### Decision 33: Formatting And License Gates

Question: Should strict formatting and license checks exist from day one?

Answer: Yes, strict from day one, but scoped.

Rationale: The user wants very strict CI, but generated output and immature docs should not make the scaffold painful.

Implications:

- Kotlin/Gradle: ktlint or Spotless, aligned with Narada style where useful.
- TypeScript: Prettier and minimal ESLint.
- Go: `gofmt` and `go vet`.
- Proto: `buf lint`.
- YAML/Markdown: lint/format only where it does not slow the scaffold too much.
- Handwritten source files should have license headers where practical.

### Decision 34: Generated File Formatting And Headers

Question: Should generated files be exempt from license-header checks?

Answer: Yes. Exempt generated files from license-header checks, but still let language-native formatters run where safe.

Rationale: Generated code should be reproducible from the generator. Post-processing headers into generated files makes freshness checks fragile.

Implications:

- Handwritten files require license headers where practical.
- Generated files keep generator comments.
- Go generated output can be `gofmt`-compatible.
- Avoid Prettier mutation on generated TypeScript unless the chosen generator output is stable under Prettier.

## Protobuf Modeling Decisions

### Decision 35: Optional Scalars

Question: Should initial contracts use `optional` scalar fields where presence matters, or avoid `optional`?

Answer: Use `optional` scalar fields only when presence is semantically important. Otherwise prefer plain scalars plus validators.

Rationale: Presence should mean something. Required business values can be enforced by validators without making every scalar optional.

Implications:

- Use `optional` for fields where absent and empty are materially different.
- Use plain strings/enums plus validators for required non-blank fields.
- Use message fields and `oneof` for structural presence.

### Decision 36: Timestamps

Question: Should timestamps use `google.protobuf.Timestamp` everywhere?

Answer: Yes. Use `google.protobuf.Timestamp` for contract timestamps.

Rationale: It is the standard protobuf timestamp type and avoids ambiguous string or epoch-millis conventions.

Implications:

- Use it for requested, failed, rendered, provider event, observed, effective, and evaluated timestamps.
- Services adapt to internal time representations at boundaries.

### Decision 37: Metadata Shape

Question: How should arbitrary metadata values be modeled?

Answer: Use bounded typed metadata entries, not `map<string, string>` and not `google.protobuf.Any`.

Rationale: Bounded typed entries provide controlled extensibility without creating unstructured JSON-like payloads.

Implications:

- Metadata uses repeated entries.
- Each entry has a key and a typed `oneof` value.
- Validators enforce bounds, key format, no duplicate keys, max string length, and reserved prefixes.

### Decision 38: Metadata Placement

Question: Should `Metadata` be used broadly on all messages?

Answer: No. Use metadata only at deliberate extension points.

Rationale: Too much metadata becomes a shadow schema and weakens contract discipline.

Implications:

- Use metadata on selected top-level messages such as `NotificationRequest`, `RenderCommand`, `DeliveryCommand`, and possibly `LifecycleEvent`.
- Prefer typed fields for target, provider, and template specifics.

### Decision 39: Channel-Specific Shape

Question: Should channel-specific targets and payloads use protobuf `oneof` variants?

Answer: Yes.

Rationale: `oneof` gives compile-time shape across JVM, TypeScript, and Go and prevents invalid combinations.

Implications:

- `NotificationTarget` uses target variants for email, SMS, push, and webhook.
- Rendered payloads and delivery payloads use `oneof`.
- Validators enforce consistency where a top-level channel enum is also present.

### Decision 40: Top-Level Channel Field

Question: Should a top-level `channel` enum still exist if `oneof` implies channel?

Answer: Yes. Keep `channel` on routing-level messages and validate consistency with the `oneof`.

Rationale: Kafka routing, indexing, logs, metrics, and filtering need a cheap top-level channel field.

Implications:

- `NotificationRequest.channel` must match `NotificationTarget.target`.
- `RenderCommand.channel` determines requested render shape.
- `DeliveryCommand.channel` must match rendered payload and target.

### Decision 41: Priority

Question: Should notification priority be topic-derived only or included inside messages?

Answer: Include `priority` inside messages and validate it against topic routing.

Rationale: Messages can move through retries, DLQs, archives, replay tooling, and admin views where the original topic is not sufficient.

Implications:

- Request topic priority must match `NotificationRequest.priority`.
- Retry and DLQ payloads preserve original priority.
- Delivery topic priority/channel must match message priority/channel.

### Decision 42: Schema Version

Question: Should `schema_version` be a Kafka header only, protobuf field only, or both?

Answer: Both, but with different meaning.

Rationale: Kafka headers support operational routing and inspection. Protobuf package/type is the real wire compatibility namespace.

Implications:

- Kafka header `schemaVersion` exists for operations.
- Protobuf package suffix such as `.notification.v1` defines wire compatibility.
- Generated helper constants expose schema family/version names.

### Decision 43: Generic Schema Version Field

Question: Should `schema_version` be required on every top-level protobuf message?

Answer: No.

Rationale: Protobuf generated type and package already identify the schema. A field on every message creates mismatch risk.

Implications:

- Do not add generic `schema_version` to every message.
- If non-Kafka storage needs self-description later, add a specific envelope type.

### Decision 44: Trace Context Duplication

Question: Should `TraceContext` fields be duplicated as Kafka headers and protobuf payload fields?

Answer: Yes, but governed by adapter rules.

Rationale: Headers are right for live propagation. Payload fields are useful for persistence, replay, DLQ, and inspection outside Kafka.

Implications:

- Kafka headers are authoritative during live transport.
- Payload `TraceContext` supports audit, replay, and storage.
- Producers set both.
- Adapters validate mismatch and prefer headers for active propagation.
- DLQ and replay preserve both original headers and payload trace context.

### Decision 45: Tenant Context Duplication

Question: Should `TenantContext` also be duplicated in Kafka headers and payload?

Answer: Yes, stricter than trace context.

Rationale: Tenant is a hard routing, authorization, audit, and partitioning boundary.

Implications:

- Kafka header `tenantId` is required.
- Payload `TenantContext.tenant_id` is required.
- Header and payload tenant ID must match exactly.
- Mismatch is a hard validation failure.
- Region/environment can remain payload-only unless routing requires them later.

### Decision 46: Idempotency Shape

Question: Should idempotency use separate fields or a nested context message?

Answer: Use nested `IdempotencyContext`.

Rationale: `source_system`, `source_event_id`, and `idempotency_key` are always interpreted together. A nested context gives validators and future extension a clean boundary.

Implications:

- Define a message similar to:

```proto
message IdempotencyContext {
  string source_system = 1;
  string source_event_id = 2;
  string idempotency_key = 3;
}
```

- `NotificationRequest` references `IdempotencyContext`.
- Future additions such as `producer_service_version` or `dedupe_scope` can be added without cluttering the request.

### Decision 47: Idempotency Dedupe Scope

Question: Should `IdempotencyContext` include an explicit `dedupe_scope` enum from day one, or keep only `source_system`, `source_event_id`, and `idempotency_key` initially?

Answer: Include `dedupe_scope` from day one.

Rationale: Idempotency bugs are expensive, and scope is not just decoration. A producer may need dedupe per tenant, per recipient, per source event, per campaign, or per channel. Making scope explicit avoids hidden assumptions in Narada and producer code.

Implications:

- `IdempotencyContext` includes `dedupe_scope`.
- `DEDUPE_SCOPE_UNSPECIFIED` is invalid for normal producer requests.
- Narada persistence should include dedupe scope in unique constraints or idempotency lookup semantics.
- Producer documentation must explain how to choose a dedupe scope.

Suggested initial enum:

```proto
enum DedupeScope {
  DEDUPE_SCOPE_UNSPECIFIED = 0;
  DEDUPE_SCOPE_TENANT = 1;
  DEDUPE_SCOPE_RECIPIENT = 2;
  DEDUPE_SCOPE_SOURCE_EVENT = 3;
  DEDUPE_SCOPE_CAMPAIGN = 4;
  DEDUPE_SCOPE_CHANNEL = 5;
}
```

## Current Next Question

Continue the grill from Decision 47.

Suggested next topic: whether `source_system` and `producerService` Kafka header should both exist, and what mismatch policy should apply.

### Decision 48: Producer Identity Split

Question: Should `source_system` in `IdempotencyContext` and Kafka header `producerService` both exist, or should there be only one producer identity field?

Answer: Both should exist, with strict-but-not-identical semantics.

Rationale: The producer service and business source system are related but not always identical. A bulk dispatcher, gateway, or integration adapter may technically publish the Kafka message on behalf of a different business source system.

Implications:

- Kafka header `producerService` identifies the technical service that put the message on Kafka.
- Payload field `IdempotencyContext.source_system` identifies the business or system origin used for idempotency, audit, and lineage.
- Both are required for normal producer requests.
- Difference between the two is not automatically invalid.
- A future allowlist can validate which producer services may publish on behalf of which source systems.
- Logs and validation output should expose both identities so operational debugging does not collapse them into one concept.

## Current Next Question

Continue the grill from Decision 48.

Suggested next topic: whether producer-on-behalf-of relationships should be represented in the protobuf payload, Kafka headers, or only in service configuration.

### Decision 49: Producer Delegation Mapping

Question: Should producer-on-behalf-of relationships be represented in protobuf payload, Kafka headers, or only in service configuration?

Answer: Service configuration first, not payload or header fields from day one.

Rationale: Producer delegation is authorization and governance metadata, not per-message business data. If messages carry an `on_behalf_of` field too early, producers can self-assert delegation unless every consumer validates it anyway.

Implications:

- Payload keeps `IdempotencyContext.source_system`.
- Kafka header keeps `producerService`.
- Environment-specific service configuration owns allowed mappings, such as `bulk-dispatcher -> commerce` or `integration-gateway -> billing`.
- Sutradhar documentation defines the rule and expected validation behavior.
- Contract validators may support allowlist-aware validation when an allowlist context is provided.
- Without an allowlist context, validators can check required fields but should not invent environment-specific authorization decisions.

## Current Next Question

Continue the grill from Decision 49.

Suggested next topic: whether recipient identity should be direct target data only, a stable `recipient_ref`, or both.

### Decision 50: Recipient Identity And Direct Target Data

Question: Should `NotificationRequest` include only direct target data, only a stable `recipient_ref`, or both?

Answer: Include both, but direct target data is required for delivery orchestration.

Rationale: Narada must not own profile lookup, and Provider Gateway should receive enough information to send without calling Narada. At the same time, a stable recipient reference is important for preferences, audit, suppression, dedupe scope, support search, and future profile correlation.

Implications:

- `NotificationRequest` includes a `recipient_ref` or equivalent recipient identity message.
- `NotificationRequest` includes `NotificationTarget` with direct channel-specific target data.
- Direct target data is required for sendable requests.
- `recipient_ref` is required when known and should be strongly recommended even if some system-originated notifications do not have a user profile identity.
- Bulk Dispatcher or upstream producers own audience expansion and target resolution before emitting `NotificationRequest`.
- Narada v1 must not call a profile service to fill missing target data.

## Current Next Question

Continue the grill from Decision 50.

Suggested next topic: whether `recipient_ref` should be a plain string or a structured message with type, id, and namespace.

### Decision 51: RecipientRef Shape

Question: Should `recipient_ref` be a plain string, or a structured message with type, namespace, and ID?

Answer: Use a structured message.

Rationale: A plain string will eventually encode hidden conventions such as `user:123`, `contact:abc`, or `tenant/user/123`. Explicit dimensions make preferences, audit search, and dedupe logic easier to reason about without parsing strings.

Implications:

- Define a `RecipientRef` message.
- `NotificationRequest` references `RecipientRef`.
- Preference contracts can reuse or align with this identity model.
- Validators enforce required identity dimensions.
- Documentation must state that recipient IDs should avoid PII unless a policy explicitly permits it.

Suggested initial shape:

```proto
message RecipientRef {
  string namespace = 1;
  string type = 2;
  string id = 3;
}
```

Validation rules:

- `namespace` required, for example `whoa`, `external`, or `crm`.
- `type` required, for example `user`, `contact`, `device`, or `account`.
- `id` required and non-blank.
- `id` should not contain PII unless explicitly allowed by policy.

## Current Next Question

Continue the grill from Decision 51.

Suggested next topic: whether email and phone targets should store raw addresses in protobuf messages or use redacted/hash-only fields.

### Decision 52: Raw Delivery Addresses And PII Classification

Question: Should `EmailTarget` and `SmsTarget` carry raw delivery addresses in protobuf messages, or only hashed/redacted references?

Answer: Use raw delivery address fields in the command/request where sending requires them, plus explicit PII classification in docs and validators.

Rationale: Provider Gateway cannot send an email or SMS with only a hash. Since Narada must not perform profile lookup in v1, the target must be direct enough for delivery. The contract must still be explicit that these fields are PII and retention-sensitive.

Implications:

- `EmailTarget.email_address` is required for email targets.
- `SmsTarget.phone_number_e164` is required for SMS targets.
- `EmailTarget.display_name` may be optional, but is PII.
- Documentation marks raw delivery target fields as PII.
- Validation metadata classifies these fields as sensitive.
- Validators enforce format and requiredness, not secrecy.
- Persistence services decide whether to store raw, encrypted, hashed, or redacted values.
- Narada and Provider Gateway retention plans must account for these fields.

## Current Next Question

Continue the grill from Decision 52.

Suggested next topic: whether webhook targets should carry a raw URL, a preconfigured endpoint reference, or both.

### Decision 53: WebhookTarget Destination

Question: Should `WebhookTarget` carry a raw URL, a preconfigured endpoint reference, or both?

Answer: Support both, but prefer endpoint reference. Raw URL is allowed only with explicit policy flags.

Rationale: Webhook URLs can contain secrets and introduce SSRF risk. A preconfigured endpoint reference is safer for enterprise operation, while raw URLs may still be needed for selected integration flows.

Implications:

- `WebhookTarget` uses a `oneof` destination.
- `endpoint_ref` is the preferred normal path.
- Raw `url` is supported but treated as sensitive and policy-controlled.
- Validators require HTTPS for raw URLs.
- Validators should warn or fail for raw URLs depending on supplied policy context.
- Localhost, private IP, and link-local URLs should be rejected unless environment policy explicitly permits them.
- Documentation must describe security and retention implications of raw URLs.

Suggested initial shape:

```proto
message WebhookTarget {
  oneof destination {
    string endpoint_ref = 1;
    string url = 2;
  }
}
```

## Current Next Question

Continue the grill from Decision 53.

Suggested next topic: whether push targets should use raw device tokens, user-device references, or both.

### Decision 54: PushTarget Destination

Question: Should `PushTarget` carry raw device tokens, user-device references, or both?

Answer: Support both, with raw token allowed only when the producer is authorized to provide it.

Rationale: Provider Gateway needs enough information to send. In some systems the gateway can resolve a device reference to a provider token, but Narada should not. If no gateway-side registry exists, a raw token is necessary. Device tokens are sensitive and should be treated like credentials.

Implications:

- `PushTarget` uses a `oneof` destination.
- `device_ref` is preferred when the Provider Gateway can resolve it.
- `device_token` is allowed only with policy context.
- `device_token` is classified as sensitive.
- Documentation must explain when raw tokens are acceptable.
- Validators should require a platform value and should validate raw token policy when policy context is supplied.

Suggested initial shape:

```proto
message PushTarget {
  oneof destination {
    string device_ref = 1;
    string device_token = 2;
  }
  string platform = 3;
}
```

## Current Next Question

Continue the grill from Decision 54.

Suggested next topic: whether push platform should be a string or an enum.

### Decision 55: Push Platform Type

Question: Should `PushTarget.platform` be a string or an enum?

Answer: Use an enum.

Rationale: Push platform drives provider routing and validation. A string would drift into inconsistent values such as `ios`, `iOS`, `apple`, `apns`, `android`, or `fcm`. Broad platform should be a stable contract enum, while provider-specific details remain in Provider Gateway routing configuration.

Implications:

- `PushTarget.platform` uses `PushPlatform`.
- `PUSH_PLATFORM_UNSPECIFIED` is invalid when a push target is used.
- Provider-specific route selection remains outside the protobuf platform enum.

Suggested initial enum:

```proto
enum PushPlatform {
  PUSH_PLATFORM_UNSPECIFIED = 0;
  PUSH_PLATFORM_IOS = 1;
  PUSH_PLATFORM_ANDROID = 2;
  PUSH_PLATFORM_WEB = 3;
}
```

## Current Next Question

Continue the grill from Decision 55.

Suggested next topic: whether `TemplateRef.version` should be optional, required, or modeled as a oneof between exact version and latest-active request.

### Decision 56: TemplateRef Version Selector

Question: Should `TemplateRef.version` be optional, required, or modeled as a `oneof` between exact version and latest-active request?

Answer: Model it as a `oneof`, not a nullable or empty string.

Rationale: Empty-string semantics such as "empty means latest" are easy to misuse and audit poorly. Producers should explicitly declare whether they want an exact immutable template version or the latest active template.

Implications:

- `TemplateRef` includes a `version_selector` oneof.
- Exact version is preferred for high-risk notifications.
- Latest-active selection is explicit and can be policy-controlled.
- `RenderResult` must always return the exact immutable `template_version_used`.
- Validators reject missing version selector unless a specific contract flow explicitly permits it.

Suggested initial shape:

```proto
message TemplateRef {
  string template_key = 1;
  string locale = 2;
  NotificationChannel channel = 3;
  string variant = 4;

  oneof version_selector {
    string version = 5;
    LatestActiveTemplate latest_active = 6;
  }
}

message LatestActiveTemplate {
  bool allow_latest = 1;
}
```

## Current Next Question

Continue the grill from Decision 56.

Suggested next topic: whether `LatestActiveTemplate` needs only a marker field or should include policy/audit fields such as reason and max_age.

### Decision 57: LatestActiveTemplate Audit Fields

Question: Should `LatestActiveTemplate` be just a marker, or include policy/audit fields like `reason` and `max_age`?

Answer: Include minimal audit/policy fields from day one.

Rationale: Choosing "latest active" is a risk decision. For compliance and high-priority traffic, producers and operators should know why the producer avoided an exact version and whether freshness was bounded.

Implications:

- `LatestActiveTemplate` includes a required `reason`.
- `LatestActiveTemplate` includes optional `max_age_seconds`.
- Validators require non-blank reason when latest-active selection is used.
- Policy-aware validators may require exact version for high-risk producers or notification classes.
- `RenderResult` still returns the exact immutable template version used.

Suggested initial shape:

```proto
message LatestActiveTemplate {
  string reason = 1;
  optional int64 max_age_seconds = 2;
}
```

## Current Next Question

Continue the grill from Decision 57.

Suggested next topic: whether rendered content should be carried inline in `RenderResult` and `DeliveryCommand`, referenced externally, or both.

### Decision 58: Rendered Content Transport

Question: Should rendered content be carried inline in `RenderResult` and `DeliveryCommand`, referenced externally, or both?

Answer: Support both, with inline payload as the v1 default and external reference available for large or sensitive payloads.

Rationale: Provider Gateway usually needs the actual rendered payload to send. Inline content is operationally simpler for most email, SMS, push, and webhook notifications. Some content may be large or highly sensitive, so the contract should support references without redesigning later.

Implications:

- `RenderedPayload` uses channel-specific `oneof`.
- Channel payloads support inline content.
- A `content_ref` or equivalent external content reference is available.
- Validators require either inline content or content reference where rendered content is required.
- Documentation marks rendered content as PII and retention-sensitive where applicable.
- Narada and Template Service decide retention and storage policy at implementation time.

## Current Next Question

Continue the grill from Decision 58.

Suggested next topic: whether `content_ref` should be a plain URI string or a structured reference with storage type, key, checksum, and sensitivity metadata.

### Decision 59: ContentRef Shape

Question: Should `content_ref` be a plain URI string, or a structured reference with storage type, key, checksum, and sensitivity metadata?

Answer: Use a structured reference.

Rationale: Rendered content references need auditability and integrity. A plain URI leaks storage assumptions and gives no standard way to validate freshness, checksum, size, or sensitivity.

Implications:

- Define a `ContentRef` message.
- `location` may be sensitive and must be classified accordingly.
- `checksum_sha256` should be required when content is immutable and retrievable.
- Consumers should not infer storage backend by URL parsing.
- Documentation must describe storage backend abstraction and sensitivity rules.

Suggested initial shape:

```proto
message ContentRef {
  string storage_type = 1;
  string location = 2;
  string checksum_sha256 = 3;
  optional int64 size_bytes = 4;
  SensitivityClass sensitivity = 5;
}
```

## Current Next Question

Continue the grill from Decision 59.

Suggested next topic: whether sensitivity classification should be a shared enum in common contracts and which initial values it needs.

### Decision 60: SensitivityClass

Question: Should `SensitivityClass` be a shared enum in `common.v1`, and what initial values should it have?

Answer: Yes. Define `SensitivityClass` as a shared enum in `common.v1`.

Rationale: Sensitivity classification applies across target data, rendered content, content references, raw webhook URLs, device tokens, metadata, and operational logs. A shared enum prevents each package from inventing incompatible sensitivity labels.

Implications:

- `SensitivityClass` lives in `common.v1`.
- `SENSITIVITY_CLASS_UNSPECIFIED` is invalid for fields that carry target data, rendered content, raw URLs, tokens, or external content references.
- Validators can enforce minimum sensitivity for known sensitive fields.
- Documentation maps sensitivity classes to retention, logging, redaction, and storage rules later.

Suggested initial enum:

```proto
enum SensitivityClass {
  SENSITIVITY_CLASS_UNSPECIFIED = 0;
  SENSITIVITY_CLASS_PUBLIC = 1;
  SENSITIVITY_CLASS_INTERNAL = 2;
  SENSITIVITY_CLASS_CONFIDENTIAL = 3;
  SENSITIVITY_CLASS_PII = 4;
  SENSITIVITY_CLASS_SECRET = 5;
}
```

## Current Next Question

Continue the grill from Decision 60.

Suggested next topic: whether sensitivity should be explicit fields in payload messages, represented only in validation metadata/docs, or both.

### Decision 61: Sensitivity Placement

Question: Should sensitivity classification be explicit fields inside payload messages, represented only in validation metadata/docs, or both?

Answer: Both, but only where sensitivity can vary per message.

Rationale: Fixed-sensitive fields should not require producers to repeat obvious classifications or allow them to self-declare a lower sensitivity. Generic or variable containers need explicit sensitivity because the contract cannot infer it from the field alone.

Implications:

- Fixed-sensitivity fields such as `email_address`, `phone_number_e164`, and `device_token` are classified in validation metadata and docs.
- Variable-sensitivity containers such as `ContentRef`, metadata entries, and external references include explicit `SensitivityClass sensitivity`.
- Validators enforce minimum sensitivity for known variable containers.
- Documentation defines default sensitivity for each fixed field.
- Producers cannot lower the sensitivity of fields whose sensitivity is known by schema.

## Current Next Question

Continue the grill from Decision 61.

Suggested next topic: whether metadata entries should include sensitivity per entry.

### Decision 62: MetadataEntry Sensitivity

Question: Should each `MetadataEntry` include its own `SensitivityClass`?

Answer: Yes.

Rationale: Metadata is deliberately generic, so sensitivity cannot be inferred from the schema. Without per-entry sensitivity, services will either over-log sensitive metadata or over-restrict harmless metadata.

Implications:

- `MetadataEntry.sensitivity` is required.
- `SENSITIVITY_CLASS_UNSPECIFIED` is invalid.
- Metadata values above `SENSITIVITY_CLASS_INTERNAL` should be excluded from normal logs.
- Validators enforce key and value bounds plus sensitivity presence.
- Documentation may reserve prefixes such as `pii.`, `secret.`, `provider.`, and `debug.` if useful.

## Current Next Question

Continue the grill from Decision 62.

Suggested next topic: whether metadata keys should be free-form with validation or governed by a manifest of allowed/reserved prefixes.

### Decision 63: Metadata Key Governance

Question: Should metadata keys be free-form with basic validation, or governed by a manifest of allowed/reserved prefixes?

Answer: Use basic validation plus a reserved-prefix manifest.

Rationale: Fully enumerating all metadata keys would slow integration and force frequent schema churn. Completely free-form keys become messy quickly. A reserved-prefix manifest gives governance without overfitting.

Implications:

- Metadata keys use lowercase dotted names, such as `provider.route_hint` or `debug.case_id`.
- Validators enforce max key length.
- Validators enforce max entry count.
- Reserved prefixes are listed in a manifest such as `contracts/metadata-prefixes.yaml`.
- Prefixes such as `secret.*`, `pii.*`, `system.*`, `provider.*`, and `debug.*` can have specific rules.
- Validators enforce format and reserved-prefix policy where context is available.

## Current Next Question

Continue the grill from Decision 63.

Suggested next topic: whether `FailureContext.failure_code` should be a string, enum, or structured code with namespace.

### Decision 64: FailureCode Shape

Question: Should `FailureContext.failure_code` be a string, enum, or structured code with namespace?

Answer: Use a structured code with namespace.

Rationale: A single enum will not cover provider, template, validation, Kafka, orchestration, and system failures without constant churn. A plain string lacks governance. Namespace plus code gives flexibility with structure.

Implications:

- Define a `FailureCode` message.
- `FailureContext` references `FailureCode`.
- Known namespaces are documented in a manifest.
- Validators can check known namespaces without needing every possible provider code in protobuf enums.
- Provider-specific raw details can be carried separately when needed.

Suggested initial shape:

```proto
message FailureCode {
  string namespace = 1;
  string code = 2;
}
```

Validation rules:

- `namespace` required.
- `code` required.
- `code` uses uppercase snake case, for example `INVALID_TARGET`, `PROVIDER_TIMEOUT`, or `TEMPLATE_NOT_FOUND`.
- Initial namespaces may include `validation`, `template`, `provider`, `kafka`, `narada`, and `system`.

## Current Next Question

Continue the grill from Decision 64.

Suggested next topic: whether `FailureContext` should include retry classification directly or leave retry decisions entirely to services.

### Decision 65: RetryHint In FailureContext

Question: Should `FailureContext` include retry classification directly, or leave retry decisions entirely to services?

Answer: Include a contract-level retry hint, but final retry policy belongs to services.

Rationale: Provider Gateway and Template Service often know whether a failure is likely retryable, but Narada owns orchestration retry budgets and DLQ behavior. The contract should carry the producer's classification without forcing the consumer to obey blindly.

Implications:

- `FailureContext` includes a `RetryHint`.
- `FailureContext` includes attempt fields where applicable.
- `RetryHint` is an input to service policy, not final authority.
- Narada can override retry behavior based on configured retry rules, budgets, stage, channel, and operational state.
- Documentation must explain the distinction between failure classification and service retry decision.

Suggested initial enum:

```proto
enum RetryHint {
  RETRY_HINT_UNSPECIFIED = 0;
  RETRY_HINT_RETRYABLE = 1;
  RETRY_HINT_NOT_RETRYABLE = 2;
  RETRY_HINT_UNKNOWN = 3;
}
```

Suggested fields:

```proto
RetryHint retry_hint = 4;
int32 attempt_number = 5;
int32 max_attempts = 6;
```

## Current Next Question

Continue the grill from Decision 65.

Suggested next topic: whether `FailureContext.failure_message` may contain user/provider raw messages or must be sanitized with raw details separately classified.

### Decision 66: Failure Message Sanitization

Question: Should `FailureContext.failure_message` allow raw provider/user-facing error text, or must it be sanitized with raw details carried separately and classified?

Answer: Sanitized message only; raw details must be carried separately and classified.

Rationale: Provider errors can contain email addresses, phone numbers, tokens, URLs, request bodies, or vendor account details. A generic `failure_message` will likely appear in logs and admin screens, so it must be safe by default.

Implications:

- `failure_message` is a sanitized operator-readable summary.
- Raw details use separately classified metadata or content references.
- Raw details require sensitivity classification.
- Validators warn or fail if raw details are present without sensitivity.
- Documentation forbids secrets and PII in `failure_message`.
- Admin UI and logs can display `failure_message` without treating it as raw provider payload.

## Current Next Question

Continue the grill from Decision 66.

Suggested next topic: whether lifecycle events should be one generic `LifecycleEvent` with enum type and oneof details, or separate event messages per lifecycle event.

### Decision 67: LifecycleEvent Shape

Question: Should lifecycle events be one generic `LifecycleEvent` with an enum type and typed `oneof` details, or separate protobuf messages per lifecycle event?

Answer: Use one generic `LifecycleEvent` envelope with enum type and typed `oneof` details.

Rationale: Lifecycle events share routing, trace, tenant, request ID, timestamps, and audit fields. Separate top-level messages would multiply topics or require another envelope. Typed details still preserve structure and avoid untyped blobs.

Implications:

- `LifecycleEvent` is the top-level event on lifecycle topics.
- `LifecycleEventType` identifies the event kind.
- `details` uses a typed `oneof`.
- Validators enforce that `type` matches the selected details variant.
- Common fields such as tenant, trace, request ID, and occurred time remain on the envelope.

Suggested initial shape:

```proto
message LifecycleEvent {
  TenantContext tenant_context = 1;
  TraceContext trace_context = 2;
  string request_id = 3;
  LifecycleEventType type = 4;
  google.protobuf.Timestamp occurred_at = 5;

  oneof details {
    AcceptedDetails accepted = 10;
    RejectedDetails rejected = 11;
    SuppressedDetails suppressed = 12;
    RenderDetails render = 13;
    DeliveryDetails delivery = 14;
    DlqDetails dlq = 15;
    ReplayDetails replay = 16;
  }
}
```

## Current Next Question

Continue the grill from Decision 67.

Suggested next topic: whether lifecycle events should include a unique `event_id` and monotonic sequence number per request.

### Decision 68: Lifecycle Event Identity And Ordering

Question: Should lifecycle events include both a unique `event_id` and a monotonic `sequence_number` per request?

Answer: Yes, include both.

Rationale: `event_id` supports idempotency and deduplication for the event record itself. `sequence_number` supports deterministic lifecycle ordering per request even during replay, duplicate delivery, or multi-stage event fan-out.

Implications:

- `LifecycleEvent.event_id` is required.
- `LifecycleEvent.sequence_number` is required.
- `sequence_number` starts at 1 per request and increments per emitted lifecycle event.
- Kafka partition key remains `tenantId:requestId` for per-request ordering where possible.
- Consumers must remain duplicate-tolerant even with sequence numbers.

## Current Next Question

Continue the grill from Decision 68.

Suggested next topic: whether `LifecycleEvent` should include `causation_event_id` to explicitly link chain-of-cause across replay/retry/admin actions.

### Decision 69: Lifecycle Causation Link

Question: Should `LifecycleEvent` include `causation_event_id` to explicitly link cause chains across retry, replay, and admin-triggered actions?

Answer: Yes, include it.

Rationale: Trace context already carries correlation and causation identifiers, but an explicit lifecycle-level `causation_event_id` makes event lineage queries easier for admin timelines, analytics, and replay debugging without parsing trace baggage.

Implications:

- `LifecycleEvent` includes optional `causation_event_id`.
- When an event is directly caused by another lifecycle event, `causation_event_id` is populated with the parent `event_id`.
- For initial root lifecycle events, `causation_event_id` can be empty.
- Replay/retry/admin actions should populate causation linkage explicitly.

## Current Next Question

Continue the grill from Decision 69.

Suggested next topic: whether `LifecycleEvent` should include `actor_type` and `actor_id` for admin-triggered mutation audit clarity.

### Decision 70: Lifecycle Actor Attribution

Question: Should `LifecycleEvent` include `actor_type` and `actor_id` for audit clarity on admin-triggered replay, cancel, and related mutations?

Answer: Yes, include both.

Rationale: Lifecycle transitions are not always system-automated. Distinguishing system actions from human or scheduled actions prevents ambiguity during incident review, support analysis, and compliance audit.

Implications:

- `LifecycleEvent` includes `actor_type`.
- `LifecycleEvent` includes `actor_id`.
- `actor_type` should be an enum, for example `SYSTEM`, `ADMIN_USER`, `SCHEDULED_JOB`, `REPLAY_WORKER`.
- `actor_id` is required when `actor_type` is not `SYSTEM`.
- Documentation should define expected actor identity formats by actor type.

## Current Next Question

Continue the grill from Decision 70.

Suggested next topic: whether lifecycle delivery detail should include provider identity and provider message id directly in the typed event details.

### Decision 71: Lifecycle Delivery Provider Linkage

Question: Should delivery-related lifecycle details include `provider` and `provider_message_id` directly in typed detail messages?

Answer: Yes, include both where delivery has been attempted.

Rationale: Support and reconciliation workflows require direct provider linkage in lifecycle records. Depending only on provider-event topics forces cross-topic joins for basic incident and status queries.

Implications:

- Delivery-related lifecycle detail variants include `provider`.
- Delivery-related lifecycle detail variants include `provider_message_id` when available.
- Fields are optional for pre-send lifecycle states and required for post-attempt states where provider interaction occurred.
- Documentation should define normalization rules for provider identity naming.

## Current Next Question

Continue the grill from Decision 71.

Suggested next topic: whether provider identity should be a free-form string or a governed enum plus optional provider sub-id.

### Decision 72: Provider Identity Type

Question: Should `provider` be a free-form string, or a governed enum with optional provider sub-id/account key?

Answer: Use a governed enum plus optional sub-id.

Rationale: Free-form provider names drift and break metrics, alerting, and audits. A governed enum gives stable dimensions, while a sub-id supports tenant/account/routing context.

Implications:

- Provider identity uses a stable enum.
- Provider sub-id/account key is optional and used when available.
- Validators reject `PROVIDER_UNSPECIFIED` when provider interaction has occurred.
- Documentation should define naming and usage conventions for provider sub-id values.

## Current Next Question

Continue the grill from Decision 72.

Suggested next topic: whether provider delivery statuses should be a compact normalized enum only, or enum plus optional provider-native status code.

### Decision 73: Provider Status Representation

Question: Should provider delivery status be only a normalized enum, or a normalized enum plus optional provider-native status code?

Answer: Use normalized enum plus optional provider-native status code.

Rationale: Narada requires stable cross-provider state semantics for orchestration, retry, and lifecycle transitions. Operations and support still need provider-native detail for debugging and reconciliation without rehydrating raw provider payloads.

Implications:

- Delivery events include normalized status enum.
- Delivery events may include provider-native status code.
- Normalized status is required for state-machine decisions.
- Provider-native status is optional and informational.
- Documentation should define how provider-native codes map to normalized status.

## Current Next Question

Continue the grill from Decision 73 in auto-accept mode.

Suggested next topic: define the normalized provider status enum set for v1.

### Decision 74: Normalized Provider Status Enum (v1)

Question: What normalized provider status set should v1 use?

Answer: Use a bounded orchestration-focused enum:

```proto
enum ProviderDeliveryStatus {
  PROVIDER_DELIVERY_STATUS_UNSPECIFIED = 0;
  PROVIDER_DELIVERY_STATUS_ACCEPTED_GATEWAY = 1;
  PROVIDER_DELIVERY_STATUS_ACCEPTED_PROVIDER = 2;
  PROVIDER_DELIVERY_STATUS_REJECTED_PROVIDER = 3;
  PROVIDER_DELIVERY_STATUS_SENT = 4;
  PROVIDER_DELIVERY_STATUS_DELIVERED = 5;
  PROVIDER_DELIVERY_STATUS_BOUNCED = 6;
  PROVIDER_DELIVERY_STATUS_FAILED_RETRYABLE = 7;
  PROVIDER_DELIVERY_STATUS_FAILED_FINAL = 8;
  PROVIDER_DELIVERY_STATUS_TIMED_OUT = 9;
}
```

Rationale: This covers the Narada lifecycle state machine and retry policy needs while staying provider-agnostic.

### Decision 75: DeliveryEvent Time Model

Question: Which timestamps should be required on delivery events?

Answer: Include both `provider_event_time` and `observed_at`; require `observed_at`, allow optional `provider_event_time`.

Rationale: Provider callbacks are often delayed or missing provider timestamps. `observed_at` is always available and operationally reliable.

### Decision 76: Idempotency Key Constraint Profile

Question: Should idempotency keys enforce a concrete shape?

Answer: Yes. Require non-blank ASCII-safe string with bounded length (recommended `16..128`) and forbid whitespace-only values.

Rationale: Prevent ambiguous or low-entropy keys while preserving producer flexibility.

### Decision 77: Request And Event IDs

Question: What ID format should be recommended for `request_id`, `event_id`, and major task IDs?

Answer: UUIDv7 string format is recommended and validated in contract helpers.

Rationale: Time-sortability and strong uniqueness align with replay, timeline, and audit workflows.

### Decision 78: Header Presence Policy

Question: Which Kafka headers are mandatory for top-level flows?

Answer: Require `traceparent`, `tenantId`, `correlationId`, `causationId`, `schemaVersion`, `messageType`, `producerService`. Allow `tracestate` optional.

Rationale: This enforces traceability, tenancy, schema routing, and producer attribution.

### Decision 79: Header/Payload Conflict Handling

Question: How should conflicts between header and payload identity fields be handled?

Answer: Hard fail for tenant mismatch, warn/fail by policy for trace mismatch, and record both values in validation output.

Rationale: Tenant mismatch is a security and routing violation. Trace mismatch is serious but may be transitional during migrations.

### Decision 80: Notification Channel Enum Scope

Question: Should channel enum include only current channels or extension placeholders?

Answer: Include only active channels in v1 (`EMAIL`, `SMS`, `PUSH`, `WEBHOOK`) plus `UNSPECIFIED`.

Rationale: Avoid speculative enum pollution and keep compatibility discipline clear.

### Decision 81: Locale Field Standard

Question: How should locale be represented in template references?

Answer: `locale` is BCP-47 string with validator normalization checks.

Rationale: Cross-language, widely understood, and future-proof for localization workflows.

### Decision 82: Template Variables Contract

Question: Should template variables be untyped map or structured entries?

Answer: Structured typed variable entries with bounded keys and typed values, aligned with metadata value model.

Rationale: Prevent stringly-typed rendering errors and preserve cross-language consistency.

### Decision 83: Retry Budget Ownership

Question: Should retry budgets be in contracts or service config?

Answer: Service config owns retry budgets; contracts carry attempt context and retry hints only.

Rationale: Retry policy is operational and environment-specific.

### Decision 84: DLQ Payload Convention

Question: What must DLQ payloads include?

Answer: Original message envelope reference, failure context, attempt counters, trace/tenant identity, and stage identifier.

Rationale: Enables deterministic replay and incident triage without DB-only dependency.

### Decision 85: Replay Event Annotation

Question: How should replay operations be represented?

Answer: Lifecycle replay events must include replay actor, causation link, and original failed stage/event reference.

Rationale: Replay without provenance undermines auditability.

### Decision 86: Validation Rule IDs

Question: Should validation rules expose stable IDs?

Answer: Yes. All contract validation rules must have stable `ruleId` values and documentation links.

Rationale: Stable IDs make CI, dashboards, and support tooling durable across language SDKs.

### Decision 87: Compatibility Review Gate

Question: Should proto PRs require an explicit compatibility checklist outcome?

Answer: Yes. CI plus required checklist items in PR template for field number reuse, enum reuse, reserved fields, and package versioning.

Rationale: Mechanical checks are necessary but not sufficient for schema governance.

### Decision 88: Generated Constants Governance

Question: How should topic/header constants evolve?

Answer: Source-of-truth manifests under `contracts/` with generated constants; direct edits in generated files are forbidden.

Rationale: Prevent drift and preserve deterministic regeneration.

### Decision 89: Snapshot Version Naming

Question: What snapshot naming should be used?

Answer: Maven `X.Y.Z-SNAPSHOT`; npm `X.Y.Z-snapshot.<runNumber>` from `master` snapshot workflow.

Rationale: Clear immutable release separation and predictable consumer behavior.

### Decision 90: Publish Preflight Matrix

Question: What publish preflights are mandatory?

Answer: SemVer input validation `vX.Y.Z`, tag non-existence, committed version match, clean generation diff, full CI pass, registry version non-existence.

Rationale: Prevent immutable release collisions and partial publishes.

## Decision Matrix Tracker

This condensed matrix is the implementation-facing view of the accepted decisions.

| Area | Decision |
|---|---|
| Repo boundary | Separate sibling repo `sutradhar`, default branch `master` |
| Build orchestration | Single Gradle root orchestrates Buf + JVM + TS + Go workflows |
| Languages | JVM + TypeScript/JS + Go are first-class |
| Publishing | Maven + npm via GitHub Packages; Go via repo tags/modules |
| Release control | Manual immutable release workflow with validated `vX.Y.Z` input |
| Snapshots | Separate `master` workflow, Maven/npm only |
| Versioning | One release version across targets; proto package versions independent |
| Compatibility | Buf mandatory; breaking checks against `master` baseline |
| Generated outputs | Commit TS/Go generated outputs, never commit JVM generated classes |
| Freshness gates | CI fails on stale generation and stale constants |
| Topic/header constants | Manifest-driven generated constants in all languages |
| Validation model | Hybrid: shared rule manifests + per-language validator impls |
| Validation output | Enterprise structured errors, collect-all default |
| IDs | UUIDv7-recommended identifiers for request/event/task lineage |
| Lifecycle envelope | Single typed `LifecycleEvent` with `event_id`, `sequence_number`, `causation_event_id`, actor attribution |
| Trace/tenant | Both header + payload with strict tenant mismatch hard-fail |
| Targets | Direct sendable target data required; structured `RecipientRef` also included |
| Webhook/push | Support ref and raw destination forms; raw forms policy-controlled |
| Sensitivity | Shared `SensitivityClass`; explicit on variable containers and metadata entries |
| Failure model | Structured namespaced failure codes + retry hints + sanitized messages |
| Provider model | Governed provider enum + optional sub-id + normalized status + native code |
| Template versioning | Explicit `oneof` selector for exact version vs latest-active with audit fields |

## Current Next Question

Continue from Decision 90 in auto-accept mode.

Suggested next topic: concrete repository file layout and first commit sequence for implementation.
