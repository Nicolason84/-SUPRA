# SUPRA Runtime Constitution V1

**Ratified**: 2026-07-29
**Status**: NORMATIVE
**Authority**: SUPRA Executive
**Amendment Process**: Formal constitutional revision (see Phase 3)

---

## ARTICLE I — RUNTIME ROOT

### §1.1 Canonical Runtime Root

The **Runtime Root** is the single source of truth for all filesystem path resolution within the SUPRA Runtime.

**Owner**: `SUPRAEnvironmentResolver` (singleton, `shared`)

**Resolution**:
- `SUPRAEnvironmentResolver.resolve()` discovers authorized filesystem roots via `ProtectedFolderAccessCoordinator`
- `workspaceRoot` is identified by a directory whose last path component is `"SUPRA"`
- `projectRoot` is derived from `workspaceRoot`

**API**:
```swift
SUPRAEnvironmentResolver.shared.projectRoot  // String
SUPRAEnvironmentResolver.shared.path(for: "workspaceRoot")  // String?
```

### §1.2 Constitution Rule

> The Runtime Root is exclusively owned by `SUPRAEnvironmentResolver.projectRoot`.
> No Runtime component shall maintain its own hardcoded filesystem path to the project root.
> No Runtime component shall resolve paths through direct string interpolation of absolute filesystem locations.

### §1.3 Prohibited Practices

- **No hardcoded absolute filesystem paths** (`/Users/`, `/home/`, etc.) in Runtime components
- **No duplicated `projectRoot` properties** — all components must consume `SUPRAEnvironmentResolver.shared.projectRoot`
- **No direct path construction** from machine-specific home directory patterns for Runtime paths

---

## ARTICLE II — RUNTIME CONTRACT

### §2.1 Continuity Contract

**Owner**: `ContinuityManager` (`SUPRA/ContinuityManager.swift`)

**Responsibility**: Load and maintain continuity artifacts from `projectRoot`.

**Mandatory Artifacts** (loaded from `\(projectRoot)/<artifact>`):

| Artifact | Path | Purpose |
|----------|------|---------|
| CONTINUITY.md | `\(projectRoot)/CONTINUITY.md` | Continuity narrative |
| SUPRA_STATE.json | `\(projectRoot)/SUPRA_STATE.json` | Runtime state |
| RUNTIME_STATUS.json | `\(projectRoot)/RUNTIME_STATUS.json` | Runtime status |
| runtime_diagnostics.json | `\(projectRoot)/runtime_diagnostics.json` | Diagnostics |
| NEXT_MISSION.md | `\(projectRoot)/NEXT_MISSION.md` | Next mission definition |
| BUILD_STATUS.md | `\(projectRoot)/BUILD_STATUS.md` | Build status |
| version.json | `\(projectRoot)/version.json` | Version metadata |

### §2.2 Executive Boot Contract

**Owner**: `ExecutiveBootManager` (`SUPRA/ExecutiveBootManager.swift`)

**Responsibility**: Bootstrap the executive layer using the same artifact contract.

**Mandatory Artifacts**: Same set as Continuity Contract (§2.1).

**Resolution**: Uses `SUPRAEnvironmentResolver.shared.projectRoot` exclusively.

### §2.3 Contract Rule

> The Continuity Contract and Executive Boot Contract use identical artifact resolution through the canonical Runtime Root. Both are read-only constitutional components.

---

## ARTICLE III — ARTIFACT CONTRACT

### §3.1 Core Artifacts

Core artifacts are the set of 7 files that MUST be present at `projectRoot` for a valid Runtime:

1. CONTINUITY.md
2. SUPRA_STATE.json
3. RUNTIME_STATUS.json
4. runtime_diagnostics.json
5. NEXT_MISSION.md
6. BUILD_STATUS.md
7. version.json

### §3.2 Diagnostic Artifacts

Diagnostic artifacts extend the core set for optional diagnostics:

