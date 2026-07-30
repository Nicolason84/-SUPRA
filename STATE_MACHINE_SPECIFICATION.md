# Executive State Machine Specification

Canonical governing states in `SUPRARuntimeLoop`:

`BOOT -> OBSERVE -> UNDERSTAND -> DECIDE -> PREPARE -> EXECUTE -> VALIDATE -> LEARN -> FREEZE -> READY`

Terminal failure state:

`FAILED`

Governance rules implemented in `SUPRA/SUPRARuntimeLoop.swift`:

- Every state is described by `SUPRAExecutiveStateRule`.
- Every rule defines preconditions, entry conditions, exit conditions, success criteria, failure criteria, timeout, evidence, confidence, recovery classification and allowed successor states.
- Transition authorization is enforced through `SUPRARuntimeLoop.isTransitionAllowed(from:to:)`.
- Runtime recording adds authorization proof to every `SUPRAExecutionTransition`.
- Recovery classification is normalized through `SUPRARuntimeLoop.classifyRecoveryStrategy(_:)`.

Canonical allowed successors:

- `BOOT` -> `OBSERVE`, `FAILED`
- `OBSERVE` -> `UNDERSTAND`, `FAILED`
- `UNDERSTAND` -> `DECIDE`, `FAILED`
- `DECIDE` -> `PREPARE`, `FAILED`
- `PREPARE` -> `EXECUTE`, `FAILED`
- `EXECUTE` -> `VALIDATE`, `FAILED`
- `VALIDATE` -> `LEARN`, `FAILED`
- `LEARN` -> `FREEZE`, `FAILED`
- `FREEZE` -> `READY`, `FAILED`
- `READY` -> none
- `FAILED` -> none

Bounded execution currently enforced:

- Mission execution timeout: `20s`
- Validation timeout: `30s`
- `xcodebuild` subprocess timeout: `120s`
- Git and shell probes timeout: `5s`

Verified completion path:

- Focused test `SUPRARuntimeLoopTests.testRuntimeLoopCompletesIterationAndUpdatesMemory()`
- Final state asserted as `READY`
- Transition sequence asserted exactly against the canonical state order
- Every asserted successor validated through `SUPRARuntimeLoop.isTransitionAllowed(from:to:)`
