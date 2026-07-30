# EXECUTIVE DATA GRAPH — SUPRA Runtime Architecture

**Generated**: 2026-07-29  
**Session**: Executive Integration Sprint V — Freeze & Handover

⸻

## 1. COMPOSITION ROOT

```
SUPRACompositionRoot (shared singleton, @MainActor, ObservableObject)
  ├── runtimeDataService  →  RuntimeDataService.shared
  ├── missionStore        →  MissionStore()
  ├── decisionStore       →  DecisionStore()
  ├── runtimeMonitor      →  RuntimeMonitor(dataService:)
  ├── eventBus            →  SUPRARuntimeEvents.shared
  ├── controlTowerState   →  ControlTowerState(dataService:monitor:)
  └── runtimeKernel       →  SUPRARuntimeKernel.shared
```

**Injected as EnvironmentObjects** in `SUPRAOperationalCoreApp.swift`:
```
SUPRAOSProductRootView
  ├── TwinUniverse.shared
  ├── RuntimeDataService
  ├── MissionStore
  ├── DecisionStore
  ├── RuntimeMonitor
  ├── SUPRARuntimeEvents
  └── ControlTowerState
```

⸻

## 2. RUNTIME DATA SERVICE (CANONICAL RUNTIME SOURCE)

```
RuntimeDataService (ObservableObject, @MainActor, shared singleton)
  │
  ├── runtimeTrace: RuntimeTrace?           ← reads runtime_trace.json
  ├── delegationTrace: DelegationTrace?     ← reads delegation_trace.json
  ├── runtimeMetrics: RuntimeMetrics?       ← reads runtime_metrics.json
  ├── agentExecution: AgentExecution?       ← reads agent_execution.json
  ├── executionGraph: ExecutionGraph?       ← reads execution_graph.json
  ├── missionGraphMetrics: MissionGraphMetrics?  ← reads mission_graph_metrics.json
  ├── providerMetrics: ProviderMetrics?     ← reads provider_metrics.json
  ├── dashboardSnapshot: DashboardSnapshot? ← reads dashboard_snapshot.json
  │
  └── systemMetrics: SystemMetricsSnapshot  ← live collection (CPU, processes, git, storage, Xcode)
       ├── cpu: Metric<String>
       ├── heavyProcesses: Metric<[ProcessInfo]>
       ├── services: Metric<[ServiceInfo]>
       ├── projects: Metric<[ProjectInfo]>
       ├── gitRepos: Metric<[GitRepoInfo]>
       ├── storage: Metric<StorageInfo>
       └── xcode: Metric<XcodeInfo>
```

**Flow**: `load()` → reads 8 JSON files from `runtimePath` → publishes to UI via `@Published`

**Flow**: `refreshSystemMetrics()` → async system calls → publishes to `systemMetrics`

**Issue**: `load()` is only called inside `ExecutiveCockpit.task {}`. No automatic refresh outside cockpit.

⸻

## 3. STORE HIERARCHY

```
SUPRACompositionRoot
  ├── RuntimeDataService ──────────────── ExecutiveCockpit, RuntimeDiagnosticsView,
  │                                        ExecutiveInspector, ExecutiveStatusBar
  ├── MissionStore ────────────────────── MissionCenterView, MissionDetailView,
  │                                        ExecutiveCockpit (mission panel)
  ├── DecisionStore ───────────────────── SUPRADecisionRoomView, DecisionInboxView,
  │                                        DecisionDetailView, ExecutiveCockpit
  ├── RuntimeMonitor ──────────────────── (wraps OpenCodeClient) → ControlTowerState
  ├── SUPRARuntimeEvents ──────────────── (event bus) → all subscribers
  └── ControlTowerState ───────────────── SUPRAOSWorkspaceExplorerView, ExecutiveCockpit

Independent Stores (singletons, NOT in CompositionRoot):
  ├── ConversationMemoryStore ──────────── ConversationTwinView, MemoryView, MultiMemoryView
  ├── SUPRARuntimeKernel ───────────────── SUPRACompositionRoot.loadRuntime()
  ├── NOVAKnowledgeKernel ──────────────── ExecutiveGraph, ExecutiveMemory, ExecutiveTimeline,
  │                                        ExecutiveSearch
  ├── ExecutiveWorkflowRegistry ────────── ExecutiveWorkflowListView
  ├── ExecutiveMissionControlStore ─────── Mission Center (file-based agent/mission snapshots)
  ├── ExecutiveCockpitFoundation ───────── Cockpit widget system
  ├── ExecutiveBootManager ─────────────── ExecutiveBootView (boot sequence)
  ├── ContinuityManager ────────────────── RuntimeDiagnosticsView
  └── 10+ additional .shared stores ────── Various views (SUPRARecommendationEngine,
                                           SUPRAEnvironmentWorldModel, SUPRAEvolutionEngine, etc.)
```

