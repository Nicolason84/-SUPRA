# RUNTIME LOOP — V1

## Status: CERTIFIED

| Property | Value |
|----------|-------|
| **Version** | RUNTIME_LOOP_V1 |
| **Date** | 2026-07-29 |
| **Authority** | FACTORY_09_EXECUTION |

---

## 1. EXECUTIVE LOOP

The Runtime heartbeat is a continuous cycle:

```
┌─────────────┐
│ Repository  │ ─── git status, branch, commit, changed files
└──────┬──────┘
       │
┌──────▼──────┐
│   State     │ ─── Load SESSION_STATE.json + EXECUTIVE_STATE.json
└──────┬──────┘
       │
┌──────▼──────┐
│  Priority   │ ─── Read NEXT_MISSION.md priority
└──────┬──────┘
       │
┌──────▼──────┐
│   Router    │ ─── Route to: Builder | Runtime | Reviewer | Explorer | Audit | Executive
└──────┬──────┘
       │
┌──────▼──────┐
│ Execution   │ ─── Factory produces certified artefact
└──────┬──────┘
       │
┌──────▼──────┐
│ Validation  │ ─── Verify output, run checks
└──────┬──────┘
       │
┌──────▼──────┐
│State Update │ ─── Sync SESSION_STATE.json, refresh cockpit
└──────┬──────┘
       │
┌──────▼──────┐
│Next Priority│ ─── Determine next executable priority
└──────┬──────┘
       │
       └──→ REPEAT
```

---

## 2. LOOP INVOCATION

The loop runs implicitly through the `supra` command.

Every `supra` invocation executes one full cycle:

| Step | Implementation | Location |
|------|---------------|----------|
| Repository | `git status --porcelain` | `scripts/supra.sh` Phase 2 |
| State | Read SESSION_STATE.json, EXECUTIVE_STATE.json | `scripts/supra.sh` Phase 1.2 |
| Priority | Read NEXT_MISSION.md priority field | `scripts/supra.sh` Phase 1.6 |
| Router | Validate delegation_rules.json + opencode.json | `scripts/supra.sh` Phase 3 |
| Execution | Delegated to Router → appropriate Factory | Router via opencode.json |
| Validation | Phase 4 heartbeat check | `scripts/supra.sh` Phase 4 |
| State Update | Phase 5 auto-sync | `scripts/supra.sh` Phase 5 |
| Next Priority | Read from NEXT_MISSION.md | `scripts/supra.sh` end |

---

## 3. LOOP STATE

| Field | Source | Update Trigger |
|-------|--------|----------------|
| Session status | SESSION_STATE.json | Every boot |
| Executive decision | EXECUTIVE_STATE.json | Every boot |
| Gate | EXECUTIVE_STATE.json | Every boot |
| Repository state | git status | Live on every boot |
| Factory health | FACTORY_REGISTRY.json | Every boot |
| Provider availability | provider_runtime.json | Every boot |

---

## 4. CONTINUOUS OPERATION

The loop is designed for continuous session operation:

- Each `supra` invocation is one cycle
- Between cycles, Router handles orchestration
- State is always fresh at the start of each cycle
- No manual intervention required

---

## 5. LOOP GUARANTEES

| Guarantee | Mechanism |
|-----------|-----------|
| State never stale | Refresh on every loop cycle |
| Priority never ambiguous | Single priority from NEXT_MISSION.md |
| Router always available | Fallback to Builder via OpenCode |
| State always recoverable | SESSION_STATE.json + EXECUTIVE_STATE.json dual source |
| Loop never infinite | Terminal after boot — next cycle on next `supra` |

---

**END OF RUNTIME LOOP V1**
