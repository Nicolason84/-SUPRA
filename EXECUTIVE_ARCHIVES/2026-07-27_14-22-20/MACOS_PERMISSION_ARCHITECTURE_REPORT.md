# macOS Protected-Folder Architecture

**Date:** 2026-07-27  
**Status:** Canonical

## Decision

`ProtectedFolderAccessCoordinator` is the single authority for Desktop,
Documents, Downloads, and any other user-selected protected root.

```text
Launch → load cached snapshot → render
Explicit Discover → NSOpenPanel → bookmark → scoped scan → cache
Consumers → coordinator snapshot only
```

Launch, passive refresh, workspace indexing, environment resolution, DataTwin,
DeveloperTwin, and CAnnoNico snapshot refresh do not enumerate protected roots.
`WorkspaceDiscovery` consumes the cached snapshot and never opens authorization
UI. `WorkspaceConfiguration.default` has no scan roots and disables auto-scan.

## Authorization contract

- `NSOpenPanel` is created only by the explicit Discover action.
- A successful selected-root scan is required before bookmark persistence.
- Bookmark restoration resolves with security scope.
- `startAccessingSecurityScopedResource()` must succeed before enumeration.
- `stopAccessingSecurityScopedResource()` is paired exactly once with a
  successful start using `defer`.
- Stale bookmarks are rejected without scanning and require explicit
  reauthorization.
- Denial, cancellation, and missing cache never trigger automatic retry.

This follows Apple's [NSOpenPanel](https://developer.apple.com/documentation/appkit/nsopenpanel)
and [security-scoped resource](https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox)
guidance.

## Traversal contract

The coordinator is the sole protected-folder enumerator. It performs one
canonical traversal per authorized root, retains `.git` directory metadata,
skips `.git` descendants and other hidden trees, and persists one snapshot.
Consumers filter or project that snapshot without filesystem recursion.

## Compatibility

No Runtime or Executive Shell redesign occurred. `Package.swift` and the Xcode
project configuration were untouched.
