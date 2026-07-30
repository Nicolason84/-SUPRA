# SUPRA RUNTIME BLUEPRINT V1

## Plan d'Architecture Runtime de SUPRA Ultimate Consolidated

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CORE — Blueprint runtime permanent |
| **Version** | SUPRA_RUNTIME_BLUEPRINT_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Architecture runtime explicite, testable, remplaçable |

---

## 1. Architecture Runtime Globale

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      SUPRA ULTIMATE CONSOLIDATED                         │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                     EXECUTIVE OS (L5)                            │   │
│  │  Orchestration · Governance · Décision · Produits               │   │
│  └────────────────────────────┬────────────────────────────────────┘   │
│                               │                                         │
│  ┌────────────────────────────┼────────────────────────────────────┐   │
│  │                            ▼                                    │   │
│  │               ┌─────────────────────────┐                       │   │
│  │               │   CORE API (CROSS)       │                      │   │
│  │               │   Point d'entrée unique  │                      │   │
│  │               └────────────┬────────────┘                       │   │
│  │                            │                                    │   │
│  │  ┌─────────────────────────┼────────────────────────────┐      │   │
│  │  │                         ▼                            │      │   │
│  │  │              ┌─────────────────────┐                  │      │   │
│  │  │              │  COMPOSITION ROOT   │                  │      │   │
│  │  │              │  L5.COMPOSITION     │                  │      │   │
│  │  │              └─────────────────────┘                  │      │   │
│  │  │                         │                            │      │   │
│  │  │     ┌───────────────────┼───────────────────┐        │      │   │
│  │  │     ▼                   ▼                   ▼        │      │   │
│  │  │ ┌─────────┐     ┌─────────────┐     ┌───────────┐   │      │   │
│  │  │ │KERNELS  │     │  RUNTIME    │     │ PRODUITS  │   │      │   │
│  │  │ │(L5)     │     │  (L4)       │     │ (L5-L6)   │   │      │   │
│  │  │ └─────────┘     └─────────────┘     └───────────┘   │      │   │
│  │  └──────────────────────────────────────────────────────┘      │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                     EXECUTIVE RUNTIME (L4)                       │   │
│  │                                                                  │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │   │
│  │  │  AGENT       │  │  PROVIDER    │  │  PIPELINE            │  │   │
│  │  │  POOL        │  │  POOL        │  │  EXECUTOR            │  │   │
│  │  │              │  │              │  │                      │  │   │
│  │  │  Builder     │  │  Ollama      │  │  Plan → Route →      │  │   │
│  │  │  Auditor     │  │  OpenAI      │  │  Execute → Validate  │  │   │
│  │  │  Research    │  │  Anthropic   │  │  → Fuse → Learn      │  │   │
│  │  │  Explorer    │  │              │  │                      │  │   │
│  │  │  Runtime     │  │              │  │  Mission Queue       │  │   │
│  │  │  Reviewer    │  │              │  │                      │  │   │
│  │  │  Refactor    │  │              │  │  States:             │  │   │
│  │  └──────────────┘  └──────────────┘  │  QUEUED, RUNNING,    │  │   │
│  │                                       │  COMPLETED, FAILED,  │  │   │
│  │  ┌──────────────┐  ┌──────────────┐  │  BLOCKED             │  │   │
│  │  │  TWIN        │  │  CONTROL     │  └──────────────────────┘  │   │
│  │  │  UNIVERSE    │  │  TOWER       │                           │   │
│  │  │              │  │              │  ┌──────────────────────┐  │   │
│  │  │  TwinRegist.│  │  Dashboard   │  │  EVIDENCE            │  │   │
│  │  │  TwinSync   │  │  Alerts      │  │  SYSTEM              │  │   │
│  │  │  TwinFactory│  │  Metrics     │  │                      │  │   │
│  │  │  Lifecycle  │  │  Snapshots   │  │  runtime_trace.json  │  │   │
│  │  └──────────────┘  └──────────────┘  │  delegation_trace    │  │   │
│  │                                       │  runtime_metrics     │  │   │
│  │  ┌──────────────────────────────┐   │  agent_execution      │  │   │
│  │  │      EVENT BUS               │   │  consensus_report     │  │   │
│  │  │  pub/sub · async · tracé     │   │  execution_graph      │  │   │
│  │  └──────────────────────────────┘   └──────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                     EXECUTIVE COCKPIT (L6)                       │   │
│  │                                                                  │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │   │
│  │  │  DASHBOARD   │  │  MISSION     │  │  RUNTIME VIEW       │  │   │
│  │  │              │  │  CENTER      │  │                      │  │   │
│  │  │  System      │  │  Active      │  │  Pipeline Steps     │  │   │
│  │  │  Status      │  │  Missions    │  │  Worker Pool        │  │   │
│  │  │  Providers   │  │  Delegations │  │  Providers          │  │   │
│  │  │  Agents      │  │  Priorities  │  │  Metrics            │  │   │
│  │  └──────────────┘  └──────────────┘  └──────────────────────┘  │   │
│  │                                                                  │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │   │
│  │  │  MISSION     │  │  EVIDENCE    │  │  SETTINGS            │  │   │
│  │  │  GRAPH       │  │  EXPLORER    │  │                      │  │   │
│  │  │  DAG View    │  │  File Viewer │  │  Runtime Path       │  │   │
│  │  │  Nodes/Edges │  │  Copy        │  │  Refresh Interval   │  │   │
│  │  │  Status      │  │  Filter      │  │  Version Info       │  │   │
│  │  └──────────────┘  └──────────────┘  └──────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 2. États du Runtime

