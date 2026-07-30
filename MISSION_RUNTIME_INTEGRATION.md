# Mission Runtime Integration

Mission Center reuses existing runtime services. No parallel runtime was introduced.

## Canonical Flow

`MissionSurfaceView` -> `MissionStore` -> `SUPRADecisionEngine` -> `SUPRAMissionBroker` -> `SUPRAExecutionPipeline` -> `InferenceSovereigntyRuntime`

## Integration Points

- `MissionStore.createMission(...)` creates the durable mission record
- `MissionStore.executeMission(id:)` advances the canonical lifecycle
- `SUPRADecisionEngine` determines mission authority and understanding
- `SUPRAMissionBroker` selects execution mode and preferred backend
- `SUPRAExecutionPipeline` performs execution
- `InferenceSovereigntyRuntime` publishes selected provider and model

## UI Integration

- `ExecutiveWindow` now starts on `.missions`
- `MissionCenterView` uses `MissionSurfaceView` as the primary surface
- `MissionDetailView` displays the full mission record, not a reduced summary
