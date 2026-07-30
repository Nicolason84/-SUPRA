# Continuity

**System:** SUPRA Executive OS  
**Updated:** 2026-07-27  
**Freeze:** `Freeze/SUPRA_EXECUTIVE_FREEZE_V4.md`

## Current canonical state

The macOS protected-folder permission objective is frozen. One
`ProtectedFolderAccessCoordinator` owns authorization, bookmarks, scoped
access, canonical traversal, and persisted cache. All named environment and
workspace subsystems are cache consumers.

Launch order is:

```text
Runtime load → protected snapshot cache load → UI render → no protected access
```

Explicit Discover is the only path to `NSOpenPanel` and protected enumeration.
Stale, denied, or missing authorization does not retry automatically.

## Proven state

- final build: **SUCCEEDED**
- focused coordinator tests: **7/7 PASS**
- repeated GUI launch proof: **3 launches, no privacy prompt**
- `Package.swift`: **untouched**

The full suite has three known pre-existing unrelated failures documented in
`MACOS_PERMISSION_VALIDATION_REPORT.md`; total regression-free status is not
claimed.

Continue with `NEXT_MISSION.md`.
