# macOS Permission Execution Report

**Date:** 2026-07-27  
**Mission:** Eliminate repeated macOS permission dialogs  
**Result:** Complete

## Evidence-led decision

Existing workspace, resolver, twin, and snapshot services duplicated protected
folder access. The existing candidate `ProtectedFolderAccessCoordinator` was
extended as the canonical owner rather than introducing a parallel service.
Runtime metrics and Executive Shell behavior were preserved.

## Implemented diff

- Hardened `SUPRA/ProtectedFolderAccessCoordinator.swift` with cache-first
  restoration, transactional explicit scans, bookmarks, stale rejection, and
  balanced scoped access.
- Converted `SUPRA/WorkspaceDiscovery.swift` to snapshot-only consumption.
- Kept `SUPRA/WorkspaceConfiguration.swift` defaults empty with auto-scan off.
- Removed the protected Desktop fallback from
  `SUPRA/CAnnoNicoIntegrationBridge.swift`.
- Added `SUPRATests/ProtectedFolderAccessCoordinatorTests.swift`.
- Consolidated DataTwin, DeveloperTwin, EnvironmentResolver, Workspace
  discovery/indexing, EnvironmentWorldModel, and CAnnoNico snapshot behavior as
  coordinator-cache consumers.
- `Package.swift`, Runtime foundations, Executive Shell, and Xcode project
  configuration were not changed for this objective.

## Metrics

- Canonical protected-folder coordinators: **1**
- Protected-folder enumerator authorities: **1**
- Automatic protected-root scan paths: **0**
- Focused tests: **7 passed / 0 failed**
- Consecutive prompt-free GUI launches: **3**
- Final application build: **SUCCEEDED**
- Known unrelated baseline failures: **3**

## Technical debt

The permission objective has no known blocking debt. The full test suite retains
three pre-existing unrelated failures:
`testFallbackScenario`, `testINDEX_FILE_EXCLUDED_FROM_SCAN`, and
`testUNCHANGED_FILES_NOT_REPARSED`. They are explicitly excluded from this
permission freeze and must be handled by a separate mission.

## Decision log

1. Reuse and harden the candidate coordinator.
2. Make consumers cache-only.
3. Permit authorization only after explicit Discover intent.
4. Reject stale or failed scoped access without scanning or automatic retry.
5. Freeze only after focused tests, repeated GUI launch validation, and final
   build success.
