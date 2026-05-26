package v1

import "testing"

func TestUpgradeParityRuleIDStability(t *testing.T) {
	e := BuildValidationError("common.idempotency.scope.required", "idempotency.scope", "ERROR")
	if e.RuleID != "common.idempotency.scope.required" {
		t.Fatalf("unexpected rule id: %s", e.RuleID)
	}
	if e.Code != "SH_WHOA_SUTRADHAR.common.idempotency.scope.required" {
		t.Fatalf("unexpected code: %s", e.Code)
	}
}
