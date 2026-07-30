# ROUTER ACTIVATION — V1

## Status: CERTIFIED

| Property | Value |
|----------|-------|
| **Version** | ROUTER_ACTIVATION_V1 |
| **Date** | 2026-07-29 |
| **Authority** | FACTORY_09_EXECUTION |

---

## 1. ACTIVATION STATE

SUPRA-Router is now the **default agent**.

| Property | Before | After |
|----------|--------|-------|
| `default_agent` in opencode.json | `"build"` | `"router"` |
| Orchestration entry point | Direct agent invocation | Router delegation |
| Routing table | Implicit | 11 explicit delegation rules |

---

## 2. ROUTING TABLE

| Rule | Task Type | Target Agent | Priority |
|------|-----------|--------------|----------|
| DEL_001 | architecture | SUPRA-Architect | 10 |
| DEL_002 | implementation | SUPRA-Builder | 10 |
| DEL_003 | review | SUPRA-Reviewer | 8 |
| DEL_004 | audit_compliance | SUPRA-Auditor | 9 |
| DEL_005 | exploration | SUPRA-Explorer | 7 |
| DEL_006 | research | SUPRA-Research | 7 |
| DEL_007 | runtime_validation | SUPRA-Runtime | 8 |
| DEL_008 | refactoring_analysis | SUPRA-Refactor | 8 |
| DEL_009 | routing | SUPRA-Router | 10 |
| DEL_010 | fallback | SUPRA-Explorer | 1 |
| DEL_011 | load_balancing | distributed | 6 |

---

## 3. FLOW

```
Request
  │
  ▼
SUPRA-Router (default_agent)
  │
  ├── task_type == architecture      → SUPRA-Architect
  ├── task_type == implementation    → SUPRA-Builder  (SOLE write agent)
  ├── task_type == review            → SUPRA-Reviewer
  ├── task_type == audit_compliance  → SUPRA-Auditor
  ├── task_type == exploration       → SUPRA-Explorer
  ├── task_type == research          → SUPRA-Research
  ├── task_type == runtime_validation→ SUPRA-Runtime
  ├── task_type == refactoring       → SUPRA-Refactor
  ├── task_type == routing           → SUPRA-Router
  ├── fallback                       → SUPRA-Explorer
  └── OpenCode auto-fallback         → SUPRA-Builder (if Router unavailable)
```

---

## 4. ROLLBACK

| Method | Time | Data Loss |
|--------|------|-----------|
| Set `"default_agent": "build"` in opencode.json | < 10s | None |
| OpenCode auto-fallback (automatic) | Instant | None |

---

## 5. VERIFICATION

| Check | Status |
|-------|--------|
| Router defined in opencode.json | ✓ |
| Router has bash access (read-only) | ✓ |
| Router mode is subagent | ✓ |
| 11 delegation rules defined | ✓ |
| All 9 agents have at least 1 rule | ✓ |
| Fallback paths defined (DEL_010, OpenCode) | ✓ |
| Single Writer Rule preserved (edit=deny) | ✓ |
| MODEL_REGISTRY_V2.json available | ✓ |
| Provider fallback chain defined | ✓ |

---

**END OF ROUTER ACTIVATION V1**
