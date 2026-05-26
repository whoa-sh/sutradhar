# Compatibility Policy

## Versioning Rules

- Contract packages use namespace versioning (`.../v1`, `.../v2`).
- Additive, wire-compatible changes are allowed within the same package version.
- Wire-breaking changes require a new package version namespace.
- Repository release tags use SemVer format `vX.Y.Z`.

## Allowed Changes In Existing `v1` Packages

- Add new message types.
- Add new optional fields with unique field numbers.
- Add new enum values at the end (never renumber existing values).
- Add new oneof variants with new field numbers.
- Add comments and non-wire documentation metadata.

## Breaking Changes (Forbidden In Existing `v1`)

- Renaming/removing existing fields or messages.
- Reusing or renumbering field tags.
- Changing scalar/message types for existing fields.
- Moving fields into/out of oneof in incompatible ways.
- Deleting or renumbering enum values.

## Deprecation Discipline

- Mark deprecated fields/messages first; do not remove in the same major contract line.
- Removal is only allowed in a newer package namespace (`v2+`) after migration guidance is published.

## Enforcement

- `buf lint` enforces schema style and correctness.
- `buf breaking --against '.git#branch=master'` enforces compatibility on PRs.
- Generation freshness checks ensure committed generated TS/Go outputs match current proto.
