import { CONTRACT_TOPICS, CONTRACT_HEADERS } from "../../packages/typescript/src/sdk/constants.mjs";

console.log("Sutradhar TypeScript consumer example");
console.log(`Topic: ${CONTRACT_TOPICS.notificationRequested}`);
console.log(`Header: ${CONTRACT_HEADERS.traceId}`);
