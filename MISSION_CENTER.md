# Mission Center

Mission Center is now the primary operating surface of SUPRA.

## Implemented Behaviour

- `ExecutiveWindow` opens on `Mission Center` by default
- `MissionCenterView` is now the canonical split view
- `MissionSurfaceView` is the primary left surface
- `MissionDetailView` is the canonical right-side inspection surface

## Standard User Flow

1. The user enters an objective, business context, technical context, priority, and risk.
2. Mission Center creates a canonical mission record through `MissionStore`.
3. SUPRA classifies authority and autonomy level automatically.
4. SUPRA routes execution through `SUPRADecisionEngine`, `SUPRAMissionBroker`, and `SUPRAExecutionPipeline`.
5. Mission Center updates progress, step, provider, model, evidence, validation, lessons, and next mission.

## Surface Outputs

- Current Mission
- Executive Decision
- Progress
- Current Step
- Evidence count
- Risk
- Blocker
- Executor
- Provider
- Model
- Remaining time
- Expected outcome
- Next action
- Mission health
- Mission queue
- Mission history
