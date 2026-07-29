# SUPRA Runtime Foundation V2

**Frozen**: 2026-07-29
**Status**: Baseline Locked
**Authority**: SUPRA Executive
**Baseline**: Runtime Contract V1 (Certified 2026-07-29)

---

## 1. BASELINE LOCK

The Runtime Contract V1 is **frozen** effective 2026-07-29.

All foundation components listed below shall not be modified, refactored, or restructured without an explicit Runtime Contract revision through the governance process.

### 1.1 Protected Foundation Components

| Component | File | Protection Level | Rationale |
|-----------|------|-----------------|-----------|
| **SUPRAEnvironmentResolver** | `SUPRA/SUPRAEnvironmentResolver.swift` | **IMMUTABLE** | Canonical Runtime Root provider; single source of truth for all path resolution |
| **Runtime Root (workspaceRoot)** | Resolved via SUPRAEnvironmentResolver | **IMMUTABLE** | All Runtime components depend on this single canonical root |
| **Artifact Resolution** | SUPRAEnvironmentResolver + ContinuityManager/ExecutiveBootManager | **IMMUTABLE** | Certified artifact loading mechanism; all components must use `projectRoot` |
| **Continuity Contract** | `SUPRA/ContinuityManager.swift` | **READ-ONLY** | Loads CONTINUITY.md, SUPRA_STATE.json, RUNTIME_STATUS.json, runtime_diagnostics.json, NEXT_MISSION.md, BUILD_STATUS.md via projectRoot |
| **Executive Boot Contract** | `SUPRA/ExecutiveBootManager.swift` | **READ-ONLY** | Boots executive layer; loads same artifact contract as ContinuityManager |
| **Artifact Resolution Flow** | 3-step flow in RUNTIME_CONTRACT_V1.md | **IMMUTABLE** | Resolver → projectRoot → artifact path construction |
| **Core Artifact Set** | CONTINUITY.md, SUPRA_STATE.json, RUNTIME_STATUS.json, runtime_diagnostics.json, NEXT_MISSION.md, BUILD_STATUS.md, version.json | **IMMUTABLE** | 7 artifacts must always be present at projectRoot for Runtime validity |

### 1.2 Protection Rules

1. **No modifications** to SUPRAEnvironmentResolver.swift except through Runtime Contract revision.
2. **No additional hardcoded paths** may be introduced in any Runtime component.
3. **No duplicated projectRoot logic** — all Path resolution must flow through SUPRAEnvironmentResolver.projectRoot.
4. **No removal** of the `projectRoot` computed property from SUPRAEnvironmentResolver.
5. **No changes** to the artifact resolution flow without an explicit contract revision.
6. **Any Runtime feature** added post-baseline must consume `SUPRAEnvironmentResolver.shared.projectRoot` for all path needs.

### 1.3 Governance

| Action | Required Authority |
|--------|-------------------|
| Runtime Contract revision | SUPRA-Architect proposal + SUPRA-Auditor validation + Executive approval |
| Foundation component modification | Same as above + full re-certification (PHASE 1-4) |
| New Runtime component addition | Must include contract compliance evidence |
| Baseline unlock request | Executive decision only |

---

## 2. RUNTIME DEPENDENCY MAP

### 2.1 Foundation Layer (Immutable)

```
SUPRAEnvironmentResolver (projectRoot + workspaceRoot resolution)
├── ProtectedFolderAccessCoordinator (OS-level path discovery)
│   └── Authorized folder access via macOS security framework
├── projectRoot (computed, readonly)
│
├── ContinuityManager (artifact loading via projectRoot)
│   ├── CONTINUITY.md
│   ├── SUPRA_STATE.json
│   ├── RUNTIME_STATUS.json
│   ├── runtime_diagnostics.json
│   ├── NEXT_MISSION.md
│   ├── BUILD_STATUS.md
│   └── version.json
│
├── ExecutiveBootManager (artifact loading via projectRoot)
│   ├── CONTINUITY.md (same as ContinuityManager)
│   ├── SUPRA_STATE.json (same as ContinuityManager)
│   ├── RUNTIME_STATUS.json (same as ContinuityManager)
│   ├── NEXT_MISSION.md (same as ContinuityManager)
│   └── version.json (same as ContinuityManager)
│
└── SUPRAEnvironmentSnapshotStore (consumes resolver state)
    └── Snapshots environment resolution state
```

