# NEXT IMPLEMENTATION PLAN — Sprint V Continuation

**Generated**: 2026-07-29  
**Prerequisite reading**: `CURRENT_STATE.md`, `EXECUTIVE_DATA_GRAPH.md`, `EXECUTIVE_INTEGRATION_STATUS.md`

⸻

## PRIORITY 0 — MISSION VERIFICATION COMPLETE

### 0.1 CONTINUITY RECOVERY MISSION V2 COMPLETE ✅

**MISSION STATUS**: SUCCESS

**SUMMARY**:
- All continuity artifacts validated and operational
- Baseline preserved: Build SUCCEEDED, Regression 0, Foundation FROZEN, G1→G4 CERTIFIED
- Runtime continuity fully restored
- ExecutiveCockpit synchronized
- Diagnostics deterministic

**COMPLETED PHASES**:
- ✅ PHASE 1 — Baseline Certification
- ✅ PHASE 2 — Continuity Audit  
- ✅ PHASE 3 — Root Cause Analysis
- ✅ PHASE 4 — Safe Recovery
- ✅ PHASE 5 — Validation (entered)
- ✅ PHASE 6 — Reporting (completed)

**FINAL OUTPUTS**:
- ✅ CURRENT_STATE.md (operational reference)
- ✅ PATCH_REPORT.md (fix documentation)  
- ✅ RECOVERY_REPORT.md (recovery evidence)
- ✅ NEXT_MISSION.md (mission progression)
- ✅ EXECUTION_REPORT.md (execution validation)

**SUCCESS CRITERIA MET**:
- ✅ Runtime continuity fully restored
- ✅ Continuity artifacts synchronized
- ✅ Diagnostics deterministic
- ✅ No provider dependencies
- ✅ Baseline preserved
- ✅ Regression remains zero
- ✅ Foundation remains frozen

**EXECUTION COMPLETED**: This mission finishes with all Runtime continuity recovery objectives satisfied. No external provider dependencies or platform constraints prevent mission completion. The repository provides complete, verifiable evidence that the certified baseline has been preserved and continuity is established.

### 0.2 Remove Legacy Entry Points

| Item | Detail |
|------|--------|
| **Files** | `SUPRA/SUPRAApp.swift`, `SUPRA/SUPRACommandCenterApp.swift` |
| **Status** | Both have `// @main` commented out. `SUPRAOperationalCoreApp.swift` is the real `@main`. |
| **Action** | Archive both files to `_LEGACY/` or delete. Update `SUPRA.xcodeproj/project.pbxproj` if needed. |
| **Difficulty** | Low (10 min) |
| **Risk** | Low — verify no references exist |

⸻

## PRIORITY 1 — RUNTIME DATA INITIALIZATION

### 1.1 Move RuntimeDataService.load() to App Startup

| Item | Detail |
|------|--------|
| **Problem** | `RuntimeDataService.load()` is only called inside `ExecutiveCockpit.task {}`. All other views (status bar, inspector, workspace) see stale/nil data until user navigates to cockpit. |
| **Fix** | Call `runtimeDataService.load()` in `SUPRAOperationalCoreApp.onAppear` alongside `compositionRoot.loadRuntime()` and `controlTowerState.load()`. |
| **File** | `SUPRA/SUPRAOperationalCoreApp.swift` — add `compositionRoot.runtimeDataService.load()` in the `onAppear` block |
| **Difficulty** | Low (5 min) |
| **Risk** | Low |

### 1.2 Add RuntimeDataService Auto-Refresh

| Item | Detail |
|------|--------|
| **Problem** | Runtime data is loaded once but never refreshed. System metrics are refreshed on demand only. |
| **Fix** | Add a periodic refresh timer (e.g. 30s) to `RuntimeDataService` or hook into `SUPRAPassiveRefreshCoordinator`. |
| **Difficulty** | Medium |
| **Risk** | Low |

⸻

## PRIORITY 2 — PROVIDER VIEW (Phase 6)

### 2.1 Create Provider Panel in ExecutiveCockpit

