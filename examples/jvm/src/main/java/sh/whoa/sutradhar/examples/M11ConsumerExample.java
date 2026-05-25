package sh.whoa.sutradhar.examples;

import sh.whoa.sutradhar.sdk.v1.ContractConstants;

public final class M11ConsumerExample {
    public static void main(String[] args) {
        System.out.println("Sutradhar JVM consumer example");
        System.out.println("Topic: " + ContractConstants.TOPIC_NOTIFICATION_REQUESTED);
        System.out.println("Header: " + ContractConstants.HEADER_TRACE_ID);
    }
}
