import test from "node:test";
import assert from "node:assert/strict";
import { buildValidationError } from "./validation.mjs";

test("rule IDs remain stable for compatibility-sensitive checks", () => {
  const e = buildValidationError("common.idempotency.scope.required", "idempotency.scope", "ERROR");
  assert.equal(e.ruleId, "common.idempotency.scope.required");
  assert.equal(e.code, "SH_WHOA_SUTRADHAR.common.idempotency.scope.required");
});
