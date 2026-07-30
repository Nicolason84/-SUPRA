# NUCLEO DEPENDENCY GRAPH — V1

## Mission : NUCLEO_DISCOVERY_001

### Légende
- `[E]` Entry Point
- `[K]` Kernel
- `[R]` Runtime
- `[M]` Mission
- `[S]` Scheduler
- `[D]` Decision
- `[Rs]` Resource
- `[I]` Intelligence
- `[B]` Broker
- `[Mem]` Memory
- `[L]` Lifecycle
- `[Inf]` Infrastructure
- `[Mon]` Monitoring
- `[T]` Twin
- `[W]` World Model

---

```
                    ┌──────────────────────────────────────┐
                    │           ENTRY POINTS [E]           │
                    │                                      │
                    │  SUPRAOperationalCoreApp (ACTIVE)    │
                    │  SUPRACommandCenterApp (LEGACY)      │
                    │  SUPRAApp (DEPRECATED)               │
                    └────────────┬─────────────────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────────────────┐
                    │     SUPRANucleoOrchestrator [L]      │
                    │  (orchestre tout le démarrage)       │
                    └──┬───┬───┬───┬───┬───┬───┬───┬───────┘
                       │   │   │   │   │   │   │   │
          ┌────────────┘   │   │   │   │   │   │   └────────────┐
          ▼                ▼   ▼   ▼   ▼   ▼   ▼                ▼
   ┌──────────┐    ┌──────────┐   ┌────────┐   ┌──────────────────┐
   │ [Rs]     │    │ [R]      │   │ [M]    │   │ [K]              │
   │Resource  │    │Runtime   │   │Mission │   │NOVAKnowledge     │
   │Governor  │    │Gateway   │   │Executor│   │Kernel            │
   └──────────┘    └────┬─────┘   └────────┘   └──────────────────┘
                        │
          ┌─────────────┼──────────────┬──────────────────┐
          ▼             ▼              ▼                  ▼
   ┌──────────┐  ┌──────────┐  ┌────────────┐  ┌────────────────┐
   │ [R]      │  │ [R]      │  │ [R]        │  │ [I]            │
   │Runtime   │  │Runtime   │  │OpenCode    │  │SUPRAIntelli-  │
   │Monitor   │  │DataService│  │Client     │  │genceEngine     │
   └──────────┘  └──────────┘  └────────────┘  └────────────────┘

```

## Dependencies hubs (plus de 10 dépendances)

| Hub | Nb dépendances sortantes | Dépend de |
|-----|--------------------------|-----------|
| **SUPRAOperationalCoreApp** [E] | 15 | SUPRANucleoOrchestrator, SUPRACommandCenterState, SUPRAResourceGovernor, CAnnoNicoSnapshotStore, SUPRAOSProductRootView, RuntimeMonitor, RuntimeDataService, SUPRABackgroundScheduler, SUPRAIntelligenceEngine, SUPRAEvolutionEngine, SUPRAMacPotential, SUPRAEnvironmentWorldModel, SUPRARecommendationEngine, SUPRAPassiveRefreshCoordinator, ConversationMemoryStore |
| **SUPRANucleoOrchestrator** [L] | 15 | SUPRAResourceGovernor, RuntimeGateway, RuntimeMonitor, RuntimeDataService, SUPRAScheduler, SUPRADecisionEngine, SUPRAMissionExecutor, MissionStore, MissionContext, NOVAKnowledgeKernel, OpenCodeClient, SUPRACanonicalWorldAccess, SUPRAResourceIntelligenceEngine, SUPRAIntelligenceEngine, SUPRAMissionObserver |
| **NOVAKnowledgeKernel** [K] | ~14 (registre) | RuntimeGateway via event bus |
| **SUPRACommandCenterState** | ~20 (hub central command) | Multiples (file >3000 lines) |
| **SUPRAResourceGovernor** [Rs] | ~18 | Multiples services système |
| **SUPRAMissionProposalEngine** [M] | ~18 | Decision, Resource, Intelligence, Scheduler, Runtime |

## Flux de dépendances

```
ENTRY POINTS → LIFECYCLE/ORCHESTRATOR
    → KERNEL → RUNTIME (Gateway, Monitor, DataService)
    → MISSION (Executor, ProposalEngine, Observer)
    → DECISION (DecisionEngine, CanonicalWorldAccess)
    → RESOURCE (Governor, IntelligenceEngine)
    → INTELLIGENCE (IntelligenceEngine, EvolutionEngine)
    → SCHEDULER (Scheduler, BackgroundScheduler)
    → MEMORY (MultiMemoryStore, CAnnoNicoSnapshotStore)
    → BROKERS (MegabusBridge)
    → INFRASTRUCTURE (SystemIntegrity)
    → MONITORING (PassiveRefreshCoordinator)
```

## Dépendances circulaires suspectées

| Cercle | Évidence |
|--------|----------|
| SUPRAIntelligenceEngine ↔ SUPRAResourceIntelligenceEngine ↔ SUPRAMissionProposalEngine ↔ SUPRAEvolutionEngine | Les 4 s'importent mutuellement via CommandCenterState |
| RuntimeGateway ↔ OpenCodeBridge ↔ OpenCodeClient ↔ RuntimeMonitor | Boucle d'event bus / bridge / monitoring |
| SUPRAMissionExecutor ↔ SUPRAMissionObserver ↔ SUPRAMissionProposalEngine | Missions, observation, propositions en triangulation |

## Composants isolés (0 dépendances externes)

| Composant | Fichier | Note |
|-----------|---------|------|
| ExecutiveMemory | SUPRA/ExecutiveMemory.swift | Mémoire exécutive sans aucune référence |
| ContextEngine | SUPRA/ContextEngine.swift | Moteur de contexte sans dépendance |
| RuntimeConnectionState | SUPRA/RuntimeConnectionState.swift | Simple enum |
| SUPRADecisionAuthority | SUPRA/SUPRADecisionAuthority.swift | Enum autorité |
| SUPRADataTwin | SUPRA/SUPRADataTwin.swift | Twin non référencé ailleurs |
| SUPRAHardwareTwin | SUPRA/SUPRAHardwareTwin.swift | Twin non référencé ailleurs |
| SUPRASoftwareTwin | SUPRA/SUPRASoftwareTwin.swift | Twin non référencé ailleurs |
| SUPRADeveloperTwin | SUPRA/SUPRADeveloperTwin.swift | Twin non référencé ailleurs |
| SUPRABusinessPlatform | SUPRA/SUPRABusinessPlatform.swift | Platforme métier isolée |
| SUPRAMonetizationEngine | SUPRA/SUPRAMonetizationEngine.swift | Moteur monétisation isolé |
| SUPRAWorkerFabric | SUPRA/SUPRAWorkerFabric.swift | Fabrique workers isolée |
| SUPRAGabrielConductorRuntime | SUPRA/SUPRAGabrielConductorRuntime.swift | Runtime Gabriel isolé |
