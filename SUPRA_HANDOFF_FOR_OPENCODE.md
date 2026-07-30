# SUPRA — Handoff Codex → OpenCode

Date: 2026-07-27  
Handoff status: **READY FOR OPENCODE**  
Last validated lot: **V2.1 / Lot 1 — Composition Root**

## Exact project state

- Repository: `/Users/nicolasalonso/Desktop/NOVA_OS/SUPRA`
- Branch: `develop`
- Branch relation at handoff: 12 commits ahead of `origin/develop`
- Current application entry point: `SUPRA/SUPRAOperationalCoreApp.swift`
- Current SwiftUI product root: `SUPRA/SUPRAOSProductRootView.swift` → `ExecutiveWindow`
- Debug macOS build: **BUILD SUCCEEDED**
- Bundle smoke launch: **PASS**
- Protected-folder freeze: `Freeze/SUPRA_EXECUTIVE_FREEZE_V4.md`
- Lot 1 report: `SUPRA_COMPOSITION_ROOT_V2_1_REPORT.md`

The worktree was already substantially dirty and contains many untracked
historical/runtime artifacts. Preserve all existing user changes. Do not clean,
reset, checkout, or delete broad paths.

## Current architecture

```text
SUPRAOperationalCoreApp
        │
        ▼
SUPRACompositionRoot
        ├── RuntimeDataService
        ├── MissionStore
        ├── DecisionStore
        ├── RuntimeMonitor
        ├── SUPRARuntimeEvents
        └── ControlTowerState
                │
                ▼
        SwiftUI environment injection
                │
                ▼
        ExecutiveWindow and existing views
```

The canonical composition root is
`SUPRA/SUPRACompositionRoot.swift`. It owns the canonical application-level
instances for runtime data, missions, decisions, monitoring, and the existing
event bus. `RuntimeDataService.shared` and `SUPRARuntimeEvents.shared` remain
the pre-existing implementations; the root exposes them rather than replacing
them.

## Consolidated components

- `RuntimeDataService` — one canonical instance exposed by the root.
- `MissionStore` — one canonical instance exposed through SwiftUI and reused by
  Nucleo, Command Center, Intelligence, Memory, and World Access.
- `DecisionStore` — one canonical instance exposed through SwiftUI and reused by
  Executive Workflows.
- `RuntimeMonitor` — one canonical instance constructed with the canonical
  `RuntimeDataService`.
- `SUPRARuntimeEvents` — existing event bus exposed by the root.
- `ControlTowerState` — receives the canonical data service and monitor.

The views no longer construct these dependencies locally. The active and
historical App roots inject the same dependency graph.

## Still fragmented

These areas remain intentionally untouched and are not part of the handoff lot:

- Provider registry/broker versus plugin registry/routing layers.
- Scheduler, worker fabric, resource governor, transmission locks, and executor
  composition.
- Multiple Runtime/event models and `RuntimeGateway`.
- Multiple memory stores, knowledge graphs, twins, and world-model projections.
- Historical shells and roots (`ContentView`, cockpit variants, old App roots).
- `.runtime`, Megabus, and `.opencode` mission representations.
- Global singletons outside the Lot 1 boundary.

## Risks

- The worktree is not a reproducible Git freeze; many files are untracked.
- Existing Swift 6 concurrency warnings remain.
- Full-suite baseline failures remain documented in
  `MACOS_PERMISSION_VALIDATION_REPORT.md`.
- The protected-folder explicit Discovery flow remains only partially
  end-to-end validated; do not reopen that freeze casually.
- The Xcode project uses synchronized filesystem groups; adding/removing files
  can silently change the target surface.
- Several paths and continuity artifacts are machine-specific.

## Recommended order of future lots

1. Validate the handoff and preserve Lot 1 exactly.
2. Lot 2: centralize lifecycle start/stop in the existing Composition Root,
   preserving launch order and behavior.
3. Add focused identity/lifecycle tests proving one instance per Lot 1
   responsibility.
4. Only after that, consolidate provider catalogue and routing; do not create a
   second provider engine.
5. Normalize Runtime events and then classify memory stores into storage,
   index, graph, and projection roles.

No future lot is authorized by this document.

## Build commands

Run from `/Users/nicolasalonso/Desktop/NOVA_OS/SUPRA`:

```sh
xcodebuild -project SUPRA.xcodeproj \
  -scheme SUPRA \
  -configuration Debug \
  -derivedDataPath /private/tmp/SUPRA_OPENCODE_DERIVED \
  CODE_SIGNING_ALLOWED=NO build
```

Use a DerivedData path outside the repository. A successful result must end in
`** BUILD SUCCEEDED **`.

## Test commands

Focused protected-folder tests:

```sh
xcodebuild -project SUPRA.xcodeproj \
  -scheme SUPRA \
  -configuration Debug \
  -derivedDataPath /private/tmp/SUPRA_OPENCODE_TEST_DERIVED \
  CODE_SIGNING_ALLOWED=NO \
  test -only-testing:SUPRATests/ProtectedFolderAccessCoordinatorTests
```

Full suite:

```sh
xcodebuild -project SUPRA.xcodeproj \
  -scheme SUPRA \
  -configuration Debug \
  -derivedDataPath /private/tmp/SUPRA_OPENCODE_TEST_DERIVED \
  CODE_SIGNING_ALLOWED=NO test
```

The full suite historically contains three unrelated baseline failures:
`SUPRARuntimeProviderProofTests.testFallbackScenario`,
`testINDEX_FILE_EXCLUDED_FROM_SCAN`, and
`testUNCHANGED_FILES_NOT_REPARSED`. Do not relabel them as regressions without
new evidence.

## Important dependencies

- Local Swift package: `Packages/CAnnoNicoIntegrationPackage`.
- SUPRA target has an explicit dependency on `CAnnoNicoIntegration`.
- Package products include `CAnnoNicoContracts`, `PucheroMemoryAdapter`,
  `NicoAppAdapter`, and `VideoSwapAdapter`.
- Do not modify `Package.swift` during ordinary Runtime consolidation.

## Sensitive files

- `SUPRA.xcodeproj/project.pbxproj`
- `SUPRA/SUPRAOperationalCoreApp.swift`
- `SUPRA/SUPRACompositionRoot.swift`
- `SUPRA/RuntimeDataService.swift`
- `SUPRA/MissionStore.swift`
- `SUPRA/DecisionStore.swift`
- `SUPRA/RuntimeMonitor.swift`
- `SUPRA/SUPRANucleoOrchestrator.swift`
- `SUPRA/ProtectedFolderAccessCoordinator.swift`
- `Freeze/SUPRA_EXECUTIVE_FREEZE_V4.md`
- `CONTINUITY.md`

Changes to these files require a focused audit, build, validation, and updated
handoff/freeze evidence.

## Architecture rules

- One composition root only.
- One canonical source per responsibility.
- Views receive application services by injection; views do not construct stores
  or Runtime services.
- Do not add a competing Runtime, Provider, Scheduler, Store, Event Bus, or
  protected-folder scanner.
- Preserve validated components and behavior.
- Do not access protected folders implicitly at launch.
- Compile after every code change; correct errors immediately.
- Keep DerivedData outside the repository.
- Do not modify packages or Xcode configuration unless a separately approved lot
  requires it.
- Document every lot and freeze only after reproducible validation.
