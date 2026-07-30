# SUPRA STORAGE GOVERNANCE

**Version**: 1.0  
**Status**: STABLE  
**Category**: Workspace Governance  
**Path**: `SUPRA_STORAGE_GOVERNANCE.md`

---

## Principles

1. **Unified Storage Model**: un seul modèle de stockage pour tout le workspace
2. **Explicit Location**: chaque type de donnée a un emplacement désigné
3. **No Orphans**: pas de fichier sans catégorie
4. **Lifecycle-Bound**: la rétention suit le cycle de vie
5. **Reversible First**: toute décision de stockage doit être réversible

---

## Storage Model

```
DESKTOP
│
├── NOVA_OS/                          ← Protected Root
│   └── SUPRA/                        ← SUPRA CORE + WORKSPACE
│       ├── SUPRA/                    → Source Code
│       ├── SUPRATests/               → Tests
│       ├── docs/                     → Technical Documentation
│       ├── Governance/               → Governance Records
│       ├── Freeze/                   → Freeze Points
│       ├── Packages/                 → Swift Packages
│       ├── Artifacts/                → Build Artifacts
│       ├── Inbox/                    → Active Intake
│       ├── Outbox/                   → Active Output
│       ├── Missions/                 → Active Missions
│       ├── SUPRA_RUNTIME/            → Runtime Data
│       ├── Reports/                  → Reports
│       ├── Logs/                     → System Logs
│       ├── Evidence/                 → Evidence Store
│       ├── .kernel/                  → Kernel System Data
│       └── .opencode/               → OpenCode Config
│
├── Products/                         → [PLANNED] Future products directory
├── Archives/                         → [PLANNED] Future archives directory
├── Snapshots/                        → [PLANNED] Future snapshots directory
│
└── Desktop Level Items               → [TO BE ORGANIZED via Migration Plan]
```

---

## Storage Rules by Data Type

### 1. New Projects

| Rule | Detail |
|------|--------|
| **Where** | `NOVA_OS/SUPRA/` ou sous `Products/` (futur) |
| **Structure** | Follow naming conventions from Workspace Kernel |
| **Lifecycle** | Start as NEW → ACTIVE |
| **Tag** | Category tag + lifecycle tag |
| **Approval** | Mission + Executive |

### 2. Archives

| Rule | Detail |
|------|--------|
| **Where** | `SUPRA_ARCHIVE/` → futur `Archives/` |
| **Format** | Zip + manifest.json |
| **Integrity** | SHA256 checksum enregistré |
| **Retention** | Illimitée pour archives FROZEN |
| **Index** | Entrée dans Workspace Index |

### 3. Snapshots

| Rule | Detail |
|------|--------|
| **Where** | `SUPRA_PROJECTS/` → futur `Snapshots/` |
| **Format** | Dossier daté (SUPRA_<NAME>_<TIMESTAMP>) |
| **Lifecycle** | FROZEN immédiatement |
| **Retention** | 90 jours avant LEGACY |
| **Consolidation** | Déduplication avec le Core |

### 4. Exports

| Rule | Detail |
|------|--------|
| **Where** | `Artifacts/exports/` |
| **Format** | .json, .csv, .tsv |
| **Lifecycle** | TRANSIENT (30 jours) |
| **Trace** | Export log dans Runtime |
| **Cleanup** | Purge automatique après 30 jours |

### 5. Evidence

| Rule | Detail |
|------|--------|
| **Where** | `Evidence/` ou `SUPRA_RUNTIME/` |
| **Format** | .md, .json, .png |
| **Lifecycle** | STABLE → ARCHIVED (après certification) |
| **Retention** | Illimitée |
| **Integrity** | Checksum + signature |

### 6. Logs

| Rule | Detail |
|------|--------|
| **Where** | `Logs/`, `SUPRA_RUNTIME/Logs/` |
| **Format** | .log |
| **Lifecycle** | TRANSIENT (30-90 jours) |
| **Max Size** | 100 MB par fichier |
| **Rotation** | Log rotation automatique |

### 7. Temporary Files

| Rule | Detail |
|------|--------|
| **Where** | `SUPRA_TEMP/` ou Desktop |
| **Format** | Any |
| **Lifecycle** | TRANSIENT (7 jours max) |
| **Cleanup** | Purge hebdomadaire |
| **Desktop Limit** | Zéro fichier temporaire sur le Desktop |

### 8. Scripts

| Rule | Detail |
|------|--------|
| **Where** | `SUPRA_SCRIPTS/` → futur `Scripts/` |
| **Lifecycle** | ACTIVE (en usage) ou ARCHIVED |
| **Documentation** | Header obligatoire avec description |
| **Version** | Tag V1, V2, etc. |

---

## Storage Capacity Plan

| Zone | Current Size | Growth Rate | Limit | Action |
|------|-------------|-------------|-------|--------|
| SUPRA CORE | ~200 MB | Stable | 500 MB | Monitor |
| SUPRA_BUILD/import/ | ~4.5 GB (65535 files) | None | 5 GB | Archive → consolidate |
| SUPRA_TEMP/ | ~200 MB | Decreasing | 500 MB | Auto-clean |
| Desktop files | ~500 MB | Decreasing | 200 MB | Migrate |
| SUPRA_ARCHIVE/ | ~900 MB (zips) | None | 2 GB | Keep |
| Snapshots | ~1 GB | None | 2 GB | Consolidate |

---

## Future Storage Layout (Phase 2 Target)

```
~/Desktop/
├── NOVA_OS/                           ← Protected
│   └── SUPRA/                         ← CORE + Workspace (unchanged)
│
├── Products/                          ← Active products
│   ├── SUPRA_VIDEO_SWAP/
│   ├── PLATFORM_CORE/
│   └── ...
│
├── Archives/                          ← Historical data
│   └── SUPRA_ARCHIVE/
│
├── Snapshots/                         ← Frozen points
│   └── SUPRA_PROJECTS/
│
└── Scripts/                           ← Script library
    └── SUPRA_SCRIPTS/
```
