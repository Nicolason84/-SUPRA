# SUPRA KNOWLEDGE KERNEL V1

## Fusion de ZERO, FOUNDATION, Registry, Manifest et Knowledge Maps

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CORE — Knowledge Kernel |
| **Version** | SUPRA_KNOWLEDGE_KERNEL_V1 |
| **Date** | 2026-07-29 |
| **Autorité** | CORE — Theory Engine utilise exclusivement ce Kernel |
| **Sources absorbées** | SUPRA_ZERO_*, SUPRA_FOUNDATION_*, SUPRA_MASTER_REGISTRY.json, SUPRA_MASTER_MANIFEST.json, knowledge_*.json, WORKSPACE_MANIFEST.json |

---

## 1. Interfaces de Lecture (Theory Engine API)

Theory Engine utilise exclusivement ces interfaces pour lire la connaissance du système :

```
Interface getVision()        → Vision du système
Interface getMission()       → Mission courante
Interface getArchitecture()  → Architecture canonique
Interface getRegistry()      → Registres canoniques
Interface getManifest()      → Manifestes
Interface getGraph()         → Graphes de connaissance
Interface getHistory()       → État historique (ZERO)
Interface getStandards()     → Standards et conventions
Interface getComponents()    → Composants et leurs états
Interface getDecisions()     → Décisions architecturales (ADR)
```

---

## 2. Vision et Mission du Système

### 2.1 Vision

**Unifier l'écosystème SUPRA en un socle canonique unique, industriellement viable.**

### 2.2 Mission

Maintenir le socle canonique unique, valider toute évolution, garantir la cohérence architecturale, assurer la traçabilité, préserver l'intégrité, permettre la réversibilité.

---

## 3. Structure de la Connaissance

### 3.1 Arbre de Connaissance

```
SUPRA KNOWLEDGE
├── Vision & Mission (Executive Kernel)
├── Architecture (Couches L0-L6)
│   ├── L0: Industrial Base
│   ├── L1: Providers + Plugins
│   ├── L2: Theory + Knowledge
│   ├── L3: Sherpa + Cortex
│   ├── L4: Runtime + Workspace
│   ├── L5: Executive + Products
│   └── L6: Presentation
├── Composants
│   ├── Agents (9 fondateurs + futurs)
│   ├── Runtime (services, pipelines)
│   ├── Produits (Alive, Alpha, etc.)
│   └── Plugins (SDK, spécifications)
├── Registres
│   ├── Master Registry
│   ├── Agent Registry
│   ├── Model Registry
│   └── ADR Registry
├── Décisions
│   └── ADR (Architecture Decision Records)
├── État
│   ├── Runtime Status
│   ├── Workspace State
│   └── System State
└── Historique
    └── ZERO (état historique validé)
```

---

## 4. Registres Canoniques

| Registre | Contenu | Source | Format |
|----------|---------|--------|--------|
| Master Registry | Sources de vérité par domaine | SUPRA_MASTER_REGISTRY.json | JSON |
| Master Manifest | Autorité unique du projet | SUPRA_MASTER_MANIFEST.json | JSON |
| Agent Registry | Définitions et permissions des agents | SUPRA_AGENT_REGISTRY_V1.md | Markdown |
| Model Registry | Modèles LLM supportés | SUPRA_MODEL_REGISTRY_V1.md | Markdown |
| ADR Registry | Décisions architecturales | ADR_REGISTRY.json | JSON |
| Governance Registry | État de la gouvernance | GOVERNANCE_REGISTRY.json | JSON |
| Module Registry | Modules Swift | MODULE_REGISTRY.json | JSON |
| Package Registry | Packages | PACKAGE_REGISTRY.json | JSON |
| Project Registry | Projets Xcode | PROJECT_REGISTRY.json | JSON |

---

## 5. Graphes de Connaissance

| Graphe | Contenu | Source |
|--------|---------|--------|
| Master Graph | Relations CORE et composants | SUPRA_MASTER_GRAPH.md |
| Knowledge Graph | Relations de connaissance | knowledge_graph.json |
| Knowledge Relations | Relations sémantiques | knowledge_relations.json |
| Knowledge Authority | Autorités par domaine | knowledge_authority.json |
| Dependency Graph | Dépendances entre composants | dependency_graph.json |
| Runtime Graph | Topologie du runtime | SUPRA_RUNTIME_GRAPH.md |
| Mission Graph | Graphe des missions | mission_graph.json |
| Global Graph | Vue globale consolidée | global_graph.json |

---

## 6. État du Système

| Artefact | Contenu | Source |
|----------|---------|--------|
| System State | État complet du système | SUPRA_STATE.json |
| Runtime Status | Statut du runtime | RUNTIME_STATUS.json |
| Workspace Manifest | État du workspace | WORKSPACE_MANIFEST.json |
| Environment Index | Index d'environnement | ENVIRONMENT_INDEX.json |
| Workspace Memory | Mémoire du workspace | workspace_memory.json |
| Session Snapshot | État de session | SESSION_SNAPSHOT_*.json |

---

