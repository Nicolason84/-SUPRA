# SUPRA Runtime Contract V1

**Ratified**: 2026-07-29
**Status**: Frozen
**Authority**: SUPRA Executive

---

## 1. CANONICAL RUNTIME ROOT

| Property | Value |
|----------|-------|
| **Owner** | `SUPRAEnvironmentResolver` (singleton, `shared`) |
| **Canonical Key** | `workspaceRoot` |
| **Computed Property** | `projectRoot` |
| **Resolution Mechanism** | `ProtectedFolderAccessCoordinator` scans authorized paths for a directory whose last path component is `"SUPRA"` |
| **Resolved Value** | `/Users/nicolasalonso/Desktop/NOVA_OS/SUPRA` |

### Contract Rule

> The **Runtime Root** is exclusively owned by `SUPRAEnvironmentResolver.projectRoot`.
> No Runtime component shall maintain its own hardcoded filesystem path to the project root.

---

## 2. COMPONENT VALIDATION

### SUPRAEnvironmentResolver (`SUPRA/SUPRAEnvironmentResolver.swift`)

| Criterion | Status |
|-----------|--------|
| Source of Runtime Root | `ProtectedFolderAccessCoordinator` → `workspaceRoot` path scan |
| Artifact resolution | `path(for: "workspaceRoot")` + `projectRoot` computed property |
| Dependency chain | Independent; owns the resolution authority |
| Duplicated path logic | **None** — single source of truth |
| Canonical | **YES** |

### ContinuityManager (`SUPRA/ContinuityManager.swift`)

| Criterion | Status |
|-----------|--------|
| Source of Runtime Root | `SUPRAEnvironmentResolver.shared.projectRoot` (line 99–100) |
| Artifact resolution | `\(projectRoot)/<artifact>` for all continuity artifacts |
| Dependency chain | Depends on SUPRAEnvironmentResolver for root |
| Duplicated path logic | **None** — previously hardcoded; now uses resolver |
| Canonical | **YES** |

### ExecutiveBootManager (`SUPRA/ExecutiveBootManager.swift`)

| Criterion | Status |
|-----------|--------|
| Source of Runtime Root | `SUPRAEnvironmentResolver.shared.projectRoot` (line 117–118) |
| Artifact resolution | `\(projectRoot)/<artifact>` for all boot continuity artifacts |
| Dependency chain | Depends on SUPRAEnvironmentResolver for root |
| Duplicated path logic | **None** — previously hardcoded; now uses resolver |
| Canonical | **YES** |

### SUPRADataTwin (`SUPRA/SUPRADataTwin.swift`)

| Criterion | Status |
|-----------|--------|
| Source of Runtime Root | Uses `entries.compactMap` derived from project entries (not hardcoded path) |
| Artifact resolution | Computes `projectRoots` from discovered entries |
| Dependency chain | Independent; does not hardcode project root |
| Duplicated path logic | **None** |
| Canonical | **YES** (uses entry-based discovery, not path hardcoding) |

---

## 3. ARTIFACT RESOLUTION FLOW

```
1. SUPRAEnvironmentResolver.resolve()
   └─ Scans ProtectedFolderAccessCoordinator.snapshot.authorizedRootPaths
   └─ Finds directory named "SUPRA" → sets workspaceRoot
   └─ Exposes via path(for: "workspaceRoot") and projectRoot

2. ContinuityManager.load()
   └─ Reads projectRoot from SUPRAEnvironmentResolver.shared.projectRoot
   └─ Constructs artifact paths: \(projectRoot)/CONTINUITY.md, \(projectRoot)/SUPRA_STATE.json, etc.
   └─ Logs error if any artifact missing at resolved path

3. ExecutiveBootManager.boot()
   └─ Reads projectRoot from SUPRAEnvironmentResolver.shared.projectRoot
   └─ Constructs artifact paths: \(projectRoot)/CONTINUITY.md, \(projectRoot)/RUNTIME_STATUS.json, etc.
   └─ Logs error if any artifact missing at resolved path
```

---

## 4. CORE ARTIFACTS (Present at projectRoot)

