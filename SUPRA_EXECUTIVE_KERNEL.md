# SUPRA EXECUTIVE KERNEL V1

## Vision, Mission, Objectifs, Responsabilités et Interfaces Publiques

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CORE — Executive Kernel |
| **Version** | SUPRA_EXECUTIVE_KERNEL_V1 |
| **Date** | 2026-07-29 |
| **Autorité** | CORE — Point d'entrée de l'Executive OS |
| **Préséance** | CORE > tout document opérationnel |

---

## 1. Vision

**Unifier l'écosystème SUPRA en un socle canonique unique, industriellement viable, sur lequel toutes les évolutions futures reposeront sans fragmentation.**

SUPRA est un Executive Operating System qui transforme des objectifs en décisions, actions, exécutions et preuves, tout en rendant l'état réel du système intelligible et gouvernable.

---

## 2. Mission

1. Maintenir le socle canonique unique (SUPRA CORE)
2. Valider toute évolution avant intégration
3. Garantir la cohérence architecturale permanente
4. Assurer la traçabilité de toutes les décisions
5. Préserver l'intégrité des données et des preuves
6. Permettre la réversibilité de toute modification
7. Fournir un point d'entrée unique pour tous les composants futurs

---

## 3. Objectifs Fondamentaux

| ID | Objectif | Critère de Succès | Priorité |
|----|----------|-------------------|----------|
| EO-01 | Zero dépendance directe aux documents historiques | Tout composant lit exclusivement CORE | CRITIQUE |
| EO-02 | Architecture à point d'entrée unique | Master Index = seul index | CRITIQUE |
| EO-03 | Graphe canonique unique | Master Graph = seul graphe | CRITIQUE |
| EO-04 | Interfaces publiques stables | CORE API défini et gelé | HAUTE |
| EO-05 | Tous les piliers absorbés | ZERO, FOUNDATION, CONSTITUTION, GOVERNANCE fusionnés | HAUTE |
| EO-06 | Théorie prête pour démarrage | Knowledge Kernel lisible par Theory Engine | HAUTE |
| EO-07 | Gouvernance exécutable | Governance Kernel opérationnel | HAUTE |

---

## 4. Responsabilités du Kernel

### 4.1 Responsabilités Directes

| Domaine | Responsable | Décideur |
|---------|-------------|----------|
| Définition de la vision | Executive | Executive |
| Maintien du CORE | Architect | Executive |
| Évolution du CORE | Architect | Executive |
| Validation des entrées CORE | Auditor | Executive |
| Implémentation CORE | Builder | Architect |

### 4.2 Responsabilités Envers les Composants Futurs

| Composant | Ce que le Kernel Fournit |
|-----------|-------------------------|
| Theory Engine | Vision, objectifs, règles de connaissance |
| Sherpa | Mission, contexte, objectifs courants |
| Cortex | Mémoire persistante, état du système |
| Plugin SDK | Contrats, points d'extension |
| Executive OS | Vision, mission, gouvernance, orchestration |
| Runtime | État, services, pipelines |
| Produits | Relations CORE → Produits |

---

## 5. Architecture du CORE

### 5.1 Couches Architecturales (L0-L6)

```
L6: PRESENTATION
    ┌─────────────────────────────────────────────┐
    │ Views, Dashboards, Control Centers, UI      │
    └─────────────────────────────────────────────┘

L5: EXECUTIVE KERNEL + PRODUCTS
    ┌─────────────────────────────────────────────┐
    │ Orchestration, Governance, Business,        │
    │ Monetization, Decision Authority            │
    └─────────────────────────────────────────────┘

L4: RUNTIME + WORKSPACE
    ┌─────────────────────────────────────────────┐
    │ Execution, Missions, Workflows,             │
    │ Twins, Resources, Index, Discovery          │
    └─────────────────────────────────────────────┘

L3: SHERPA + CORTEX
    ┌─────────────────────────────────────────────┐
    │ Context Selection, Memory, Decisions,       │
    │ Evidence, Learning, Experience              │
    └─────────────────────────────────────────────┘

L2: THEORY + KNOWLEDGE
    ┌─────────────────────────────────────────────┐
    │ Ontology, Concepts, Principles,             │
    │ Theory Graph, Knowledge                     │
    └─────────────────────────────────────────────┘

L1: PROVIDERS + PLUGINS
    ┌─────────────────────────────────────────────┐
    │ AI Engines, Model Access, Extensions,       │
    │ Contracts, Registry                         │
    └─────────────────────────────────────────────┘

L0: INDUSTRIAL BASE
    ┌─────────────────────────────────────────────┐
    │ Standards, Conventions, Registries,         │
    │ Schemas, Templates, SDK                     │
    └─────────────────────────────────────────────┘
```

