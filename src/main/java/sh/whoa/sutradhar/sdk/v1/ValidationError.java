package sh.whoa.sutradhar.sdk.v1;

public record ValidationError(
        String code,
        String message,
        String path,
        String severity,
        String category,
        String ruleId
) {
    public static ValidationError build(String ruleId, String path, String severity) {
        return new ValidationError(
                "SH_WHOA_SUTRADHAR." + ruleId,
                "validation failed",
                path,
                severity,
                null,
                ruleId
        );
    }
}

