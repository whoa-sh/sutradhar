SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

.DEFAULT_GOAL := help

.PHONY: help dev proto-lint generate verify smoke-examples prototype preflight-release suite-local suite-contracts suite-examples

help:
	@printf '%s\n' "Sutradhar make targets"
	@printf '%s\n' "  make dev                              - quick local bootstrap checks"
	@printf '%s\n' "  make proto-lint                       - run buf lint when buf.yaml exists"
	@printf '%s\n' "  make generate                         - run buf generate when buf.gen.yaml exists"
	@printf '%s\n' "  make verify                           - run local verification script"
	@printf '%s\n' "  make smoke-examples                   - run JVM + TypeScript + Go examples"
	@printf '%s\n' "  make prototype                        - lint + generate + verify (non-release loop)"
	@printf '%s\n' "  make preflight-release VERSION=vX.Y.Z - release preflight checks"
	@printf '%s\n' ""
	@printf '%s\n' "Command suites"
	@printf '%s\n' "  make suite-contracts                  - proto-lint + generate"
	@printf '%s\n' "  make suite-examples                   - smoke-examples"
	@printf '%s\n' "  make suite-local                      - suite-contracts + verify + suite-examples"

dev:
	@./scripts/dev.sh

proto-lint:
	@if [ -f "buf.yaml" ]; then \
		command -v buf >/dev/null 2>&1 || { echo "buf.yaml present but buf CLI missing."; exit 1; }; \
		buf lint; \
	else \
		echo "[skip] proto-lint: buf.yaml not present yet"; \
	fi

generate:
	@if [ -f "buf.gen.yaml" ]; then \
		command -v buf >/dev/null 2>&1 || { echo "buf.gen.yaml present but buf CLI missing."; exit 1; }; \
		buf generate; \
		echo "[ok] buf generate"; \
	else \
		echo "[skip] generate: buf.gen.yaml not present yet"; \
	fi

verify:
	@./scripts/verify.sh

smoke-examples:
	@./scripts/smoke-examples.sh

prototype: proto-lint generate verify
	@printf '%s\n' "[ok] prototype loop complete"

suite-contracts: proto-lint generate
	@printf '%s\n' "[ok] suite-contracts complete"

suite-examples: smoke-examples
	@printf '%s\n' "[ok] suite-examples complete"

suite-local: suite-contracts verify suite-examples
	@printf '%s\n' "[ok] suite-local complete"

preflight-release:
	@if [ -z "$${VERSION:-}" ]; then \
		echo "Set VERSION=vX.Y.Z. Example: make preflight-release VERSION=v0.1.0"; \
		exit 1; \
	fi
	@./scripts/release-preflight.sh "$${VERSION}"
