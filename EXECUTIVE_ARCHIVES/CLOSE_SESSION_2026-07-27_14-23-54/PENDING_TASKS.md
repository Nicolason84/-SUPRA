# Pending Tasks

## Current status

The macOS permission objective is complete and frozen. The canonical state is:

- one `ProtectedFolderAccessCoordinator`
- cache-first launch
- explicit-Discover `NSOpenPanel`
- security-scoped bookmarks and balanced scoped access
- stale authorization rejected without scanning
- cache-only consumers
- 7/7 focused tests passed
- final application build succeeded
- three consecutive launches produced no privacy prompt

## Next engineering task

Resolve the three deterministic, pre-existing failures under a separate,
evidence-led mission:

1. `SUPRARuntimeProviderProofTests.testFallbackScenario`
2. `testINDEX_FILE_EXCLUDED_FROM_SCAN`
3. `testUNCHANGED_FILES_NOT_REPARSED`

These failures are unrelated to protected-folder authorization. Until they are
resolved, do not claim that the full suite passes or that the repository is
totally regression-free.

## Continuing safeguards

- Do not add direct protected-folder enumeration to consumers.
- Do not invoke `NSOpenPanel` from launch, refresh, discovery, or indexing.
- Do not retry denied, revoked, or stale authorization automatically.
- Preserve cache restoration before any protected-folder access.
- Re-run focused permission tests, final build, and repeated GUI launch checks
  after relevant changes.
- Avoid `Package.swift`, Xcode project, Runtime, or Executive Shell redesign
  unless separately authorized and supported by evidence.

## Handoff note

No permission implementation work remains pending. This documentation step
created only `WORK_SUMMARY.md`, `LESSONS_LEARNED.md`, and `PENDING_TASKS.md`.
It made no source changes and did not stage or commit files.
