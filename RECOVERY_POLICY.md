# Recovery Policy

Recovery is deterministic and classified through `SUPRARecoveryStrategyKind`.

Supported classes:

- `RETRY`
- `REPLAY`
- `FALLBACK`
- `SKIP`
- `ABORT`
- `HUMAN_INTERVENTION`

Current canonical mappings inside the Executive loop:

- `BOOT`: `REPLAY`
- `OBSERVE`: `FALLBACK`
- `UNDERSTAND`: `RETRY`
- `DECIDE`: `RETRY`
- `PREPARE`: `RETRY`
- `EXECUTE`: `FALLBACK`
- `VALIDATE`: `SKIP`
- `LEARN`: `RETRY`
- `FREEZE`: `ABORT`
- `FAILED`: `HUMAN_INTERVENTION`

Deterministic failure behavior:

- Failure paths produce `SUPRARootCauseReport`.
- `SUPRARootCauseReport` now includes `recoveryClassification`.
- Mission persistence failures produce proof from `MissionStore`.
- Mission execution failures produce proof from the latest transition evidence.
- Validation timeout produces explicit timeout output.
- Git or shell stalls return bounded empty output instead of blocking the loop.

Termination rule:

- Recovery does not recurse.
- The current iteration terminates by returning a `SUPRARuntimeIterationResult` with `finalState` `FAILED` or `READY`.
