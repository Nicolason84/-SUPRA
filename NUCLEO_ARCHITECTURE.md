# SUPRA NUCLEO — Architecture V1

## Objectif

Point d'entrée unique de tout le système SUPRA.
Toute requête passe par le NUCLEO. Aucune logique métier ne le contourne.

## Principes

- Zero business logic — routing, validation, lifecycle, observabilité uniquement
- Tous les composants existants sont préservés — le NUCLEO est une couche de coordination
- Chaque composant a une classification stricte
- Tout est observable via le traceur central

## Cartographie des composants

### CORE (composants essentiels au démarrage)

| Composant | Fichier | Rôle | Dépendances |
|-----------|---------|------|-------------|
| **NUCLEO Orchestrator** | `SUPRANucleoOrchestrator.swift` | Point d'entrée unique — validation, routing, lifecycle, observabilité | Tous les CORE |
| **ResourceGovernor** | `SUPRAResourceGovernor.swift` | Monitoring CPU/RAM/disk, throttle | host_statistics, ProcessInfo |
| **RuntimeGateway** | `RuntimeGateway.swift` | Event bus, connexion runtime, pont BridgeRequest | Bridge types |
| **RuntimeMonitor** | `RuntimeMonitor.swift` | Monitoring runtime, collecte d'events | RuntimeDataService, OpenCodeClient |
| **RuntimeDataService** | `RuntimeDataService.swift` | Chargement des traces JSON runtime | RuntimeModels |
| **MissionStore** | `MissionStore.swift` | CRUD missions, classification, filtrage | Mission |
| **MissionContext** | `MissionContext.swift` | Préparation du contexte pour missions | NOVAKnowledgeKernel |
| **SUPRAScheduler** | `SUPRAScheduler.swift` | Ordonnancement priorisé des tâches | SUPRAResourceGovernor, CAnnoNicoSnapshotStore |
| **SUPRADecisionEngine** | `SUPRADecisionEngine.swift` | Évaluation des décisions (evidence → verdict) | DecisionEvidence, DecisionVerdict |
| **SUPRAMissionExecutor** | `SUPRAMissionExecutor.swift` | Exécution des missions approuvées | MissionProposal |
| **OpenCodeBridge** | `OpenCodeBridge.swift` | Pont de communication avec OpenCode | RuntimeGateway |
| **OpenCodeClient** | `OpenCodeClient.swift` | Client OpenCode avec sources JSON/OpenCode | RuntimeSourceProtocol |
| **RuntimeSourceProtocol** | `RuntimeSourceProtocol.swift` | Protocole source runtime (JSON, OpenCode) | RuntimeConnectionState |
| **SUPRACanonicalWorldAccess** | `SUPRACanonicalWorldAccess.swift` | Accès unifié à tous les états système | MultiMemoryStore, MissionStore, etc. |
| **NOVAKnowledgeKernel** | `NOVAKnowledgeKernel.swift` | Kernel de connaissances, registre central d'objets | CAnnoNicoObject |

### SERVICES (composants métier non critiques au boot)

