# EXECUTION GRAPH — V1

## Status: CERTIFIED

| Property | Value |
|----------|-------|
| **Version** | EXEC_GRAPH_V1 |
| **Date** | 2026-07-29 |
| **Authority** | FACTORY_01_ARCHITECTURE |

---

## 1. ENTRY POINTS

| Entry Point | File | Trigger |
|-------------|------|---------|
| SUPRAApp | SUPRA/SUPRAApp.swift | User launch |
| SUPRAOperationalCoreApp | SUPRA/SUPRAOperationalCoreApp.swift | User launch |
| SUPRACommandCenterApp | SUPRA/SUPRACommandCenterApp.swift | User launch |
| CLI | SUPRA_AST_PLATFORM/Sources/CLI/main.swift | Command line |

---

## 2. APPLICATION EXECUTION FLOW

```
SUPRAApp.swift
  │
  ▼
CompositionRoot (SUPRACompositionRoot.swift)
  │
  ├──► ExecutiveStore (ExecutiveMissionControlStore.swift)
  ├──► MemoryStore (MultiMemoryStore.swift)
  ├──► KnowledgeEngine (NOVAKnowledgeKernel.swift)
  ├──► MissionCenter (MissionCenterView.swift)
  ├──► RuntimeMonitor (RuntimeMonitor.swift)
  ├──► DecisionEngine (SUPRADecisionEngine.swift)
  └──► WorkspaceDiscovery (WorkspaceDiscovery.swift)
```

---

## 3. VIEW HIERARCHY

```
SUPRAApp
  ├── ContentView
  │   ├── DashboardView
  │   ├── MissionView
  │   ├── KnowledgeView
  │   ├── MemoryView
  │   ├── RuntimeView
  │   ├── DecisionView
  │   └── SettingsView
  │
  ├── MissionCenterView
  │   ├── MissionDetailView
  │   ├── MissionTimelineView
  │   └── MissionGraphView
  │
  ├── ExecutiveWorkflowListView
  │   └── ExecutiveTimeline
  │
  ├── SUPRAChatView
  │
  ├── SUPRAWorldMapView
  │
  └── SUPRAOSWorkspaceExplorerView
```

---

## 4. ASYNC EXECUTION PATHS

### 4.1 Mission Execution Flow

```
MissionProposalEngine
  │ async
  ▼
SUPRAMissionExecutor
  │ async
  ▼
SUPRAMissionObserver
  │ async (NotificationCenter)
  ▼
MissionStore
  │ async
  ▼
UI Update (MainActor)
```

### 4.2 Runtime Monitoring Flow

```
RuntimeMonitor
  │ async (Timer)
  ▼
RuntimeGateway (URLSession)
  │ async
  ▼
RuntimeDataService
  │ async (MainActor)
  ▼
RuntimeView / DashboardView
```

---

## 5. DATA EXECUTION PATHS

### 5.1 Memory Persistence

```
ConversationMemoryStore (write)
  │
  ├──► MultiMemoryStore
  │       │
  │       ├──► CAnnoNicoSnapshotStore
  │       └──► JSON file persistence
  │
  └──► TwinSynchronizer
          └──► TwinRegistry
```

### 5.2 Knowledge Pipeline

```
KnowledgeSource (discovery)
  │
  ▼
NOVAKnowledgeKernel
  │
  ├──► KnowledgeGraph
  │       ├──► KnowledgeIdentity
  │       ├──► KnowledgeRelation
  │       └──► KnowledgeStatistics
  │
  └──► KnowledgeAuthority
```

---

## 6. ERROR EXECUTION PATHS

### 6.1 Fallback Chain

```
Primary Operation
  │ fail
  ▼
SUPRAFallbackEngine
  │
  ├──► Cache fallback
  ├──► Degraded mode
  └──► Error reporting
```

### 6.2 Recovery

```
RuntimeGateway detects failure
  │
  ▼
RuntimeMonitor logs event
  │
  ▼
RuntimeDataService triggers recovery
  │
  ▼
SUPRARuntimeLogger archives diagnostic
```