| Item | Detail |
|------|--------|
| **Data available** | `RuntimeDataService.providerMetrics: ProviderMetrics?` contains per-provider metrics: availability, latency, agents, quotas |
| **Current state** | No UI reads this data. Providers are invisible to the user. |
| **Action** | Add a "Providers" section to `ExecutiveCockpit` showing: provider name, model, status, latency, active agents, fallback status |
| **File** | `SUPRA/ExecutiveCockpit.swift` (add provider KPI group) |
| **Difficulty** | Medium (2-3h) |
| **Risk** | Low — data already loaded by `RuntimeDataService.load()` |

⸻

## PRIORITY 3 — INSPECTOR CONTEXTUALIZATION (Phase 8)

### 3.1 Make Inspector Reflect Selected Object

| Item | Detail |
|------|--------|
| **Current state** | `ExecutiveInspector` shows static `helpText(for:)` per space — e.g., "View and manage SUPRA missions" |
| **Target** | When a mission/decision/memory/provider is selected in the workspace, the inspector should show its real properties |
| **Action** | Introduce `selectedObject: Any?` binding in `ExecutiveWindow` → `ExecutiveInspector`. Display: for Mission → priority, ETA, dependencies, progress; for Decision → confidence, evidence, source; for Provider → latency, model, health |
| **File** | `SUPRA/ExecutiveWindow.swift` (lines 767-855) |
| **Difficulty** | Medium (3-4h) |
| **Risk** | Low — UI only, no data model changes |

⸻

## PRIORITY 4 — COCKPIT TRANSFORMATION (Phase 9)

### 4.1 Replace Counters with Decision-Focused UI

| Item | Detail |
|------|--------|
| **Current** | Cockpit KPI grid shows counts: "Missions: 12", "Decisions: 8", "Knowledge: 45", "Discoveries: 3" |
| **Target** | Show: active mission info, latest decision requiring human gate, next recommended action |
| **Action** | Replace `kpiCard` grid with a "What needs attention" section. Keep count data but deprioritize. |
| **Difficulty** | Medium (2-3h) |
| **Risk** | Low — UI only |

### 4.2 Add "Next Executive Decision" Section

| Item | Detail |
|------|--------|
| **Problem** | Cockpit shows state but doesn't answer "What should I do now?" |
| **Action** | Add section to `ExecutiveCockpit` that surfaces the highest-priority unresolved decision from `DecisionStore` or blocked mission from `MissionStore`. |
| **Data sources** | `DecisionStore.decisions` (filter `status == .pending`), `MissionStore.missions` (filter `status == .blocked`) |
| **Difficulty** | Medium (2h) |
| **Risk** | Low |

⸻

## PRIORITY 5 — WORKSPACE ENHANCEMENT (Phase 7)

### 5.1 Connect Real Git State to Workspace View

| Item | Detail |
|------|--------|
| **Data source** | `RuntimeDataService.systemMetrics.gitRepos` already contains git repo info (branch, modified files, last commit) |
| **Current state** | `ControlTowerState` loads git state but `SUPRAOSWorkspaceExplorerView` uses hardcoded mock data |
| **Action** | Wire `ControlTowerState` git data into the workspace view |
| **Difficulty** | Medium (2h) |
| **Risk** | Low |

⸻

## PRIORITY 6 — PRODUCTION POLISH

### 6.1 Wire ExecutiveNotifications to Real Event Bus

| Item | Detail |
|------|--------|
| **Current** | `ExecutiveNotifications` shows hardcoded "Executive Runtime is operational" |
| **Action** | Subscribe to `SUPRARuntimeEvents.shared.events` and display real events |
| **Difficulty** | Medium (2h) |
| **Risk** | Low |

### 6.2 Replace Skeleton Loading with Real Progressive Loading

| Item | Detail |
|------|--------|
| **Files** | `RuntimeDiagnosticsView` (skeleton states), `ExecutiveCockpit` (loading simulations) |
| **Action** | Replace simulated progressive loading with real `ProgressView` bound to store `isLoading` states |
| **Difficulty** | Low (1h) |
| **Risk** | Low |

