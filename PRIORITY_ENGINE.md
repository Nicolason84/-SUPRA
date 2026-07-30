# PRIORITY ENGINE — V1

## Status: CERTIFIED

| Property | Value |
|----------|-------|
| **Version** | PRIORITY_ENGINE_V1 |
| **Date** | 2026-07-29 |
| **Authority** | FACTORY_10_EXECUTIVE |

---

## 1. PRIORITY ENGINE DESIGN

The Priority Engine ranks every detected issue using 6 dimensions:

```
PRIORITY = (Impact × 0.25) + (Risk × 0.20) + (Complexity × 0.15) + 
           (ExecutionCost × 0.10) + (BusinessValue × 0.20) + (Confidence × 0.10)
```

### Dimension Scales

| Dimension | Scale | Description |
|-----------|-------|-------------|
| **Impact** | 1–10 | How much damage if unresolved |
| **Risk** | 1–10 | Likelihood of negative outcome |
| **Complexity** | 1–10 | How hard to fix (higher = harder) |
| **ExecutionCost** | 1–10 | Resource cost to implement |
| **BusinessValue** | 1–10 | Value delivered by fixing |
| **Confidence** | 1–10 | Certainty in the assessment |

### Priority Bands

| Band | Score Range | Action |
|------|-------------|--------|
| CRITICAL | ≥ 8.0 | Immediate action required |
| HIGH | 6.0 – 7.9 | Next mission priority |
| MEDIUM | 4.0 – 5.9 | Schedule within 3 missions |
| LOW | 2.0 – 3.9 | Backlog |
| INFO | < 2.0 | Monitor only |

---

## 2. ISSUE INVENTORY

All issues detected across Phases 1–5 of EXECUTION GATE VI, scored by the Priority Engine.

### Issue 1: 28GB .overnight_audit/ Stale Data

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Impact | 6 | Consumes disk space, could cause confusion |
| Risk | 2 | Low risk — data is gitignored and isolated |
| Complexity | 1 | Trivial — rm -rf |
| ExecutionCost | 1 | 1 command |
| BusinessValue | 3 | Recovers 28GB disk |
| Confidence | 10 | Direct measurement |
| **PRIORITY** | **3.9** | **LOW** |

### Issue 2: 5 Overlapping Registries (Registry Fragmentation)

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Impact | 7 | Multiple sources of truth cause inconsistency |
| Risk | 6 | High risk of stale data if any registry is updated independently |
| Complexity | 4 | Requires merging and deduplication |
| ExecutionCost | 5 | Multiple files to reconcile |
| BusinessValue | 8 | Single authoritative registry reduces confusion |
| Confidence | 9 | Clear evidence of overlap |
| **PRIORITY** | **6.4** | **HIGH** |

### Issue 3: Executive Report Fragmentation (6+ reports)

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Impact | 6 | Unclear which executive report is authoritative |
| Risk | 5 | Confusion about current state |
| Complexity | 3 | Consolidating reports |
| ExecutionCost | 3 | Rename/archive older versions |
| BusinessValue | 7 | Clear decision-making chain |
| Confidence | 9 | Direct file listing evidence |
| **PRIORITY** | **5.6** | **MEDIUM** |

### Issue 4: No Swift Router Implementation

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Impact | 5 | Router limited to OpenCode subagent only |
| Risk | 3 | Low — spec exists and OpenCode works |
| Complexity | 7 | Requires Swift implementation, testing |
| ExecutionCost | 8 | New component development |
| BusinessValue | 6 | Enables native routing capability |
| Confidence | 8 | Clear gap evidence |
| **PRIORITY** | **5.6** | **MEDIUM** |

### Issue 5: 706 Untracked Certified Artefacts

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Impact | 7 | Certified state could be lost between sessions |
| Risk | 8 | High risk of state loss |
| Complexity | 2 | git add + git commit |
| ExecutionCost | 2 | Simple git operations |
| BusinessValue | 8 | Preserves certified state |
| Confidence | 10 | git status evidence |
| **PRIORITY** | **6.3** | **HIGH** |

### Issue 6: Pipeline Dependencies Not Enforced

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Impact | 4 | Dependencies documented but not mechanical |
| Risk | 4 | Low — manual discipline works |
| Complexity | 6 | Requires validation scripts |
| ExecutionCost | 5 | Gate script creation |
| BusinessValue | 5 | Mechanical enforcement |
| Confidence | 8 | Clear gap |
| **PRIORITY** | **4.9** | **MEDIUM** |

