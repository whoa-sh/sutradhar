# Producer and Consumer Onboarding

## Purpose

Use this guide to integrate with Sutradhar contracts without reading Narada implementation code.

## Required Message Headers

Set these headers on every produced message:

- `tenantId`
- `traceparent`
- `correlationId`
- `causationId`
- `schemaVersion`
- `messageType`
- `producerService`

Optional header:

- `tracestate`

Header names are defined in `contracts/headers.yaml`.

## Topic Selection

Topics are governed in `contracts/topics.yaml`.

Producer rules:

1. Pick topic by business stage and priority.
2. Ensure message payload contract matches the topic family.
3. Do not invent unregistered topics.

Common examples:

- Notification request ingress:
  - `notification.requests.critical`
  - `notification.requests.high`
  - `notification.requests.normal`
  - `notification.requests.low`
- Preference projection events:
  - `preference.events.state.v1`

## Idempotency Model

Use `common.v1.IdempotencyContext` for dedupe-safe producers.

Required semantics:

- `source_system`: stable producer identity
- `source_event_id`: event identity from producer source-of-truth
- `idempotency_key`: dedupe key for retries/replays
- `dedupe_scope`: explicit scope (`tenant`, `recipient`, `campaign`, etc. as encoded by enum)

Do not omit scope. Scope is part of correctness, not metadata decoration.

## Validation Error Handling

Validation rules are governed in `contracts/validation.yaml`. Rule IDs are stable and language-neutral.

Error model fields:

- `code`
- `message`
- `path`
- `severity`
- `category` (optional)
- `ruleId`
- `expected` (optional)
- `actual` (optional)
- `constraint` (optional)
- `documentationUrl` (optional)

Default mode is collect-all: producers should expect multiple validation errors in one response.

## Consumer Contract Handling

Consumer rules:

1. Parse by package version (`.../v1` namespaces).
2. Reject unknown or unsupported breaking versions.
3. Treat unknown enum values defensively.
4. Preserve correlation and causation identities in downstream emissions.

## Local Integration Verification

Before opening a PR:

- Unix-like: `./scripts/verify.sh`
- PowerShell: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\verify.ps1`

## Version Alignment For Release Consumers

Release preparation uses Gradle version as source-of-truth.

1. Set release version in `build.gradle.kts`.
2. Sync TypeScript package version from Gradle:
   - Unix-like: `make sync-version`
   - PowerShell: `make -f Makefile.windows sync-version`
3. Validate release version consistency:
   - Unix-like: `./scripts/validate-version.sh vX.Y.Z`
   - PowerShell: `.\scripts\validate-version.ps1 -Version vX.Y.Z`
