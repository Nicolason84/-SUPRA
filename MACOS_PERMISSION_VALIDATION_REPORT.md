# macOS Permission Validation Report

**Date:** 2026-07-27  
**Objective result:** **PASS**  
**Build:** **PASS**

## Acceptance evidence

| Check | Result |
|---|---|
| Cold, warm, and repeated launch avoid protected access | PASS |
| Three consecutive GUI launches show no privacy prompt | PASS |
| Desktop/Documents/Downloads are not scanned automatically | PASS |
| Workspace discovery and refresh are cache-only | PASS |
| One protected-folder coordinator/enumerator authority | PASS |
| Explicit Discover is the only `NSOpenPanel` path | PASS |
| Bookmark create/resolve/scoped start/paired stop | PASS |
| Stale bookmark rejection without scan | PASS |
| Empty-cache state avoids scan and prompt | PASS |
| Focused coordinator tests | **7/7 PASS** |
| Final `xcodebuild` application build | **SUCCEEDED** |

Validated scenarios cover cache-first restoration, explicit temp-root scanning,
access failure without bookmark/cache replacement, balanced scoped access,
`.git` metadata handling, empty snapshot consumption, consumer-source
invariants, and disabled workspace defaults. Tests use temporary directories
and injected scoped-access seams, so they do not invoke TCC dialogs.

## Apple compliance

Folder selection is user initiated through
[NSOpenPanel](https://developer.apple.com/documentation/appkit/nsopenpanel).
Persistent access uses bookmark creation and resolution plus balanced
security-scoped resource access, consistent with Apple's
[sandbox file-access guidance](https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox).

## Baseline test debt

The full suite is **not** fully passing. Three deterministic, pre-existing,
unrelated failures remain:

- `SUPRARuntimeProviderProofTests.testFallbackScenario`
- `ConversationMemory` — `testINDEX_FILE_EXCLUDED_FROM_SCAN`
- `ConversationMemory` — `testUNCHANGED_FILES_NOT_REPARSED`

These failures do not exercise protected-folder authorization. This report does
not claim total regression-free status.

## Remaining risks

- Revoked bookmarks correctly require explicit user reauthorization; this is an
  expected operational state, not an automatic recovery path.
- The three unrelated baseline failures require separate ownership.
- Future consumers could regress by adding direct enumeration; the focused
  source-invariant test guards the named protected-folder consumers.
