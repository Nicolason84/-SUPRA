# SUPRA WORKSPACE KERNEL

**Version**: 1.0  
**Status**: STABLE  
**Category**: Workspace Kernel  
**Path**: `SUPRA_WORKSPACE_KERNEL.md`

---

## Kernel Identity

```
SUPRA WORKSPACE KERNEL
├── Identity: SUPRA Workspace Operating System
├── Version: 1.0
├── State: STABLE
├── Domain: Physical Workspace Organization
└── Dependencies: SUPRA CORE (stable, unchanged)
```

---

## Kernel Positioning

```
SUPRA SYSTEM KERNELS
├── Executive Kernel       → SUPRA_EXECUTIVE_KERNEL.md
├── Governance Kernel      → SUPRA_GOVERNANCE_KERNEL.md
├── Mission Kernel         → SUPRA_MISSION_KERNEL.md
├── Knowledge Kernel       → SUPRA_KNOWLEDGE_KERNEL.md
├── Runtime Kernel         → SUPRA_RUNTIME_KERNEL.md
├── Product Kernel         → SUPRA_PRODUCT_KERNEL.md
├── Provider Kernel        → SUPRA_PROVIDER_KERNEL.md
└── Workspace Kernel       → SUPRA_WORKSPACE_KERNEL.md    ★ YOU ARE HERE
```

Le Workspace Kernel est le **socle physique** de SUPRA. Il définit où et comment le travail existe dans le système de fichiers.

---

## Responsibilities

| # | Responsibility | Description |
|---|---------------|-------------|
| 1 | **Workspace Structure** | Définir l'arborescence officielle du workspace |
| 2 | **Naming Conventions** | Standards de nommage pour dossiers et fichiers |
| 3 | **Zone Management** | Délimiter zones protégées, actives, temporaires |
| 4 | **Lifecycle Enforcement** | Appliquer les règles du cycle de vie |
| 5 | **Storage Governance** | Définir où créer/archiver/stocker |
| 6 | **Access Control** | Gérer permissions et visibilité |
| 7 | **Indexation** | Maintenir le Workspace Index |
| 8 | **Desktop Readiness** | Évaluer et maintenir la lisibilité du Desktop |
| 9 | **Migration Planning** | Planifier les réorganisations |
| 10 | **Evidence Preservation** | Garantir zéro perte de données |

---

## Workspace Physical Root

```
/Users/nicolasalonso/Desktop/
├── NOVA_OS/                         ← Active Workspace Root
│   └── SUPRA/                       ← SUPRA CORE + WORKSPACE
└── Desktop items                    ← Legacy / To Be Organized
```

### Protected Zone

La zone protégée est le répertoire `NOVA_OS/SUPRA/`. Aucune modification de structure ne peut y être faite sans décision Executive.

```
PROTECTED ZONE
└── ~/Desktop/NOVA_OS/SUPRA/
    ├── SUPRA/                  ← Source code Swift
    ├── SUPRATests/             ← Tests
    ├── .kernel/                ← Kernel data
    ├── .opencode/              ← OpenCode config
    ├── docs/                   ← Documentation
    ├── Governance/             ← Governance
    ├── Freeze/                 ← Freeze points
    ├── Packages/               ← Swift packages
    ├── Artifacts/              ← Build artifacts
    ├── Inbox/                  ← Active inbox
    ├── Outbox/                 ← Active outbox
    ├── Missions/               ← Active missions
    ├── SUPRA_RUNTIME/          ← Runtime data
    ├── Reports/                ← Reports
    ├── Logs/                   ← System logs
    └── Evidence/              ← Evidence store
```

### Active Desktop Zone

Zone Desktop hors NOVA_OS — à organiser mais **ne rien déplacer maintenant**.

```
ACTIVE DESKTOP ZONE (à organiser)
├── SUPRA_VIDEO_SWAP_APP_V1/       ← Product
├── SUPRA_VIDEO_SWAP_V3/           ← Product
├── PLATFORM_CORE/                  ← Product
├── SUPRA_BUILD/                    ← Development (build assets)
├── SUPRA_SCRIPTS/                  ← Archive (scripts historiques)
├── SUPRA_PROJECTS/                 ← Snapshots
├── SUPRA_TEMP/                     ← Temporary
├── SUPRA_ARCHIVE/                  ← Archive
├── SUPRA_RELEASE/                  ← Documentation
├── SUPRA_REPORTS/                  ← External Imports
├── .app bundles                    ← Products
├── .sh scripts                     ← Temporary (Desktop level)
├── .txt / .log / .md files        ← Temporary
└── .png files                      ← Temporary
```

