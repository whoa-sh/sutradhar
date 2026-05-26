# Sensitivity and PII Handling

## Purpose

Define contract-level expectations for sensitive destination data and message metadata.

## Classification Model

Sensitivity is modeled with governed enums in contracts, not free-form labels.

Key rule:

- Data that can directly identify or contact a recipient is sensitive by default.

## Destination Fields

Policy choices already encoded in contracts:

1. Webhook targets:
   - prefer endpoint reference fields.
   - raw URLs are allowed only under explicit policy control.
2. Push targets:
   - support both reference and raw token.
   - raw token use is restricted to authorized producers.
3. Delivery request paths can include raw destination values only when required for orchestration.

## Metadata Constraints

Use typed metadata entries (`MetadataEntry`) with explicit sensitivity per entry.

Do not use:

- `map<string,string>` for sensitive operational metadata
- `google.protobuf.Any` for uncontrolled extension payloads

## Logging and Error Surfaces

Validation and failure message requirements:

- include sanitized operator-safe message in shared error/failure context
- keep raw provider details separately classified
- avoid leaking raw tokens, raw URLs, email addresses, or phone numbers in broad logs

## Producer Responsibilities

1. Set correct sensitivity enum for target and metadata fields.
2. Prefer reference-style destination fields where available.
3. Ensure policy authorization before sending raw destination fields.

## Consumer Responsibilities

1. Respect sensitivity classifications when storing or logging payloads.
2. Apply stricter access controls for sensitive payload paths.
3. Preserve sensitivity fields in onward events.