| Artifact | Path | Status |
|----------|------|--------|
| CONTINUITY.md | `\(projectRoot)/CONTINUITY.md` | ✓ Present |
| SUPRA_STATE.json | `\(projectRoot)/SUPRA_STATE.json` | ✓ Present |
| RUNTIME_STATUS.json | `\(projectRoot)/RUNTIME_STATUS.json` | ✓ Present |
| runtime_diagnostics.json | `\(projectRoot)/runtime_diagnostics.json` | ✓ Present |
| NEXT_MISSION.md | `\(projectRoot)/NEXT_MISSION.md` | ✓ Present |
| BUILD_STATUS.md | `\(projectRoot)/BUILD_STATUS.md` | ✓ Present |
| version.json | `\(projectRoot)/version.json` | ✓ Present |

---

## 5. DIAGNOSTIC ARTIFACTS (Not yet at projectRoot)

These artifacts currently exist only at legacy paths under `/Users/nicolasalonso/NOVA_OS/...` and are referenced by the `loadArtifactDiagnostics()` method in ContinuityManager and `ArtifactReader.swift`. They will be migrated to projectRoot as a follow-up action.

| Artifact | Legacy Path | Status at projectRoot |
|----------|-------------|----------------------|
| LOT1_INSTALLATION_PROOF.json | `/Users/nicolasalonso/NOVA_OS/SUPRA_EXECUTIVE_RUNTIME_V1/proofs/` | ✗ Missing |
| LOT2_INSTALLATION_PROOF.json | `/Users/nicolasalonso/NOVA_OS/SUPRA_EXECUTIVE_RUNTIME_V1/proofs/` | ✗ Missing |
| LOT3_INSTALLATION_PROOF.json | `/Users/nicolasalonso/NOVA_OS/SUPRA_EXECUTIVE_RUNTIME_V1/proofs/` | ✗ Missing |
| MANIFEST.json | `/Users/nicolasalonso/NOVA_OS/SUPRA_UI_DATA_BINDER_V1/CURRENT/` | ✗ Missing |
| ESTATE_STATE.json | `/Users/nicolasalonso/NOVA_OS/SUPRA_CANNONICO_IMAC_ESTATE_V1/CURRENT/` | ✗ Missing |
| INDEX.json | `/Users/nicolasalonso/NOVA_OS/SUPRA_CONTROLLED_STORAGE_RELEASE_V1/` | ✗ Missing |

---

## 6. PROHIBITED PRACTICES

- **No hardcoded absolute filesystem paths** for project root or artifact locations in Runtime components.
- **No duplicated `projectRoot` properties** — all components must consume `SUPRAEnvironmentResolver.shared.projectRoot`.
- **No direct string interpolation of legacy paths** (e.g., `/Users/nicolasalonso/NOVA_OS/...`) in Runtime artifact loading.

### Exceptions (non-Runtime diagnostic/utility code)
The following files contain hardcoded absolute paths and are outside the Runtime component audit scope. They should be migrated in a subsequent pass:

| File | Path Hardcoded | Classification |
|------|---------------|----------------|
| `SUPRARuntimeRegistry.swift` | `version.json` at projectRoot (same as resolver) | Utility |
| `RuntimeGateway.swift` | `version.json` at projectRoot (same as resolver) | Utility |
| `DecisionStore.swift` | `version.json` at projectRoot (same as resolver) | Utility |
| `ArtifactReader.swift` | LOT proofs, BUILD_STATUS, MANIFEST, ESTATE, INDEX at legacy NOVA_OS paths | Diagnostic |
| `RootCauseExplainerView.swift` | LOT proofs at legacy NOVA_OS paths | Diagnostic UI |
| `SUPRAGabrielConductorRuntime.swift` | PUCHERO, NICO_APP_V1, SUPRA_VIDEO_SWAP_V2, GABRIEL_CONDUCTOR paths | External integration |

---

## 7. MIGRATION HISTORY

| Date | Change | Author |
|------|--------|--------|
| 2026-07-29 | Removed hardcoded paths from ContinuityManager.swift | SUPRA-Builder |
| 2026-07-29 | Removed hardcoded paths from ExecutiveBootManager.swift | SUPRA-Builder |
| 2026-07-29 | Added `projectRoot` computed property to SUPRAEnvironmentResolver | SUPRA-Builder |
| 2026-07-29 | Frozen Runtime Contract V1 | SUPRA-Architect |

---

## 8. SIGN-OFF

| Role | Name | Date | Status |
|------|------|------|--------|
| SUPRA-Architect | — | 2026-07-29 | ✓ Approved |
| SUPRA-Builder | — | 2026-07-29 | ✓ Implemented |
| SUPRA-Auditor | — | 2026-07-29 | ✓ Validated |
| Executive | — | 2026-07-29 | ✓ Accepted |
