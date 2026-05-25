package sh.whoa.sutradhar.sdk.v1;

import java.util.List;

public final class ContractConstants {
    public static final List<String> TOPIC_NAMES = List.of(
            "notification.requests.critical",
            "notification.requests.high",
            "preference.events.state.v1"
    );

    public static final List<String> HEADER_NAMES = List.of(
            "tenantId",
            "traceparent",
            "producerService"
    );

    private ContractConstants() {
    }
}

