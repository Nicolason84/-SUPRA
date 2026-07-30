# Autonomy Policy

Mission autonomy is governed by `DecisionAuthority` and published as `autonomyLevel` on every mission.

## Levels

- Level 0: automatic execution through `autoExecute`
- Level 1: automatic with supervision through `supervised`
- Level 2: human confirmation required through `humanRequired`
- Level 3: sovereign human decision only through `sovereignHumanOnly`

## Automatic Actions

The current Mission Center flow supports automatic handling for:

- mission creation persistence
- mission classification
- mission routing
- pipeline execution
- evidence publication
- validation publication
- next-mission recommendation

## Guardrails

- the user does not select providers directly
- the user does not select models directly
- execution stays on the canonical runtime path
- mission records are persisted before execution and mutated in place
- failures publish proof through error, logs, validation, and blocker fields
