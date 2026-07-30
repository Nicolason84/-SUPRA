# STATE SYNCHRONIZER — V1

## Status: CERTIFIED

| Property | Value |
|----------|-------|
| **Version** | STATE_SYNCHRONIZER_V1 |
| **Date** | 2026-07-29 |
| **Authority** | FACTORY_05_MEMORY |

---

## 1. PURPOSE

Keep SESSION_STATE.json and EXECUTIVE_STATE.json in alignment automatically.

No manual state editing after initial certification.

---

## 2. SYNC TRIGGERS

| Trigger | Action | Location |
|---------|--------|----------|
| `supra` boot | Full state sync | `scripts/supra.sh` Phase 5 |
| Executive State change | Cockpit refresh | Auto-detected on next boot |
| Repository change | Live update | Phase 2 live detection |
| Gate change | State version bump | Executive decision |

---

## 3. SYNC FIELDS

| SESSION_STATE.json | Source | Direction |
|--------------------|--------|-----------|
| `session.executive_confidence` | EXECUTIVE_STATE.json | ← |
| `build.last_result` | EXECUTIVE_STATE.json | ← |
| `build.errors` | EXECUTIVE_STATE.json | ← |
| `build.warnings` | EXECUTIVE_STATE.json | ← |
| `gate.current` | EXECUTIVE_STATE.json | ← |
| `gate.current_state` | EXECUTIVE_STATE.json | ← |
| `repository.last_commit` | git live | ← |
| `repository.branch` | git live | ← |
| `repository.status` | git live | ← |
| `workspace.swift_sources` | EXECUTIVE_STATE.json | ← |
| `provider.active_provider` | EXECUTIVE_STATE.json | ← |
| `provider.active_model` | EXECUTIVE_STATE.json | ← |
| `timestamp` | System clock | ← |

---

## 4. SYNC IMPLEMENTATION

The synchronizer runs as Phase 5 of the `supra` boot sequence.

```python
# Simplified sync logic:
exec_state = load(EXECUTIVE_STATE.json)
session_state = load(SESSION_STATE.json)

session_state.build.last_result = exec_state.build.status
session_state.gate.current = exec_state.current_execution_gate
session_state.repository.branch = git_current_branch()
session_state.repository.last_commit = git_current_commit()
session_state.repository.status = git_status()

save(SESSION_STATE.json)
```

---

## 5. RECOVERY

| Failure | Behavior |
|---------|----------|
| SESSION_STATE.json missing | Continue with EXECUTIVE_STATE.json only |
| EXECUTIVE_STATE.json missing | Halt — no executive authority |
| Checksum mismatch | Flag warning, continue with primary source |
| Concurrent write | Last write wins (atomic file write) |

---

**END OF STATE SYNCHRONIZER V1**