## 7. Standards et Conventions

### 7.1 Standards de Codage et d'Architecture

| Standard | Source | Statut |
|----------|--------|--------|
| Architecture 7 couches | SUPRA_EXECUTIVE_CANON.md | CANONIQUE |
| Object Model | EXECUTIVE_OBJECT_MODEL.md | CANONIQUE |
| Runtime Model | EXECUTIVE_RUNTIME.md | CANONIQUE |
| AI Lab Architecture | SUPRA_AI_LAB_ARCHITECTURE_V1.md | CANONIQUE |
| Plugin SDK Spec | SUPRA_PLUGIN_SDK_SPEC.md | SPÉCIFIÉ |

### 7.2 Conventions de Travail

| Convention | Source | Statut |
|------------|--------|--------|
| Continuity Standard | CAnnoNico_CONTINUITY_STANDARD.md | CANONIQUE |
| Development Guide | CAnnoNico_DEVELOPMENT_GUIDE.md | CANONIQUE |
| Workflow Standard | CAnnoNico_WORKFLOW_STANDARD.md | CANONIQUE |
| Git Cleanup Plan | GIT_CLEANUP_PLAN.md | CANONIQUE |
| Workflow V1 | SUPRA_WORKFLOW_V1.md | CANONIQUE |

---

## 8. État Historique (ZERO)

### 8.1 Ce que ZERO a Produit

| Domaine | Livrable |
|---------|----------|
| Cartographie | 15+ locations scannées, 12 documents produits |
| Détection doublons | 5 catégories, 7 runtimes, 10 cores |
| Santé workspace | ACTIF, v2.2.0, 6/9 tests passants |
| Gap Analysis | Theory Engine 0%, Sherpa 0%, Cortex 20% |
| Architecture cible | SUPRA ULTIMATE définie |

### 8.2 Leçons de ZERO (Intégrées dans CORE)

| Leçon | Application dans CORE |
|-------|----------------------|
| Pas de doublons | Source de Vérité Unique (NN-04) |
| Pas d'architectures concurrentes | Unité d'Architecture (NN-01) |
| Traçabilité obligatoire | Traçabilité des Décisions (NN-06) |
| Cycle de vie strict | Cycle de Vie Obligatoire (NN-05) |
| Réversibilité | Réversibilité (NN-03) |

---

## 9. Services de Connaissance

### 9.1 Services de Lecture (Read-only)

```
KnowledgeReader.getKernel(kernelId)       → Contenu d'un kernel
KnowledgeReader.getRegistry(registryId)   → Contenu d'un registre
KnowledgeReader.getManifest(manifestId)   → Contenu d'un manifest
KnowledgeReader.getDecision(adrId)        → Contenu d'une ADR
KnowledgeReader.getGraph(graphId)         → Contenu d'un graphe
KnowledgeReader.getState(stateId)         → État d'un composant
KnowledgeReader.search(query)             → Recherche dans la connaissance
KnowledgeReader.resolve(reference)        → Résolution de référence
```

### 9.2 Services de Navigation

```
KnowledgeNavigator.browse(path)           → Navigation dans l'arbre
KnowledgeNavigator.relations(entityId)    → Relations d'une entité
KnowledgeNavigator.dependencies(entityId) → Dépendances d'une entité
KnowledgeNavigator.path(from, to)         → Chemin entre deux entités
KnowledgeNavigator.history(entityId)      → Historique d'une entité
```

---

## 10. Règles du Knowledge Kernel

| ID | Règle | Description |
|----|-------|-------------|
| KK-01 | Théorie lit exclusivement ce Kernel | Theory Engine n'accède pas aux documents historiques |
| KK-02 | Les registres sont la source de vérité | Tout composant a une entrée dans un registre |
| KK-03 | Les graphes sont dérivés des registres | Les graphes reflètent l'état des registres |
| KK-04 | L'historique est préservé | ZERO reste accessible mais n'est plus actif |
| KK-05 | Les interfaces sont stables | Les interfaces de lecture ne changent pas sans ADR |

---

## 11. Correspondance : Documents Historiques → Knowledge Kernel

| Document Historique | Absorbé Dans |
|--------------------|--------------|
| SUPRA_ZERO_EXECUTIVE_REPORT.md | Section 8 (État Historique) |
| SUPRA_ZERO_MASTER_MAP.md | Section 3 (Arbre de Connaissance) |
| SUPRA_EXECUTIVE_CANON.md | Section 3.1 (Architecture) |
| SUPRA_FOUNDATION_RULES.md | Section 7 (Standards) |
| SUPRA_MASTER_REGISTRY.json | Section 4 (Registres) |
| SUPRA_MASTER_MANIFEST.json | Section 4 (Registres) |
| knowledge_graph.json | Section 5 (Graphes) |
| knowledge_relations.json | Section 5 (Graphes) |
| WORKSPACE_MANIFEST.json | Section 6 (État) |
| SESSION_SNAPSHOT_*.json | Section 6 (État) |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA ULTIMATE CORE V1. Knowledge Kernel — interface unique pour Theory Engine.*
