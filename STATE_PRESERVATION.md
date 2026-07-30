# STATE PRESERVATION — V1

## Status: CERTIFIED

| Property | Value |
|----------|-------|
| **Version** | STATE_PRESERVATION_V1 |
| **Date** | 2026-07-29 |
| **Authority** | FACTORY_05_MEMORY |
| **Evidence** | EXECUTIVE_STATE.json, MEMORY_STATE.json, 714 uncommitted files |

---

## 1. PROBLEM STATEMENT

Current session state is stored in multiple disconnected files:

| File | Purpose | Risk |
|------|---------|------|
| EXECUTIVE_STATE.json | Executive snapshot | Untracked — not preserved across sessions |
| MEMORY_STATE.json | Mission memory | Outdated (shows pre-Gate-VI state) |
| .opencode/execution_state.json | Runtime state | In .opencode — not in git |
| 714 uncommitted files | Working state | High entropy — no deterministic recovery |

**Evidence**: EXECUTIVE_STATE.json shows `"current_execution_gate": "EXECUTION GATE V"` but NEXT_MISSION.md certifies Gate VI. MEMORY_STATE.json shows only 1 mission with 6 factories "PENDING". Both are stale.

---

## 2. STATE PRESERVATION DESIGN

### 2.1 State Categories

| Category | Volatility | Preservation | Restore Order |
|----------|-----------|-------------|---------------|
| **Executive State** | Low (per decision) | SESSION_STATE.json (committed) | 1 |
| **Active Mission** | Medium (per gate) | SESSION_STATE.json + NEXT_MISSION.md | 2 |
| **Active Decision** | Low (per gate) | SESSION_STATE.json | 3 |
| **Current Gate** | Low (per phase) | SESSION_STATE.json | 4 |
| **Active Agent** | High (per task) | .opencode/agent_registry_runtime.json | 5 |
| **Build Context** | Medium (per build) | SESSION_STATE.json.build | 6 |
| **Workspace** | Low (per env) | EXECUTIVE_STATE.json | 7 |
| **Validation Status** | Medium (per check) | VALIDATION_REPORT.md | 8 |

### 2.2 Storage Hierarchy

```
SESSION_STATE.json         — Volatile machine state (committed at gate close)
├── session.id             — UUID v4
├── session.started        — ISO8601
├── session.ended          — ISO8601
├── executive.state        — Snapshot of EXECUTIVE_STATE.json
├── mission.active         — Current mission name + ID
├── decision.active        — Current executive decision
├── gate.current           — Current execution gate + state
├── gate.previous          — Previous gate + state
├── agent.active           — Currently active agent
├── build.last             — Last build result + commit
├── workspace              — Workspace path + project
├── validation             — Last validation status + score
├── provider               — Active provider + model
├── registry.version       — Registry version in use
└── checksums              — SHA256 of key artefacts for integrity

EXECUTIVE_STATE.json       — Stable environment state (committed at mission end)
FACTORIES/FACTORY_05_MEMORY/outputs/MEMORY_STATE.json  — Mission memory (factories only)
```

### 2.3 Preservation Protocol

```
RESTORE:
  1. Read SESSION_STATE.json from root
  2. Validate checksums against EXECUTIVE_STATE.json, NEXT_MISSION.md, VALIDATION_REPORT.md
  3. Load mission from NEXT_MISSION.md
  4. Load executive decision from EXECUTIVE_COCKPIT.md
  5. Restore active agent from .opencode/agent_registry_runtime.json
  6. Validate build context from SESSION_STATE.json.build
  7. Load workspace from EXECUTIVE_STATE.json
  8. Restore validation status from VALIDATION_REPORT.md

PRESERVE:
  1. Collect all state dimensions into SESSION_STATE.json
  2. Update EXECUTIVE_STATE.json with current snapshots
  3. Update MEMORY_STATE.json with mission progress
  4. Commit all three to git
  5. Tag commit with GATE_<N>_STATE

VERIFY:
  1. SESSION_STATE.json must be valid JSON
  2. EXECUTIVE_STATE.json must match SESSION_STATE.json session.id
  3. NEXT_MISSION.md must reference same gate as SESSION_STATE.json
  4. All referenced files must exist
  5. Checksums must match for EXECUTIVE_STATE.json and NEXT_MISSION.md
```

