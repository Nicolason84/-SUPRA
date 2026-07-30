# Mission Queue

## Canonical Queue

SUPRA now uses the `MissionStore` queue as the canonical execution queue.

- `currentMission`: first active mission, otherwise first planned mission, otherwise most recent mission
- `queuedMissions`: every mission in `planned` or `active` state
- `missionHistory`: every mission in `completed` or `blocked` state ordered by latest update

## Queue Sources

- Mission Center composer creates missions through `MissionStore.createMission(...)`
- Mission Center launch action executes missions through `MissionStore.createAndExecuteMission(...)`
- Existing runtime services continue to execute through `SUPRAExecutionPipeline`

## Queue Classification

Each mission is classified from `DecisionAuthority`.

- Level 0: `autoExecute`
- Level 1: `supervised`
- Level 2: `humanRequired`
- Level 3: `sovereignHumanOnly`

The queue is published in three visible lanes in Mission Center.

- Automatic
- Supervised
- Human

## Queue Guarantees

- No mission executes outside `MissionStore`
- No provider is selected directly by the user
- No terminal interaction is required for standard mission creation and launch
- Every mission record persists as JSON before execution
- Every executed mission publishes timeline, evidence, logs, validation, and next action in the same record
