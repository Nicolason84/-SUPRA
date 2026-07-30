# EXECUTIVE STARTUP PIPELINE — V1

## Status: CERTIFIED

| Property | Value |
|----------|-------|
| **Version** | STARTUP_PIPELINE_V1 |
| **Date** | 2026-07-29 |
| **Authority** | FACTORY_10_EXECUTIVE |
| **Evidence** | AGENTS.md §12, EXECUTIVE_BOOT.sh, STATE_PRESERVATION.md, SESSION_STATE.json |

---

## 1. TARGET SEQUENCE

```
  ┌──────────────────────────────────────────────┐
  │                 TERMINAL                       │
  │  (opencode opens in workspace root)           │
  └──────────────────┬───────────────────────────┘
                     │
  ┌──────────────────▼───────────────────────────┐
  │                 SUPRA                          │
  │  (AGENTS.md loaded via opencode.json          │
  │   instructions: ["AGENTS.md"])                │
  └──────────────────┬───────────────────────────┘
                     │
  ┌──────────────────▼───────────────────────────┐
  │         1. EXECUTIVE BOOT                     │
  │  Run: FACTORIES/EXECUTIVE_BOOT.sh            │
  │  Load: FACTORIES/SUPRA_FACTORY_CONSTITUTION.md │
  │  Result: PASS/FAIL/WARN summary               │
  └──────────────────┬───────────────────────────┘
                     │
  ┌──────────────────▼───────────────────────────┐
  │         2. STATE RESTORE                      │
  │  Read: SESSION_STATE.json                     │
  │  Validate: checksums against EXECUTIVE_STATE  │
  │  Restore: mission, decision, gate, agent      │
  │  Reference: STATE_PRESERVATION.md §3          │
  └──────────────────┬───────────────────────────┘
                     │
  ┌──────────────────▼───────────────────────────┐
  │         3. REPOSITORY VALIDATION               │
  │  Check: git status, branch, commit            │
  │  Compare: SESSION_STATE.json.repository       │
  │  Detect: drift since last session             │
  │  Report: dirty/clean/ahead/behind             │
  └──────────────────┬───────────────────────────┘
                     │
  ┌──────────────────▼───────────────────────────┐
  │         4. REGISTRY VALIDATION                 │
  │  Load: FACTORIES/FACTORY_REGISTRY.json        │
  │  Verify: 10 factories, 26 outputs             │
  │  Check: all factory states match expected     │
  │  Check: MODEL_REGISTRY_V2.json exists         │
  │  Reference: REGISTRY_CONSOLIDATION_PLAN.md    │
  └──────────────────┬───────────────────────────┘
                     │
  ┌──────────────────▼───────────────────────────┐
  │         5. PROVIDER VALIDATION                 │
  │  Check: ollama list (local models)            │
  │  Check: opencode-zen availability             │
  │  Check: opencode.json provider config         │
  │  Select: best available provider (primary)    │
  │  Reference: PROVIDER_RESILIENCE.md §3         │
  └──────────────────┬───────────────────────────┘
                     │
  ┌──────────────────▼───────────────────────────┐
  │         6. WORKSPACE DETECTION                 │
  │  Verify: SUPRA.xcodeproj exists               │
  │  Verify: project.xcworkspace exists           │
  │  Verify: SUPRA/ directory with .swift files   │
  │  Count: Swift source files                    │
  └──────────────────┬───────────────────────────┘
                     │
  ┌──────────────────▼───────────────────────────┐
  │         7. BUILD VALIDATION                    │
  │  Check: DerivedData exists (build cache)      │
  │  Check: last build result from SESSION_STATE  │
  │  Optional: xcodebuild (if cache missing)      │
  └──────────────────┬───────────────────────────┘
                     │
  ┌──────────────────▼───────────────────────────┐
  │         8. EXECUTIVE COCKPIT                   │
  │  Read: EXECUTIVE_COCKPIT.md                   │
  │  Read: VALIDATION_REPORT.md                   │
  │  Read: NEXT_MISSION.md                        │
  │  Display: 12 cockpit dimensions               │
  └──────────────────┬───────────────────────────┘
                     │
  ┌──────────────────▼───────────────────────────┐
  │                  READY                          │
  │  Proceed with current mission per NEXT_MISSION │
  └──────────────────────────────────────────────┘
```

---

## 2. EXISTING RESOURCES REUSE

| Pipeline Stage | Existing Resource | Action |
|----------------|-------------------|--------|
| Executive Boot | FACTORIES/EXECUTIVE_BOOT.sh | **REUSE** — covers git, factory integrity, registry, outputs, executive health, workspace |
| State Restore | STATE_PRESERVATION.md + SESSION_STATE.json | **NEW** — created in PHASE 1 |
| Repository Validation | EXECUTIVE_BOOT.sh Phase 1 | **REUSE** — git verification already in boot script |
| Registry Validation | EXECUTIVE_BOOT.sh Phase 3 | **REUSE** — factory registry check already in boot script |
| Provider Validation | PROVIDER_RESILIENCE.md | **NEW** — no provider check in existing boot script |
| Workspace Detection | EXECUTIVE_BOOT.sh Phase 6 | **REUSE** — workspace selection already in boot script |
| Build Validation | EXECUTIVE_BOOT.sh (build command) | **REUSE** — build command documented at end of boot script |
| Executive Cockpit | EXECUTIVE_COCKPIT.md | **REUSE** — pre-read cockpit document |

