# SUPRA DOCUMENT HIERARCHY V1

## Hiérarchie Documentaire Officielle de SUPRA

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CONSTITUTION |
| **Version** | SUPRA_DOCUMENT_HIERARCHY_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Chaque catégorie a une seule autorité canonique |

---

## 1. Arbre Hiérarchique

```
╔══════════════════════════════════════════════════════╗
║            1. SUPRA CONSTITUTION                      ║
║  Cadre immuable. Principes non négociables.          ║
║  Autorité : Constitution / Executive                  ║
╚══════════════════════════════════════════════════════╝
        │
        ▼
╔══════════════════════════════════════════════════════╗
║            2. EXECUTIVE CANON                         ║
║  Constitution opérationnelle. Architecture 7 couches. ║
║  Autorité : Executive Canon / Architect               ║
╚══════════════════════════════════════════════════════╝
        │
        ▼
╔══════════════════════════════════════════════════════╗
║            3. MASTER MANIFEST                         ║
║  Autorité unique du projet. Composition.             ║
║  Format : JSON. Statut : Canonique.                   ║
╚══════════════════════════════════════════════════════╝
        │
        ▼
╔══════════════════════════════════════════════════════╗
║            4. MASTER REGISTRY                         ║
║  Source de vérité par catégorie.                     ║
║  Format : JSON. Statut : Canonique.                   ║
╚══════════════════════════════════════════════════════╝
        │
        ├──────────────────────────────────┐
        ▼                                  ▼
╔══════════════════════════╗    ╔══════════════════════════╗
║    5. POLICIES           ║    ║    6. STANDARDS           ║
║  Gouvernance             ║    ║  Règles et conventions    ║
║  Sécurité               ║    ║  Guides                   ║
║  Validation             ║    ║  Templates                ║
║  Routage                ║    ║  Schemas                  ║
╚══════════════════════════╝    ╚══════════════════════════╝
        │                                  │
        └──────────────┬───────────────────┘
                       ▼
╔══════════════════════════════════════════════════════╗
║            7. ARCHITECTURE                            ║
║  ADR (Architecture Decision Records)                 ║
║  Architecture Index                                   ║
║  Object Models                                        ║
║  Contrats fournisseurs                               ║
╚══════════════════════════════════════════════════════╝
                       │
                       ▼
╔══════════════════════════════════════════════════════╗
║            8. PRODUCTS                                ║
║  Roadmap                                              ║
║  Releases                                             ║
║  Fonctionnalités                                     ║
║  Certifications                                      ║
╚══════════════════════════════════════════════════════╝
                       │
                       ▼
╔══════════════════════════════════════════════════════╗
║            9. RUNTIME                                 ║
║  État du runtime                                      ║
║  Diagnostics                                          ║
║  Métriques                                            ║
║  Workflows                                            ║
╚══════════════════════════════════════════════════════╝
                       │
                       ▼
╔══════════════════════════════════════════════════════╗
║           10. PLUGINS                                 ║
║  SDK                                                  ║
║  Spécifications                                      ║
║  Registres                                           ║
║  Manifests                                           ║
╚══════════════════════════════════════════════════════╝
                       │
                       ▼
╔══════════════════════════════════════════════════════╗
║           11. WORKSPACE                               ║
║  Index du workspace                                   ║
║  État des fichiers                                   ║
║  Git                                                  ║
╚══════════════════════════════════════════════════════╝
                       │
                       ▼
╔══════════════════════════════════════════════════════╗
║           12. DOCUMENTATION                           ║
║  Guides                                               ║
║  Rapports                                             ║
║  Logs                                                 ║
║  Sessions                                             ║
╚══════════════════════════════════════════════════════╝
```

---

## 2. Table de Hiérarchie

