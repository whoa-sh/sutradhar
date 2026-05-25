package v1

type ValidationError struct {
	Code     string `json:"code"`
	Message  string `json:"message"`
	Path     string `json:"path"`
	Severity string `json:"severity"`
	Category string `json:"category,omitempty"`
	RuleID   string `json:"ruleId"`
}

func BuildValidationError(ruleID string, path string, severity string) ValidationError {
	return ValidationError{
		Code:     "SH_WHOA_SUTRADHAR." + ruleID,
		Message:  "validation failed",
		Path:     path,
		Severity: severity,
		RuleID:   ruleID,
	}
}