---

## 3. RESTORE SEQUENCE

```
  ┌─────────────────────────────────────────────┐
  │        START — Read SESSION_STATE.json       │
  └─────────────────────┬───────────────────────┘
                        │
  ┌─────────────────────▼───────────────────────┐
  │   STEP 1: Validate session integrity        │
  │   - Checksum EXECUTIVE_STATE.json           │
  │   - Checksum NEXT_MISSION.md                │
  │   - Checksum VALIDATION_REPORT.md           │
  └─────────────────────┬───────────────────────┘
                        │
  ┌─────────────────────▼───────────────────────┐
  │   STEP 2: Load executive snapshot           │
  │   - Restore environment                     │
  │   - Restore repository state                │
  │   - Restore workspace                       │
  └─────────────────────┬───────────────────────┘
                        │
  ┌─────────────────────▼───────────────────────┐
  │   STEP 3: Restore mission context           │
  │   - Active mission                          │
  │   - Active decision                         │
  │   - Current gate                            │
  └─────────────────────┬───────────────────────┘
                        │
  ┌─────────────────────▼───────────────────────┐
  │   STEP 4: Restore runtime state             │
  │   - Active agent                            │
  │   - Build context                           │
  │   - Provider/model                          │
  └─────────────────────┬───────────────────────┘
                        │
  ┌─────────────────────▼───────────────────────┐
  │   STEP 5: Verify restoration integrity      │
  │   - All dimensions match                    │
  │   - All referenced files exist              │
  │   - Gate alignment confirmed                │
  └─────────────────────┬───────────────────────┘
                        │
  ┌─────────────────────▼───────────────────────┐
  │          READY — Proceed to Cockpit          │
  └─────────────────────────────────────────────┘
```

---

## 4. MIGRATION FROM CURRENT STATE

Current state (EXECUTIVE_STATE.json) is at Gate V with 714 untracked files.
Migrate to SESSION_STATE.json at first commit:

| Step | Action | Evidence |
|------|--------|----------|
| 1 | Create SESSION_STATE.json from EXECUTIVE_STATE.json + NEXT_MISSION.md | Current session data |
| 2 | Update EXECUTIVE_STATE.json `gate` to EXECUTION GATE VI | NEXT_MISSION.md certifies Gate VI |
| 3 | Update MEMORY_STATE.json with Gate VI mission data | This mission's outputs |
| 4 | Add .opencode/agent_registry_runtime.json to SESSION_STATE.json.agent | Runtime agent state |
| 5 | No migration required for existing files — all paths preserved | Backward compatibility |

---

## 5. ROLLBACK

| Scenario | Action |
|----------|--------|
| SESSION_STATE.json corrupted | Delete and regenerate from EXECUTIVE_STATE.json + NEXT_MISSION.md |
| Checksum mismatch | Recompute from source files, flag warning to Executive |
| Session ID conflict | Generate new UUID, archive old SESSION_STATE.json to FACTORY_05_MEMORY/ |
| State dimension missing | Log missing dimension, set to `null`, continue with warning |

---

## 6. CERTIFICATION

| Criterion | Status |
|-----------|--------|
| All 8 state dimensions defined | CERTIFIED |
| Restore sequence is deterministic | CERTIFIED |
| Preservation protocol is documented | CERTIFIED |
| Migration path from current state | CERTIFIED |
| Rollback strategy defined | CERTIFIED |
| Evidence-backed design | CERTIFIED |

---

**END OF STATE PRESERVATION V1**
