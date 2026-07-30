# SUPRA MASTER GRAPH V1

## Graphe Officiel des Relations, Dépendances, Autorités et Flux

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CORE — Graphe canonique unique |
| **Version** | SUPRA_MASTER_GRAPH_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Un seul graphe pour tout le système |

---

## 1. Graphe des Composants CORE

```
                            ┌──────────────────────┐
                            │   SUPRA CORE API      │
                            │  (Interface Publique) │
                            └──────────┬───────────┘
                                       │
              ┌────────────────────────┼────────────────────────┐
              │                        │                        │
              ▼                        ▼                        ▼
    ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
    │ EXECUTIVE KERNEL │    │ MISSION KERNEL   │    │ GOVERNANCE       │
    │ Vision, Mission  │    │ Lifecycle, States│◄───│ KERNEL           │
    │ Objectives, APIs │    │ Handover, Proof  │    │ Const, Gates,    │
    └──────────────────┘    └──────────────────┘    │ Compliance, ADR  │
              │                        │            └──────────────────┘
              │                        │                        │
              ├────────────────────────┼────────────────────────┤
              │                        │                        │
              ▼                        ▼                        ▼
    ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
    │ KNOWLEDGE KERNEL │    │ RUNTIME KERNEL   │    │ PRODUCT KERNEL   │
    │ ZERO, FOUNDATION │    │ Runtime, Services│    │ CORE, Runtime,   │
    │ Registry, Maps   │    │ Orchestrateur    │    │ Products, Apps   │
    └──────────────────┘    └──────────────────┘    └──────────────────┘
              │                        │                        │
              └────────────────────────┼────────────────────────┘
                                       │
                                       ▼
                            ┌──────────────────────┐
                            │   PROVIDER KERNEL    │
                            │   Abstraction,       │
                            │   Contrats, Fallback │
                            └──────────────────────┘
```

---

## 2. Graphe des Dépendances entre Composants Futurs

```
Theory Engine ──┬──▶ Knowledge Kernel (lecture seule)
                ├──▶ Executive Kernel (vision, objectifs)
                └──▶ Governance Kernel (règles)

Sherpa ──┬──▶ Knowledge Kernel (contexte)
         ├──▶ Mission Kernel (missions actives)
         └──▶ Executive Kernel (objectifs)

Cortex ──┬──▶ Knowledge Kernel (mémoire)
         ├──▶ Mission Kernel (historique)
         └──▶ Runtime Kernel (état)

Plugin SDK ──┬──▶ Provider Kernel (contrats)
             ├──▶ Runtime Kernel (services)
             └──▶ Governance Kernel (gates, validation)

Executive OS ──┬──▶ Executive Kernel (vision, mission)
               ├──▶ Mission Kernel (exécution)
               ├──▶ Governance Kernel (gouvernance)
               ├──▶ Runtime Kernel (runtime)
               └──▶ Product Kernel (produits)
```

---

## 3. Graphe des Flux d'Autorité

```
                    ┌──────────────────────┐
                    │     EXECUTIVE        │
                    │  (Décideur Suprême)  │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │  SUPRA-Architect     │
                    │  (Architecture)      │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │  SUPRA-Router        │
                    │  (Routage)           │
                    └──────────┬───────────┘
                               │
         ┌─────────────────────┼─────────────────────┐
         │                     │                     │
         ▼                     ▼                     ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ SUPRA-Builder    │  │ SUPRA-Auditor    │  │ SUPRA-Research   │
│ (SEUL ÉCRIVAIN)  │  │ (Conformité)     │  │ (Recherche)      │
└──────────────────┘  └──────────────────┘  └──────────────────┘
         │                     │                     │
         ▼                     ▼                     ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ SUPRA-Explorer   │  │ SUPRA-Runtime    │  │ SUPRA-Reviewer   │
│ (Navigation)     │  │ (Diagnostic)     │  │ (Relecture)      │
└──────────────────┘  └──────────────────┘  └──────────────────┘
         │
         ▼
┌──────────────────┐
│ SUPRA-Refactor   │
│ (Refactoring)    │
└──────────────────┘
```

---

## 4. Graphe des Dépendances Critiques

### 4.1 Dépendances de Flux de Données

```
                    ┌──────────────────┐
                    │   MASTER INDEX   │◄──────────── Tout composant
                    │                  │              (lecture obligatoire)
                    └──────────────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │   MASTER GRAPH   │◄──────────── Tout composant
                    │                  │              (navigation)
                    └──────────────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │ KNOWLEDGE    │ │ GOVERNANCE   │ │ RUNTIME      │
    │ KERNEL       │ │ KERNEL       │ │ KERNEL       │
    │ (Données)    │ │ (Règles)     │ │ (Services)   │
    └──────────────┘ └──────────────┘ └──────────────┘
```

### 4.2 Dépendances de Cycle de Vie

```
IDEA ──[G1]──▶ FOUNDATION ──[G2]──▶ CONSTITUTION ──[G3]──▶ GOVERNANCE ──[G4]──▶ ULTIMATE ──[G5]──▶ PRODUCTION
  │              │                     │                    │              │                  │
  ▼              ▼                     ▼                    ▼              ▼                  ▼
Note        Dossier               ADR +              Implémentation    Intégration       Release
d'intention  Foundation           Architecture        + Tests          finale             officialisée
```

