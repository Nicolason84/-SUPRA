# NEXT EXECUTIVE MISSION

## Mission ID

SUPRA-MISSION-QUEUE-HARDENING-V1

## Objective

Harden the mission queue so Mission Center can continuously prepare, order, and resume the next executable mission using persisted repository evidence and workspace memory.

## Scope

- `MissionStore`
- mission ordering and queue policies
- persisted queue recovery
- next-mission recommendation quality

## Constraints

- no new runtime
- no parallel execution path
- preserve the canonical Mission Center flow
- preserve the existing focused passing tests

## Validation

- Mission Center still launches missions without terminal interaction
- queue ordering is deterministic after restart
- next mission is persisted and recoverable
- focused tests remain green
