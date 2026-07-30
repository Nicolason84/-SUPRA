# SUPRA DEPENDENCY GRAPH V1

## Graphe Permanent des Dépendances entre Composants SUPRA Ultimate Consolidated

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CORE — Graphe de dépendances canonique |
| **Version** | SUPRA_DEPENDENCY_GRAPH_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Toute dépendance est explicite. Aucun couplage caché. |

---

## 1. Graphe Global (Simplifié)

```
                          ┌──────────────────────┐
                          │   SUPRA CORE API      │
                          │   (CROSS.CORE_API)    │
                          └──────────┬───────────┘
                                     │
           ┌─────────────────────────┼─────────────────────────┐
           │                         │                         │
           ▼                         ▼                         ▼
┌──────────────────────┐ ┌──────────────────────┐ ┌──────────────────────┐
│  L5.EXECUTIVE_KERNEL │ │ L5.GOVERNANCE_KERNEL │ │ L5.KNOWLEDGE_KERNEL  │
│  Vision, Mission     │ │ Constitution, Gates,  │ │ Registres, Manifests,│
│  Objectifs           │ │ Compliance, ADR       │ │ Knowledge Maps       │
└──────────┬───────────┘ └──────────┬───────────┘ └──────────┬───────────┘
           │                        │                        │
           ├────────────────────────┼────────────────────────┤
           │                        │                        │
           ▼                        ▼                        ▼
┌──────────────────────┐ ┌──────────────────────┐ ┌──────────────────────┐
│  L4.MISSION_KERNEL   │ │ L4.RUNTIME_KERNEL    │ │ L5.PRODUCT_KERNEL   │
│  Missions, Lifecycle │ │ Runtime, State,       │ │ CORE/Runtime/        │
│  Handover            │ │ Services, Pipelines   │ │ Products Relations  │
└──────────┬───────────┘ └──────────┬───────────┘ └──────────┬───────────┘
           │                        │                        │
           └────────────────────────┼────────────────────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │  L5.PROVIDER_KERNEL  │
                         │  Abstraction,        │
                         │  Contrats, Fallback  │
                         └──────────┬───────────┘
                                    │
         ┌──────────────────────────┼──────────────────────────┐
         │                          │                          │
         ▼                          ▼                          ▼
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│ L1.OLLAMA        │     │ L1.OPENAI        │     │ L1.ANTHROPIC     │
│ PROVIDER         │     │ PROVIDER         │     │ PROVIDER         │
└──────────────────┘     └──────────────────┘     └──────────────────┘
```

---

## 2. Graphe de Dépendances par Couche

### L0 ← L0 (Intra-couche)
```
L0.IMMUTABLE_PRINCIPLES  ──▶ L0.CONSTITUTION
L0.STANDARD_FRAMEWORK    ──▶ L0.REGISTRY_SYSTEM
L0.REGISTRY_SYSTEM       ──▶ L0.CANONICAL_ID
L0.EVOLUTION_LAW         ──▶ L0.GATE_SYSTEM
L0.CONSTITUTION          ──▶ L0.AUTHORITY_MODEL
L0.AUTHORITY_MODEL       ──▶ L0.PROTECTION_MODEL
```

### L1 ← L1 (Intra-couche)
```
L1.CAPABILITY_REGISTRY   ──▶ L1.AGENT_REGISTRY
L1.CAPABILITY_REGISTRY   ──▶ L1.MODEL_REGISTRY
L1.OLLAMA_PROVIDER       ──▶ L1.PROVIDER_FRAMEWORK
L1.OPENAI_PROVIDER       ──▶ L1.PROVIDER_FRAMEWORK
L1.ANTHROPIC_PROVIDER    ──▶ L1.PROVIDER_FRAMEWORK
L1.GOOGLE_PROVIDER       ──▶ L1.PROVIDER_FRAMEWORK
```