---

## 3. NO DUPLICATED LOGIC

Each validation concern appears exactly once:

| Concern | Where | Why Not Duplicated |
|---------|-------|-------------------|
| Git status | EXECUTIVE_BOOT.sh Phase 1 | Boot script is single entry point |
| Factory integrity | EXECUTIVE_BOOT.sh Phase 2 | Constitution + opencode.json validation |
| Factory registry | EXECUTIVE_BOOT.sh Phase 3 | 10 factories validated via python3 |
| Factory outputs | EXECUTIVE_BOOT.sh Phase 4 | Iterates 10 output directories |
| Executive health | EXECUTIVE_BOOT.sh Phase 5 | Reads NEXT_DECISION + factory health |
| Workspace | EXECUTIVE_BOOT.sh Phase 6 | Xcode project + Swift source count |
| State restoration | STATE_PRESERVATION.md | Read-only check against SESSION_STATE.json |
| Provider check | PROVIDER_RESILIENCE.md | Diagnostics only — no config mutation |
| Model selection | MODEL_REGISTRY_V2.json | Data file — not a script |

---

## 4. INTEGRATION WITH AGENTS.md §12

AGENTS.md §12 defines the session startup:
```
1. Load FACTORY_00_CONSTITUTION.md (→ PHASE 1: boot)
2. Check FACTORY_10_EXECUTIVE/NEXT_DECISION.md (→ PHASE 1: boot)
3. Check FACTORY_09_EXECUTION/EXECUTION_PLAN.md (→ PHASE 2: state)
4. Load FACTORY_05_MEMORY/MEMORY_STATE.json (→ PHASE 2: state)
```

The pipeline maps AGENTS.md §12 steps to its stages:

| AGENTS.md §12 | Pipeline Stage | Artifact |
|---------------|----------------|----------|
| 1. Load Constitution | 1. Executive Boot | FACTORIES/SUPRA_FACTORY_CONSTITUTION.md |
| 2. Check NEXT_DECISION | 2. State Restore | SESSION_STATE.json → mission.decision |
| 3. Check EXECUTION_PLAN | 2. State Restore | SESSION_STATE.json → gate.current |
| 4. Load MEMORY_STATE | 2. State Restore | SESSION_STATE.json → session.id |
| 5. Proceed per plan | 8. Executive Cockpit → READY | NEXT_MISSION.md |

---

## 5. STAGE DETAILS

### Stage 1: Executive Boot
**Command**: `bash FACTORIES/EXECUTIVE_BOOT.sh`
**Expected**: 30+ checks across 6 phases
**Failure**: Exit code 1 — system not ready
**Evidence**: EXECUTIVE_BOOT.sh (229 lines, covers all foundation checks)

### Stage 2: State Restore
**Command**: Read SESSION_STATE.json
**Expected**: Valid JSON with session.id, mission, decision, gate, agent
**Failure**: Checksum mismatch → flag warning, continue with EXECUTIVE_STATE.json
**Evidence**: STATE_PRESERVATION.md §3, SESSION_STATE.json

### Stage 3: Repository Validation
**Command**: `git -C $SUPRA_ROOT status --porcelain | wc -l`
**Expected**: 0 uncommitted files (= clean session)
**Failure**: >0 uncommitted = dirty. Log count, continue.

### Stage 4: Registry Validation
**Command**: Read FACTORIES/FACTORY_REGISTRY.json
**Expected**: 10 factories, all CERTIFIED, all HEALTHY
**Failure**: Any factory < 1.0 health → flag to Executive

### Stage 5: Provider Validation
**Command**: `ollama list` + check opencode-zen
**Expected**: At least 1 provider available
**Failure**: No provider → HALT, no execution possible

### Stage 6: Workspace Detection
**Command**: `ls SUPRA.xcodeproj/project.xcworkspace`
**Expected**: Workspace exists
**Failure**: Missing workspace → flag warning, try SUPRA.xcodeproj

### Stage 7: Build Validation
**Command**: `ls DerivedData` (optional: `xcodebuild build`)
**Expected**: Build cache present
**Failure**: No cache → recommend `xcodebuild` before any mission

### Stage 8: Executive Cockpit
**Command**: Read EXECUTIVE_COCKPIT.md + VALIDATION_REPORT.md
**Expected**: All 12 dimensions READY
**Failure**: Any FAIL → escalate to Executive

---

## 6. IMPLEMENTATION NOTES

- No new shell script needed — EXECUTIVE_BOOT.sh is the single entry point
- Stages 2-7 can be manual verification steps during session startup
- Provider validation (Stage 5) is the only gap in EXECUTIVE_BOOT.sh
- Future enhancement: add `ollama list` check to EXECUTIVE_BOOT.sh Phase 6

---

## 7. CERTIFICATION

| Criterion | Status |
|-----------|--------|
| Target sequence defined (9 stages) | CERTIFIED |
| No duplicated logic across stages | CERTIFIED |
| Existing resources reused (EXECUTIVE_BOOT.sh) | CERTIFIED |
| Integration with AGENTS.md §12 confirmed | CERTIFIED |
| Provider validation gap identified | CERTIFIED |
| Build cache validation included | CERTIFIED |
| Rollback: manual per stage | CERTIFIED |

---

**END OF EXECUTIVE STARTUP PIPELINE V1**
