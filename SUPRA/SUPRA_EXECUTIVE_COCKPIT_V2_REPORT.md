# SUPRA Executive Cockpit V2 — Live Monitoring Layer

## Mission
SUPRA_EXECUTIVE_COCKPIT_V2 — Ajouter une couche de monitoring live au cockpit existant.

## Summary
V2 étend le cockpit avec 3 nouvelles vues temps réel et 4 nouveaux modèles de données, le tout sans modifier le Runtime.

## New Files (6)

| File | Lines | Purpose |
|------|-------|---------|
| `RuntimeEvent.swift` | ~55 | 12 event types, Identifiable timeline events |
| `RuntimeHealth.swift` | ~40 | Health struct with sync status, agent/provider counts |
| `RuntimeMonitor.swift` | ~130 | @MainActor ObservableObject, polls 9 JSON files every 3s, publishes events |
| `MissionTimelineView.swift` | ~90 | Chronological event list with icons, timestamps, source files |
| `WorkerPoolView.swift` | ~120 | Agent grid (9 agents) + live status + quality bars + active section |
| `MissionDetailView.swift` | ~140 | DAG steps, pipeline stages, evidence, metrics, consensus section |

## Modified Files (2)

| File | Changes |
|------|---------|
| `CockpitNavigation.swift` | +3 tabs (Timeline, Worker Pool, Mission Detail) in "Live Monitoring" section; `@StateObject var monitor` initialized with dataService; `.environmentObject(monitor)` |
| `RuntimeDataService.swift` | +4 Published properties (executionGraph, missionGraphMetrics, providerMetrics, dashboardSnapshot); loads 8 JSON files instead of 4 |

## RuntimeModels.swift Additions (4 new types + helpers)

| Model | JSON Source | Key Fields |
|-------|-------------|------------|
| `ExecutionGraph` | execution_graph.json | 16 nodes, 16 edges, 3 parallel paths, single-writer verified |
| `MissionGraphMetrics` | mission_graph_metrics.json | 2.17x speedup, critical path 270s, 6 parallel tasks |
| `ProviderMetrics` | provider_metrics.json | 3 providers, 2 active, 100% success rate, multi-model verified |
| `DashboardSnapshot` | dashboard_snapshot.json | 100 missions, 20 workers, 91.5% completion rate, top 3 bottlenecks |

## Architecture

```
CockpitNavigation
├── DashboardView (V1)
├── MissionCenterView (V1)
├── RuntimeView (V1)
├── MissionGraphView (V1)
├── EvidenceExplorerView (V1)
├── MissionTimelineView ← RuntimeMonitor
├── WorkerPoolView     ← RuntimeMonitor + RuntimeDataService
├── MissionDetailView  ← RuntimeMonitor + RuntimeDataService
└── SettingsView (V1)
```

`RuntimeMonitor` polls 9 runtime JSON files every 3 seconds, detects changes via modification dates, and publishes `RuntimeEvent` instances to a timeline.

## Design Decisions
- **No Runtime mutations**: Monitor is read-only, reads JSON files that the Runtime writes
- **Polling over FileSystem events**: Simpler, cross-platform (no FSEvents dependency), 3s interval matches the operational cadence
- **@MainActor**: All UI updates on main thread, no thread safety concerns
- **Single Writer Rule**: Cockpit does not write to any Runtime file — SUPRA-Builder only

## Metrics
- Total Swift files: 16 (10 V1 + 6 V2)
- Total lines: ~1,600 (805 V1 + ~580 V2 + ~215 new models)
- New model types: 4 main + 15 helper structs
- New tabs: 3 (Timeline, Worker Pool, Mission Detail)

## Next Moves
1. V3: Detail view for individual missions from timeline events
2. V3: Filter/search for timeline events
3. V3: Configurable polling interval via Settings
4. V3: Visual graph overlay for MissionDetail (DAG visualization)