---

## 5. Graphe des Interfaces Publiques

```
┌─────────────────────────────────────────────────────────────────────┐
│                       SUPRA CORE API                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  GET    /core/v1/kernel/executive    → Executive Kernel             │
│  GET    /core/v1/kernel/mission      → Mission Kernel               │
│  GET    /core/v1/kernel/governance   → Governance Kernel            │
│  GET    /core/v1/kernel/knowledge    → Knowledge Kernel             │
│  GET    /core/v1/kernel/runtime      → Runtime Kernel               │
│  GET    /core/v1/kernel/product      → Product Kernel               │
│  GET    /core/v1/kernel/provider     → Provider Kernel              │
│                                                                      │
│  GET    /core/v1/index               → Master Index                 │
│  GET    /core/v1/graph               → Master Graph                 │
│                                                                      │
│  POST   /core/v1/mission             → Create Mission               │
│  GET    /core/v1/mission/{id}        → Get Mission Status           │
│  POST   /core/v1/mission/{id}/gate   → Validate Gate                │
│                                                                      │
│  GET    /core/v1/compliance/check    → Compliance Check             │
│  GET    /core/v1/adr/{id}            → Get ADR                      │
│  POST   /core/v1/adr                 → Propose ADR                  │
│                                                                      │
│  GET    /core/v1/runtime/status      → Runtime Status               │
│  GET    /core/v1/provider/status     → Provider Status              │
│  GET    /core/v1/product/list        → Product List                 │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 6. Graphe des Composants et Produits

```
                    ┌──────────────────────────────────────┐
                    │          SUPRA CORE                   │
                    │  (Point d'entrée unique)              │
                    └──────────────────────────────────────┘
                                      │
          ┌───────────────────────────┼───────────────────────────┐
          │                           │                           │
          ▼                           ▼                           ▼
┌─────────────────────┐   ┌─────────────────────┐   ┌─────────────────────┐
│   THEORY ENGINE     │   │      SHERPA         │   │      CORTEX         │
│   (Knowledge Layer)  │   │   (Context Layer)   │   │   (Memory Layer)    │
│   L2                 │   │   L3                │   │   L3                │
└─────────────────────┘   └─────────────────────┘   └─────────────────────┘
          │                           │                           │
          └───────────────────────────┼───────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────┐
│                         EXECUTIVE OS                                  │
│                (Orchestration, Governance, Décision)                  │
│                               L5                                      │
└──────────────────────────────────────────────────────────────────────┘
                                      │
          ┌───────────────────────────┼───────────────────────────┐
          │                           │                           │
          ▼                           ▼                           ▼
┌─────────────────────┐   ┌─────────────────────┐   ┌─────────────────────┐
│     PLUGIN SDK      │   │      RUNTIME        │   │      PRODUITS       │
│   (Extension Layer)  │   │   (Execution Layer)  │   │   (Product Layer)   │
│   L1                 │   │   L4                │   │   L5-L6             │
└─────────────────────┘   └─────────────────────┘   └─────────────────────┘
```

---

## 7. Graphe des Cycles Identifiés

### 7.1 Cycle Vertueux

```
Mission → Planification → Routage → Exécution → Validation → Evidence → Apprentissage
    │                                                                            │
    └────────────────────────────────────────────────────────────────────────────┘
                                 Feedback Loop
```

### 7.2 Cycle de Gouvernance

```
Proposition → Évaluation → Décision → Exécution → Validation → Clôture
    │                                                                 │
    └─────────────────────────────────────────────────────────────────┘
                             Audit Loop
```

### 7.3 Cycle d'Évolution

```
Besoin → ADR → Validation → Implémentation → Test → Intégration → Documentation
    │                                                                        │
    └────────────────────────────────────────────────────────────────────────┘
                              Amélioration Continue
```

---

## 8. Dépendances non-Résolues (Points d'Attention)

| Dépendance | De | Vers | Risque |
|------------|----|------|--------|
| Theory Engine | Knowledge Kernel | Non implémenté | Theory Engine bloqué |
| Sherpa | Theory Engine | 0% | Sherpa bloqué |
| Cortex | Knowledge Kernel | Partiel (20%) | Cortex partiel |
| Plugin SDK | Provider Kernel | Spécifié seulement | Plugins non implémentés |
| Executive OS | Tous les Kernels | Dépend de l'implémentation | Doit lire via CORE API |

---

## 9. Règles du Graphe

### G-01 : Unicité
Il existe un seul graphe officiel. Tout composant futur navigue via ce graphe.

### G-02 : Non-Contradiction
Aucune relation dans ce graphe ne peut contredire la structure définie dans les Kernels.

### G-03 : Mise à Jour
Toute modification d'un composant CORE doit être répercutée dans ce graphe.

### G-04 : Détection de Cycles
Les cycles identifiés (sections 7.1-7.3) sont des cycles vertueux autorisés. Tout autre cycle doit être signalé comme anomalie.

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA ULTIMATE CORE V1. Graphe canonique unique du système SUPRA.*
