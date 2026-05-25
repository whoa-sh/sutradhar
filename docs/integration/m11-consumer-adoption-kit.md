# M11 Consumer Adoption Kit

This guide provides minimal runnable consumer examples for JVM, TypeScript, and Go, plus the expected adoption sequence for downstream services (including Narada feature branches).

## What M11 Adds

- `examples/jvm/.../M11ConsumerExample.java`
- `examples/typescript/consumer-example.mjs`
- `examples/go/main.go`
- smoke scripts:
  - `scripts/smoke-examples.sh`
  - `scripts/smoke-examples.ps1`

## Run Examples

Unix-like:

```bash
./scripts/smoke-examples.sh
```

Windows PowerShell:

```powershell
.\scripts\smoke-examples.ps1
```

## Adoption Sequence (Recommended)

1. Consume snapshot artifacts first from `master` during feature integration.
2. Validate constants + validation helper usage at service boundaries.
3. Migrate to immutable `vX.Y.Z` release tags before production rollout.
4. Keep service-side retry/backoff policy in service config; use contract hints only as guidance.

## Compatibility Guardrails

- Do not break existing `v1` wire contracts in place.
- Additive changes in `v1`; breaking changes must move to `v2`.
- Keep contract manifests (`contracts/*.yaml`) and generated TS/Go outputs in sync on every change.
