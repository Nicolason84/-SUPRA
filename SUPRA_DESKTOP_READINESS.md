# SUPRA DESKTOP READINESS

**Version**: 1.0  
**Status**: STABLE  
**Category**: Workspace Assessment  
**Path**: `SUPRA_DESKTOP_READINESS.md`

---

## Executive Summary

Le Desktop est actuellement la **principale source de complexité** du workspace SUPRA.  
Il contient ~95 items (dossiers + fichiers) à la racine, dont une majorité de snapshots, archives, et données temporaires.

**Score de lisibilité**: 3/10  
**Score de complexité**: 8/10  
**Dette organisationnelle**: Élevée  
**Risque de perte de données**: Faible (tout est backupé ou réplicable)

---

## Readability Assessment

### Criteria

| Criteria | Weight | Score | Notes |
|----------|--------|-------|-------|
| Nombre d'items Desktop | 25% | 2/10 | ~95 items à la racine |
| Nommage cohérent | 20% | 6/10 | Majorité en SUPRA_* mais mélange de conventions |
| Hiérarchie claire | 20% | 2/10 | Pas de structure, tout est à plat |
| Sép. préoccupations | 15% | 4/10 | Core/workspace mélangés sur le Desktop |
| Documentation | 10% | 5/10 | Rapports existent mais pas de vue d'ensemble |
| Évolutivité | 10% | 3/10 | Ajouter un item aggrave le problème |

**Overall**: 3.2/10

---

## Complexity Analysis

### Desktop Composition

```
Desktop Root (~95 items)
├── NOVA_OS/                    ← 1 directory (contains SUPRA Core + siblings)
├── SUPRA_* directories         ← ~25 directories
├── Other directories           ← ~5 (PLATFORM_CORE, OPENCODE_*, STORAGE_*)
├── .app bundles                ← 3
├── .sh scripts                 ← ~30 files
├── .log files                  ← 5 files
├── .txt files                  ← 10 files
├── .md files                   ← 5 files
├── .png files                  ← 4 files
└── .jsonc / other              ← 2 files
```

### Complexity Factors

| Factor | Severity | Description |
|--------|----------|-------------|
| **Flat structure** | HIGH | Tout au même niveau |
| **No categorization** | HIGH | Aucune distinction produits/archives/snapshots |
| **Desktop scripts** | MEDIUM | 30 scripts mélangés aux données |
| **Duplicate app bundles** | LOW | 3 bundles, 2 sont des doublons |
| **Large build import** | MEDIUM | 65535 fichiers dans SUPRA_BUILD/import/ |
| **Temporary files** | LOW | Fichiers .txt/.log dispersés |
| **Mixed naming** | MEDIUM | SUPRA_*, GO_*, OPENCODE_*, KRIMI_*, etc. |

---

## Duplication Analysis

| Duplicate Group | Paths | Action |
|-----------------|-------|--------|
| App Bundles | `SupraVideoSwap_FINAL.app`, `SupraVideoSwap_FINAL 2.app` | Keep 1, archive 1 |
| SUPRA CORE copies | `SUPRA_BISECT/SUPRA/`, `SUPRA_FRESH/SUPRA/`, `SUPRA_MODEL_TEST/SUPRA/`, etc. | Consolidate into 1 snapshot |
| Mission snapshots | `SUPRA_MISSION_001_*`, `SUPRA_AUTOINTEGRATOR_*`, etc. | Group under Snapshots/ |
| OpenCode audits | `OPENCODE_AUDIT_*`, `OPENCODE_PROVIDER_DIAG_*`, `OPENCODE_PROVIDER_FORENSICS_*` | Group under Snapshots/OpenCode/ |

---

## Organizational Debt

### Debt Items

| # | Item | Impact | Resolution |
|---|------|--------|------------|
| 1 | 30 shell scripts on Desktop | Low readability | Move to Scripts/ |
| 2 | 5 SUPRA Core copies in NOVA_OS siblings | ~3 GB wasted | Consolidate snapshots |
| 3 | 65535 files in SUPRA_BUILD/import/ | Performance | Archive + compress |
| 4 | No Desktop directory structure | Navigation | Create Products/, Archives/, Snapshots/ |
| 5 | Unclear lifecycle state | Confusion | Add lifecycle tags |
| 6 | Temporary files mixed with permanent | Clutter | Purge temp files |
| 7 | Duplicate app bundles | Confusion | Clean up duplicates |

### Debt Score: 7/10 (High)

---

## Priority Matrix

| Quadrant | Action | Items | Priority |
|----------|--------|-------|----------|
| **High Impact / Low Effort** | Quick wins | Desktop scripts cleanup, temp file purge, duplicate bundle removal | P0 |
| **High Impact / High Effort** | Strategic | SUPRA CORE copy consolidation, import/ archive | P1 |
| **Low Impact / Low Effort** | Incremental | File renaming, tag addition, README creation | P2 |
| **Low Impact / High Effort** | Defer | Full Desktop restructuring, symlink setup | P3 |

### Priority Queue

| Priority | Action | Effort | Impact | Target Phase |
|----------|--------|--------|--------|--------------|
| **P0** | Move 30 scripts to SUPRA_SCRIPTS/ | 1h | High | Phase 0 |
| **P0** | Remove temp .txt/.log/.png from Desktop | 30min | High | Phase 0 |
| **P0** | Archive duplicate app bundles | 15min | Medium | Phase 0 |
| **P1** | Consolidate 5 Core copies into 1 snapshot | 2h | High | Phase 1 |
| **P1** | Archive SUPRA_BUILD/import/ | 3h | High | Phase 2 |
| **P2** | Create Products/, Archives/, Snapshots/ dirs | 1h | Medium | Phase 2 |
| **P2** | Add lifecycle tags to all directories | 30min | Medium | Phase 2 |
| **P3** | Full Desktop restructuring per Migration Plan | 4h | High | Phase 2+ |
| **P4** | SUPRA_TEMP/ selective purge | 1h | Low | Phase 3 |

---

## Desktop Target State

Après migration, le Desktop doit ressembler à :

```
~/Desktop/
├── NOVA_OS/                         ← Protected (unchanged)
├── Products/                        ← Active products
├── Archives/                        ← Historical data
├── Snapshots/                       ← Frozen points
├── Scripts/                         ← Shell scripts
└── README.md                        ← Desktop overview
```

### Target Metrics

| Metric | Current | Target |
|--------|---------|--------|
| Desktop root items | ~95 | <10 |
| Named categories | 0 | 5 directories |
| Scripts on Desktop | 30 | 0 |
| Temp files on Desktop | 20+ | 0 |
| Core duplicates | 5 | 0 |
| Orphan directories | ~25 | 0 |
