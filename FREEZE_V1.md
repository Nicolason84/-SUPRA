# SUPRA macOS Privacy Refactor — Freeze V1

Date: 2026-07-27
Status: **BUILD PASS**

## Canonical Architecture

`ProtectedFolderAccessCoordinator` is the sole canonical owner of protected-folder
authorization and traversal.

```text
Explicit user action
        |
        v
ProtectedFolderAccessCoordinator
  - NSOpenPanel
  - permission state
  - security-scoped bookmarks
  - authorized roots
  - one recursive traversal
  - persisted snapshot cache
        |
        v
ProtectedFolderSnapshot
        |
        +--> SUPRADataTwin
        +--> SUPRADeveloperTwin
        +--> SUPRAEnvironmentResolver
        +--> WorkspaceDiscovery
        +--> CAnnoNicoSnapshotStore
        +--> SUPRAEnvironmentWorldModel
```

No consumer may recursively enumerate Desktop, Documents, Downloads, or another
user-selected protected root. Consumers derive their state from the coordinator's
cached snapshot.

## Design Decisions

- Protected-folder access is opt-in and initiated only by explicit user action.
- Launch loads operational state and cached data without resolving bookmarks or
  enumerating protected folders.
- Security-scoped access is temporary and paired with `defer`-guaranteed release.
- Bookmark data and snapshots are persisted separately and atomically in SUPRA's
  Application Support directory.
- Selected roots are standardized, symlinks are resolved, and nested duplicates are
  collapsed before scanning.
- Traversal skips package descendants, ignores most hidden entries, does not descend
  into `.git`, and is bounded to eight levels below an authorized root.
- Workspace configuration defaults to no scan paths and disabled automatic scans.
- Environment auto-refresh has no immediate refresh side effect and is not started
  by application launch.
- Broad startup services that could transitively touch protected paths remain
  disabled until individually audited.
- Runtime foundations and the Executive Shell were not redesigned.

## Interfaces

### Data types

`ProtectedFolderEntry`

- `path`
- `authorizedRootPath`
- `name`
- `pathExtension`
- `isDirectory`
- `sizeBytes`
- `createdAt`
- `modifiedAt`

`ProtectedFolderSnapshot`

- `generatedAt`
- `authorizedRootPaths`
- `entries`
- `static empty`

### Coordinator state

`ProtectedFolderAccessCoordinator.PermissionState`

- `notRequested`
- `authorized`
- `denied`
- `stale`

Published read-only state:

- `permissionState`
- `snapshot`
- `isScanning`
- `lastError`

## Public APIs

```swift
static let shared: ProtectedFolderAccessCoordinator

@discardableResult
func requestDiscovery() -> ProtectedFolderSnapshot?

@discardableResult
func scanExplicitlySelectedURLs(
    _ urls: [URL]
) throws -> ProtectedFolderSnapshot

@discardableResult
func refreshAuthorizedRoots() -> ProtectedFolderSnapshot?

func entries(under rootPath: String? = nil) -> [ProtectedFolderEntry]

func containsPath(_ path: String) -> Bool
```

The injectable initializer is available for focused tests:

```swift
init(
    fileManager: FileManager,
    supportDirectory: URL?,
    startScopedAccess: @escaping (URL) -> Bool,
    stopScopedAccess: @escaping (URL) -> Void,
    makeBookmark: @escaping (URL) throws -> Data
)
```

Consumers should use `shared.snapshot`, `entries(under:)`, or `containsPath(_:)`.
Only explicit discovery UI should call `requestDiscovery()`. A user-requested
refresh of previously authorized roots may call `refreshAuthorizedRoots()`.

## Runtime Impacts

- Application launch no longer starts environment auto-refresh.
- Application launch no longer triggers CAnnoNico snapshot refresh.
- Automatic workspace discovery is disabled by default.
- Data and developer twins now report from cached protected-folder data.
- Environment resolution uses authorized cached paths.
- Hardware storage metrics no longer probe Desktop or Documents.
- Discovery remains available through the Environment Command Center and invokes
  the canonical authorization flow.
- Runtime, mission loading, decision loading, metrics, and Executive Shell startup
  remain available.

## Migration Notes

- Delete direct protected-root traversal from any new or existing subsystem.
- Replace path discovery with coordinator snapshot queries.
- Do not add Desktop, Documents, or Downloads to default scan paths.
- Do not resolve bookmarks at launch.
- Do not retain a security-scoped resource across scans.
- If a consumer needs additional metadata, extend `ProtectedFolderEntry` and the
  single canonical traversal rather than introducing another scanner.
- If a service is restored to startup, prove through static audit and cold-launch
  validation that it does not transitively touch protected folders.
- Existing cached snapshots are safe to load without opening their source roots.
- Stale bookmarks require explicit user reauthorization.

## Freeze Evidence

- Dedicated Debug build: `BUILD SUCCEEDED`.
- Three consecutive post-refactor launches: no protected-folder dialog observed.
- Static audit: one protected-folder traversal in the refactored architecture.
- Explicit Discovery interaction remains a documented follow-up validation item.

This freeze records the code state at mission completion. Nothing was staged or
committed as part of the freeze package.