| Niveau | Catégorie | Autorité Canonique | Format | Statut |
|--------|-----------|-------------------|--------|--------|
| 1 | Constitution | SUPRA_CONSTITUTION.md | Markdown | CONSTITUTION |
| 2 | Executive Canon | SUPRA_EXECUTIVE_CANON.md | Markdown | CANONIQUE |
| 3 | Master Manifest | SUPRA_MASTER_MANIFEST.json | JSON | CANONIQUE |
| 4 | Master Registry | SUPRA_MASTER_REGISTRY.json | JSON | CANONIQUE |
| 5 | Policies | Governance/ directory | Mixte | ACTIF |
| 6 | Standards | SUPRA_FOUNDATION_RULES.md | Markdown | CANONIQUE |
| 7 | Architecture | SUPRA_ARCHITECTURE_INDEX.json | JSON | CANONIQUE |
| 8 | Products | SUPRA_FOUNDATION_ROADMAP.md | Markdown | CANONIQUE |
| 9 | Runtime | RUNTIME_STATUS.json | JSON | ACTIF |
| 10 | Plugins | SUPRA_PLUGIN_SDK_SPEC.md | Markdown | SPÉCIFIÉ |
| 11 | Workspace | WORKSPACE_MANIFEST.json | JSON | ACTIF |
| 12 | Documentation | Per-domain | Mixte | VARIABLE |

---

## 3. Sources Canoniques par Catégorie

### 3.1 Constitution (Niveau 1 — Immuable)

| Document | Rôle | Source |
|----------|------|--------|
| SUPRA_CONSTITUTION.md | Constitution du système | Ce document |
| SUPRA_IMMUTABLE_PRINCIPLES.md | Principes non négociables | Constitution |
| SUPRA_AUTHORITY_MODEL.md | Modèle d'autorité | Constitution |
| SUPRA_DOCUMENT_HIERARCHY.md | Hiérarchie documentaire | Constitution |
| SUPRA_EVOLUTION_LAW.md | Loi d'évolution | Constitution |
| SUPRA_GATE_SYSTEM.md | Système de gates | Constitution |
| SUPRA_ADR_STANDARD.md | Standard des ADR | Constitution |
| SUPRA_PROTECTION_MODEL.md | Modèle de protection | Constitution |

### 3.2 Executive Canon (Niveau 2)

| Document | Rôle |
|----------|------|
| SUPRA_EXECUTIVE_CANON.md | Constitution opérationnelle |
| SUPRA_AGENT_CANON.md | Architecture des agents |

### 3.3 Policies (Niveau 5)

| Politique | Source | Statut |
|-----------|--------|--------|
| Workflow | SUPRA_WORKFLOW_V1.md | CANONIQUE |
| Router | SUPRA_ROUTER_SPECIFICATION_V1.md | CANONIQUE |
| Validation | VALIDATION_PROTOCOL.md | CANONIQUE |
| Desktop | DESKTOP_GOVERNANCE.md | CANONIQUE |
| Agent Registry | SUPRA_AGENT_REGISTRY_V1.md | CANONIQUE |
| Model Registry | SUPRA_MODEL_REGISTRY_V1.md | CANONIQUE |

### 3.4 Standards (Niveau 6)

| Standard | Source | Statut |
|----------|--------|--------|
| Foundation Rules | SUPRA_FOUNDATION_RULES.md | CANONIQUE |
| Continuité | CAnnoNico_CONTINUITY_STANDARD.md | CANONIQUE |
| Développement | CAnnoNico_DEVELOPMENT_GUIDE.md | CANONIQUE |
| Workflow | CAnnoNico_WORKFLOW_STANDARD.md | CANONIQUE |
| Executive Object Model | EXECUTIVE_OBJECT_MODEL.md | CANONIQUE |
| Executive Runtime | EXECUTIVE_RUNTIME.md | CANONIQUE |

### 3.5 Agents

| Agent | Source de Définition | Source de Configuration |
|-------|---------------------|------------------------|
| Tous | AGENTS.md | opencode.json |
| Détails | SUPRA_AGENT_CANON.md | SUPRA_AGENT_REGISTRY_V1.md |

