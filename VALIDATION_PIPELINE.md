# VALIDATION PIPELINE — V1

## Status: CERTIFIED

| Property | Value |
|----------|-------|
| **Version** | VALIDATION_PIPELINE_V1 |
| **Date** | 2026-07-29T06:44:00Z |
| **Authority** | FACTORY_09_EXECUTION |

---

## 1. PIPELINE OVERVIEW

The validation pipeline is a single automated workflow that executes all validation phases sequentially. Each phase produces a gate decision.

```
EXECUTIVE BOOT
    │
    ▼
REGISTRY VALIDATION
    │
    ▼
WORKSPACE VALIDATION
    │
    ▼
BUILD VALIDATION
    │
    ▼
DASHBOARD REFRESH
    │
    ▼
EXECUTIVE STATE REFRESH
    │
    ▼
HEALTH REFRESH
    │
    ▼
READY
```

---

## 2. PHASE DEFINITIONS

### Phase 1: EXECUTIVE BOOT

**Purpose**: Verify the executive environment is operational.

| Check | Method | Pass Criteria |
|-------|--------|---------------|
| Git repository | `git rev-parse HEAD` | Returns valid commit hash |
| Git branch | `git rev-parse --abbrev-ref HEAD` | Returns branch name |
| AGENTS.md present | `test -f AGENTS.md` | File exists |
| opencode.json present | `test -f opencode.json` | File exists |
| Factory Constitution | `test -f FACTORIES/SUPRA_FACTORY_CONSTITUTION.md` | File exists |
| Factory Registry | `test -f FACTORIES/FACTORY_REGISTRY.json` | File exists |
| Workspace exists | `test -f SUPRA.xcodeproj/project.xcworkspace` | Directory exists |

**Output**: Boot status (PASS/FAIL with evidence)

### Phase 2: REGISTRY VALIDATION

**Purpose**: Verify all registries are consistent and complete.

| Check | Method | Pass Criteria |
|-------|--------|---------------|
| Factory Registry valid JSON | Parse FACTORIES/FACTORY_REGISTRY.json | Valid JSON, 10 factories |
| All factories have outputs | Check each factory's outputs array | Every factory has ≥1 output |
| All outputs on disk | `test -f` for each output path | All files present |
| Agent Registry consistent | Compare AGENTS.md vs opencode.json vs .opencode/agent_registry_runtime.json | No critical drift |
| Model Registry exists | `test -f SUPRA_MODEL_REGISTRY_V1.md` | File exists |

**Output**: Registry validation report

### Phase 3: WORKSPACE VALIDATION

**Purpose**: Verify the Swift workspace is structurally sound.

| Check | Method | Pass Criteria |
|-------|--------|---------------|
| Xcode project exists | `test -d SUPRA.xcodeproj` | Directory exists |
| Swift sources count | `find SUPRA -name "*.swift" | wc -l` | Count stable (≥200) |
| Package dependencies | Check Package.swift for packages | Dependencies resolvable |

**Output**: Workspace validation status

### Phase 4: BUILD VALIDATION

**Purpose**: Verify the project compiles.

| Check | Method | Pass Criteria |
|-------|--------|---------------|
| Build passes | `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -destination 'platform=macOS' build` | Exit 0, 0 errors |

**Output**: Build result (PASS/FAIL)

### Phase 5: DASHBOARD REFRESH

**Purpose**: Regenerate the executive dashboard with current data.

| Action | Description |
|--------|-------------|
| Gather git state | Branch, commit, status |
| Gather factory state | Read FACTORY_REGISTRY.json |
| Gather build result | Read build output |
| Gather runtime info | Models, providers, agents |
| Compile dashboard | Generate EXECUTIVE_DASHBOARD.md |

**Output**: EXECUTIVE_DASHBOARD.md (refreshed)

### Phase 6: EXECUTIVE STATE REFRESH

**Purpose**: Regenerate machine-readable state snapshot.

| Action | Description |
|--------|-------------|
| Snapshot all subsystems | Collect environment, git, build, factories, runtime, agents, mission |
| Format as JSON | Generate EXECUTIVE_STATE.json |
| Add timestamp | Record generation timestamp |

**Output**: EXECUTIVE_STATE.json (refreshed)

### Phase 7: HEALTH REFRESH

**Purpose**: Regenerate health report.

| Action | Description |
|--------|-------------|
| Score all subsystems | Compute health scores from evidence |
| Check for warnings | Identify degraded or blocked subsystems |
| Produce report | Generate HEALTH_REPORT.md |

**Output**: HEALTH_REPORT.md (refreshed)

---

## 3. PIPELINE EXECUTION

### Command

```bash
# Execute full validation pipeline
FACTORIES/supra-pipeline.sh validate

# Execute specific phase
FACTORIES/supra-pipeline.sh validate --phase <phase_name>
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | ALL PASS — system READY |
| 1 | FAIL — one or more phases blocked |
| 2 | WARNING — all phases pass with warnings |

### Dependencies

Each phase depends only on its predecessor. No parallel execution within the pipeline to maintain deterministic ordering.

---

## 4. GATE INTEGRATION

```
INPUT GATE: All upstream artefacts certified
    ↓
VALIDATION PIPELINE (this document)
    ↓
OUTPUT GATE: Pipeline result determines gate state
    ↓
PASSED  →  READY for next mission
FAILED  →  Return to factory for remediation
BLOCKED →  Wait for missing inputs
```

---

## 5. AUTOMATION

This pipeline is designed for:

1. **Manual execution**: via `supra-pipeline.sh validate`
2. **CI integration**: can be wired into pre-commit hooks or CI pipeline
3. **Scheduled refresh**: can be triggered by cron for continuous validation
4. **Executive command**: via `supra-executive` command trigger

---

## 6. EVIDENCE REQUIREMENTS

Every phase must log:
- Timestamp
- Check name
- Result (PASS/FAIL/WARN)
- Evidence (file path, command output, or reference)

---

**END OF VALIDATION PIPELINE V1**
