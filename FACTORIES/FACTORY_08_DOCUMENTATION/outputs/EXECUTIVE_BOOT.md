# EXECUTIVE BOOT — V1

## Status: CERTIFIED

| Property | Value |
|----------|-------|
| **Version** | EXEC_BOOT_V1 |
| **Date** | 2026-07-29 |
| **Authority** | FACTORY_10_EXECUTIVE |

---

## 1. PURPOSE

Executive Boot is the single mandatory entry point for every SUPRA session.

It performs automatic environment verification before any build operation begins.

---

## 2. ENTRYPOINT

The operator enters a single command:

```
supra
```

This invokes the boot script at `FACTORIES/EXECUTIVE_BOOT.sh`.

---

## 3. BOOT SEQUENCE

```
supra
  │
  ▼
PHASE 1: GIT VERIFICATION
  ├── Repository check
  ├── Branch detection
  ├── Dirty/clean state
  └── Current commit
  │
  ▼
PHASE 2: FACTORY INTEGRITY
  ├── AGENTS.md validation
  ├── opencode.json validation
  └── Factory Constitution check
  │
  ▼
PHASE 3: FACTORY REGISTRY
  ├── Registry exists
  ├── Registry valid
  └── 10 factories registered
  │
  ▼
PHASE 4: FACTORY OUTPUTS
  ├── Per-factory output verification
  └── Artefact presence check
  │
  ▼
PHASE 5: EXECUTIVE HEALTH
  ├── NEXT_DECISION.md
  ├── EXECUTIVE_REPORT.md
  └── Per-factory health scores
  │
  ▼
PHASE 6: WORKSPACE SELECTION
  ├── Xcode project detection
  ├── Workspace detection
  ├── Swift source verification
  └── Build cache detection
  │
  ▼
EXECUTIVE DASHBOARD
  ├── Workspace path
  ├── Branch
  ├── Commit
  ├── Executive Decision
  ├── Next Mission
  ├── Check results
  └── Factory health summary
  │
  ▼
BUILD READINESS
  ├── READY TO BUILD (all checks pass)
  ├── READY WITH WARNINGS (non-blocking issues)
  └── NOT READY (blocking failures)
```

---

## 4. OUTPUT

Executive Boot produces:

| Output | Format | When |
|--------|--------|------|
| Executive Dashboard | Terminal display | Every boot |
| Build Readiness | Terminal conclusion | Every boot |
| Exit code 0 | READY | All checks pass |
| Exit code 1 | NOT READY | Blocking failures |

---

## 5. CERTIFICATION

The boot sequence is certified by FACTORY_10_EXECUTIVE.

| Criterion | Status |
|-----------|--------|
| Git verification | CERTIFIED |
| Factory integrity checks | CERTIFIED |
| Registry validation | CERTIFIED |
| Output verification | CERTIFIED |
| Executive health | CERTIFIED |
| Workspace selection | CERTIFIED |
| Dashboard rendering | CERTIFIED |
| Build readiness decision | CERTIFIED |

---

**END OF EXECUTIVE BOOT V1**
