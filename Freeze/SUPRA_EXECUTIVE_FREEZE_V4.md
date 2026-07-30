# SUPRA Executive Freeze V4 — macOS Protected-Folder Access

| Field | Value |
|---|---|
| Date | 2026-07-27 |
| Objective | Eliminate repeated macOS protected-folder permission dialogs |
| Objective status | **FROZEN / PASS** |
| Application build | **SUCCEEDED** |
| Focused tests | **7/7 PASS** |
| GUI launch proof | **3 consecutive launches, no privacy prompt** |

## Frozen boundary

`ProtectedFolderAccessCoordinator` is the sole authority and enumerator for
user-selected protected folders. Application launch loads its persisted cache
before rendering and performs no Desktop, Documents, or Downloads access.
Consumers use its snapshot only. Authorization UI is available only from the
explicit Discover action.

Bookmarks are created after successful scoped scanning, resolved with security
scope, rejected when stale, and wrapped in balanced start/stop access. Denial,
cancellation, stale authorization, and absent cache never cause automatic
retry.

`Package.swift`, Runtime foundations, Executive Shell, and Xcode project
configuration are outside this freeze and were untouched.

## Evidence

- `MACOS_PERMISSION_ARCHITECTURE_REPORT.md`
- `MACOS_PERMISSION_VALIDATION_REPORT.md`
- `MACOS_PERMISSION_EXECUTION_REPORT.md`
- `SUPRATests/ProtectedFolderAccessCoordinatorTests.swift`
- Focused tests: 7 passed, 0 failed
- Final `xcodebuild`: succeeded

## Baseline debt exclusion

This is a permission-objective freeze, not a claim that the complete suite is
green. Three deterministic pre-existing unrelated failures remain:

- `SUPRARuntimeProviderProofTests.testFallbackScenario`
- `testINDEX_FILE_EXCLUDED_FROM_SCAN`
- `testUNCHANGED_FILES_NOT_REPARSED`

Future protected-folder changes require a new mission, focused authorization
tests, prompt-loop validation, and a successful application build.