---

## 4. Règles de Hiérarchie

### Règle H-01 : Non-Contradiction

Un document de niveau inférieur ne peut contredire un document de niveau supérieur.

**Sanction** : En cas de contradiction, le document de niveau supérieur prévaut.

### Règle H-02 : Référencement

Chaque document de niveau inférieur doit référencer son document de niveau supérieur comme autorité.

### Règle H-03 : Précision

Un document de niveau inférieur peut préciser sans contredire. La précision est autorisée. La contradiction est interdite.

### Règle H-04 : Mise à Jour

Toute modification d'un document de niveau supérieur doit être répercutée dans les documents de niveau inférieur qui le référencent.

### Règle H-05 : Création

Un nouveau document doit être créé au niveau approprié de la hiérarchie. Un document ne peut pas être créé sans niveau défini.

### Règle H-06 : Suppression

Un document ne peut être supprimé que si son niveau supérieur l'autorise. Un document de niveau 1 (Constitution) ne peut jamais être supprimé.

### Règle H-07 : Gel

Un document peut être FROZEN à son niveau actuel. Un document frozen ne peut plus être modifié.

---

## 5. Correspondance avec le Cycle de Vie

| Niveau | Cycle de Vie |
|--------|-------------|
| 1-4 (Constitution → Registry) | CONSTITUTION |
| 5-6 (Policies → Standards) | FOUNDATION → CONSTITUTION |
| 7 (Architecture) | CONSTITUTION → GOVERNANCE |
| 8 (Products) | GOVERNANCE → ULTIMATE |
| 9-10 (Runtime → Plugins) | ULTIMATE → PRODUCTION |
| 11 (Workspace) | GOUVERNÉ |
| 12 (Documentation) | LIBRE |

---

## 6. Index des Documents Existants par Niveau

### Niveau 1 : Constitution (8 documents)
| Document | Statut |
|----------|--------|
| SUPRA_CONSTITUTION.md | ✅ ACTIF |
| SUPRA_IMMUTABLE_PRINCIPLES.md | ✅ ACTIF |
| SUPRA_AUTHORITY_MODEL.md | ✅ ACTIF |
| SUPRA_DOCUMENT_HIERARCHY.md | ✅ ACTIF |
| SUPRA_EVOLUTION_LAW.md | ✅ ACTIF |
| SUPRA_GATE_SYSTEM.md | ✅ ACTIF |
| SUPRA_ADR_STANDARD.md | ✅ ACTIF |
| SUPRA_PROTECTION_MODEL.md | ✅ ACTIF |

### Niveau 2 : Executive Canon (5 documents)
| Document | Statut |
|----------|--------|
| SUPRA_EXECUTIVE_CANON.md | ✅ CANONIQUE |
| SUPRA_AGENT_CANON.md | ✅ CANONIQUE |
| SUPRA_FOUNDATION_EXECUTIVE_REPORT.md | ✅ CANONIQUE |
| SUPRA_FOUNDATION_VALIDATION_REPORT.md | ✅ CANONIQUE |
| SUPRA_CONSTITUTION_EXECUTIVE_REPORT.md | ✅ ACTIF |

### Niveau 3 : Master Manifest (1 document)
| Document | Statut |
|----------|--------|
| SUPRA_MASTER_MANIFEST.json | ✅ CANONIQUE |

### Niveau 4 : Master Registry (1 document)
| Document | Statut |
|----------|--------|
| SUPRA_MASTER_REGISTRY.json | ✅ CANONIQUE |

### Niveau 5 : Policies (6 documents)
| Document | Statut |
|----------|--------|
| SUPRA_WORKFLOW_V1.md | ✅ CANONIQUE |
| SUPRA_ROUTER_SPECIFICATION_V1.md | ✅ CANONIQUE |
| VALIDATION_PROTOCOL.md | ✅ CANONIQUE |
| DESKTOP_GOVERNANCE.md | ✅ CANONIQUE |
| SUPRA_AGENT_REGISTRY_V1.md | ✅ CANONIQUE |
| SUPRA_MODEL_REGISTRY_V1.md | ✅ CANONIQUE |