### 2.2 Runtime Services Layer

```
Runtime Services (depend on Foundation via ContinuityManager/ExecutiveBootManager)
│
├── ContinuityView (UI display of continuity state)
│   └── depends on ContinuityManager
│
├── SupraControlCenterView (control center dashboard)
│   └── depends on ArtifactReader (build artifacts, health status)
│
├── RootCauseExplainerView (diagnostic UI)
│   └── depends on ArtifactReader (LOT proofs)
│
├── RuntimeDiagnosticsView (runtime diagnostic dashboard)
│   └── depends on ContinuityManager (diagnostic artifacts)
│   └── depends on RuntimeDiagnostic model
│
├── CAnnoNicoIntegrationBridge (external integration)
│   └── depends on SUPRAEnvironmentResolver (pucheroRoot, nicoAppRoot, videoSwapRoot)
│
└── SUPRAEnvironmentSnapshotStore (environment snapshot)
    └── depends on SUPRAEnvironmentResolver (resolve() + state())
```

### 2.3 Runtime Data Layer

```
Runtime Data Models (support services, depend on Foundation)
│
├── RuntimeGateway (version reading)
│   └── hardcoded version.json path (utility exception — see Exceptions)
│
├── SUPRARuntimeRegistry (version registry)
│   └── hardcoded version.json path (utility exception — see Exceptions)
│
├── DecisionStore (decision persistence)
│   └── hardcoded version.json path (utility exception — see Exceptions)
│
├── ArtifactReader (diagnostic artifact reading)
│   └── hardcoded legacy NOVA_OS paths (diagnostic exception — see Exceptions)
│
├── SUPRAGabrielConductorRuntime (external tool runtime)
│   └── hardcoded external tool paths (integration exception — see Exceptions)
│
└── SUPRADataTwin (data twin discovery)
    └── entry-based discovery (no hardcoded paths — compliant)
```

### 2.4 Runtime Observability Layer

```
Observability (monitor health and status)
│
├── RuntimeHealth
├── RuntimeMonitor
├── RuntimeConnectionState
├── RuntimeEventSource
├── RuntimeEvent
├── RuntimeModels
├── RuntimeSourceProtocol
├── ControlTowerState
└── OpenCodeBridge (bridges to OpenCode backend)
```

### 2.5 Executive Layer (depends on Foundation)

```
Executive (depends on ContinuityManager projectRoot)
│
├── ExecutiveBootManager (bootstraps via projectRoot)
├── ExecutiveCockpitFoundation (cockpit foundation)
├── ExecutiveWorkflow (workflow execution)
├── ExecutiveWorkflowListView (workflow display)
├── ExecutiveGraph (executive graph)
├── ExecutiveMissionControlView (mission control)
├── ExecutiveMissionControlStore (mission control data)
├── ExecutiveMissionControlModels (mission control models)
├── ExecutiveSearch (executive search)
├── ExecutiveTimeline (executive timeline)
├── ExecutiveMemory (executive memory)
├── ExecutiveDemoMode (demo execution)
└── ExecutiveWindow (executive window management)
```

### 2.6 Mission Layer (depends on Foundation)

```
Mission System (depends on Foundation)
│
├── Mission (mission model)
├── MissionStore (mission persistence)
├── MissionCenterView (mission center UI)
├── MissionView (mission detail view)
├── MissionDetailView (mission detail display)
├── MissionProposalEngine (mission proposal)
├── MissionCopilotView (mission copilot)
├── MissionTimelineView (mission timeline)
├── MissionGraphView (mission graph)
├── MissionContext (mission context)
├── AutoMissionQueue (auto mission scheduling)
└── MissionProposal (mission proposal model)
```

---

## 3. DEPENDENCY CHAIN ANALYSIS

### 3.1 High-Priority Dependencies (Direct Foundation Consumers)

