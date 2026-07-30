# Lessons Learned

## Architectural findings

Repeated macOS privacy prompts were caused by automatic, duplicated access to
protected roots rather than by a single defective dialog. One authority, one
traversal, and one persisted snapshot removed the retry loop while preserving
consumer capabilities.

Cache-first startup is the safe default: load the persisted environment
snapshot, render the UI, and represent an unscanned environment explicitly.
Absence of cache or authorization must not be interpreted as permission to
scan.

Authorization and discovery are separate concerns. `NSOpenPanel` belongs only
to an explicit user action. Consumers such as workspace discovery must read the
coordinator snapshot and must never open permission UI themselves.

Security-scoped access is a balanced operation. Bookmark creation and
resolution, successful `startAccessingSecurityScopedResource()`, exactly one
matching stop, and stale-bookmark rejection are all required for a durable
authorization contract.

## Assumptions validated

- Executive Runtime capabilities can consume cached filesystem metadata without
  owning filesystem traversal.
- Runtime metrics and passive refresh do not require Desktop, Documents, or
  Downloads access.
- Explicit reauthorization is preferable to automatic retry after denial,
  revocation, or stale bookmark detection.
- The existing coordinator could be hardened without a parallel architecture.

## Risks and safeguards

- A future consumer could reintroduce direct enumeration or authorization UI.
  Focused source-invariant tests should remain mandatory.
- Revoked or stale bookmarks require user action; this is expected behavior and
  must remain visible rather than silently retried.
- Focused success does not imply complete-suite success. The three unrelated
  deterministic baseline failures remain explicit debt.
- Moving authorization into background timers would recreate the original
  failure mode.

## Recommendation

Preserve `ProtectedFolderAccessCoordinator` as the sole protected-folder owner,
keep consumers cache-only, and require the focused 7-test permission suite,
application build, and repeated prompt-free launches for future changes.

This handoff is documentation-only. It includes no source, `Package.swift`,
Xcode project, Runtime, or Executive Shell changes and is not staged or
committed.
