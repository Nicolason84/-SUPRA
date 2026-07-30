# Work Summary

**Date:** 2026-07-27  
**Objective:** Eliminate repeated macOS protected-folder permission dialogs  
**Status:** Complete

## Completed work

- Established `ProtectedFolderAccessCoordinator` as the sole authority and
  enumerator for user-selected protected folders.
- Made application launch cache-first, with no automatic Desktop, Documents, or
  Downloads traversal.
- Restricted `NSOpenPanel` to the explicit Discover action.
- Implemented security-scoped bookmark creation and resolution, required scoped
  access before scanning, paired start/stop access, and rejected stale
  bookmarks without scanning.
- Converted workspace, environment, twin, discovery, indexing, and CAnnoNico
  consumers to cached-snapshot consumption.
- Removed automatic scan roots and protected-path fallback behavior.
- Added focused coordinator and consumer-invariant coverage.
- Updated the canonical permission reports, continuity documents, and
  `Freeze/SUPRA_EXECUTIVE_FREEZE_V4.md`.

## Validation evidence

- Focused permission tests: **7/7 passed**
- Final application build: **succeeded**
- Consecutive GUI launches without a privacy prompt: **3**
- Canonical protected-folder authority: **1**
- Automatic protected-folder scan paths: **0**

## Unfinished work

The permission objective has no known unfinished implementation work. The full
test suite still has three deterministic, pre-existing, unrelated failures:

- `SUPRARuntimeProviderProofTests.testFallbackScenario`
- `testINDEX_FILE_EXCLUDED_FROM_SCAN`
- `testUNCHANGED_FILES_NOT_REPARSED`

## Scope statement

No `Package.swift`, Xcode project, Runtime foundation, or Executive Shell
redesign occurred. This documentation handoff added Markdown only; it made no
source changes and was not staged or committed.
