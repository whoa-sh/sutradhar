# Rollback Runbook

## Scope

Operational rollback guidance for bad contract/package releases.

## Core Rule

Do not delete published release artifacts or tags. Use forward-fix releases.

## Scenarios

## 1) Snapshot Breakage

Symptoms:

- Consumer integration fails against snapshot builds.

Actions:

1. Stop consuming latest snapshot in dependent services.
2. Pin to previous known-good snapshot or release.
3. Fix contracts on a new commit to `master`.
4. Allow snapshot workflow to publish corrected snapshot.

## 2) Production Release Breakage (Maven/npm)

Symptoms:

- Consumer failures after adopting `vX.Y.Z`.

Actions:

1. Pause rollout in downstream services.
2. Revert consumer dependency to previous stable release.
3. Prepare forward-fix contracts.
4. Release `vX.Y.(Z+1)` with fix.

Never republish same immutable version.

## 3) Bad Tag Created

If tag points to incorrect commit but no package release happened:

1. Stop and assess blast radius.
2. If no external consumption, coordinate repository admin action.
3. Prefer releasing a corrective higher version instead of rewriting history.

## Incident Data to Capture

- failing rule IDs
- failing topic/message type
- impacted tenants/channels
- first bad version
- fixed-by version

