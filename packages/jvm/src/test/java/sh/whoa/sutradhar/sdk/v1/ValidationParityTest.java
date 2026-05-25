package sh.whoa.sutradhar.sdk.v1;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.junit.jupiter.api.Test;

class ValidationParityTest {
    @Test
    void fixtureParity() throws IOException {
        String raw = Files.readString(Path.of("contracts/fixtures/validator-fixtures.json"));
        Pattern p = Pattern.compile("\"ruleId\"\\s*:\\s*\"([^\"]+)\"[\\s\\S]*?\"path\"\\s*:\\s*\"([^\"]+)\"[\\s\\S]*?\"severity\"\\s*:\\s*\"([^\"]+)\"[\\s\\S]*?\"expectedCode\"\\s*:\\s*\"([^\"]+)\"");
        Matcher m = p.matcher(raw);
        int count = 0;
        while (m.find()) {
            ValidationError error = ValidationError.build(m.group(1), m.group(2), m.group(3));
            assertEquals(m.group(4), error.code());
            count++;
        }
        assertTrue(count > 0);
    }
}

