import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import { buildValidationError } from "./validation.mjs";

test("validation fixture parity", () => {
  const raw = fs.readFileSync("../../contracts/fixtures/validator-fixtures.json", "utf8");
  const fixtures = JSON.parse(raw);
  for (const c of fixtures.cases) {
    const e = buildValidationError(c.ruleId, c.path, c.severity);
    assert.equal(e.code, c.expectedCode);
    assert.equal(e.ruleId, c.ruleId);
    assert.equal(e.path, c.path);
  }
});