### L2 ← L2 (Intra-couche)
```
L2.INGESTION_*           ──▶ L2.KNOWLEDGE_COMPILER
L2.ONTOLOGY_ENGINE       ──▶ L2.UNIFIED_ONTOLOGY
L2.CONSTRAINT_ENGINE     ──▶ L2.CONSTRAINT_LIBRARY
L2.CONSISTENCY_ENGINE    ──▶ L2.CONSTRAINT_ENGINE
L2.EVIDENCE_ENGINE       ──▶ L2.KNOWLEDGE_COMPILER
L2.TRUST_ENGINE          ──▶ L2.EVIDENCE_ENGINE
L2.ROOT_CAUSE_ENGINE     ──▶ L2.CONSTRAINT_ENGINE
L2.REPAIR_ENGINE         ──▶ L2.ROOT_CAUSE_ENGINE
L2.PATTERN_ENGINE        ──▶ L2.PATTERN_LIBRARY
L2.PROJECTION_ENGINE     ──▶ L2.KNOWLEDGE_COMPILER
L2.EXECUTIVE_ENGINE      ──▶ Tous les engines L2
L2.MISSION_ENGINE_KC     ──▶ L2.KNOWLEDGE_COMPILER
L2.MEMORY_ENGINE_KC      ──▶ L2.KNOWLEDGE_COMPILER
L2.KNOWLEDGE_GRAPH       ──▶ L2.KNOWLEDGE_COMPILER
L2.CONSTRAINT_GRAPH      ──▶ L2.CONSTRAINT_ENGINE
L2.EVIDENCE_GRAPH        ──▶ L2.EVIDENCE_ENGINE
L2.CONSISTENCY_GRAPH     ──▶ L2.CONSISTENCY_ENGINE
L2.EXECUTIVE_GRAPH       ──▶ L2.EXECUTIVE_ENGINE
```

### L3 ← L3 (Intra-couche)
```
L3.DECISION_ENGINE       ──▶ L5.GOVERNANCE_KERNEL
L3.LEARNING_ENGINE       ──▶ L1.MODEL_REGISTRY
L3.LEARNING_ENGINE       ──▶ L1.PROMPT_REGISTRY
L3.SHERPA                ──▶ L5.KNOWLEDGE_KERNEL
L3.SHERPA                ──▶ L4.MISSION_KERNEL
L3.CORTEX                ──▶ L5.KNOWLEDGE_KERNEL
L3.CORTEX                ──▶ L4.RUNTIME_KERNEL
```

### L4 ← L4 (Intra-couche)
```
L4.WORKFLOW_ENGINE       ──▶ Tous les modules L4
L4.PLANNER               ──▶ L4.ROUTER
L4.PLANNER               ──▶ L3.CORTEX
L4.ROUTER                ──▶ L1.AGENT_REGISTRY
L4.ROUTER                ──▶ L1.MODEL_REGISTRY
L4.ROUTER                ──▶ L1.CAPABILITY_REGISTRY
L4.COMPARATOR            ──▶ L4.FUSION_ENGINE
L4.FUSION_ENGINE         ──▶ L4.COMPARATOR
L4.VALIDATOR             ──▶ L4.FUSION_ENGINE
L4.BENCHMARK             ──▶ L1.MODEL_REGISTRY
L4.METRICS_ENGINE        ──▶ Tous les modules
L4.TWIN_UNIVERSE         ──▶ L4.RUNTIME_KERNEL
L4.CONTROL_TOWER         ──▶ L4.METRICS_ENGINE
L4.CONTROL_TOWER         ──▶ L4.EVENT_BUS
```

### L5 ← L5 (Intra-couche)
```
L5.EXECUTIVE_KERNEL      ──▶ L5.CONSTITUTION
L5.GOVERNANCE_KERNEL     ──▶ L0.GATE_SYSTEM
L5.GOVERNANCE_KERNEL     ──▶ L0.ADR_STANDARD
L5.KNOWLEDGE_KERNEL      ──▶ L2.KNOWLEDGE_COMPILER
L5.PRODUCT_KERNEL        ──▶ Tous les kernels L5
L5.PROVIDER_KERNEL       ──▶ L1.PROVIDER_FRAMEWORK
L5.EXECUTIVE_OS          ──▶ Tous les kernels L5
L5.EXECUTIVE_OS          ──▶ L4.RUNTIME_KERNEL
L5.COMPOSITION_ROOT      ──▶ Tous les composants
```

