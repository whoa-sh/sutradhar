package sh.whoa.sutradhar.sdk.v1;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class UpgradeParityTest {
    @Test
    void ruleIdMappingStaysStable() {
        ValidationError e = ValidationError.build("common.idempotency.scope.required", "idempotency.scope", "ERROR");
        assertEquals("common.idempotency.scope.required", e.ruleId());
        assertEquals("SH_WHOA_SUTRADHAR.common.idempotency.scope.required", e.code());
    }
}
