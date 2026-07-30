# SUPRA

SUPRA is an autonomous software factory and execution platform. Its
operating contract is defined by [AGENTS.md](AGENTS.md); the active certified
baseline is [BASELINE_V1_CERTIFIED.md](BASELINE_V1_CERTIFIED.md).

## Entry Points

- [AGENTS.md](AGENTS.md): constitution, governance, workflow, evidence, and agent rules.
- [OPENCODE_HANDOVER.md](OPENCODE_HANDOVER.md): current transfer state and execution boundaries.
- [EXECUTION_READINESS.json](EXECUTION_READINESS.json): machine-readable readiness.
- [Artifacts/baseline_v1/](Artifacts/baseline_v1/): certified snapshot and archived evidence.
- [FACTORIES/](FACTORIES/): factory specifications and certified outputs.
- [SUPRA/](SUPRA/): macOS runtime source.
- [SUPRATests/](SUPRATests/): runtime and governance tests.

## Validation

The certified baseline reports `EXECUTION_READINESS = READY`, package
resolution `PASS`, indexing `PASS`, projection consistency `PASS`, and the
full test suite `135/135`.

OpenCode must read `AGENTS.md` and `OPENCODE_HANDOVER.md` before executing any
mission. No executor may change the Constitution, Executive Digital Twin, or
frozen baseline without a new certified execution gate.