### Issue 7: AGENTS.md Permission Drift from opencode.json

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Impact | 4 | Discrepancy could cause confusion |
| Risk | 3 | Low — config is authoritative |
| Complexity | 2 | Simple text alignment |
| ExecutionCost | 1 | Quick edit |
| BusinessValue | 5 | Documentation accuracy |
| Confidence | 9 | REG-001 from registry report |
| **PRIORITY** | **3.9** | **LOW** |

### Issue 8: No MODEL_REGISTRY.json (Machine-Readable)

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Impact | 5 | Cannot query models at runtime |
| Risk | 4 | Low — manual model selection works |
| Complexity | 3 | Moderate — create JSON from MD |
| ExecutionCost | 2 | 1 file creation |
| BusinessValue | 6 | Enables automated model selection |
| Confidence | 9 | REG-002 from registry report |
| **PRIORITY** | **4.7** | **MEDIUM** |

### Issue 9: 14 Modified Swift Files Not Committed

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Impact | 5 | Development changes unsaved |
| Risk | 6 | Could lose work |
| Complexity | 1 | git add + commit |
| ExecutionCost | 1 | Trivial |
| BusinessValue | 7 | Preserves development progress |
| Confidence | 10 | git status evidence |
| **PRIORITY** | **5.0** | **MEDIUM** |

### Issue 10: Build Cache/Tests Not Validated This Session

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Impact | 5 | Build may have regressed |
| Risk | 5 | 14 modified Swift files could break build |
| Complexity | 3 | Run xcodebuild |
| ExecutionCost | 2 | ~90s build time |
| BusinessValue | 8 | Ensures build integrity |
| Confidence | 8 | Previous build was clean |
| **PRIORITY** | **5.3** | **MEDIUM** |

---

## 3. RANKED PRIORITY LIST

| Rank | Issue | Score | Band | 
|------|-------|-------|------|
| 1 | **5: Untracked Certified Artefacts** | **6.3** | HIGH |
| 2 | **2: Registry Fragmentation** | **6.4** | HIGH |
| 3 | 10: Build/Tests Not Validated | 5.3 | MEDIUM |
| 4 | 9: 14 Modified Swift Files | 5.0 | MEDIUM |
| 5 | 6: Pipeline Dependencies Not Enforced | 4.9 | MEDIUM |
| 6 | 8: No MODEL_REGISTRY.json | 4.7 | MEDIUM |
| 7 | 3: Executive Report Fragmentation | 5.6 | MEDIUM |
| 8 | 4: No Swift Router Implementation | 5.6 | MEDIUM |
| 9 | 1: 28GB Stale Audit Data | 3.9 | LOW |
| 10 | 7: Permission Drift in AGENTS.md | 3.9 | LOW |

---

## 4. SINGLE RECOMMENDED NEXT ACTION

### ▶ Commit certified artefacts and validate build

**Rationale**: The highest-value action is to preserve the certified state of all artefacts produced in EXECUTION GATE V and validate that the build still passes after 14 modified Swift files.

**Action**:
1. `git add` all EXECUTIVE GATE V artefacts (EXECUTIVE_STATE.json, HEALTH_REPORT.md, etc.)
2. `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -destination 'platform=macOS' build`
3. If build passes, commit with message `[CERTIFY] EXECUTION GATE V — Autonomous Runtime V1`
4. If build fails, fix per Evidence Rule before committing

**Expected Outcome**: Repository state preserved at a certified checkpoint. Next mission can proceed from a known good state.

---

## 5. ENGINE SPECIFICATION

```json
{
  "priority_engine_version": "PRIORITY_ENGINE_V1",
  "dimensions": ["Impact", "Risk", "Complexity", "ExecutionCost", "BusinessValue", "Confidence"],
  "weights": {"Impact": 0.25, "Risk": 0.20, "Complexity": 0.15, "ExecutionCost": 0.10, "BusinessValue": 0.20, "Confidence": 0.10},
  "bands": {"CRITICAL": 8.0, "HIGH": 6.0, "MEDIUM": 4.0, "LOW": 2.0, "INFO": 0.0},
  "current_top_issue": "Untracked Certified Artefacts (P=6.3, HIGH)",
  "recommended_action": "Commit certified artefacts and validate build"
}
```

---

**END OF PRIORITY ENGINE V1**
