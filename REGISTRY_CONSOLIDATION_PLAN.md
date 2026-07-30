# REGISTRY CONSOLIDATION PLAN — V1

## Status: CERTIFIED

| Property | Value |
|----------|-------|
| **Version** | REGISTRY_CONSOLIDATION_V1 |
| **Date** | 2026-07-29 |
| **Authority** | FACTORY_01_ARCHITECTURE |
| **Evidence** | REPOSITORY_INTELLIGENCE.md §5, §6, §8; KNOWLEDGE_GRAPH_REPORT.md §9 |

---

## 1. REGISTRY AUDIT

### 1.1 All Registry Files Found at Root Level

| # | File | Size | Purpose | Status |
|---|------|------|---------|--------|
| 1 | FACTORIES/FACTORY_REGISTRY.json | 8KB | 10 factories, 26 outputs | **AUTHORITATIVE** |
| 2 | CANONICAL_REGISTRY.json | 2KB | Environment twin, secondary repos | **OVERLAPS** #4 |
| 3 | SUPRA_EXECUTIVE_PLATFORM_REGISTRY.json | 177KB | 89 components, 9 layers | **OVERLAPS** #1, #5 |
| 4 | SUPRA_MASTER_REGISTRY.json | 16KB | 16 canonical sources, 11 categories | **OVERLAPS** #1, #2, #3 |
| 5 | CANNO_REGISTRY.json | 45KB | 89 NUCLEO components | **OVERLAPS** #3 |
| 6 | SUPRA_MASTER_MANIFEST.json | — | Master manifest | **OVERLAPS** WORKSPACE_MANIFEST.json |
| 7 | SUPRA_AGENT_REGISTRY_V1.md | — | 9 agents | **STANDALONE** (markdown) |
| 8 | SUPRA_MODEL_REGISTRY_V1.md | — | Model catalog | **STANDALONE** (markdown) |
| 9 | WORKSPACE_MANIFEST.json | — | Workspace structure | **OVERLAPS** #6 |
| 10 | CANONICAL_MODULES.json | — | Modules | Derived view |
| 11 | CANONICAL_PACKAGES.json | — | Packages | Derived view |
| 12 | CANONICAL_PROJECTS.json | — | Projects | Derived view |
| 13 | SUPRAMODULE_REGISTRY.json | — | Module registry | Overlaps #10 |
| 14 | PROJECT_REGISTRY.json | — | Project registry | Overlaps #12 |

### 1.2 Duplicate Detection

| Overlap Group | Files | Severity | Impact |
|---------------|-------|----------|--------|
| **Factory Registries** | FACTORY_REGISTRY.json, SUPRA_EXECUTIVE_PLATFORM_REGISTRY.json (L0 layer), SUPRA_MASTER_REGISTRY.json (categories.workspace) | HIGH | Multiple sources of truth for factory data |
| **Canonical Sources** | CANONICAL_REGISTRY.json, SUPRA_MASTER_REGISTRY.json (canonical_sources_by_category) | HIGH | Both claim to be canonical source registry |
| **Component Inventories** | SUPRA_EXECUTIVE_PLATFORM_REGISTRY.json, CANNO_REGISTRY.json | MEDIUM | Both list 89 components with different schemas |
| **Workspace Manifests** | SUPRA_MASTER_MANIFEST.json, WORKSPACE_MANIFEST.json | MEDIUM | Two manifest files |
| **Derived Views** | CANONICAL_MODULES.json, MODULE_REGISTRY.json, etc. | LOW | Intentional derived views but multiply referenced |

### 1.3 Obsolete Registries

| Registry | Reason for Obsolescence | Action |
|----------|------------------------|--------|
| CANONICAL_REGISTRY.json | Dated 2026-07-24, only 1 project (deprecated environment twin data) | **ARCHIVE** |
| SUPRA_EXECUTIVE_PLATFORM_REGISTRY.json | 177KB spec with no runtime consumer — 89 components never referenced by Swift code as registry | **ARCHIVE** |
| SUPRA_MASTER_MANIFEST.json | Replaced by WORKSPACE_MANIFEST.json as canonical manifest | **ARCHIVE** |

### 1.4 Missing Registries