- `proofs/LOT1_INSTALLATION_PROOF.json`
- `proofs/LOT2_INSTALLATION_PROOF.json`
- `proofs/LOT3_INSTALLATION_PROOF.json`
- `MANIFEST.json`
- `ESTATE_STATE.json`
- `INDEX.json`

Diagnostic artifacts are resolved at `\(projectRoot)/<artifact>` and are optional for Runtime validity.

### §3.3 Artifact Resolution Rule

> All artifact paths are constructed from `SUPRAEnvironmentResolver.shared.projectRoot + "/" + artifactName`. No artifact path may be hardcoded to an absolute filesystem location.

---

## ARTICLE IV — BOOT CONTRACT

### §4.1 Boot Sequence

The Runtime boot sequence is constitutional:

```
1. SUPRAEnvironmentResolver.resolve()
   └─ Discovers workspaceRoot via ProtectedFolderAccessCoordinator
   └─ Sets projectRoot from workspaceRoot

2. ExecutiveBootManager.load()
   └─ Reads projectRoot from SUPRAEnvironmentResolver.shared.projectRoot
   └─ Loads CONTINUITY.md, SUPRA_STATE.json, RUNTIME_STATUS.json, NEXT_MISSION.md

3. ContinuityManager.load()
   └─ Reads projectRoot from SUPRAEnvironmentResolver.shared.projectRoot
   └─ Loads same core artifact set as ExecutiveBootManager
   └─ Loads diagnostic artifacts

4. Runtime services initialize (using resolved projectRoot)
   └─ ArtifactReader reads diagnostic artifacts from projectRoot
   └─ RuntimeRegistry reads version.json from projectRoot
   └─ DecisionStore reads version.json from projectRoot
```

### §4.2 Boot Contract Rule

> The boot sequence is constitutional. No component may be added, removed, or reordered without a formal constitutional amendment.

---

## ARTICLE V — ENVIRONMENT RESOLUTION

### §5.1 Resolution Architecture

`SUPRAEnvironmentResolver` resolves the following environment identifiers:

| Identifier | Label | Scans For |
|-----------|-------|-----------|
| workspaceRoot | Workspace Root | Directory named "SUPRA" |
| novaOSRoot | NOVA OS Root | Directory named "NOVA_OS" |
| pucheroRoot | Puchero Root | Directory named "PUCHERO" |
| nicoAppRoot | Nico App Root | Directory named "NICO_APP_V1" |
| videoSwapRoot | Video Swap Root | Directory named "SUPRA_VIDEO_SWAP_V2" |
| gabrielConductorRoot | Gabriel Conductor Root | Directory named "GABRIEL_PARALLEL_MISSION_CONDUCTOR_V1" |
| desktop | Desktop | Directory named "Desktop" |
| documents | Documents | Directory named "Documents" |
| downloads | Downloads | Directory named "Downloads" |
| developer | Developer | Directory named "Developer" |
| projects | Projects | Directory named "Projects" |
| github | GitHub | Directory named "github" or "GitHub" |

### §5.2 Resolution Method

Resolution uses `ProtectedFolderAccessCoordinator.shared.snapshot` to discover authorized filesystem roots. The resolver does not hardcode any paths.

### §5.3 Extension Points

New environment identifiers may be added to SUPRAEnvironmentResolver by constitutional amendment (see ARTICLE IX).

---

## ARTICLE VI — DEPENDENCY RULES

### §6.1 Constitutional Components

The following components are constitutional and may NOT be modified without a formal constitutional revision:

| Component | File | Constitutional Property |
|-----------|------|------------------------|
| SUPRAEnvironmentResolver | `SUPRA/SUPRAEnvironmentResolver.swift` | Canonical Runtime Root owner |
| ContinuityManager | `SUPRA/ContinuityManager.swift` | Continuity Contract implementation |
| ExecutiveBootManager | `SUPRA/ExecutiveBootManager.swift` | Executive Boot Contract implementation |
| Runtime Gateway | `SUPRA/RuntimeGateway.swift` | version.json resolution |
| Runtime Registry | `SUPRA/SUPRARuntimeRegistry.swift` | version.json resolution |
| Decision Store | `SUPRA/DecisionStore.swift` | version.json resolution |
| Artifact Reader | `SUPRA/ArtifactReader.swift` | Diagnostic artifact resolution |
| Root Cause Explainer | `SUPRA/RootCauseExplainerView.swift` | Diagnostic LOT verification |
| Gabriel Conductor Runtime | `SUPRA/SUPRAGabrielConductorRuntime.swift` | External integration resolution |

