# SUPRA ZERO — Duplicate Analysis

## Detection Method

Each duplicate was identified by comparing:
1. Directory name and contents
2. Git history (when available)
3. File types and structures
4. Last modification dates
5. Purpose and usage context

## DUPLICATE CATEGORY A: MULTIPLE RUNTIME INSTANCES

| # | Instance | Location | Type | Verdict |
|---|----------|----------|------|---------|
| 1 | Runtime V2 | `~/NOVA_ERA_SUPRA/SUPRA_RUNTIME_V2` | Historic (Node.js) | ARCHIVE |
| 2 | Runtime V3 | `~/NOVA_ERA_SUPRA/SUPRA_RUNTIME_V3` | Historic | ARCHIVE |
| 3 | Runtime V6 | `~/NOVA_OS/_SUPRA_RUNTIME_V6` | Historic | ARCHIVE |
| 4 | Executive Runtime V1 | `~/NOVA_OS/SUPRA_EXECUTIVE_RUNTIME_V1` | Frozen Pre-Swift | FROZEN |
| 5 | Runtime V1 (backup) | `~/NOVA_OS/SUPRA_EXECUTIVE_RUNTIME_V1.before_lot2` | Backup | INCLUDE AS BACKUP |
| 6 | Runtime V1 (backup) | `~/NOVA_OS/SUPRA_EXECUTIVE_RUNTIME_V1.before_lot3` | Backup | INCLUDE AS BACKUP |
| 7 | Active Runtime | `~/Desktop/NOVA_OS/SUPRA` | ACTIVE Swift | **CANONICAL** |

**Canonical**: Active Runtime v2.2.0 at `~/Desktop/NOVA_OS/SUPRA`
**Action**: All others are historic/backup — preserve in place, no migration.

## DUPLICATE CATEGORY B: MULTIPLE CORES

| # | Core | Location | Type | Verdict |
|---|------|----------|------|---------|
| 1 | SUPRA_CORE (Node.js) | `~/SUPRA_CORE` | Node.js | ARCHIVE |
| 2 | SUPRA_CORE_V2 | `~/SUPRA_CORE_V2` | Node.js | ARCHIVE |
| 3 | SUPRA_CORE_CLEAN_V1 | `~/SUPRA_CORE_CLEAN_V1` | Node.js | ARCHIVE |
| 4 | SUPRA_V10_CORE | `~/SUPRA_V10_CORE` | JS | ARCHIVE |
| 5 | SUPRA_V10_5 | `~/SUPRA_V10_5` | JS | ARCHIVE |
| 6 | SUPRA_MODULAR CORE | `~/NOVA_OS/_MODULAR_APPS_V1/SUPRA_CORE` | Unknown | ARCHIVE |
| 7 | SUPRA_CORE (NOVA_RUNTIME) | `~/NOVA_RUNTIME/SUPRA_CORE` | Unknown | ARCHIVE |
| 8 | SUPRA_CORE_UNIVERSAL_V1 | `~/NOVA_OS/SUPRA_CORE_UNIVERSAL_V1` | Mission artifact | ARCHIVE |
| 9 | SUPRA_CORE_MEMORY_V2 | `~/NOVA_OS/SUPRA_CORE_MEMORY_V2` | Mission artifact | ARCHIVE |
| 10 | SUPRA_PRIVATE_CORE_ULTIMA | `~/NOVA_OS/SUPRA_PRIVATE_CORE_ULTIMA` | Mission artifact | ARCHIVE |

**Canonical**: None of the above — the active Swift codebase IS the canonical core.
**Action**: All Node.js cores are historic. Preserve but do not reference in active development.

## DUPLICATE CATEGORY C: MULTIPLE MANIFESTS

| # | Manifest | Location | Verdict |
|---|----------|----------|---------|
| 1 | `WORKSPACE_MANIFEST.json` | `~/Desktop/NOVA_OS/SUPRA/` | **CANONICAL** |
| 2 | `CANONICAL_REGISTRY.json` | `~/Desktop/NOVA_OS/SUPRA/` | Derive from manifest |
| 3 | `MODULE_REGISTRY.json` | `~/Desktop/NOVA_OS/SUPRA/` | Derive from manifest |
| 4 | `PACKAGE_REGISTRY.json` | `~/Desktop/NOVA_OS/SUPRA/` | Derive from manifest |
| 5 | `PROJECT_REGISTRY.json` | `~/Desktop/NOVA_OS/SUPRA/` | Derive from manifest |
| 6 | `SERVICE_RELATIONS.json` | `~/Desktop/NOVA_OS/SUPRA/` | Derive from manifest |
| 7 | `.supra_node_manifest.json` | `~/Desktop/NOVA_OS/SUPRA/` | Node-specific |
| 8 | `FREEZE_REGISTRY.json` | `~/Desktop/NOVA_OS/SUPRA/` | Freeze-specific |
| 9 | `RELEASE_MANIFEST.json` | `~/Desktop/NOVA_OS/SUPRA/` | Release-specific |
| 10 | `DUPLICATE_REGISTRY.json` | `~/Desktop/NOVA_OS/SUPRA/` | Duplicate-specific |

