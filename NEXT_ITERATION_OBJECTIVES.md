# Next Iteration Objectives

## Primary objective

Resolve the three documented baseline test failures while preserving the
frozen macOS protected-folder boundary.

## Ordered work

1. Reproduce and isolate `SUPRARuntimeProviderProofTests.testFallbackScenario`.
2. Reproduce and isolate ConversationMemory index exclusion behavior.
3. Reproduce and isolate unchanged-file reparsing behavior.
4. Apply the smallest coherent correction.
5. Run focused tests, the complete suite, application build, and three
   prompt-loop regression launches.

## Guardrails

- `ProtectedFolderAccessCoordinator` remains the only protected enumerator.
- Consumers remain cache-only.
- No authorization UI without explicit Discover intent.
- No automatic protected-folder retry.
- No Runtime or Executive Shell redesign.
- Keep `Package.swift` unchanged unless separately authorized by evidence.

Report complete-suite results exactly; do not infer regression-free status from
focused tests alone.