### §6.2 Dependency Direction

```
SUPRAEnvironmentResolver (foundation)
│
├── ContinuityManager (depends on resolver for projectRoot)
├── ExecutiveBootManager (depends on resolver for projectRoot)
├── RuntimeGateway (depends on resolver for version.json)
├── RuntimeRegistry (depends on resolver for version.json)
├── DecisionStore (depends on resolver for version.json)
├── ArtifactReader (depends on resolver for diagnostic artifacts)
├── RootCauseExplainerView (depends on resolver for LOT proofs)
├── SUPRAGabrielConductorRuntime (depends on resolver for external paths)
├── CAnnoNicoIntegrationBridge (depends on resolver for puchero/nico/video paths)
│
└── User Interface components (depend on above resolved values)
```

### §6.3 Dependency Rule

> Dependencies flow FROM `SUPRAEnvironmentResolver` TO consuming components. No component may resolve paths independently. No component may bypass the resolver for Runtime Root resolution.

---

## ARTICLE VII — EXTENSION RULES

### §7.1 Adding New Environment Identifiers

To add a new environment identifier to `SUPRAEnvironmentResolver.resolve()`:

1. Propose through SUPRA-Architect
2. Validate through SUPRA-Auditor
3. Approve through Executive decision
4. Add to `SUPRAEnvironmentResolver.swift` in the `resolve()` method `all` array
5. Update this Constitution

### §7.2 Adding New Runtime Components

New Runtime components MUST:

1. Consume `SUPRAEnvironmentResolver.shared.projectRoot` for all Runtime Root needs
2. NOT maintain their own `projectRoot` property
3. NOT hardcode any filesystem path for Runtime resolution
4. Pass through SUPRA-Auditor validation
5. Be documented in this Constitution's Protected Surface (ARTICLE VIII)

### §7.3 Constitutional Amendments

This Constitution may only be amended through:

1. SUPRA-Architect proposal
2. SUPRA-Auditor validation of impact
3. Executive approval
4. Full re-certification of affected components
5. Version bump (V1 → V2, etc.)

---

## ARTICLE VIII — PROTECTED RUNTIME SURFACE

### §8.1 Public Responsibilities

| Component | Public Responsibility | Constitutional Status |
|-----------|----------------------|----------------------|
| SUPRAEnvironmentResolver | Resolve all Runtime filesystem paths | **IMMUTABLE** |
| ContinuityManager | Load and maintain continuity artifacts | **READ-ONLY** |
| ExecutiveBootManager | Bootstrap executive layer | **READ-ONLY** |
| RuntimeGateway | Resolve version.json at projectRoot | **READ-ONLY** |
| SUPRARuntimeRegistry | Register and resolve Runtime plugins | **READ-ONLY** |
| DecisionStore | Store and resolve decision sources | **READ-ONLY** |
| ArtifactReader | Read diagnostic artifacts from projectRoot | **READ-ONLY** |
| SUPRAGabrielConductorRuntime | Resolve external integration paths | **READ-ONLY** |
| CAnnoNicoIntegrationBridge | Resolve integration adapter paths | **READ-ONLY** |

### §8.2 Permitted Dependencies

All constitutional components depend on:
- `SUPRAEnvironmentResolver.shared` — canonical path resolution
- `Foundation` / `Combine` / `SwiftUI` — standard frameworks
- `FileManager` — filesystem operations through resolved paths only

### §8.3 Forbidden Dependencies