### Cross-layer Dependencies
```
L1 ← L0:  Tous les composants L1  ←  L0.STANDARD_FRAMEWORK
L2 ← L5:  L2.KNOWLEDGE_COMPILER   ←  L5.EXECUTIVE_CANON
L2 ← L5:  L2.ONTOLOGY_ENGINE      ←  L5.KNOWLEDGE_KERNEL
L3 ← L5:  L3.SHERPA               ←  L5.KNOWLEDGE_KERNEL
L3 ← L5:  L3.CORTEX               ←  L5.KNOWLEDGE_KERNEL
L4 ← L5:  L4.MISSION_KERNEL       ←  L5.EXECUTIVE_KERNEL
L4 ← L5:  L4.RUNTIME_KERNEL       ←  L5.PROVIDER_KERNEL
L6 ← L4:  L6.*                    ←  L4.RUNTIME_KERNEL
L6 ← L5:  L6.*                    ←  L5.EXECUTIVE_KERNEL
```

---

## 3. Graphe des Flux d'Exécution (Pipeline)

```
Mission Utilisateur
    │
    ▼
┌──────────────┐
│  PLANNER     │ ← lit L3.CORTEX (contexte)
│  L4.PLANNER  │ ← lit L4.MISSION_KERNEL (missions actives)
└──────┬───────┘
       │ DAG
       ▼
┌──────────────┐
│  ROUTER      │ ← lit L1.AGENT_REGISTRY
│  L4.ROUTER   │ ← lit L1.MODEL_REGISTRY
└──────┬───────┘ ← lit L1.CAPABILITY_REGISTRY
       │ Plan d'affectation
       ▼
┌──────────────────┐
│ WORKFLOW ENGINE  │
│ L4.WORKFLOW_ENG  │ ← exécute le DAG
└──────┬───────────┘
       │
       ├────► Agent 1 (ex: RESEARCH) ────► Résultat 1
       ├────► Agent 2 (ex: BUILDER)  ────► Résultat 2
       └────► Agent N                     ► Résultat N
                        │
                        ▼
               ┌────────────────┐
               │  COMPARATOR    │ (si mode consensus)
               │  L4.COMPARATOR │
               └───────┬────────┘
                       │ Matrice
                       ▼
               ┌────────────────┐
               │ FUSION ENGINE  │
               │ L4.FUSION_ENG  │
               └───────┬────────┘
                       │ Résultat fusionné
                       ▼
               ┌────────────────┐
               │  VALIDATOR     │
               │  L4.VALIDATOR  │
               └───────┬────────┘
                       │ PASS / FAIL
                       ▼
               ┌────────────────┐
               │   LEARNING     │ ← feedback loop
               │  L3.LEARNING   │
               └───────┬────────┘
                       │
                       ▼
               ┌────────────────┐
               │    MEMORY      │
               │  L3.CORTEX     │ ← stockage
               └────────────────┘
```

---

## 4. Graphe des Dépendances d'Exécution (Runtime)

