# Dependency Graph After Fix

Date: July 29, 2026

## Canonical Direction

The initialization graph is now a DAG.

```text
SUPRACompositionRoot
├─ RuntimeDataService.shared
├─ RuntimeMonitor(dataService:)
├─ MultiMemoryStore.shared
├─ SUPRAIntelligenceEngine.shared
├─ SUPRAMissionObserver.shared
├─ MissionOpportunityEngine.shared
├─ MissionEvolutionEngine.shared
└─ MissionStore(evolutionEngine:)

Binding phase
├─ MissionStore.bind(evolutionEngine:)
├─ MultiMemoryStore.bind(missionStore:, runtimeMonitor:)
└─ SUPRAIntelligenceEngine.bind(missionStore:)

Activation phase
└─ SUPRACompositionRoot.loadRuntime()
```

## Service Dependencies

```text
MissionStore
└─ MissionEvolutionEngine?        injected / bound

MissionEvolutionEngine
└─ MissionOpportunityEngine.shared

MissionOpportunityEngine
├─ SUPRAMissionObserver.shared
├─ SUPRAOptimizationCopilot.shared
└─ SUPRAResourceIntelligenceEngine.shared

SUPRAMissionObserver
├─ SUPRAIntelligenceEngine.shared
├─ MultiMemoryStore.shared
├─ SUPRAResourceGovernor.shared
└─ CAnnoNicoSnapshotStore.shared

SUPRAIntelligenceEngine
├─ MultiMemoryStore.shared
├─ SUPRAResourceGovernor.shared
├─ SUPRAScheduler.shared
├─ CAnnoNicoSnapshotStore.shared
└─ MissionStore?                  bound after root creation

MultiMemoryStore
├─ CAnnoNicoSnapshotStore.shared
├─ MissionStore?                  bound after root creation
└─ RuntimeMonitor?                bound after root creation
```

## Removed Illegal Upward Edges

- `MultiMemoryStore -> SUPRACompositionRoot.shared`
- `SUPRAIntelligenceEngine -> SUPRACompositionRoot.shared`

## Invariant

No service in the mission-evolution chain now requests `SUPRACompositionRoot.shared` during its own initialization.