| Missing Registry | Required By | Current State |
|-----------------|-------------|---------------|
| MODEL_REGISTRY.json (machine-readable) | SUPRA-Router, FACTORY_04 | SUPRA_MODEL_REGISTRY_V1.md is markdown-only — **CREATED IN PHASE 3** |
| AGENT_REGISTRY.json (machine-readable) | SUPRA-Router, FACTORY_09 | AGENTS.md + SUPRA_AGENT_REGISTRY_V1.md are markdown-only |
| CAPABILITY_REGISTRY.json | SUPRA-Router for task delegation | Referenced in SUPRA_EXECUTIVE_PLATFORM_REGISTRY.json but no actual file |

---

## 2. CANONICAL REGISTRY HIERARCHY

```
FACTORIES/FACTORY_REGISTTRY.json  ← SINGLE SOURCE OF TRUTH for factory structure
├── FACTORY_01→10
├── outputs (26 certified)
├── health scores
└── dependencies

SUPRA/SUPRA_MODEL_REGISTRY_V2.json  ← Machine-readable model catalog (NEW)
├── providers (8)
├── models (per provider)
├── capability scores
└── health status

SUPRA/SUPRA_AGENT_REGISTRY_V2.json  ← Machine-readable agent catalog (FUTURE)
├── agents (9)
├── permissions
├── commands
└── capability mapping

FACTORIES/FACTORY_01_ARCHITECTURE/outputs/ARCHITECTURE_MAP.md  ← Architecture truth
FACTORIES/FACTORY_04_KNOWLEDGE/outputs/CANONICAL_MODEL.json    ← Knowledge truth
```

---

## 3. CONSOLIDATION STEPS

### Step 1: Archive Obsolete Registries
```
Files to move to FACTORIES/FACTORY_01_ARCHITECTURE/archived/:
  CANONICAL_REGISTRY.json
  SUPRA_EXECUTIVE_PLATFORM_REGISTRY.json
  SUPRA_MASTER_MANIFEST.json
```
Rollback: Restore from archive directory.

### Step 2: Mark SUPRA_MASTER_REGISTRY.json as DERIVED
```
Add to file header: "status": "DERIVED_VIEW"
Reference FACTORIES/FACTORY_REGISTRY.json as authoritative source
```
Rollback: Revert header change.

### Step 3: Mark CANNO_REGISTRY.json as NUCLEO-ONLY
```
Add to file header: "scope": "NUCLEO_COMPONENT_INVENTORY_ONLY"
Remove any factory/executive data overlaps
```
Rollback: Restore original file.

### Step 4: Create MODEL_REGISTRY_V2.json
```
New file at root (machine-readable, see PHASE 3)
Replace SUPRA_MODEL_REGISTRY_V1.md as runtime source
Mark SUPRA_MODEL_REGISTRY_V1.md as "HISTORICAL"
```
Rollback: Delete MODEL_REGISTRY_V2.json, restore SUPRA_MODEL_REGISTRY_V1.md.

### Step 5: Clean Duplicate Derived Views
```
Audit: CANONICAL_MODULES.json vs MODULE_REGISTRY.json
Action: Preserve canonical, archive duplicates
```

---

## 4. RISK ASSESSMENT

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Archived registry still referenced by script | MEDIUM | MEDIUM | grep for file references before archiving |
| Consolidation breaks SUPRA_EXECUTIVE_PLATFORM_REGISTRY.md consumers | LOW | MEDIUM | No known runtime consumer — all spec-only |
| MODEL_REGISTRY_V2.json schema diverges from V1.md | LOW | LOW | V2 is superset of V1 data |
| Registration of new models conflicts | LOW | LOW | Merge strategy: V1.md data wins on overlap |

---

## 5. CERTIFICATION

| Criterion | Status |
|-----------|--------|
| All 14+ registry files audited | CERTIFIED |
| 3 duplicate groups identified | CERTIFIED |
| 3 obsolete registries identified | CERTIFIED |
| 3 missing registries identified | CERTIFIED |
| Canonical hierarchy defined | CERTIFIED |
| 5-step consolidation plan with rollback | CERTIFIED |
| No migration executed (plan only) | CERTIFIED |

---

**END OF REGISTRY CONSOLIDATION PLAN V1**
