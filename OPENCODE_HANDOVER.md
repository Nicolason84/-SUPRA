# SUPRA OpenCode Handover

Status: TRANSFER PREPARATION — NOT READY
Generated: 2026-07-30

## System State

`EXECUTION_READINESS.json` reports `READY`. The certified validation state is:

- Tests: `PASS`, 135 passed, 0 failed.
- Digital Twin synchronization: `PASS`.
- Projection consistency: `PASS`.
- Indexing: `PASS`, 2,674 non-empty index records.
- Package reproducibility: `PASS`, Xcode resolver exit code 0.

## Baseline

- Active baseline: `BASELINE_V1_CERTIFIED.md`.
- Current commit: `9dd42bc6044e9cb17ec878f898f5915888f5cda6`.
- Current branch: `develop`.
- Current tag: `BASELINE_V1_CERTIFIED`.
- Snapshot: `Artifacts/baseline_v1/`.
- Executive Twin freeze: `Artifacts/baseline_v1/EXECUTIVE_TWIN_FREEZE.md`.

## Critical Components

- `SUPRA/MissionStore.swift`: canonical mission persistence and execution state reconstruction.
- `SUPRA/SUPRARuntimeLoop.swift`: runtime execution loop and evidence publication.
- `SUPRA/TwinUniverse.swift`: Executive Digital Twin coordination.
- `SUPRA/TwinSynchronizer.swift`: Twin synchronization logic.
- `SUPRA/RuntimeGateway.swift`: runtime/provider boundary.
- `SUPRA/ConversationMemoryStore.swift`: persistent memory and reconciliation.

## Critical Services

- Mission execution and persistence.
- Runtime loop and provider routing.
- Executive Digital Twin and projections.
- Conversation memory and continuity.
- Xcode/SwiftPM build and test validation.

## Critical Dependencies

- Xcode/macOS toolchain.
- Local package `Packages/CAnnoNicoIntegrationPackage`.
- Workspace lockfile `SUPRA.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.
- Local Swift and Clang caches required by Xcode validation.

## Frozen Elements

- Constitution and architecture.
- `AGENTS.md` operating contract.
- Certified baseline and `BASELINE_V1_CERTIFIED` tag.
- Executive Digital Twin projections in the baseline snapshot.
- Mission state authority and evidence rules.

## Modifiable Elements

Only a new governed mission may modify runtime or documentation. It must use
the same Observation Cycle, evidence-before-edit rule, targeted validation,
memory synchronization, Twin projection regeneration, and Executive gate.

## Vigilance Points

- The worktree is not clean: 18 tracked paths are modified and thousands of
  generated or untracked paths exist. No unrelated changes may be reverted.
- The root contains historical reports, backups, temporary exports, and
  generated registries without a complete ownership classification.
- `AGENTS.md` is authoritative but does not currently contain explicit
  standalone Git-rules and security-policy sections.
- `README.md` was absent before this handover and is now restored as the
  navigation entry point.

## First OpenCode Action

Read `AGENTS.md`, this handover, `EXECUTION_READINESS.json`, and the active
baseline snapshot. Do not execute a mission until the root-artifact
classification and governance-document gaps are resolved or explicitly
accepted by the Executive.

