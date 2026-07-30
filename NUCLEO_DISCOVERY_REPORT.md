# NUCLEO DISCOVERY REPORT — V1

## Mission : NUCLEO_DISCOVERY_001

**État :** TERMINÉE — READ ONLY
**Date :** 2026-07-25
**Aucune modification** du code existant.

---

## Résumé

| Métrique | Valeur |
|----------|--------|
| Fichiers Swift analysés | 189 |
| Composants non-UI identifiés | 84 |
| Composants UI/View | 64 |
| Singletons détectés | 26 |
| Fichiers JSON kernel | 7 |
| Scripts shell | 18 |
| Registres CANONICAL | 9 |
| Doublons potentiels | 6 groupes |
| Violations structurelles | 5 |

---

## 1. Découverte

### Composants NUCLEO par couche

**ENTRY POINTS (3)**
- `SUPRAOperationalCoreApp` — @main actuel (SUPRA/SUPRAOperationalCoreApp.swift)
- `SUPRACommandCenterApp` — @main commenté (SUPRA/SUPRACommandCenterApp.swift) → LEGACY
- `SUPRAApp` — @main commenté (SUPRA/SUPRAApp.swift) → DEPRECATED

**KERNEL (3)**
- `NOVAKnowledgeKernel` — Singleton, registre central d'objets/relations/sources (SUPRA/NOVAKnowledgeKernel.swift)
- `ExecutiveMemory` — Mémoire exécutive query/réponse (SUPRA/ExecutiveMemory.swift)
- `ContextEngine` — Moteur de contexte avec scoring (SUPRA/ContextEngine.swift)

**RUNTIME (9)**
- `RuntimeGateway` — Singleton, event bus + BridgeRequest/Response (SUPRA/RuntimeGateway.swift)
- `RuntimeMonitor` — Monitoring runtime, délégation OpenCodeClient (SUPRA/RuntimeMonitor.swift)
- `RuntimeDataService` — Chargement 8 fichiers JSON de traces (SUPRA/RuntimeDataService.swift)
- `OpenCodeClient` — Singleton, client OpenCode multi-source (SUPRA/OpenCodeClient.swift)
- `OpenCodeBridge` — Singleton, pont BridgeCommand/Response (SUPRA/OpenCodeBridge.swift)
- `JSONRuntimeSource` — Source runtime JSON (SUPRA/RuntimeEventSource.swift)
- `OpenCodeRuntimeSource` — Source runtime OpenCode (SUPRA/RuntimeEventSource.swift)
- `RuntimeSourceProtocol` — Protocole source runtime (SUPRA/RuntimeSourceProtocol.swift)
- `RuntimeConnectionState` — Enum état connexion (SUPRA/RuntimeConnectionState.swift)

**MISSION (8)**
- `MissionStore` — CRUD missions, classification, filtrage (SUPRA/MissionStore.swift)
- `MissionContext` — Préparation de contexte mission (SUPRA/MissionContext.swift)
- `Mission` — Modèle de données mission (SUPRA/Mission.swift)
- `SUPRAMissionExecutor` — Singleton, exécution avec rollback (SUPRA/SUPRAMissionExecutor.swift)
- `SUPRAMissionObserver` — Singleton, observation conditions système (SUPRA/SUPRAMissionObserver.swift)
- `SUPRAMissionProposalEngine` — Singleton, propositions avec auto/supervision/human (SUPRA/SUPRAMissionProposalEngine.swift)
- `AutoMissionQueue` — File de missions automatiques (SUPRA/AutoMissionQueue.swift)
- `SUPRAMissionEvidenceLoader` — Chargement preuves mission (SUPRA/Infrastructure/SUPRAMissionEvidenceLoader.swift)

**SCHEDULER (2)**
- `SUPRAScheduler` — Singleton, ordonnancement priorisé (SUPRA/SUPRAScheduler.swift)
- `SUPRABackgroundScheduler` — Singleton, ordonnancement basse priorité (SUPRA/SUPRABackgroundScheduler.swift)

**DECISION (6)**
- `SUPRADecisionEngine` — Évaluation evidence → verdict (SUPRA/SUPRADecisionEngine.swift)
- `SUPRADecisionAuthority` — Enum autorité décisionnelle (SUPRA/SUPRADecisionAuthority.swift)
- `DecisionStore` — Stockage décisions architecturales (SUPRA/DecisionStore.swift)
- `SUPRAAutonomyControlView` — UI contrôle autonomie (SUPRA/SUPRAAutonomyControlView.swift)
- `SUPRADecisionEngineView` — UI décisions (SUPRA/SUPRADecisionRoomView.swift)
- `SUPRACanonicalWorldAccess` — Singleton, accès unifié état système (SUPRA/SUPRACanonicalWorldAccess.swift)

