# SUPRA macOS Privacy Refactor V1 — Final Report

Date: 2026-07-27
Build status: **BUILD SUCCEEDED**

## Implemented Architecture

The refactor introduced `ProtectedFolderAccessCoordinator` as the single owner of
protected-folder authorization, security-scoped bookmarks, authorized roots,
recursive traversal, scan orchestration, and cached snapshots.

Protected-folder discovery is now designed as an explicit user action:

```text
Discovery request
→ NSOpenPanel
→ authorization
→ temporary security-scoped access
→ one canonical traversal
→ snapshot cache
→ access release
```

The coordinator's cached `ProtectedFolderSnapshot` is consumed by:

- `SUPRADataTwin`
- `SUPRADeveloperTwin`
- `SUPRAEnvironmentResolver`
- `WorkspaceDiscovery`
- `CAnnoNicoSnapshotStore`
- `SUPRAEnvironmentWorldModel`

Automatic workspace scanning is disabled by default. Launch no longer starts the
environment refresh or broad passive startup services that could transitively
touch protected folders. Hardware storage reporting no longer probes Desktop or
Documents. Runtime foundations and the Executive Shell remain intact.

## Modified Files

- `SUPRA/SUPRAOperationalCoreApp.swift`
- `SUPRA/SUPRAEnvironmentWorldModel.swift`
- `SUPRA/SUPRAEnvironmentCommandCenterView.swift`
- `SUPRA/SUPRADataTwin.swift`
- `SUPRA/SUPRADeveloperTwin.swift`
- `SUPRA/SUPRAEnvironmentResolver.swift`
- `SUPRA/SUPRAHardwareTwin.swift`
- `SUPRA/WorkspaceConfiguration.swift`
- `SUPRA/WorkspaceDiscovery.swift`
- `SUPRA/CAnnoNicoSnapshotStore.swift`

Created:

- `SUPRA/ProtectedFolderAccessCoordinator.swift`

The working tree was already dirty and substantially untracked. The list above
records the mission's touched implementation files without claiming ownership of
unrelated changes.

## Validation Actually Completed

- Debug compilation and linking with a dedicated Derived Data directory.
- Final build result: `BUILD SUCCEEDED`.
- One post-refactor cold launch without a protected-folder permission dialog.
- A second launch without a protected-folder permission dialog.
- A third launch without a protected-folder permission dialog.
- Executive Shell launch smoke observation.
- Static inspection of the named consumers.
- Static search of recursive enumeration ownership in the refactored path.

The first launch before final startup-path narrowing still showed a permission
dialog. Startup calls were narrowed, the app was rebuilt, and the subsequent three
launches were clean.

## Validation Not Completed

- Successful interaction with the final Discovery control.
- Final demonstration that Discovery presents `NSOpenPanel`.
- Real folder selection and completed security-scoped scan.
- Inspection of the resulting cached snapshot.
- Restart followed by bookmark-backed refresh.
- Cancellation, denied-access, and stale-bookmark scenarios.
- Full navigation and regression suites.
- Performance measurements.
- Automated coordinator unit or UI tests.

The final accessibility automation attempt failed to resolve the application's
button tree. No end-to-end Discovery validation is claimed.

## Remaining Risks

- The explicit discovery path is compiled but not demonstrated end to end.
- Bookmark persistence and restoration behavior remains runtime-unverified.
- Unrelated enumerators elsewhere in the repository remain outside this mission's
  scope.
- Disabled startup services must not be restored until each is proven not to touch
  protected folders implicitly.
- Existing Swift concurrency warnings remain.
- The dirty/untracked working tree increases integration risk.

## Recommended Next Mission

Perform a narrowly scoped permission acceptance test using a disposable fixture
directory. Demonstrate panel presentation, authorization, one scan, cache output,
scoped-access release, restart, bookmark refresh, cancellation, denial, and stale
bookmark recovery. Then add dependency-injected coordinator tests and audit startup
services one at a time before selectively restoring them.

No files were staged or committed.

