# Contract Support Matrix

| Package | Status | Compatibility Promise |
|---|---|---|
| `common.v1` | Active | Additive-only within `v1`; breaking changes require `v2`. |
| `notification.v1` | Active | Additive-only within `v1`; breaking changes require `v2`. |
| `template.v1` | Active | Additive-only within `v1`; breaking changes require `v2`. |
| `provider.v1` | Active | Additive-only within `v1`; breaking changes require `v2`. |
| `preference.v1` | Active | Additive-only within `v1`; breaking changes require `v2`. |

## Artifact Guarantees

- JVM: helper surfaces published; generated protobuf classes are not committed.
- TypeScript: generated outputs are committed and versioned with release tags.
- Go: generated outputs are committed; release tags are module-consumption anchors.

## Consumer Upgrade Rule

- Consumers may safely adopt patch/minor releases within the same package namespace (`v1`) without wire-breaking changes.