| État | Description | Composant Pilote |
|------|-------------|------------------|
| BOOTING | Démarrage du système | L5.COMPOSITION_ROOT |
| IDLE | En attente de mission | L4.EXECUTIVE_RUNTIME |
| PLANNING | Mission en cours de planification | L4.PLANNER |
| ROUTING | Mission en cours de routage | L4.ROUTER |
| EXECUTING | Mission en cours d'exécution | L4.WORKFLOW_ENGINE |
| VALIDATING | Résultat en cours de validation | L4.VALIDATOR |
| LEARNING | Apprentissage en cours | L3.LEARNING_ENGINE |
| STORING | Stockage en mémoire | L3.CORTEX |
| ERROR | Erreur runtime | L4.EXECUTIVE_RUNTIME |
| SHUTDOWN | Arrêt du système | L5.COMPOSITION_ROOT |

### Machine à États du Runtime

```
        ┌─────────────────────────────────────────────────────┐
        │                                                     │
        ▼                                                     │
   ┌────────┐    ┌───────────┐    ┌────────┐    ┌──────────┐ │
   │ BOOTING│───▶│   IDLE    │───▶│PLANNING│───▶│ ROUTING  │ │
   └────────┘    └───────────┘    └────────┘    └──────────┘ │
                     ▲                           │            │
                     │                           ▼            │
                     │                      ┌──────────┐      │
                     │                      │EXECUTING │      │
                     │                      └────┬─────┘      │
                     │                           │            │
                     │                    ┌──────┼──────┐     │
                     │                    ▼      ▼      ▼     │
                     │              ┌──────────┐ ┌──────────┐ │
                     │              │VALIDATING│ │ LEARNING │ │
                     │              └────┬─────┘ └────┬─────┘ │
                     │                   │            │        │
                     │                   ▼            ▼        │
                     │              ┌──────────┐ ┌──────────┐ │
                     │              │  STORING │ │  ERROR   │ │
                     │              └────┬─────┘ └────┬─────┘ │
                     │                   │            │        │
                     └───────────────────┴────────────┘        │
                                                               │
   ┌──────────┐                                                │
   │ SHUTDOWN │◀───────────────────────────────────────────────┘
   └──────────┘
```

---

## 3. Flux de Données Runtime

### 3.1 Flux d'Exécution de Mission

```
1. CRÉATION:  Utilisateur → Mission Kernel → Mission Queue
2. PLAN:      Planner reçoit la mission → produit DAG
3. ROUTE:     Router → AgentRegistry + ModelRegistry → Plan
4. EXECUTE:   WorkflowEngine exécute le DAG via agents
5. COMPARE:   (optionnel) Comparator analyse les sorties multiples
6. FUSE:      FusionEngine produit un résultat unique
7. VALIDATE:  Validator vérifie les critères d'acceptation
8. LEARN:     LearningEngine met à jour les modèles
9. STORE:     Memory stocke le contexte
10. REPORT:   Résultat → Dashboard / Evidence
```

### 3.2 Flux de Données Read-Only (Cockpit)