### 5.2 Statut des Couches

| Couche | Complétion | Statut |
|--------|-----------|--------|
| L6 Presentation | 40% | PARTIEL |
| L5 Executive + Products | 80% | ACTIF |
| L4 Runtime + Workspace | 85% | ACTIF |
| L3 Sherpa + Cortex | 0% | NON DÉMARRÉ |
| L2 Theory + Knowledge | 0% | NON DÉMARRÉ |
| L1 Providers + Plugins | 75% | ACTIF |
| L0 Industrial Base | 100% | CANONIQUE |

---

## 6. Chaîne d'Autorité

```
EXECUTIVE (Décideur Suprême)
    │
    ▼
SUPRA-Architect (Architecture, Standards)
    │
    ▼
SUPRA-Router (Routage, Priorisation)
    │
    ├──▶ SUPRA-Builder (Implémentation — SEUL ÉCRIVAIN)
    ├──▶ SUPRA-Auditor (Conformité, Audit)
    ├──▶ SUPRA-Research (Recherche)
    ├──▶ SUPRA-Explorer (Navigation)
    ├──▶ SUPRA-Runtime (Runtime)
    ├──▶ SUPRA-Reviewer (Relecture)
    └──▶ SUPRA-Refactor (Refactoring)
```

---

## 7. Principes du CORE

| ID | Principe | Description |
|----|----------|-------------|
| CP-01 | Unité | Une seule architecture, un seul index, un seul graphe |
| CP-02 | Réversibilité | Toute évolution est réversible |
| CP-03 | Traçabilité | Toute décision a une cause, un auteur, une date, une preuve |
| CP-04 | Non-Contradiction | Aucun document ne peut contredire le CORE |
| CP-05 | Propriété Unique | Toute capacité a un propriétaire unique |
| CP-06 | Source de Vérité Unique | Un seul document par domaine |
| CP-07 | Cycle de Vie Obligatoire | 6 étapes, aucune sautée |
| CP-08 | Single Writer | Builder seul autorisé à écrire |
| CP-09 | Point d'Entrée Unique | Tout composant passe par CORE |
| CP-10 | Zéro Dépendance Directe | Aucun accès direct aux documents historiques |

---

## 8. Interfaces Publiques

### 8.1 Interfaces de Lecture

```
Kernel Interfaces (tous les composants futurs lisent via ces interfaces) :

Executive Kernel  → Vision, Mission, Objectifs, Principes
Mission Kernel    → Missions actives, états, historique
Governance Kernel → Règles, gates, compliance, ADR
Knowledge Kernel  → Registres, manifests, knowledge maps
Runtime Kernel    → État du runtime, services, pipelines
Product Kernel    → Produits, applications, relations
Provider Kernel   → Providers disponibles, contrats, statuts
```

### 8.2 Interfaces d'Écriture

```
CORE API (tous les composants futurs écrivent via cette API) :

POST   /mission         → Créer une mission
PATCH  /mission/{id}    → Mettre à jour une mission
POST   /mission/{id}/gate → Valider un gate
POST   /adr             → Proposer une ADR
PATCH  /adr/{id}        → Mettre à jour une ADR
POST   /evidence        → Enregistrer une preuve
PATCH  /runtime/status  → Mettre à jour le statut runtime
```

---

## 9. Règle Fondamentale

**À partir de SUPRA CORE V1, aucun composant futur ne lit directement les documents historiques.**

Theory Engine, Sherpa, Cortex, Plugin SDK, Executive OS, tout nouveau produit ou service doit passer exclusivement par :
1. **SUPRA_MASTER_INDEX.md** — pour naviguer
2. **SUPRA_MASTER_GRAPH.md** — pour comprendre les relations
3. **Les 7 Kernels** — pour la logique métier
4. **SUPRA_CORE_API.md** — pour les interfaces

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA ULTIMATE CORE V1. Premier kernel du socle opérationnel unique.*