⸻

## 4. DATA FLOW DIAGRAM

```
JSON Files (*.json in CWD or runtimePath)
    │
    ▼
RuntimeDataService.load()  [called from ExecutiveCockpit.task {} only]
    │
    ├── runtimeMetrics    ──► ExecutiveCockpit (KPI grid: pipeline duration, agents, success rate)
    ├── runtimeTrace      ──► CockpitRuntimeView (unused — broken)
    ├── agentExecution    ──► DashboardView (unused)
    ├── providerMetrics   ──► UNUSED — no provider UI exists
    ├── dashboardSnapshot ──► ExecutiveCockpit (general status)
    ├── executionGraph    ──► SceneKit/Graph views (unused)
    ├── delegationTrace   ──► UNUSED
    └── missionGraphMetrics ──► UNUSED

System Metrics:
    RuntimeDataService.refreshSystemMetrics()
    └── systemMetrics     ──► ExecutiveCockpit (CPU, processes, git, storage, Xcode)

MissionStore.load()
    │
    ├── .missions         ──► ExecutiveCockpit (mission count, active missions)
    ├── .visibleMissions  ──► MissionCenterView (library + supervision)
    └── .autoMissions     ──► SUPRAExecutionPlanner (mission classification)

DecisionStore.load()
    │
    ├── .decisions        ──► ExecutiveCockpit (decision count, pending decisions)
    ├── .visibleDecisions ──► SUPRADecisionRoomView, DecisionInboxView
    └── .decisions        ──► DecisionDetailView

ConversationMemoryStore.refresh()
    │
    ├── .conversations    ──► ConversationTwinView
    └── .conversations    ──► NOVAKnowledgeKernel (via connectToKnowledgeGraph)

SUPRARuntimeKernel.load()
    │
    └── .state            ──► PlatformState (component registry, health, dependencies, contracts)

NOVAKnowledgeKernel (aggregator)
    │
    ├── ExecutiveGraph.build(from:)    ──► ExecutiveGraphLayout
    ├── ExecutiveMemory.build(from:)   ──► [MemoryEntry]
    ├── ExecutiveTimeline.build(from:) ──► [TimelineEvent]
    └── ExecutiveSearch.search(query:) ──► [SearchResult]

ExecutiveBootManager.executeBoot()
    │
    └── bootSteps          ──► ExecutiveBootView (boot animation sequence)
```

⸻

## 5. VIEW DEPENDENCY GRAPH

```
SUPRAOperationalCoreApp
  └── SUPRAOSProductRootView
        ├── ExecutiveBootView [dep: ExecutiveBootManager]
        └── ExecutiveWindow
              ├── ExecutiveSidebar
              ├── ExecutiveWorkspace
              │     ├── .cockpit   → ExecutiveCockpit
              │     │                  [dep: RuntimeDataService, MissionStore, DecisionStore,
              │     │                   ConversationMemoryStore, SUPRARuntimeEvents,
              │     │                   ExecutiveWorkflowRegistry, ControlTowerState]
              │     ├── .workflows → ExecutiveWorkflowListView
              │     │                  [dep: ExecutiveWorkflowRegistry]
              │     ├── .missions  → MissionCenterView
              │     │                  [dep: MissionStore]
              │     │                  ├── ExecutiveMissionControlView
              │     │                  │     [dep: ExecutiveMissionControlStore]
              │     │                  └── MissionDetailView
              │     │                        [dep: Mission]
              │     ├── .knowledge → ConversationTwinView
              │     │                  [dep: ConversationMemoryStore]
              │     │                  └── MemoryView
              │     │                        [dep: ConversationMemoryStore]
              │     ├── .discovery → SUPRAEnvironmentCommandCenterView
              │     │                  [dep: SUPRARecommendationEngine, SUPRAEnvironmentWorldModel,
              │     │                   SUPRAEvolutionEngine]
              │     ├── .decisions → SUPRADecisionRoomView
              │     │                  [dep: DecisionStore]
              │     │                  ├── DecisionInboxView
              │     │                  │     [dep: DecisionStore]
              │     │                  └── DecisionDetailView
              │     │                        [dep: Decision]
              │     ├── .workspace → SUPRAOSWorkspaceExplorerView
              │     │                  [dep: ControlTowerState, RuntimeDataService]
              │     ├── .runtime   → RuntimeDiagnosticsView
              │     │                  [dep: RuntimeDataService, ContinuityManager]
              │     └── .settings  → SettingsView
              │
              └── ExecutiveInspector
                     [dep: RuntimeDataService, selected space context]
```

