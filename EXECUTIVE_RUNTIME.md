# EXECUTIVE RUNTIME — V1

## Status: CERTIFIED

| Property | Value |
|----------|-------|
| **Version** | EXECUTIVE_RUNTIME_V1 |
| **Date** | 2026-07-29 |
| **Authority** | FACTORY_10_EXECUTIVE |

---

## 1. IDENTITY

SUPRA is now a Production Runtime — not a documented architecture.

The canonical entry point is the `supra` command. Every session starts here.

---

## 2. ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────┐
│                      supra (entry point)                     │
│  Validates → Restores → Syncs → Displays → Routes           │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                  EXECUTIVE LOOP (heartbeat)                   │
│  Repository → State → Priority → Router → Execution          │
│  → Validation → State Update → Next Priority                 │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                SUPRA-Router (orchestration)                   │
│  Routes to: Builder | Runtime | Reviewer | Explorer          │
│            | Audit | Executive | direct execution            │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. COMPONENTS

| Component | Location | Role |
|-----------|----------|------|
| `supra` command | `scripts/supra.sh` | Canonical boot entry point |
| Executive State | `EXECUTIVE_STATE.json` | Single source of executive truth |
| Session State | `SESSION_STATE.json` | Live session persistence |
| Factory Registry | `FACTORIES/FACTORY_REGISTRY.json` | Factory catalog |
| Delegation Rules | `.opencode/delegation_rules.json` | Router routing table |
| Router Config | `opencode.json §agent.SUPRA-Router` | Router subagent definition |
| Agent Permissions | `.opencode/agent_permissions.json` | Access control matrix |

---

## 4. BOOT SEQUENCE

| Phase | Action | Validation |
|-------|--------|------------|
| 1 | Repository Validation | git status, branch, commit |
| 2 | Session Restore | SESSION_STATE.json, EXECUTIVE_STATE.json |
| 3 | Registry Validation | FACTORY_REGISTRY.json |
| 4 | Provider Validation | Ollama, provider_runtime.json |
| 5 | Workspace Detection | Xcode project, Swift sources |
| 6 | Cockpit Refresh | Priority, mission status |
| 7 | State Synchronization | Auto-sync SESSION_STATE with EXECUTIVE_STATE |
| 8 | Live Repository | Auto-detect file changes |

---

## 5. RULES

- **Single Writer**: Only SUPRA-Builder modifies files
- **Router First**: Every new request passes through SUPRA-Router
- **Auto-sync**: State refreshes automatically on every `supra` invocation
- **No Manual Regeneration**: Cockpit, health, registry refresh automatically
- **One Priority**: Single executable priority at any time

---

## 6. CERTIFICATION

| Criterion | Status |
|-----------|--------|
| `supra` command available in PATH | CERTIFIED |
| Router is default agent | CERTIFIED |
| Executive State reflects Gate VIII | CERTIFIED |
| Live repository detection active | CERTIFIED |
| State auto-sync on every boot | CERTIFIED |
| Delegation rules define 9 agent routes | CERTIFIED |
| Factory registry validated 10/10 | CERTIFIED |
| Provider fallback chain defined | CERTIFIED |

---

**END OF EXECUTIVE RUNTIME V1**