```
┌─────────────────────────────────────────────────────────────┐
│                 SUPRA EXECUTIVE RUNTIME                      │
│                     L4.EXECUTIVE_RUNTIME                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │  Provider    │    │   Twin       │    │   Metrics    │  │
│  │  Pool        │◄──▶│   Universe   │◄──▶│   Engine     │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│         │                   │                   │            │
│         ▼                   ▼                   ▼            │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │  Pipeline    │    │   Event Bus  │    │ Control Tower│  │
│  │  Executor    │◄──▶│   L4.EVENT   │◄──▶│ L4.CONTROL   │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Mission Queue                            │   │
│  │  [Mission 1: RUNNING] [Mission 2: QUEUED] [M3: ...] │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│                    SUPRA COMPOSITION ROOT                    │
│                     L5.COMPOSITION_ROOT                     │
├─────────────────────────────────────────────────────────────┤
│  Dependency Injection · Service Location · State Management │
│  RuntimeDataService · MissionStore · DecisionStore          │
│  RuntimeMonitor · EventBus · ControlTowerState              │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Graphe des Dépendances Critique (Critical Path)

Les dépendances critiques sont celles dont la défaillance bloque le fonctionnement du système :

```
DÉPENDANCE CRITIQUE                  IMPACT EN CAS DE DÉFAILLANCE
───────────────────────────────      ──────────────────────────────
L5.CONSTITUTION                      Tout le système perd son cadre légal
CROSS.MASTER_INDEX                   Tous les composants perdent la navigation
CROSS.MASTER_GRAPH                   Tous les composants perdent les relations
L5.EXECUTIVE_KERNEL                  Plus de vision, plus de décision
L5.GOVERNANCE_KERNEL                 Plus de validation, plus de gates
L5.PROVIDER_KERNEL                   Plus d'accès aux modèles IA
L4.RUNTIME_KERNEL                    Plus d'exécution
L5.COMPOSITION_ROOT                  Plus d'application
L4.ROUTER                            Plus d'affectation des missions
L2.KNOWLEDGE_COMPILER               Plus d'intégration de connaissance
AGENT.BUILDER                        Plus d'écriture (seul écrivain)
AGENT.ARCHITECT                      Plus de validation architecturale
```

---

## 6. Dépendances non-Résolues

| # | Dépendance | De | Vers | Statut | Bloque |
|---|-----------|----|------|--------|--------|
| D-01 | Theory Engine → Knowledge Kernel | L3.SHERPA | L5.KNOWLEDGE_KERNEL | SPECIFIED | L3.SHERPA |
| D-02 | Sherpa → Theory Engine | L3.SHERPA | L2.KNOWLEDGE_COMPILER | NOT_STARTED | L3.SHERPA |
| D-03 | Cortex → Knowledge Kernel | L3.CORTEX | L5.KNOWLEDGE_KERNEL | PARTIAL | L3.CORTEX |
| D-04 | Plugin SDK → Provider Kernel | L1.PLUGIN_SDK | L5.PROVIDER_KERNEL | SPECIFIED | L1.PLUGIN_SDK |
| D-05 | Executive OS → All Kernels | L5.EXECUTIVE_OS | Tous les L5 | EXPERIMENTAL | L5.EXECUTIVE_OS |
| D-06 | Workflow Engine → All Modules | L4.WORKFLOW_ENGINE | Tous | SPECIFIED | Pipeline complet |
| D-07 | Workflow Engine → Router | L4.WORKFLOW_ENGINE | L4.ROUTER | SPECIFIED | Pipeline complet |
| D-08 | Workflow Engine → Comparator | L4.WORKFLOW_ENGINE | L4.COMPARATOR | SPECIFIED | Mode consensus |
| D-09 | Workflow Engine → Fusion Engine | L4.WORKFLOW_ENGINE | L4.FUSION_ENGINE | SPECIFIED | Mode consensus |
| D-10 | Workflow Engine → Validator | L4.WORKFLOW_ENGINE | L4.VALIDATOR | SPECIFIED | Pipeline complet |

---

## 7. Règles du Graphe de Dépendances

### G-01: Explicite
Toute dépendance entre composants doit être déclarée dans ce graphe.

### G-02: Pas de Cycle Non-Vertueux
Les cycles vertueux (feedback loop) sont autorisés. Tout autre cycle est interdit.

### G-03: Pas de Dépendance Absente
Tout composant qui en utilise un autre doit avoir cette dépendance déclarée.

### G-04: Principe de Direction
Les dépendances pointent des couches supérieures vers les couches inférieures (L6→L5→L4→L3→L2→L1→L0), sauf pour les graphes de navigation (CROSS).

### G-05: Versionnage
Toute modification d'une dépendance doit être versionnée avec ADR.

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA ULTIMATE CONSOLIDATED PHASE 2. Graphe permanent des dépendances.*
