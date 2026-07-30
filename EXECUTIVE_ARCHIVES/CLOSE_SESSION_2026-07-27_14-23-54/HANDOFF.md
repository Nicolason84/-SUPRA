# SUPRA macOS Permission Refactor — Handoff

Date: 2026-07-27

## Implemented Architecture

`ProtectedFolderAccessCoordinator` is the canonical owner of `NSOpenPanel`,
permission state, security-scoped bookmarks, authorized roots, protected-folder
traversal, scan orchestration, and snapshot caching. Existing data, developer,
environment, workspace, and CAnnoNico consumers read its cached snapshot.
Automatic protected-folder discovery was removed from launch.

## Modified Files

- `SUPRA/ProtectedFolderAccessCoordinator.swift` (created)
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

## Validation Actually Completed

- Debug build: `BUILD SUCCEEDED`.
- Three consecutive post-refactor launches displayed no protected-folder dialog.
- Static inspection verified coordinator consumption in the scoped path.

## Validation Not Completed

- End-to-end explicit Discovery.
- Demonstrated `NSOpenPanel` presentation.
- Real security-scoped scan and cache inspection.
- Bookmark refresh after restart.
- Denied and stale authorization paths.
- Automated tests, full navigation/regression testing, and performance measurement.

## Remaining Risks

The explicit authorization flow is not runtime-proven. Other repository enumerators
remain outside this mission's scope. Disabled startup services could reintroduce
privacy prompts if restored without individual audits. The working tree was already
dirty and substantially untracked.

## Recommended Next Mission

Use a disposable fixture directory to complete the permission acceptance matrix:
panel, authorization, scan, cache, access release, restart, bookmark refresh,
cancellation, denial, and stale recovery. Add focused coordinator tests afterward.
Do not redesign Runtime or the Executive Shell.

Nothing was staged or committed.
