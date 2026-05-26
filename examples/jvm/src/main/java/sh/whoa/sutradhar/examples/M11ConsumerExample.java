package sh.whoa.sutradhar.examples;

import sh.whoa.sutradhar.sdk.v1.ContractConstants;

public final class M11ConsumerExample {
    public static void main(String[] args) {
        System.out.println("Sutradhar JVM consumer example");
        System.out.println("Topics: " + ContractConstants.TOPIC_NAMES);
        System.out.println("Headers: " + ContractConstants.HEADER_NAMES);
    }
}
