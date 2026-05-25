export function buildValidationError(ruleId, path, severity) {
  return {
    code: `SH_WHOA_SUTRADHAR.${ruleId}`,
    message: "validation failed",
    path,
    severity,
    ruleId,
  };
}

