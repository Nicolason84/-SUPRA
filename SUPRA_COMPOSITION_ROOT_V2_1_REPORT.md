# SUPRA Composition Root V2.1 — Lot 1

Date: 2026-07-27  
Status: **BUILD SUCCEEDED / SMOKE LAUNCH PASS**

## Objective

Consolidate construction and ownership of the existing runtime data, mission,
decision, monitoring, and event services without replacing their implementations
or changing their behavior.

## Canonical composition

```text
SUPRAOperationalCoreApp
        |
        v
SUPRACompositionRoot
        |
        +-- RuntimeDataService
        +-- MissionStore
        +-- DecisionStore
        +-- RuntimeMonitor(RuntimeDataService)
        +-- SUPRARuntimeEvents
        +-- ControlTowerState(RuntimeDataService, RuntimeMonitor)
        |
        +-- SwiftUI environment injection
        +-- Runtime/service consumers
```

`SUPRACompositionRoot` is the only construction site for `MissionStore`,
`DecisionStore`, and `RuntimeMonitor`. It exposes the existing
`RuntimeDataService.shared` and `SUPRARuntimeEvents.shared` as their canonical
instances.

## Consolidation performed

- The active app injects the canonical dependencies through the SwiftUI
  environment.
- The retained historical app roots use the same dependency graph.
- Mission Center, Decision Inbox, Executive Cockpit, Executive Inspector,
  Executive Status Bar, Operational Control Center, Settings routing, and Total
  Control Tower consume injected dependencies.
- Nucleo, Command Center State, Intelligence Engine, Canonical World Access,
  Multi Memory, and Executive Workflows reference the canonical stores and
  monitor.
- `ControlTowerState` now receives its monitor instead of constructing another
  monitor internally.
- Mission Center and Decision Inbox previews receive the canonical stores.

## Removed duplicate constructions

| Component | Before | After |
|---|---:|---:|
| `RuntimeDataService()` outside its canonical owner | 8 construction paths | 0 |
| `RuntimeMonitor(...)` outside the composition root | 6 construction paths | 0 |
| `MissionStore()` outside the composition root | 10 construction paths | 0 |
| `DecisionStore()` outside the composition root | 4 construction paths | 0 |

The counts include direct view, service, fallback, workflow, and historical app
construction paths found during the Lot 1 inventory.

## Validation

- Static construction audit: PASS.
- Debug macOS build with signing disabled: **BUILD SUCCEEDED**.
- Built application smoke launch: PASS; the SUPRA process remained alive after
  startup.
- No provider, scheduler, store implementation, mission format, decision format,
  or user-facing behavior was removed.

## Residual risks

- The target retains pre-existing Swift 6 concurrency warnings.
- Several global singletons outside the Lot 1 boundary remain.
- Historical app and shell types are still compiled; they were preserved
  intentionally.
- The working tree remains substantially dirty and untracked from earlier
  sessions, so a reproducible Git freeze is not yet claimed.

## Proposed Lot 2 boundary

After explicit approval only:

1. Give the composition root explicit lifecycle ownership (`start`/`stop`) while
   preserving current launch order.
2. Inject the remaining runtime collaborators currently reached through unrelated
   global singletons.
3. Add focused identity/lifecycle tests proving one canonical instance per
   responsibility.

No Lot 2 implementation is included in this report.