```
Runtime JSON Files ──▶ RuntimeDataService ──▶ SwiftUI Views
  (read)                  (ObservableObject)      (read-only display)
                              │
                          @Published
                              │
                    ┌─────────┼─────────┐
                    ▼         ▼         ▼
              Dashboard   Mission    Runtime
              View        Center     View
                          View
```

### 3.3 Flux d'Événements

```
Component A ──▶ EventBus ──▶ Component B
    │                          (async subscriber)
    │
    ├─▶ Metrics Engine (record)
    ├─▶ Control Tower (monitor)
    └─▶ Evidence System (trace)
```

---

## 4. Contrats de Données Runtime

### 4.1 Runtime Trace

```json
{
  "timestamp": "ISO8601",
  "state": "RUNNING | IDLE | ERROR",
  "current_mission": "mission_id",
  "pipeline": {
    "steps": [
      {"id": "step_1", "status": "COMPLETED", "duration_ms": 1200},
      {"id": "step_2", "status": "RUNNING", "duration_ms": 450}
    ],
    "started_at": "ISO8601",
    "estimated_completion": "ISO8601"
  },
  "metrics": {
    "cpu_usage": 0.45,
    "memory_mb": 256,
    "active_agents": 2
  }
}
```

### 4.2 Delegation Trace

```json
{
  "delegations": [
    {
      "mission_id": "uuid",
      "agent": "SUPRA-Builder",
      "model": "anthropic/claude-sonnet-4-6",
      "task": "Implémenter X",
      "status": "RUNNING",
      "started_at": "ISO8601",
      "duration_ms": 5000
    }
  ]
}
```

### 4.3 Runtime Metrics

```json
{
  "global_quality": 0.92,
  "success_rate": 0.88,
  "pipeline_duration_ms": 45000,
  "active_providers": 2,
  "active_agents": 3,
  "last_validation": {"status": "PASS", "score": 95}
}
```

---

## 5. Cycle de Vie des Composants Runtime

```
                   ┌──────────────────────┐
                   │     IDEA (Conception) │
                   └──────────┬───────────┘
                              │ Gate G1
                              ▼
                   ┌──────────────────────┐
                   │   FOUNDATION (Spec)  │
                   └──────────┬───────────┘
                              │ Gate G2
                              ▼
                   ┌──────────────────────┐
                   │  CONSTITUTION (ADR)  │
                   └──────────┬───────────┘
                              │ Gate G3
                              ▼
                   ┌──────────────────────┐
                   │   GOVERNANCE (Impl)  │
                   └──────────┬───────────┘
                              │ Gate G4
                              ▼
                   ┌──────────────────────┐
                   │    ULTIMATE (Valid)  │
                   └──────────┬───────────┘
                              │ Gate G5
                              ▼
                   ┌──────────────────────┐
                   │   PRODUCTION (Live)  │
                   └──────────────────────┘
```

---

## 6. Invariants du Runtime

| ID | Invariant | Description |
|----|-----------|-------------|
| RI-01 | Unicité Pipeline | Un seul pipeline d'exécution actif à la fois |
| RI-02 | Atomicité Mission | Une mission est soit complète, soit annulée — pas d'état intermédiaire non tracé |
| RI-03 | Read-Only Cockpit | L'interface utilisateur ne modifie jamais l'état du Runtime |
| RI-04 | Traçabilité | Toute action runtime est tracée avec timestamp + auteur |
| RI-05 | Non-Perturbation | Les agents read-only ne modifient jamais l'état du système |
| RI-06 | Append-Only Logs | Les traces runtime sont append-only, jamais modifiées a posteriori |
| RI-07 | Dépendances Descendantes | Les couches supérieures dépendent des couches inférieures (pas l'inverse) |

---

## 7. Validation du Runtime

| Critère | Méthode | Fréquence |
|---------|---------|-----------|
| État cohérent | Vérification des fichiers JSON | Continue |
| Pipeline non-bloqué | Health check des steps | Toutes les 30s |
| Agents disponibles | Ping agents | Toutes les 60s |
| Providers disponibles | Health check providers | Toutes les 5min |
| Pas de fuite mémoire | Monitoring mémoire | Continue |
| Traçabilité complète | Audit des traces | Par mission |
| Read-Only Cockpit | Vérification des permissions | Par session |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA ULTIMATE CONSOLIDATED PHASE 2. Blueprint runtime permanent.*
