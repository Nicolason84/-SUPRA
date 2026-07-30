# macOS Permission Refactor — Final Report

Date: 2026-07-27

## Implemented Architecture

`ProtectedFolderAccessCoordinator` is the canonical boundary for protected-folder
access. It owns:

- explicit folder selection through `NSOpenPanel`;
- permission state;
- security-scoped bookmark persistence and resolution;
- authorized root normalization;
- the single protected-folder recursive traversal;
- snapshot cache persistence and loading;
- scan orchestration and scoped-resource lifetime.

The intended explicit scan lifecycle is:

```text
User requests discovery
→ NSOpenPanel
→ selected roots
→ security-scoped bookmarks
→ startAccessingSecurityScopedResource()
→ canonical traversal
→ cached ProtectedFolderSnapshot
→ stopAccessingSecurityScopedResource()
```

Security-scoped access is released with `defer`. Cached snapshots can be loaded
without reopening their protected roots.

The data twin, developer twin, environment resolver, workspace discovery,
CAnnoNico snapshot store, and environment world model consume coordinator data
instead of owning protected-folder recursion. Workspace automatic scanning is
disabled by default. Launch-time calls that could initiate environment discovery
or broad passive scanning were removed. Hardware storage reporting no longer
probes Desktop or Documents.

Runtime foundations and the Executive Shell were not redesigned.

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

Created implementation file:

- `SUPRA/ProtectedFolderAccessCoordinator.swift`

The repository already had a dirty and substantially untracked worktree. This list
records files touched during this mission; it does not attribute unrelated
repository changes to the refactor.

## Validation Actually Completed

- A Debug build was run with:

  ```text
  xcodebuild -project /Users/nicolasalonso/Desktop/NOVA_OS/SUPRA/SUPRA.xcodeproj \
    -scheme SUPRA \
    -configuration Debug \
    -derivedDataPath /private/tmp/SUPRA_PRIVACY_REFACTOR_DERIVED \
    build
  ```

- The build completed with `BUILD SUCCEEDED`.
- A cold launch after the final startup narrowing reached the Executive Shell
  without a protected-folder dialog.
- A second launch reached the Executive Shell without a protected-folder dialog.
- A third launch reached the Executive Shell without a protected-folder dialog.
- Static inspection confirmed that the scoped consumer path delegates
  protected-folder data to `ProtectedFolderAccessCoordinator`.
- Static search confirmed that the canonical recursive protected-folder traversal
  in the refactored path is located in the coordinator.

An earlier launch before the final startup narrowing did display a permission
dialog. The remaining broad startup calls were narrowed afterward, followed by a
successful rebuild and the three clean launches listed above.

## Validation Not Completed

- The final explicit Discovery interaction was not completed.
- `NSOpenPanel` presentation was not successfully demonstrated in the final
  validation sequence.
- Selecting a folder and completing a real security-scoped scan was not
  demonstrated.
- Snapshot cache contents after a manual scan were not inspected.
- Bookmark restoration and `refreshAuthorizedRoots()` after restart were not
  demonstrated.
- Denied authorization was not exercised.
- Stale-bookmark handling was not exercised.
- A full navigation test was not completed.
- Performance measurement was not completed.
- Automated unit or UI tests for the coordinator were not executed.
- The entire repository was not proven free of unrelated folder enumerators.

## Remaining Risks

- The explicit user-authorized flow could still contain an integration or UI issue
  not exposed by compilation or clean-launch testing.
- Security-scoped bookmark creation, restoration, denial, and staleness require
  runtime verification.
- Other enumerators exist outside the scoped refactor path. A disabled startup
  service could reintroduce implicit protected-folder access if restored without
  an audit.
- Broad startup services were disabled to establish the privacy boundary. Their
  absence may reduce nonessential background capabilities until they are audited.
- Existing Swift concurrency warnings remain.
- The dirty/untracked repository state complicates attribution and integration.

## Recommended Next Mission

Run a focused macOS permission acceptance mission without redesigning the
architecture:

1. Create a disposable fixture directory outside sensitive user data.
2. Invoke Discovery and verify `NSOpenPanel`.
3. Authorize only the fixture directory.
4. Confirm one scan, correct cache output, and immediate scoped-access release.
5. Restart and explicitly refresh the bookmarked root.
6. Exercise cancellation, denial, and stale-bookmark recovery.
7. Add dependency-injected coordinator unit tests.
8. Audit each disabled startup service before restoring it individually.

No files were staged or committed.

