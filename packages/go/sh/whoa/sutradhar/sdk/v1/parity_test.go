package v1

import (
	"encoding/json"
	"path/filepath"
	"os"
	"testing"
)

type fixture struct {
	Cases []struct {
		RuleID       string `json:"ruleId"`
		Path         string `json:"path"`
		Severity     string `json:"severity"`
		ExpectedCode string `json:"expectedCode"`
	} `json:"cases"`
}

func TestValidationFixtureParity(t *testing.T) {
	data, err := os.ReadFile(filepath.Join("..", "..", "..", "..", "..", "..", "..", "contracts", "fixtures", "validator-fixtures.json"))
	if err != nil {
		t.Fatalf("read fixtures: %v", err)
	}
	var fx fixture
	if err := json.Unmarshal(data, &fx); err != nil {
		t.Fatalf("parse fixtures: %v", err)
	}
	for _, c := range fx.Cases {
		e := BuildValidationError(c.RuleID, c.Path, c.Severity)
		if e.Code != c.ExpectedCode {
			t.Fatalf("expected code %s, got %s", c.ExpectedCode, e.Code)
		}
		if e.RuleID != c.RuleID || e.Path != c.Path {
			t.Fatalf("fixture mismatch for rule %s", c.RuleID)
		}
	}
}