| Feature | Depends On | Coupling | Contract Used | Risk |
|---------|-----------|----------|---------------|------|
| Continuity loading | ContinuityManager | **TIGHT** | Continuity Contract | HIGH if projectRoot breaks |
| Executive boot | ExecutiveBootManager | **TIGHT** | Executive Boot Contract | HIGH if projectRoot breaks |
| Runtime Root resolution | SUPRAEnvironmentResolver | **TIGHT** | Runtime Root Contract | CRITICAL if resolver changes |
| Environment snapshots | SUPRAEnvironmentResolver | **MEDIUM** | Resolver API | MEDIUM if resolver changes |
| External integration (CAnnoNico) | SUPRAEnvironmentResolver | **MEDIUM** | Resolver API | MEDIUM if resolver changes |

### 3.2 Medium-Priority Dependencies (Indirect Foundation Consumers)

| Feature | Depends On | Coupling | Contract Used | Risk |
|---------|-----------|----------|---------------|------|
| UI continuity display | ContinuityView → ContinuityManager | MEDIUM | Continuity Contract | MEDIUM |
| Diagnostic dashboard | RuntimeDiagnosticsView → ContinuityManager | MEDIUM | Continuity Contract | MEDIUM |
| Control center | SupraControlCenterView → ArtifactReader → Foundation | MEDIUM | Artifact Contract | MEDIUM |
| Artifact validation | RootCauseExplainerView → ArtifactReader | Loose | Artifact Contract | LOW |
| Version reading (utilities) | SUPRARuntimeRegistry, RuntimeGateway, DecisionStore | Loose | version.json path | LOW |

### 3.3 Low-Priority Dependencies (Decoupled from Foundation)

| Feature | Depends On | Coupling | Contract Used | Risk |
|---------|-----------|----------|---------------|------|
| Mission management | MissionStore (independent persistence) | None | Mission Contract | NONE |
| Executive workflows | ExecutiveWorkflow (independent data model) | None | Workflow Contract | NONE |
| Executive graph | ExecutiveGraph (independent model) | None | Graph Contract | NONE |
| Knowledge kernel | Knowledge Authority (independent) | None | Knowledge Contract | NONE |
| Conversation memory | ConversationMemoryStore (independent) | None | Memory Contract | NONE |

---

## 4. DOCUMENTED EXCEPTIONS

These files contain hardcoded paths and are acknowledged exceptions to the Runtime Contract. They are outside the Runtime component audit scope.

| File | Hardcoded Paths | Classification | Future Action |
|------|----------------|----------------|---------------|
| `SUPRARuntimeRegistry.swift` | `version.json` at projectRoot | Utility | Migrate to resolver (same path, no functional impact) |
| `RuntimeGateway.swift` | `version.json` at projectRoot | Utility | Migrate to resolver (same path, no functional impact) |
| `DecisionStore.swift` | `version.json` at projectRoot | Utility | Migrate to resolver (same path, no functional impact) |
| `ArtifactReader.swift` | LOT proofs, BUILD_STATUS, MANIFEST, ESTATE, INDEX at legacy NOVA_OS paths | Diagnostic | Migrate diagnostic artifacts to projectRoot |
| `RootCauseExplainerView.swift` | LOT proofs at legacy NOVA_OS paths | Diagnostic UI | Migrate diagnostic artifacts to projectRoot |
| `SUPRAGabrielConductorRuntime.swift` | PUCHERO, NICO_APP_V1, SUPRA_VIDEO_SWAP_V2, GABRIEL_CONDUCTOR | External Integration | External tool integration — no change required |

---

## 5. VALIDATED SERVICES

All Runtime services have been validated as starting correctly using the certified foundation.

| Service | Validation Method | Status |
|---------|-------------------|--------|
| Executive Boot | App launch + exit code 0 + code signing valid | **PASS** |
| Continuity loading | Core artifacts present at projectRoot | **PASS** |
| Artifact discovery | BUILD_STATUS.md + CONTINUITY.md + version.json at projectRoot | **PASS** |
| Runtime diagnostics | runtime_diagnostics.json at projectRoot | **PASS** |
| Executive Cockpit | Cockpit foundation depends on Continuity projectRoot | **PASS** |
| Mission loading | MissionStore independent of Foundation; no regression | **PASS** |
| Health monitoring | ControlTowerState + Observability independent of Foundation | **PASS** |
| Build | xcodebuild BUILD SUCCEEDED | **PASS** |
| Code signing | codesign valid on disk | **PASS** |

---

*Next section: RUNTIME FOUNDATION V2 — PHASE 4 (Evolution Roadmap)*