### Sibling Directories (NOVA_OS)

```
SIBLING ZONE (NOVA_OS)
├── _IMMUNITY/                      ← Sandbox
├── MEMORY_CORE/                    ← Sandbox
├── SUPRA_BISECT/                   ← Snapshot
├── SUPRA_DEEPSEEK_EXIT_READINESS/  ← Sandbox
├── SUPRA_FRESH/                    ← Snapshot
├── SUPRA_MODEL_TEST/               ← Snapshot
├── SUPRA_RECOVERY/                 ← Snapshot
└── SUPRA_RUNTIME_EVIDENCE_READONLY/← Snapshot
```

---

## Naming Conventions

### Directories

| Pattern | Example | Rule |
|---------|---------|------|
| `SUPRA_<NAME>` | `SUPRA_BUILD` | Projects, tools, archives |
| `SUPRA_<NAME>_<DATE>` | `SUPRA_BISECT_20260724` | Dated snapshots |
| `_<PREFIX>_<NAME>` | `_FOUNDATION_MEMORY` | System/infra directories |
| `.<name>` | `.kernel` | Hidden system directories |
| `<Product>_V<N>` | `SUPRA_VIDEO_SWAP_V3` | Product versions |
| `<Product>_FINAL` | `SupraVideoSwap_FINAL` | Release builds |

### Files

| Pattern | Example | Rule |
|---------|---------|------|
| `SUPRA_<DOMAIN>_<TYPE>.md` | `SUPRA_WORKSPACE_KERNEL.md` | Kernel documents |
| `SUPRA_<TOPIC>.md` | `SUPRA_CONSTITUTION.md` | Core documents |
| `GO_<ACTION>_<CONTEXT>.sh` | `GO_SUPRA_GLOBAL_AUDIT.sh` | Executable scripts |
| `SUPRA_<TOPIC>_<DATE>.txt` | `SUPRA_RECOVERY_REPORT_20260724.txt` | Timestamped reports |

### Prohibited Patterns

- Espaces dans les noms de fichiers/dossiers
- Caractères spéciaux hors `_` et `-`
- Noms vides ou trop génériques (`CURRENT`, `CURRENT 2`, `test`)
- Extensions incohérentes
- Mélange de langues dans un même chemin

---

## Zone Rules

| Zone | Path | Rule |
|------|------|------|
| **Protected** | `NOVA_OS/SUPRA/` | Read-Only pour Refactor/Auditor. Modifications via Builder uniquement |
| **Workspace Root** | `Desktop/NOVA_OS/SUPRA/` | Point d'entrée unique. Ne pas déplacer |
| **Source** | `SUPRA/` (subdir) | Code Swift. Changements via PR |
| **Kernel** | `.kernel/` | Données système. Ne pas éditer manuellement |
| **Runtime** | `SUPRA_RUNTIME/` | Données d'exécution. Peut être purgé |
| **Active** | `Inbox/`, `Outbox/`, `Missions/` | Usage quotidien. Nettoyage régulier |
| **Temporary** | Desktop root files | Durée de vie max 7 jours |
| **Snapshots** | `SUPRA_PROJECTS/` et siblings | Read-Only. Frozen |

---

## Conventions

1. **Single Source of Truth**: le Workspace Index est l'entrée unique
2. **No Data Loss**: toute opération doit être réversible
3. **Explicit State**: chaque dossier a un état (tag ou fichier `.lifecycle`)
4. **Minimal Desktop**: le Desktop doit contenir moins de 20 items
5. **Separation of Concerns**: Core (logique) ≠ Workspace (physique)
6. **Traceability**: chaque décision d'organisation est documentée
7. **No Hidden Duplicates**: deux dossiers ne peuvent pas avoir la même fonction

---

## Kernel Boundaries

Le Workspace Kernel ne peut pas :

- Modifier SUPRA CORE
- Supprimer des fichiers ou dossiers
- Déplacer des données sans plan validé
- Changer les permissions système
- Créer des documents de spécification fonctionnelle

Le Workspace Kernel peut :

- Classifier et catégoriser
- Proposer des migrations
- Documenter la structure
- Évaluer la lisibilité
- Définir des conventions
- Créer des indexes et des plans
