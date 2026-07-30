# SUPRA ZERO — Phase 2 Readiness

## Diagnostic: Is SUPRA Ready for Phase 2?

### VERDICT: NOT READY

SUPRA is **not ready** for Phase 2 (Theory Engine, Sherpa, Cortex, plugins).

## Why Not — Blocking Issues

### CRITICAL (must resolve before Phase 2)

| # | Issue | Detail | Impact |
|---|-------|--------|--------|
| 1 | **3 failing tests** | `testFallbackScenario`, `testINDEX_FILE_EXCLUDED_FROM_SCAN`, `testUNCHANGED_FILES_NOT_REPARSED` | Undermines confidence in runtime stability |
| 2 | **No theory foundation** | Theory ontology, library, graph, and search engine at 0% | Phase 2 requires theory engine as prerequisite |
| 3 | **No Sherpa layer** | Context selection engine at 0% | Required for intelligent routing |
| 4 | **No Cortex layer** | Persistent memory not formalized | Required for decision persistence |
| 5 | **No Plugin contract** | Plugin interfaces defined but not implemented | No extension mechanism |
| 6 | **Uncommitted changes** | 14 modified files not committed | Workspace not in clean state |
| 7 | **Unified architecture** | 2 NOVA_OS roots, 7 parallel workspaces, multiple cores | No single source of truth |

### HIGH (should resolve before Phase 2)

| # | Issue | Detail |
|---|-------|--------|
| 8 | **Workspace duplication** | ~400 historical SUPRA dirs at `~/NOVA_OS/` create confusion |
| 9 | **No build automation** | Build requires manual Xcode launch |
| 10 | **No CI/CD** | No automated test runner, no build pipeline |
| 11 | **3 agents missing** | Theory, Sherpa, Cortex agents not defined |
| 12 | **MissionExecutor is a shell** | `execute()` exists but makes no LLM calls |
| 13 | **5 workflows registered but 0 executed** | Workflow engine never tested end-to-end |

### MEDIUM (should resolve before Phase 2)

| # | Issue | Detail |
|---|-------|--------|
| 14 | **No formal JSON schemas** | Manifests have implicit structure only |
| 15 | **No coding standards doc** | Conventions are implicit in code |
| 16 | **No SDK** | Provider/Plugin SDK not extracted |
| 17 | **130 .md files may contain duplication** | Report proliferation |
| 18 | **123 .json registries may overlap** | Registry proliferation |

## Mandatory Steps Before Phase 2

### Step 1: Resolve Critical Issues (1-7)

1. **Commit uncommitted changes** — `git add` the 14 modified files
2. **Fix 3 failing tests** — root cause analysis + fix
3. **Define Theory ontology** — domains, concepts, relations
4. **Define Sherpa interfaces** — context selection contract
5. **Define Cortex interfaces** — memory persistence contract
6. **Define Plugin contract** — interfaces + manifest schema

### Step 2: Stabilize Workspace (8-10)

7. **Mark parallel workspaces** — clearly label ACTIVE vs ARCHIVE vs STALE
8. **Establish build script** — `supra-build` command for CLI build
9. **Establish test script** — `supra-test` command for automated test run

### Step 3: Activate Runtime (11-13)

10. **Define Theory/Sherpa/Cortex agents** in AGENTS.md
11. **Connect MissionExecutor** to OllamaProvider (first LLM call)
12. **Execute first workflow** end-to-end

### Step 4: Industrialize (14-18)

13. **Extract JSON schemas** from existing manifests
14. **Extract coding standards** from codebase
15. **Declutter reports/registries** — mark canonical sources

## Readiness Criteria Matrix

| Criteria | Current | Required | Delta |
|----------|---------|----------|-------|
| All tests pass | 6/9 pass | 9/9 | 3 failures |
| Workspace clean | 14 modified files | Clean | 14 files |
| Theory engine | 0% | 100% | Full build |
| Sherpa engine | 0% | 100% | Full build |
| Cortex engine | 20% | 100% | 80% missing |
| Plugin system | 20% | 100% | 80% missing |
| Build automated | No | Yes | Script needed |
| Tests automated | No | Yes | Script needed |
| Workspace unified | 2 roots | 1 root | Logical consolidation |
| Agents defined | 9 | 12 | +3 agents |
| Runtime active | 0 LLM calls | 1+ call | Implement execute() |

## Estimated Effort

| Phase | Effort | Dependencies |
|-------|--------|-------------|
| Commit + test fix | 1 session | None |
| Theory Engine | 2-3 sessions | None |
| Sherpa | 1 session | Theory Engine |
| Cortex | 1-2 sessions | Theory Engine |
| Plugin System | 1 session | None |
| Runtime Activation | 1 session | Provider implementation |
| Workspace Consolidation | 1 session | None |
| **Total** | **8-10 sessions** | |

## Recommendation

**Do not start Phase 2 until these conditions are met:**
1. ✅ All 3 failing tests are fixed
2. ✅ Uncommitted changes are committed
3. ✅ Theory ontology is defined (first deliverable of Phase 2)
4. ✅ Sherpa and Cortex interfaces are specified
5. ✅ Plugin contract is drafted

This ensures that Phase 2 work builds on a stable, clean, fully understood foundation rather than attempting to construct a theory layer on shaky ground.