No constitutional component may:
- Maintain its own hardcoded filesystem path for Runtime Root
- Duplicate `projectRoot` property logic
- Reference absolute filesystem paths (`/Users/`, `/home/`, etc.) for Runtime operations
- Bypass `SUPRAEnvironmentResolver` for Runtime Root resolution

### §8.4 Extension Points

| Extension Point | Interface | Purpose |
|----------------|-----------|---------|
| New environment identifier | `SUPRAEnvironmentResolver.resolve()` → `all` array | Add new resolvable paths |
| New diagnostic artifact | `ArtifactReader` + projectRoot migration | Add diagnostic artifacts |
| New Runtime service | Must consume `SUPRAEnvironmentResolver.shared.projectRoot` | Add Runtime functionality |
| External integration | Must follow SUPRAEnvironmentResolver + NSHomeDirectory() fallback pattern | Add external tools |

---

## ARTICLE IX — COMPATIBILITY MATRIX

### §9.1 Runtime Components

| Component | Version | Contract | Status |
|-----------|---------|----------|--------|
| SUPRAEnvironmentResolver | V1 | Runtime Contract V1 | Certified |
| ContinuityManager | V1 | Runtime Contract V1 | Certified |
| ExecutiveBootManager | V1 | Runtime Contract V1 | Certified |
| RuntimeGateway | V1 | Runtime Contract V1 | Certified |
| SUPRARuntimeRegistry | V1 | Runtime Contract V1 | Certified |
| DecisionStore | V1 | Runtime Contract V1 | Certified |
| ArtifactReader | V1 | Runtime Contract V1 | Certified |
| SUPRAGabrielConductorRuntime | V1 | Runtime Contract V1 | Certified |
| CAnnoNicoIntegrationBridge | V1 | Runtime Contract V1 | Certified |
| SUPRADataTwin | V1 | Runtime Contract V1 | Certified |

### §9.2 Proposal History

| Proposal | Date | Description | Status |
|----------|------|-------------|--------|
| A | 2026-07-29 | Migrate utility files to SUPRAEnvironmentResolver | **COMPLETE** |
| B | 2026-07-29 | Migrate diagnostic files + copy artifacts to projectRoot | **COMPLETE** |
| C | 2026-07-29 | Migrate external integration paths to SUPRAEnvironmentResolver | **COMPLETE** |

### §9.3 Migration Roadmap

All hardcoded Runtime paths have been eliminated. The Runtime Foundation is canonical. Future engineering focuses on capabilities built on this foundation.

---

## ARTICLE X — GOVERNANCE RULES

### §10.1 Amendment Authority

| Action | Required Authority |
|--------|-------------------|
| Constitutional revision | SUPRA-Architect proposal + SUPRA-Auditor validation + Executive approval |
| Foundation component modification | Same as above + full re-certification |
| New Runtime component addition | Must include contract compliance evidence |
| Baseline unlock request | Executive decision only |

### §10.2 Violation Handling

| Violation | Action |
|-----------|--------|
| Hardcoded absolute Runtime path introduced | Block operation, revert, escalate to Executive |
| Runtime component bypasses SUPRAEnvironmentResolver | Flag in Proof report, mark confidence = 0 |
| Constitutional component modified without revision | Halt affected feature, require full re-certification |
| Duplicated projectRoot logic introduced | Block operation, route to SUPRA-Builder for resolver cleanup |

### §10.3 Preservation Rules

1. **Runtime Constitution V1** is normative — superseding all informal governance documents.
2. **Runtime Contract V1** (RUNTIME_CONTRACT_V1.md) is certified and frozen.
3. **Runtime Foundation V2** (RUNTIME_FOUNDATION_V2.md) documents the foundation state.
4. All three documents must be updated in lockstep for any constitutional amendment.
5. The Runtime Constitution may only be amended through the formal process defined in §7.3.

---

*SUPRA Runtime Constitution V1 — NORMATIVE*
*One Runtime Foundation. One Constitution. One Governance Model. One Evolution Path.*
