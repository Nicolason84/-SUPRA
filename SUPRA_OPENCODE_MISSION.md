# SUPRA OpenCode Mission

Mission type: **continuation / consolidation**  
Source: Codex Lot 1 handoff  
Repository: `/Users/nicolasalonso/Desktop/NOVA_OS/SUPRA`

## Where to resume

Resume at the validated Lot 1 boundary:

- [SUPRACompositionRoot.swift](SUPRA/SUPRACompositionRoot.swift)
- [SUPRAOperationalCoreApp.swift](SUPRA/SUPRA/SUPRAOperationalCoreApp.swift)
- [SUPRA_COMPOSITION_ROOT_V2_1_REPORT.md](SUPRA_COMPOSITION_ROOT_V2_1_REPORT.md)
- [SUPRA_HANDOFF_FOR_OPENCODE.md](SUPRA_HANDOFF_FOR_OPENCODE.md)

Read these continuity files before any action:

1. `AGENTS.md`
2. `CONTINUITY.md`
3. `SUPRA_CONTINUITY_PACK.md`
4. `SUPRA_COMPOSITION_ROOT_V2_1_REPORT.md`
5. `SUPRA_HANDOFF_FOR_OPENCODE.md`
6. `FREEZE_V1.md`

## Do not modify

Do not modify the following during handoff verification:

- `ProtectedFolderAccessCoordinator` and its freeze behavior.
- Package definitions or `Packages/CAnnoNicoIntegrationPackage`.
- `SUPRA.xcodeproj/project.pbxproj`.
- Mission, Decision, Provider, Scheduler, Memory, or Shell behavior.
- Existing validated startup order.
- Existing user changes or untracked artifacts.

Do not start Lot 2 automatically. This mission is a transfer mission, not an
implementation authorization.

## Lot 2 objective for a future explicit approval

The next development lot, once separately approved, is narrowly scoped to
lifecycle ownership:

1. Move the existing Runtime start/stop coordination into
   `SUPRACompositionRoot`.
2. Preserve the current launch order and observable behavior.
3. Avoid creating another runtime owner or service graph.
4. Add focused tests for identity, ownership, and repeated start/stop.
5. Compile and validate before touching any later provider or memory work.

This objective is recorded for planning only. It is not authorization to begin.

## Validation criteria for Lot 2

- No duplicate `RuntimeDataService`, `MissionStore`, `DecisionStore`,
  `RuntimeMonitor`, or Event Bus construction sites.
- Active app starts with the same behavior as the Lot 1 smoke baseline.
- Repeated lifecycle calls are idempotent.
- Debug build ends with `** BUILD SUCCEEDED **`.
- Focused tests pass.
- Existing baseline failures remain isolated and documented.
- No protected-folder prompt or implicit protected-folder scan is introduced.
- A new report and continuity update are produced before freeze.

## Compilation rules

Use a DerivedData directory outside the repository:

```sh
xcodebuild -project SUPRA.xcodeproj \
  -scheme SUPRA \
  -configuration Debug \
  -derivedDataPath /private/tmp/SUPRA_OPENCODE_DERIVED \
  CODE_SIGNING_ALLOWED=NO build
```

If compilation fails, stop the lot, fix the error immediately, and rebuild before
any other modification. Do not leave the repository in a broken state.

## Test rules

Focused test command:

```sh
xcodebuild -project SUPRA.xcodeproj \
  -scheme SUPRA \
  -configuration Debug \
  -derivedDataPath /private/tmp/SUPRA_OPENCODE_TEST_DERIVED \
  CODE_SIGNING_ALLOWED=NO \
  test -only-testing:SUPRATests/ProtectedFolderAccessCoordinatorTests
```

The full suite may report the three known baseline failures documented in the
handoff. Any new failure must be treated as a regression until proven otherwise.

## Continuity rules

- Preserve the single-writer rule from `AGENTS.md`.
- Recover and read existing reports before designing anything.
- Prefer injection and adapters over new engines.
- Keep one canonical owner per responsibility.
- Never use destructive cleanup commands on the repository or user directories.
- Never reset or checkout over the dirty worktree.
- Do not stage, commit, or publish unless explicitly requested.
- Record exact files, commands, build result, tests, risks, and remaining work in
  every mission report.
- Freeze only after validation; update the continuity pack together with the
  report.

## Handoff completion condition

OpenCode should first acknowledge this mission, verify the eight files in
`SUPRA_HANDOFF_OPENCODE_V2_1`, and confirm that no Lot 2 work has started. The
next implementation action requires a separate explicit approval.
