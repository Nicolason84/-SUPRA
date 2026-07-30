# Root Cause Report

Date: July 29, 2026
Mission: `SUPRA-MISSION-EVOLUTION-OS-V1`

## Failure

`xcodebuild test` failed during test-host bootstrap with:

`libdispatch.dylib: BUG IN CLIENT OF LIBDISPATCH: trying to lock recursively`

The crash occurred before the test runner established its connection.

## Root Cause

The failure was caused by recursive singleton initialization across the mission-evolution stack:

`SUPRACompositionRoot.shared`
→ `MissionStore`
→ `MissionEvolutionEngine.shared`
→ `MissionOpportunityEngine.shared`
→ `SUPRAMissionObserver.shared`
→ `SUPRAIntelligenceEngine.shared`
→ `MultiMemoryStore.shared`
→ `SUPRACompositionRoot.shared`

This violated the requirement that the composition root be the unique owner of dependency creation and produced a recursive `dispatch_once` path.

## Direct Causes In Code

- `MissionStore` eagerly captured `MissionEvolutionEngine.shared` during initialization.
- `SUPRAIntelligenceEngine` eagerly captured `SUPRACompositionRoot.shared.missionStore`.
- `MultiMemoryStore` eagerly captured `SUPRACompositionRoot.shared.missionStore` and `SUPRACompositionRoot.shared.runtimeMonitor`.
- `SUPRACompositionRoot` built `MissionStore` before the dependent services had been bound into an acyclic graph.

## Corrective Action

The fix removed every upward dependency from the affected services to `SUPRACompositionRoot.shared`.

- `MissionStore` now receives `MissionEvolutionEngine` by injection and can be rebound explicitly.
- `MultiMemoryStore` now binds `MissionStore` and `RuntimeMonitor` after construction.
- `SUPRAIntelligenceEngine` now binds `MissionStore` after construction.
- `SUPRACompositionRoot` now constructs the canonical services, binds dependencies, and only then loads the runtime.

## Validation

Focused validation command:

```bash
xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx -derivedDataPath /private/tmp/SUPRA_MISSION_EVOLUTION_DAG_FIX -only-testing:SUPRATests/SUPRAMissionExecutionTests -only-testing:SUPRATests/SUPRAMissionEvolutionEngineTests -only-testing:SUPRATests/SUPRARuntimeLoopTests test
```

Result:

- `SUPRAMissionExecutionTests`: passed
- `SUPRAMissionEvolutionEngineTests`: passed
- `SUPRARuntimeLoopTests`: passed
- Final result: `TEST SUCCEEDED`