| Composant | Fichier | Rôle |
|-----------|---------|------|
| SUPRABackgroundScheduler | `SUPRABackgroundScheduler.swift` | Ordonnancement basse priorité, user-aware |
| SUPRAIntelligenceEngine | `SUPRAIntelligenceEngine.swift` | Moteur d'insights et scoring de santé |
| SUPRAResourceIntelligenceEngine | `SUPRAResourceIntelligenceEngine.swift` | Détection d'anomalies CPU/RAM/stockage |
| SUPRAEvolutionEngine | `SUPRAEvolutionEngine.swift` | Auto-optimisation du poste de travail |
| SUPRARecommendationEngine | `SUPRARecommendationEngine.swift` | Recommandations (DerivedData, espace disque, etc.) |
| SUPRAMissionObserver | `SUPRAMissionObserver.swift` | Observation des conditions système |
| SUPRAMissionProposalEngine | `SUPRAMissionProposalEngine.swift` | Moteur de propositions de missions |
| ExecutiveMemory | `ExecutiveMemory.swift` | Mémoire exécutive (query/réponses) |
| ContextEngine | `ContextEngine.swift` | Moteur de contexte avec scoring |
| DecisionStore | `DecisionStore.swift` | Stockage et filtrage des décisions |
| ControlCenterStore | `ControlCenterStore.swift` | Chargement snapshot contrôle |
| ExecutiveCockpitFoundation | `ExecutiveCockpitFoundation.swift` | Foundation du cockpit exécutif |
| SUPRAOSFoundation | `SUPRAOSFoundation.swift` | Fondation OS SUPRA (navigation, config) |
| TwinUniverse | `TwinUniverse.swift` | Univers des jumeaux numériques |
| MultiMemoryStore | `MultiMemoryStore.swift` | Store multi-sources mémoire |
| CAnnoNicoSnapshotStore | `_bridging_` | Store des snapshots CAnnoNico |
| SUPRAPassiveRefreshCoordinator | `SUPRAPassiveRefreshCoordinator.swift` | Rafraîchissement passif |
| ConversationMemoryStore | `ConversationMemoryStore.swift` | Mémoire des conversations |
| SUPRAEnvironmentWorldModel | `SUPRAEnvironmentWorldModel.swift` | Modèle du monde environnement |

### ADAPTERS (ponts vers l'extérieur)

| Composant | Fichier | Rôle |
|-----------|---------|------|
| SUPRATerminalMegabusBridge | `Infrastructure/SUPRATerminalMegabusBridge.swift` | Pont vers le bus MEGABUS |
| SUPRASystemIntegrityLoader | `Infrastructure/SUPRASystemIntegrity.swift` | Vérification d'intégrité du build |
| SUPRAMissionEvidenceLoader | `Infrastructure/SUPRAMissionEvidenceLoader.swift` | Chargement des preuves de mission |
| SUPRAChatRuntimeAdapter | `SUPRAChatRuntimeAdapter.swift` | Adaptateur chat → runtime |
| SUPRAGabrielConductorRuntime | `SUPRAGabrielConductorRuntime.swift` | Runtime Gabriel (conductor UI) |
| CAnnoNicoIntegrationBridge | `CAnnoNicoIntegrationBridge.swift` | Pont CAnnoNico |

### EXTERNALS (dépendances extérieures)

| Dépendance | Type | Usage |
|------------|------|-------|
| OpenCode CLI | Binaire externe | Agents SUPRA, exécution de missions |
| Ollama | Service local | Modèles LLM locaux |
| CAnnoNicoContracts | Package SPM | Contrats CAnnoNico |
| FileSystem (JSON) | Stockage | Traces, registres, snapshots |
| SUPRATerminalMegabus | Filesystem bus | Messages inter-terminaux |

## Classification NUCLEO

```
IMMUTABLE  → RuntimeGateway, OpenCodeBridge, RuntimeSourceProtocol,
             BridgeCommand, BridgeResponse, RuntimeEventType,
             SUPRASystemIntegritySnapshot
             (ne pas modifier, interfaces stabilisées)

CORE       → SUPRANucleoOrchestrator, SUPRAResourceGovernor, RuntimeMonitor,
             RuntimeDataService, MissionStore, MissionContext, SUPRAScheduler,
             SUPRADecisionEngine, SUPRAMissionExecutor, NOVAKnowledgeKernel,
             SUPRACanonicalWorldAccess, OpenCodeClient,
             RuntimeModels (tous les types)

OPTIONAL   → SUPRABackgroundScheduler, SUPRAIntelligenceEngine,
             SUPRAResourceIntelligenceEngine, SUPRAEvolutionEngine,
             SUPRARecommendationEngine, SUPRAMissionObserver,
             ExecutiveMemory, ContextEngine, DecisionStore,
             ControlCenterStore, ExecutiveCockpitFoundation,
             SUPRAOSFoundation, TwinUniverse

PLUGIN     → SUPRATerminalMegabusBridge, SUPRAChatRuntimeAdapter,
             SUPRAGabrielConductorRuntime, CAnnoNicoIntegrationBridge,
             SUPRAPassiveRefreshCoordinator

LEGACY     → SUPRACommandCenterState (à migrer vers NUCLEO),
             ControlTowerState (remplacé par CanonicalWorldAccess),
             SUPRAEnvironmentAutoMissions (fusionné dans MissionStore),
             ArtifactReader (à déprécier au profit de RuntimeDataService)

DEPRECATED → SUPRACommandCenterApp (remplacé par SUPRAOperationalCoreApp)
```

