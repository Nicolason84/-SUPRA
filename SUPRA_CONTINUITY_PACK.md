# SUPRA Continuity Pack

**Canonical state:** 2026-07-27  
**Current freeze:** `Freeze/SUPRA_EXECUTIVE_FREEZE_V4.md`

## Restored state

The macOS permission objective is complete. Protected-folder access has one
canonical owner, `ProtectedFolderAccessCoordinator`. Launch and passive refresh
load cached data only. Desktop, Documents, and Downloads are accessed only
after explicit Discover selection through `NSOpenPanel`.

## Validation

- focused permission tests: **7/7 PASS**
- final application build: **SUCCEEDED**
- three consecutive GUI launches: **no privacy prompt**
- automatic protected-folder scans: **0**
- `Package.swift`: **untouched**

The complete suite retains three unrelated baseline failures:
`SUPRARuntimeProviderProofTests.testFallbackScenario`,
`testINDEX_FILE_EXCLUDED_FROM_SCAN`, and
`testUNCHANGED_FILES_NOT_REPARSED`.

## Recovery order

1. `AGENTS.md`
2. `Freeze/SUPRA_EXECUTIVE_FREEZE_V4.md`
3. `SUPRA_CONTINUITY_PACK.md`
4. `SESSION_SUMMARY.md`
5. `NEXT_MISSION.md`

Detailed evidence is in the three `MACOS_PERMISSION_*_REPORT.md` files.
