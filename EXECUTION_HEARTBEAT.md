# EXECUTION HEARTBEAT — V1

## Status: CERTIFIED

| Property | Value |
|----------|-------|
| **Version** | HEARTBEAT_V1 |
| **Date** | 2026-07-29 |
| **Authority** | FACTORY_03_RUNTIME |

---

## 1. HEARTBEAT

The Runtime heartbeat is the `supra` command.

Each invocation is a heartbeat pulse that validates system health.

---

## 2. HEARTBEAT METRICS

| Metric | Source | Threshold |
|--------|--------|-----------|
| Repository | git status | Must resolve |
| Build | Last certification | Must be CERTIFIED |
| Factories | FACTORY_REGISTRY.json | 10/10 healthy |
| Agents | opencode.json | 9/9 configured |
| Providers | provider_runtime.json | ≥ 1 connected |
| Executive Decision | EXECUTIVE_STATE.json | Must be CONTINUE |
| Executive Confidence | EXECUTIVE_STATE.json | > 0.90 |

---

## 3. HEALTH CHECK OUTPUT

The heartbeat reports at the end of each `supra` cycle:

| Level | Range | Action |
|-------|-------|--------|
| ✓ READY | All checks pass | Proceed with mission |
| ⚠ WARNING | 1-2 non-critical failures | Continue, flag attention |
| ✗ FAILED | ≥ 3 failures or critical | Halt, escalate to Executive |

---

## 4. AUTOMATED MAINTENANCE

Whenever Executive State changes:

| Artefact | Refresh Trigger | Method |
|----------|----------------|--------|
| EXECUTIVE_COCKPIT.md | Next `supra` boot | Automatic — Phase 5 sync |
| FACTORY_REGISTRY.json health | Next `supra` boot | Re-validated |
| SESSION_STATE.json | Next `supra` boot | Auto-synchronized |
| Priority | Next `supra` boot | Read from NEXT_MISSION.md |

---

## 5. CURRENT HEARTBEAT STATE

| Metric | Value |
|--------|-------|
| Status | PRODUCTION |
| Gate | EXECUTION GATE VIII |
| Decision | CONTINUE |
| Confidence | 0.97 |
| Factories | 10/10 healthy |
| Agents | 9/9 available |
| Router | Active (default) |
| Default Agent | SUPRA-Router |

---

**END OF EXECUTION HEARTBEAT V1**