## Graphe des dépendances

```
SUPRANucleoOrchestrator
├── SUPRAResourceGovernor (CORE)
├── RuntimeGateway (IMMUTABLE) — Event Bus
├── RuntimeMonitor (CORE)
├── RuntimeDataService (CORE)
├── SUPRAScheduler (CORE)
├── SUPRADecisionEngine (CORE)
├── SUPRAMissionExecutor (CORE)
├── MissionStore (CORE)
├── MissionContext (CORE)
├── NOVAKnowledgeKernel (CORE)
├── OpenCodeClient (CORE)
├── OpenCodeBridge (IMMUTABLE)
│   └── RuntimeGateway (IMMUTABLE)
├── SUPRACanonicalWorldAccess (CORE)
│   ├── MultiMemoryStore (SERVICE)
│   ├── CAnnoNicoSnapshotStore (SERVICE)
│   └── SUPRAResourceGovernor (CORE)
├── SUPRAMissionObserver (OPTIONAL)
├── SUPRAIntelligenceEngine (OPTIONAL)
├── SUPRAResourceIntelligenceEngine (OPTIONAL)
└── TraceStore (NUCLEO Metrics)
```

## Interfaces publiques du NUCLEO

```swift
protocol SUPRANucleoProtocol {
    // Lifecycle
    func start() async throws
    func stop() async
    func pause() async
    func resume() async

    // Request routing (point d'entrée unique)
    func execute(_ request: NucleoRequest) async -> NucleoResponse

    // Observability
    var traceStore: TraceStore { get }
    func metrics() -> NucleoMetrics
    func health() -> NucleoHealth

    // Component access
    func resolve<T>(_ type: T.Type) -> T?  // Service locator

    // Freeze
    func freeze() -> FreezeManifest
    func restore(from: FreezeManifest) async throws
}
```

## Flux d'exécution

```
Requête externe
     │
     ▼
┌──────────────────────────┐
│ SUPRANucleoOrchestrator  │
│  ① validate(request)     │
│  ② TraceStore.record()   │
│  ③ route(request)        │
│     │                    │
│     ├─ RESOURCE    → SUPRAResourceGovernor
│     ├─ MISSION     → MissionStore + MissionContext
│     ├─ DECISION    → SUPRADecisionEngine + SUPRAMissionExecutor
│     ├─ RUNTIME     → RuntimeGateway + RuntimeMonitor
│     ├─ SCHEDULER   → SUPRAScheduler
│     ├─ KNOWLEDGE   → NOVAKnowledgeKernel
│     ├─ OBSERVE     → SUPRAMissionObserver
│     └─ CANONICAL   → SUPRACanonicalWorldAccess
│     │                    │
│     ▼                    ▼
│  ④ monitor(execution)   │
│  ⑤ TraceStore.complete()│
│  ⑥ return response      │
└──────────────────────────┘
```

## Métriques NUCLEO (TraceStore)

Chaque requête enregistre :

```json
{
  "trace_id": "uuid",
  "source": "opencode|api|scheduler|user",
  "executor": "mission|decision|resource|runtime|knowledge|canonical",
  "provider": "local|ollama|opencode",
  "model": "qwen3:4b|...",
  "elapsed_ms": 1234,
  "cancelled": false,
  "retry_count": 0,
  "timeout": false,
  "cache_hit": false,
  "prompt_tokens": 0,
  "completion_tokens": 0,
  "status": "success|error|timeout|cancelled",
  "error": null,
  "timestamp": "2026-07-25T00:00:00Z"
}
```

## Points d'extension futurs

- Banking — canal financier via NUCLEO
- Legal — validation juridique via DecisionEngine
- Multi-node — orchestration distribuée
- UI layer — tous les écrans passent par NUCLEO
- Memory Router — routage mémoire optimisé
- Plugin system — chargement dynamique de plugins
