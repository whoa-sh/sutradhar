# M12 Consumer CI Samples

M12 standardizes downstream adoption checks by adding a dedicated Linux CI job that runs `make suite-local`.

## CI Gate

- Workflow: `.github/workflows/ci.yml`
- Job: `consumer-samples-linux`
- Command: `make suite-local`

This gate validates:
- contract lint + generation loop,
- parity tests across JVM/TypeScript/Go,
- runnable consumer examples across JVM/TypeScript/Go.

## Local Equivalents

- Unix-like: `make suite-local`
- PowerShell: `.\scripts\verify.ps1` and `.\scripts\smoke-examples.ps1`

## Consumer Example Locations

- JVM: `examples/jvm/src/main/java/sh/whoa/sutradhar/examples/M11ConsumerExample.java`
- TypeScript: `examples/typescript/consumer-example.mjs`
- Go: `packages/go/examples/m11/main.go`
