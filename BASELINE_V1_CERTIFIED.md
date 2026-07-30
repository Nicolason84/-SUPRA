# BASELINE_V1_CERTIFIED

Status: CERTIFIED
Certified at: 2026-07-30T14:27:41+02:00
Branch: develop
Tagged as: `BASELINE_V1_CERTIFIED`

## Gate Results

| Criterion | Result | Evidence |
|---|---|---|
| MissionExecution tests | PASS | `TEST_STATUS.json`, 135 passed, 0 failed |
| Full test suite | PASS | `/private/tmp/SUPRA_BASELINE_V1_TEST.log`, exit code 0 |
| Digital Twin synchronization | PASS | `DIGITAL_TWIN_SYNC_STATUS.json` |
| Projection consistency | PASS | `CONSTITUTION_REALITY_DIFF.json` |
| Indexing observability | PASS | `INDEXING_STATUS.json`, 2,674 index records |
| Package reproducibility | PASS | `PACKAGE_STATUS.json`, Xcode resolver exit code 0 |
| EXECUTION_READINESS | READY | `EXECUTION_READINESS.json` |

## Snapshot

The machine-readable snapshot and archived observation artefacts are under
`Artifacts/baseline_v1/`. The repository worktree was not clean at
certification: 18 tracked paths were modified and 1,379 paths were
untracked. The tag identifies the current HEAD; the archived artefacts
identify the certified observed state without attributing unrelated dirty
worktree changes to this certification.

## Executor Gate

OpenCode may execute missions only under the same Constitution, Executive
Digital Twin, Observation Cycle, Quality Rules, and Proof requirements.

