# CANNO SYSTEM GRAPH — V1

## Mission : NUCLEO_VALIDATION_CANNO_002

## Graphe relationnel CAnnoNico du système SUPRA

---

### Niveau 0 : ENTRY POINTS

```
SUPRAOperationalCoreApp (@main)
  │ CREATES
  ├──→ SUPRANucleoOrchestrator [SYSTEM]
  ├──→ SUPRACommandCenterState [SERVICE]
  ├──→ SUPRAResourceGovernor [RESOURCE]
  ├──→ CAnnoNicoSnapshotStore [MEMORY]
  ├──→ RuntimeMonitor [SERVICE]
  ├──→ RuntimeDataService [SERVICE]
  ├──→ SUPRABackgroundScheduler [SERVICE]
  ├──→ SUPRAIntelligenceEngine [ENGINE]
  ├──→ SUPRAEvolutionEngine [ENGINE]
  ├──→ SUPRAEnvironmentWorldModel [MODULE]
  ├──→ SUPRARecommendationEngine [ENGINE]
  ├──→ SUPRAPassiveRefreshCoordinator [SERVICE]
  └──→ ConversationMemoryStore [MEMORY]
```

### Niveau 1 : ORCHESTRATEUR NUCLEO

```
SUPRANucleoOrchestrator
  │ ROUTES_TO (9 executors)
  ├──→ [RESOURCE]   SUPRAResourceGovernor
  ├──→ [SERVICE]    RuntimeGateway ───→ OpenCodeBridge [BRIDGE]
  ├──→ [SERVICE]    RuntimeMonitor
  ├──→ [SERVICE]    RuntimeDataService
  ├──→ [SERVICE]    SUPRAScheduler ───→ SUPRAResourceGovernor [RESOURCE]
  │                                    └──→ CAnnoNicoSnapshotStore [MEMORY]
  ├──→ [DECISION]   SUPRADecisionEngine ───→ SUPRADecisionAuthority [DECISION]
  ├──→ [MISSION]    SUPRAMissionExecutor
  ├──→ [MISSION]    MissionStore
  ├──→ [MISSION]    MissionContext
  ├──→ [KERNEL]     NOVAKnowledgeKernel ───→ RuntimeGateway [SERVICE]
  ├──→ [SERVICE]    OpenCodeClient
  ├──→ [SERVICE]    SUPRACanonicalWorldAccess
  ├──→ [ENGINE]     SUPRAResourceIntelligenceEngine
  ├──→ [ENGINE]     SUPRAIntelligenceEngine ───→ SUPRAIntelligenceState [SERVICE]
  └──→ [MISSION]    SUPRAMissionObserver
```

### Niveau 2 : AGRÉGATEURS

```
SUPRAWorldModel [MODULE]
  │ READS
  ├──→ SUPRACanonicalWorldAccess [SERVICE]
  ├──→ SUPRAIntelligenceEngine [ENGINE]
  ├──→ SUPRAMissionProposalEngine [MISSION]
  └──→ SUPRAMissionExecutor [MISSION]
  │ GENERATES
  └──→ SUPRAWorldSnapshot

SUPRAEnvironmentWorldModel [MODULE]
  │ READS
  ├──→ SUPRADataTwin [PLUGIN]
  ├──→ SUPRAHardwareTwin [PLUGIN]
  ├──→ SUPRASoftwareTwin [PLUGIN]
  ├──→ SUPRADeveloperTwin [PLUGIN]
  └──→ SUPRACanonicalWorldAccess [SERVICE]
  │ GENERATES
  └──→ CompleteEnvironmentState

SUPRABusinessPlatform [MODULE]
  │ READS
  ├──→ SUPRAWorldModel [MODULE]
  ├──→ SUPRAMissionProposalEngine [MISSION]
  ├──→ SUPRAMissionExecutor [MISSION]
  └──→ SUPRAResourceGovernor [RESOURCE]
  │ GENERATES
  └──→ CustomerTwin
```

### Niveau 3 : SERVICES SPÉCIALISÉS