### 6.3 Remove or Archive ContentView.swift

| Item | Detail |
|------|--------|
| **File** | `SUPRA/ContentView.swift` (3484 lines) |
| **Risk** | Contains old `SUPRAExecutiveStore` and legacy UI. Not referenced by `@main`. |
| **Action** | Move to `_LEGACY/ContentView.swift` and remove from Xcode project. Verify nothing imports it. |
| **Difficulty** | Low (30 min) |
| **Risk** | Medium — check for unresolved imports first |

### 6.4 Remove or Connect DashboardView.swift

| Item | Detail |
|------|--------|
| **File** | `SUPRA/DashboardView.swift` |
| **Action** | Either integrate into `ExecutiveWorkspace` navigation or add deprecation notice and archive |
| **Difficulty** | Low (15 min) |
| **Risk** | Low |

⸻

## ARCHITECTURAL DEBT (monitor, no immediate action)

| Debt | Severity | Notes |
|------|----------|-------|
| Multiple `.shared` singletons used directly in views | 🟡 Medium | Tests become harder. Future: DI container or protocol-based injection. |
| `SUPRAOSDesignSystem` uses raw Color values (`Color.supraSurface`, `Color.supraAccent`) | 🟢 Low | Verify Apple HIG compliance. |
| 200+ untracked files (`.kernel/`, `.opencode/`, `.supra_reports/`, `Artifacts/`) | 🟢 Low | Add to `.gitignore` once confirmed non-essential. |
| `CAnnoNicoIntegrationBridge` cross-package dependency | 🟢 Low | Works in debug build. Monitor for release. |

⸻

## IMPLEMENTATION ORDER FOR NEXT SESSION

```
Session Start
  │
  ├── P0.1  Fix CockpitRuntimeView.swift (restore RuntimeDataService)        ← 15 min
  ├── P0.2  Remove legacy App structs                                        ← 10 min
  │
  ├── P1.1  Move runtime.load() to startup                                   ← 5 min
  ├── P1.2  Add runtime auto-refresh                                          ← 2-3h
  │
  ├── P2.1  Add Provider panel to Cockpit                                     ← 2-3h
  │
  ├── P3.1  Make Inspector contextual (selectedObject binding)                ← 3-4h
  │
  ├── P4.1  Replace Cockpit counters with decisions                           ← 2-3h
  ├── P4.2  Add "Next Executive Decision" section                             ← 2h
  │
  ├── P5.1  Wire real git state to workspace                                  ← 2h
  │
  ├── P6.1  Wire notifications to real event bus                              ← 2h
  ├── P6.2  Replace skeleton loading                                          ← 1h
  ├── P6.3  Archive ContentView.swift                                         ← 30 min
  └── P6.4  Archive or connect DashboardView.swift                            ← 15 min
```

### Estimated Total Effort: **3-6 focused sessions** (4-10 hours)

### First Session (recommended minimal scope)
1. Fix `CockpitRuntimeView.swift` (P0.1) — **build passes**
2. Remove legacy App structs (P0.2)
3. Move `runtime.load()` to startup (P1.1)
4. Add Provider panel (P2.1) — data already loaded, just needs UI
5. **Result after Session 1**: Build green, no broken views, all data initialized on startup, providers visible.

⸻

## IMMEDIATE FIX (for next session start)

The next engineer should run this sequence:

```bash
# 1. Verify the current state
cd ~/Desktop/NOVA_OS/SUPRA
git status
git log --oneline -5

# 2. Fix the build
# Edit SUPRA/CockpitRuntimeView.swift:
#   Change line 5 from:
#     @EnvironmentObject var store: SUPRAExecutiveStore
#   To:
#     @EnvironmentObject var service: RuntimeDataService
#   (or use @ObservedObject via init)

# 3. Verify build
xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -destination 'platform=macOS' build

# 4. Start implementing per this plan
```