### Niveau 6 : Standards (6 documents)
| Document | Statut |
|----------|--------|
| SUPRA_FOUNDATION_RULES.md | ✅ CANONIQUE |
| CAnnoNico_CONTINUITY_STANDARD.md | ✅ CANONIQUE |
| CAnnoNico_DEVELOPMENT_GUIDE.md | ✅ CANONIQUE |
| CAnnoNico_WORKFLOW_STANDARD.md | ✅ CANONIQUE |
| EXECUTIVE_OBJECT_MODEL.md | ✅ CANONIQUE |
| EXECUTIVE_RUNTIME.md | ✅ CANONIQUE |

### Niveau 7 : Architecture (1 document)
| Document | Statut |
|----------|--------|
| SUPRA_ARCHITECTURE_INDEX.json | ✅ CANONIQUE |

### Niveau 8 : Products (1 document)
| Document | Statut |
|----------|--------|
| SUPRA_FOUNDATION_ROADMAP.md | ✅ CANONIQUE |

### Niveau 9 : Runtime (2 documents)
| Document | Statut |
|----------|--------|
| RUNTIME_STATUS.json | ✅ ACTIF |
| SUPRA_STATE.json | ✅ CANONIQUE |

### Niveau 10 : Plugins (1 document)
| Document | Statut |
|----------|--------|
| SUPRA_PLUGIN_SDK_SPEC.md | ✅ SPÉCIFIÉ |

### Niveau 11 : Workspace (1 document)
| Document | Statut |
|----------|--------|
| WORKSPACE_MANIFEST.json | ✅ ACTIF |

### Niveau 12 : Documentation (nombreux)
| Document | Statut |
|----------|--------|
| SESSION_SNAPSHOT_*.json | ✅ ACTIF |
| GIT_HYGIENE_REPORT.md | ✅ ACTIF |
| CONTINUITY.md | ✅ ACTIF |

---

## 7. Règles de Nommage

| Type | Pattern | Exemple |
|------|---------|--------|
| Constitution | SUPRA_CONSTITUTION*.md | SUPRA_CONSTITUTION.md |
| Documents niveau 1 | SUPRA_*_.md | SUPRA_CONSTITUTION.md |
| Documents niveau 2-6 | SUPRA_*_.md | SUPRA_EXECUTIVE_CANON.md |
| Rapports | *_REPORT.md | SUPRA_FOUNDATION_EXECUTIVE_REPORT.md |
| Spécifications | *_SPEC.md | SUPRA_PLUGIN_SDK_SPEC.md |
| JSON structurés | *_MANIFEST.json, *_REGISTRY.json | SUPRA_MASTER_MANIFEST.json |
| Registres | *_REGISTRY.json | SUPRA_MASTER_REGISTRY.json |
| Gouvernance | *_GOVERNANCE.md | DESKTOP_GOVERNANCE.md |
| Roadmap | *_ROADMAP.md | SUPRA_FOUNDATION_ROADMAP.md |
| ADR | ADR-*.md | ADR-001.md |

---

## 8. Autorité de Maintenance

| Niveau | Maintenance | Validation des Changements |
|--------|-------------|---------------------------|
| 1 (Constitution) | Architect | Executive |
| 2 (Canon) | Architect | Executive |
| 3-4 (Manifest + Registry) | Builder | Architect |
| 5-6 (Policies + Standards) | Architect | Executive |
| 7 (Architecture) | Architect | Executive |
| 8 (Products) | Architect | Executive |
| 9 (Runtime) | Runtime | Architect |
| 10 (Plugins) | Builder | Architect |
| 11 (Workspace) | Builder | Architect |
| 12 (Documentation) | Explorer | Router |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA CONSTITUTION V1.*