**Canonical**: `WORKSPACE_MANIFEST.json` is the master manifest.
**Action**: Other registries are derived views — acceptable as long as they reference the canonical manifest.

## DUPLICATE CATEGORY D: MULTIPLE WORKSPACE COPIES

| # | Workspace | Location | Git | Verdict |
|---|-----------|----------|-----|---------|
| 1 | SUPRA (main) | `~/Desktop/NOVA_OS/SUPRA` | Yes | **CANONICAL** |
| 2 | SUPRA_BISECT | `~/Desktop/NOVA_OS/SUPRA_BISECT` | Yes | ACTIVE (parallel) |
| 3 | SUPRA_DEEPSEEK_EXIT_READINESS | `~/Desktop/NOVA_OS/SUPRA_DEEPSEEK_EXIT_READINESS` | Yes | ACTIVE (parallel) |
| 4 | SUPRA_FRESH | `~/Desktop/NOVA_OS/SUPRA_FRESH` | Yes | ARCHIVE (may be stale) |
| 5 | SUPRA_MODEL_TEST | `~/Desktop/NOVA_OS/SUPRA_MODEL_TEST` | Yes | ARCHIVE (testing done) |
| 6 | SUPRA_RECOVERY | `~/Desktop/NOVA_OS/SUPRA_RECOVERY` | Partial | ARCHIVE |
| 7 | SUPRA_RUNTIME_EVIDENCE_READONLY | `~/Desktop/NOVA_OS/SUPRA_RUNTIME_EVIDENCE_READONLY` | No | ARCHIVE |

**Canonical**: Main workspace.
**Action**: Bisect and DeepSeek are legitimate parallel activities. Fresh and ModelTest should be marked STALE after verification.

## DUPLICATE CATEGORY E: DOCUMENTATION AND REPORTS

Large overlap in report documents. Key observations:
- 130 `.md` files contain significant duplicates (many report variants)
- `EXECUTION_REPORT.md`, `SUPRA_EXECUTION_REPORT.md`, `EXECUTIVE_SUMMARY.md` cover similar ground
- Multiple FREEZE reports reference the same artifacts
- `WORKSPACE_STRUCTURE.md` duplicates information in `WORKSPACE_MANIFEST.json`
- `DEPENDENCY_MAP.md` duplicates `dependency_graph.json`
- Many JSON registries contain overlapping information

**Canonical source**: `WORKSPACE_MANIFEST.json` for workspace structure, `SUPRA_STATE.json` for runtime state, `RUNTIME_STATUS.json` for runtime health.
**Action**: These overlaps are acceptable as different views of the same data. No consolidation needed unless explicitly required.

## Summary Table

| Category | Total Instances | Canonical | Action |
|----------|----------------|-----------|--------|
| Multiple Runtimes | 7 | Active v2.2.0 | PRESERVE all as historic |
| Multiple Cores | 10 | None (Swift=canonical) | PRESERVE all as historic |
| Multiple Manifests | 10 | WORKSPACE_MANIFEST.json | ACCEPT as derived views |
| Multiple Workspace Copies | 7 | Main workspace | KEEP Bisect+DeepSeek active, mark others STALE |
| Multiple Reports | ~30 | Varies | ACCEPT as different views |
| Script Duplicates | ~15 Desktop scripts | Various | ACCEPT (different missions) |

## Conclusion

**No destructive consolidation needed.** Every duplicate serves a purpose (historic reference, parallel activity, or different viewpoint). The key recommendation is to:
1. Recognize the active canonical sources
2. Mark parallel workspaces as STALE when confirmed unused
3. Never reference historic cores/runtimes as active
4. Use WORKSPACE_MANIFEST.json as the single source of truth for workspace structure