```
SUPRAScheduler [SERVICE]
  │ OBSERVES (via Combine)
  ├──→ SUPRAResourceIntelligenceEngine [ENGINE]
  ├──→ SUPRAIntelligenceEngine [ENGINE]
  ├──→ SUPRAMissionProposalEngine [MISSION]
  └──→ SUPRAEvolutionEngine [ENGINE]

SUPRABackgroundScheduler [SERVICE]
  │ USES
  └──→ SUPRAResourceGovernor [RESOURCE] (budget CPU)

SUPRAWorkerFabric [WORKER]
  │ READS
  ├──→ CAnnoNicoSnapshotStore [MEMORY]
  ├──→ MultiMemoryStore [MEMORY]
  ├──→ SUPRAResourceGovernor [RESOURCE]
  ├──→ SUPRAMissionProposalEngine [MISSION]
  └──→ SUPRAMissionExecutor [MISSION]
```

### Niveau 4 : ISOLÉS / PLUGINS

```
ExecutiveMemory [KERNEL] ──READS──→ NOVAKnowledgeKernel [KERNEL]

ContextEngine [KERNEL] ──READS──→ WorkspaceIndex, WorkspaceGraph

SUPRAGabrielConductorRuntime [EXTERNAL] ──READS──→ Filesystem (JSON)

SUPRAMonetizationEngine [ENGINE] ──READS──→ SUPRAWorldModel [MODULE]

--- TOTALEMENT ISOLÉS ---
SUPRADataTwin [PLUGIN]         → Aucune dépendance
SUPRAHardwareTwin [PLUGIN]     → Aucune dépendance
SUPRASoftwareTwin [PLUGIN]     → Aucune dépendance
SUPRADeveloperTwin [PLUGIN]    → Aucune dépendance
```

### Niveau 5 : RUNTIME / DATA FLOW

```
SUPRACommandCenterState [SERVICE]
  │ OBSERVES (12+ sources Combine)
  ├──→ Health
  ├──→ Missions
  ├──→ Resources
  ├──→ CAnnoNico
  ├──→ Runtime
  ├──→ MultiMemory
  ├──→ Decision
  ├──→ Intelligence
  ├──→ Copilot
  └──→ Actions
  │ GENERATES
  └──→ CommandCenterSnapshot
```

---

## Dépendances circulaires — VALIDATION

| Cercle suspecté | Verdict | Explication |
|-----------------|---------|-------------|
| IntelligenceEngine ↔ ResourceIntelligence ↔ MissionProposal ↔ EvolutionEngine | **FAUX POSITIF** | Les 4 sont observés PAR SUPRAScheduler via Combine, pas de dépendance mutuelle directe. C'est un hub d'observation, pas un cycle. |
| RuntimeGateway ↔ OpenCodeBridge ↔ OpenCodeClient ↔ RuntimeMonitor | **FAUX POSITIF** | OpenCodeBridge délègue À RuntimeGateway (client→backend). Pas de cycle. RuntimeMonitor est indépendant. |
| MissionExecutor ↔ MissionObserver ↔ MissionProposalEngine | **FAUX POSITIF** | MissionProposalEngine lit MissionObserver (unidirectionnel). MissionExecutor est indépendant. Flux en pipeline, pas en cycle. |

**Aucune dépendance circulaire confirmée** dans le code source. Tous les flux sont unidirectionnels.

## Hubs de dépendances — VALIDATION

| Hub | Degré sortant | Degré entrant | Verdict |
|-----|---------------|---------------|---------|
| SUPRANucleoOrchestrator | 15 | 1 | CONFIRMÉ — hub de routage principal |
| SUPRAOperationalCoreApp | 14 | 0 | CONFIRMÉ — créateur de tous les services |
| SUPRABackgroundScheduler | 0 | 1 → EvolutionEngine | CONFIRMÉ — consommé par EvolutionEngine |
| SUPRAWorldModel | 4 | 2 (BusinessPlatform, Monetization) | CONFIRMÉ — agrégateur central |
| SUPRAEnvironmentWorldModel | 5 | 1 | CONFIRMÉ — agrégateur des twins |
| CAnnoNicoSnapshotStore | 0 | 3 (Scheduler, WorkerFabric, CoreApp) | CONFIRMÉ — cache partagé |

## Métriques du graphe

| Métrique | Valeur |
|----------|--------|
| Nœuds (composants) | 84 |
| Relations explicites | 60+ |
| Cycles confirmés | 0 |
| Hubs (>5 dépendances) | 5 |
| Composants isolés | 6 |
| Profondeur max | 4 niveaux |