**RESOURCE (3)**
- `SUPRAResourceGovernor` — Singleton, monitoring CPU/RAM/disk/throttle (SUPRA/SUPRAResourceGovernor.swift)
- `SUPRAResourceIntelligenceEngine` — Singleton, anomalies + gaspillage (SUPRA/SUPRAResourceIntelligenceEngine.swift)
- `SUPRAOptimizationCopilot` — Singleton, copilot optimisation (SUPRA/SUPRAOptimizationCopilot.swift)

**INTELLIGENCE (4)**
- `SUPRAIntelligenceEngine` — Singleton, insights + scoring santé/confiance (SUPRA/SUPRAIntelligenceEngine.swift)
- `SUPRAEvolutionEngine` — Singleton, auto-optimisation poste (SUPRA/SUPRAEvolutionEngine.swift)
- `SUPRARecommendationEngine` — Singleton, recommandations système (SUPRA/SUPRARecommendationCenter.swift)
- `SUPRAIntelligenceState` — État du moteur d'intelligence (SUPRA/SUPRAIntelligenceState.swift)

**BROKERS (2)**
- `SUPRATerminalMegabusBridge` — Pont bus MEGABUS inter-terminal (SUPRA/Infrastructure/SUPRATerminalMegabusBridge.swift)
- `SUPRAChatRuntimeAdapter` — Adaptateur chat → runtime (SUPRA/SUPRAChatRuntimeAdapter.swift)

**MEMORY (4)**
- `MultiMemoryStore` — Singleton, store multi-sources mémoire (SUPRA/MultiMemoryStore.swift)
- `ConversationMemoryStore` — Singleton, mémoire conversations (SUPRA/ConversationMemoryStore.swift)
- `CAnnoNicoSnapshotStore` — Singleton, store snapshots CAnnoNico (implémenté dans CAnnoNicoSnapshotStore.swift)
- `ExecutiveMemory` — Mémoire exécutive (déjà listé sous KERNEL)

**LIFECYCLE (1)**
- `SUPRANucleoOrchestrator` — Singleton, point d'entrée NUCLEO (SUPRA/SUPRANucleoOrchestrator.swift)

**INTEGRITY (1)**
- `SUPRASystemIntegrityLoader` — Vérification build + rollback (SUPRA/Infrastructure/SUPRASystemIntegrity.swift)

**MONITORING (3)**
- `RuntimeMonitor` — Monitoring runtime (déjà listé)
- `SUPRAPassiveRefreshCoordinator` — Singleton, rafraîchissement passif (SUPRA/SUPRAPassiveRefreshCoordinator.swift)
- `SUPRAEnvironmentAutoMissions` — Missions automatiques environnement (SUPRA/SUPRAEnvironmentAutoMissions.swift)

**TRACE & METRICS (3)**
- `RuntimeTrace` — Modèle trace runtime (SUPRA/RuntimeModels.swift)
- `RuntimeMetrics` — Modèle métriques runtime (SUPRA/RuntimeModels.swift)
- `DashboardSnapshot` — Modèle snapshot dashboard (SUPRA/RuntimeModels.swift)

**REGISTRY (2)**
- `.kernel/registry/agents.json` — Registre des agents SUPRA
- `.kernel/runtime/node_identity.json` — Identité du nœud

---

## 2. Composants non listés initialement découverts

| Composant | Fichier | Surprise |
|-----------|---------|----------|
| `SUPRAGabrielConductorRuntime` | SUPRA/SUPRAGabrielConductorRuntime.swift | Runtime Gabriel non documenté |
| `SUPRABusinessPlatform` | SUPRA/SUPRABusinessPlatform.swift | Plateforme métier inconnue |
| `SUPRAMonetizationEngine` | SUPRA/SUPRAMonetizationEngine.swift | Moteur de monétisation |
| `SUPRADataTwin` | SUPRA/SUPRADataTwin.swift | Jumeau données |
| `SUPRAHardwareTwin` | SUPRA/SUPRAHardwareTwin.swift | Jumeau matériel |
| `SUPRASoftwareTwin` | SUPRA/SUPRASoftwareTwin.swift | Jumeau logiciel |
| `SUPRADeveloperTwin` | SUPRA/SUPRADeveloperTwin.swift | Jumeau développeur |
| `SUPRAWorkerFabric` | SUPRA/SUPRAWorkerFabric.swift | Fabrique de workers |
| `SUPRAWorldModel` | SUPRA/SUPRAWorldModel.swift | Modèle du monde |
| `SUPRAEnvironmentWorldModel` | SUPRA/SUPRAEnvironmentWorldModel.swift | Modèle environnement |

---

## 3. État général

- **Points forts :** Architecture modulaire, forte séparation des responsabilités, pattern singleton dominant, utilisation cohérente d'ObservableObject/Combine.
- **Points faibles :** 3 @main concurrents (dont 2 commentés), singletons en masse sans interface formelle, fichiers de 3000+ lignes (ContentView.swift, SUPRACommandCenterState.swift), responsabilités multiples dans SUPRACommandCenterState.
- **Risques :** Couplage fort à SwiftUI/AppKit (macOS only), dépendances circulaires potentielles entre les engines, pas de couche d'abstraction pour les tests.
