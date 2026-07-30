# Initialization Order

Date: July 29, 2026

## Required Order

1. Create `RuntimeDataService.shared`
2. Create `RuntimeMonitor(dataService:)`
3. Resolve shared leaf services that do not depend on `SUPRACompositionRoot.shared`
4. Create `MissionStore(evolutionEngine:)`
5. Publish canonical references on `SUPRACompositionRoot`
6. Bind cross-service references explicitly
7. Activate the runtime

## Implemented Order In `SUPRACompositionRoot`

```text
1. runtimeDataService = RuntimeDataService.shared
2. runtimeMonitor = RuntimeMonitor(dataService: runtimeDataService)
3. multiMemoryStore = MultiMemoryStore.shared
4. intelligenceEngine = SUPRAIntelligenceEngine.shared
5. missionObserver = SUPRAMissionObserver.shared
6. missionOpportunityEngine = MissionOpportunityEngine.shared
7. missionEvolutionEngine = MissionEvolutionEngine.shared
8. missionStore = MissionStore(evolutionEngine: missionEvolutionEngine)
9. publish references on SUPRACompositionRoot
10. missionStore.bind(evolutionEngine: missionEvolutionEngine)
11. multiMemoryStore.bind(missionStore: missionStore, runtimeMonitor: runtimeMonitor)
12. intelligenceEngine.bind(missionStore: missionStore)
13. loadRuntime()
```

## Why This Terminates Safely

- The shared services created in steps 3 to 7 no longer request `SUPRACompositionRoot.shared`.
- The services that need `MissionStore` or `RuntimeMonitor` receive them only after those canonical instances exist.
- Runtime activation happens after dependency binding, not during partial construction.

## Validation Evidence

The post-fix focused test run completed successfully and no longer crashed during XCTest bootstrap:

- `SUPRAMissionExecutionTests`
- `SUPRAMissionEvolutionEngineTests`
- `SUPRARuntimeLoopTests`

Result: `TEST SUCCEEDED`
