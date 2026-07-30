# Next Mission

## Baseline Test Debt Resolution

Resolve the three deterministic pre-existing failures without changing the
frozen protected-folder architecture:

1. `SUPRARuntimeProviderProofTests.testFallbackScenario`
2. `ConversationMemory.testINDEX_FILE_EXCLUDED_FROM_SCAN`
3. `ConversationMemory.testUNCHANGED_FILES_NOT_REPARSED`

## Constraints

- Preserve `ProtectedFolderAccessCoordinator` as the sole protected authority.
- No automatic Desktop, Documents, or Downloads access.
- No Runtime or Executive Shell redesign.
- Do not modify `Package.swift` unless a separate, evidence-backed mission
  explicitly authorizes it.
- One coherent objective and a reviewable diff.

## Completion evidence

- root-cause report for each failure
- focused tests passing
- complete suite result stated precisely
- successful application build
- no macOS privacy prompt regression across repeated launches
