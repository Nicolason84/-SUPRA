# Mission Object Specification

The canonical mission object is implemented in `SUPRA/Mission.swift`.

## Identity

- `id`
- `identity.missionID`
- `identity.slug`
- `identity.createdAt`
- `identity.updatedAt`
- `identity.createdBy`

## Mission Definition

- `title`
- `objective`
- `businessContext`
- `technicalContext`
- `summary`
- `constraints`
- `priority`
- `risk`
- `value`
- `impact`

## Runtime Control

- `status`
- `lifecycle`
- `health`
- `planner`
- `executor`
- `authority`
- `autonomyLevel`
- `executionStrategy`

## Execution State

- `progress`
- `currentStatus`
- `currentStep`
- `currentProvider`
- `currentModel`
- `providers`
- `models`
- `estimatedRemainingMinutes`
- `expectedOutcome`
- `blocker`

## Evidence and Learning

- `executiveDecision`
- `nextMission`
- `evidence`
- `artifacts`
- `logs`
- `memoryLinks`
- `lessonsLearned`
- `validation`
- `confidence`
- `score`

## Derived Collections

- `objectives`
- `tasks`
- `dependencies`
- `timeline`