⸻

## 6. EXECUTIVE STORES (beyond CompositionRoot)

### ExecutiveCockpitFoundation
```
ExecutiveCockpitFoundation (ObservableObject)
  ├── activeTab: CockpitTab
  ├── state: CockpitState?
  ├── widgets: [CockpitWidget]
  └── dependencies: NOVAKnowledgeKernel, ExecutiveMemory, ExecutiveTimeline, ExecutiveGraph
```
**Role**: Widget system, tab management, state aggregation for Cockpit dashboard.
**Usage**: `ExecutiveCockpit` creates it locally (`@StateObject`).

### ExecutiveMissionControlStore
```
ExecutiveMissionControlStore (ObservableObject, .shared singleton)
  ├── runtime: ExecutiveRuntimeSnapshot?    ← runtime.json
  ├── agents: [ExecutiveAgentSnapshot]      ← agents/*.json
  ├── missions: [ExecutiveMissionSnapshot]  ← missions/*.json
  ├── timeline: [ExecutiveRuntimeEvent]     ← events/*.json
  ├── alerts: [ExecutiveRuntimeAlert]       ← alerts.json + generated
  └── dependencies: FileManager, File system monitoring
```
**Role**: Reads file-based snapshots produced by SUPRA agents.
**Used by**: `ExecutiveMissionControlView`.

### ExecutiveWorkflowRegistry
```
ExecutiveWorkflowRegistry (ObservableObject, .shared singleton)
  ├── workflows: [ExecutiveWorkflow]
  ├── executionHistory: [WorkflowExecutionRecord]
  ├── lastReport: ExecutiveReport?
  ├── lastError: String?
  └── dependencies: SUPRARuntimeLogger
```
**Role**: Manages workflow definitions, execution, and reporting.
**Used by**: `ExecutiveWorkflowListView`.

### NOVAKnowledgeKernel
```
NOVAKnowledgeKernel (ObservableObject, .shared singleton)
  ├── objects: [KnowledgeObject]
  ├── relations: [KnowledgeRelation]
  ├── governance: GovernanceEngine
  ├── bridge: MegabusBridge
  ├── isInitialized: Bool
  └── dependencies: FileManager, JSON files
```
**Role**: Central knowledge graph — aggregator for objects, relations, governance.
**Serves**: ExecutiveGraph, ExecutiveMemory, ExecutiveTimeline, ExecutiveSearch.

⸻

## 7. UNUSED / BROKEN FILES

| File | Status | Reason |
|------|--------|--------|
| `CockpitRuntimeView.swift` | ❌ Broken | References `service.*` but declares `store: SUPRAExecutiveStore`. 9 build errors. |
| `DashboardView.swift` | ❌ Unused | Never instantiated in navigation hierarchy. |
| `ContentView.swift` | ❌ Legacy | 3484 lines, uses old `SUPRAExecutiveStore`. Not referenced by `@main`. |
| `SUPRAApp.swift` | ❌ Legacy | `@main` commented out. |
| `SUPRACommandCenterApp.swift` | ❌ Legacy | `@main` commented out. |
| `DefaultView.swift` | ❌ Unused | Not referenced by any navigation path. |

⸻

## 8. FILE SIZE BREAKDOWN (key Swift files)

| File | Lines | Role |
|------|-------|------|
| `RuntimeDataService.swift` | 444 | Canonical runtime source |
| `ConversationMemoryStore.swift` | 839 | Memory persistence |
| `ExecutiveWorkflow.swift` | 508 | Workflow engine |
| `SUPRARuntimeKernel.swift` | 429 | Platform manifest loader |
| `SUPRAOperationalControlCenterView.swift` | 437 | Main control center view |
| `ExecutiveWorkflowListView.swift` | 422 | Workflow UI |
| `ExecutiveMissionControlStore.swift` | 258 | File-based agent/mission snapshots |
| `ExecutiveMissionControlModels.swift` | 230 | Models for MC store |
| `DecisionStore.swift` | 174 | Decision store |
| `ExecutiveCockpitFoundation.swift` | 168 | Cockpit widget system |
| `ExecutiveGraph.swift` | 153 | Graph builder |
| `ExecutiveSearch.swift` | 174 | Global search |
| `ExecutiveTimeline.swift` | 111 | Timeline builder |
| `ExecutiveMemory.swift` | 143 | Memory builder |
| `ContentView.swift` | 3484 | **Legacy — largest file** |
