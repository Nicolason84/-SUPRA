# CANNO COMPONENT MAP — V1

## Mission : NUCLEO_VALIDATION_CANNO_002

## Cartographie des composants par catégorie CAnnoNico

---

### SYSTEM (3)

| ID CAnnoNico | Composant | Rôle |
|---|---|---|
| `sup.system.app.v1` | SUPRAOperationalCoreApp | @main actuel — démarrage du système |
| `sup.system.app.legacy.v1` | SUPRACommandCenterApp | @main legacy (commenté) |
| `sup.system.app.deprecated.v1` | SUPRAApp | @main obsolète (commenté) |
| `sup.lifecycle.nucleo.v1` | SUPRANucleoOrchestrator | Routeur central NUCLEO |

### KERNEL (3)

| ID CAnnoNico | Composant | Rôle |
|---|---|---|
| `sup.kernel.knowledge.v1` | NOVAKnowledgeKernel | Registre central de connaissances |
| `sup.kernel.memory.executive.v1` | ExecutiveMemory | Mémoire exécutive vectorisée |
| `sup.kernel.context.v1` | ContextEngine | Moteur de recherche contextuelle |

### SERVICE (9)

| ID CAnnoNico | Composant | Rôle |
|---|---|---|
| `sup.service.runtime.gateway.v1` | RuntimeGateway | Pont HTTP/bridge runtime |
| `sup.service.runtime.monitor.v1` | RuntimeMonitor | Monitoring runtime |
| `sup.service.runtime.data.v1` | RuntimeDataService | Chargement traces JSON |
| `sup.service.opencode.client.v1` | OpenCodeClient | Client OpenCode |
| `sup.protocol.runtime.source.v1` | RuntimeSourceProtocol | Protocole source runtime |
| `sup.state.runtime.connection.v1` | RuntimeConnectionState | État connexion |
| `sup.scheduler.priority.v1` | SUPRAScheduler | Ordonnancement priorisé |
| `sup.scheduler.background.v1` | SUPRABackgroundScheduler | Ordonnancement background |
| `sup.service.world.access.v1` | SUPRACanonicalWorldAccess | Façade état canonique |
| `sup.integrity.system.v1` | SUPRASystemIntegrity | Intégrité build/rollback |
| `sup.service.refresh.passive.v1` | SUPRAPassiveRefreshCoordinator | Rafraîchissement passif |
| `sup.service.environment.missions.v1` | SUPRAEnvironmentAutoMissions | Missions environnement |
| `sup.state.intelligence.v1` | SUPRAIntelligenceState | État intelligence |

### ENGINE (11)

| ID CAnnoNico | Composant | Rôle |
|---|---|---|
| `sup.engine.decision.v1` | SUPRADecisionEngine | Évaluation preuves → verdict |
| `sup.engine.resource.intelligence.v1` | SUPRAResourceIntelligenceEngine | Anomalies ressources |
| `sup.engine.optimization.copilot.v1` | SUPRAOptimizationCopilot | Copilot optimisation |
| `sup.engine.intelligence.v1` | SUPRAIntelligenceEngine | Scores santé/confiance |
| `sup.engine.evolution.v1` | SUPRAEvolutionEngine | Auto-optimisation |
| `sup.engine.recommendation.v1` | SUPRARecommendationEngine | Recommandations |
| `sup.engine.monetization.v1` | SUPRAMonetizationEngine | Tarifs et ROI |

### MODULE (4)

| ID CAnnoNico | Composant | Rôle |
|---|---|---|
| `sup.platform.business.v1` | SUPRABusinessPlatform | Plateforme business |
| `sup.model.world.v1` | SUPRAWorldModel | Modèle du monde |
| `sup.model.world.environment.v1` | SUPRAEnvironmentWorldModel | Modèle environnement |

### PLUGIN (4)

| ID CAnnoNico | Composant | Rôle |
|---|---|---|
| `sup.twin.data.v1` | SUPRADataTwin | Jumeau données |
| `sup.twin.hardware.v1` | SUPRAHardwareTwin | Jumeau matériel |
| `sup.twin.software.v1` | SUPRASoftwareTwin | Jumeau logiciel |
| `sup.twin.developer.v1` | SUPRADeveloperTwin | Jumeau développeur |

### WORKER (1)

| ID CAnnoNico | Composant | Rôle |
|---|---|---|
| `sup.fabric.worker.v1` | SUPRAWorkerFabric | Fabrique de 4 workers |

### MISSION (8)

| ID CAnnoNico | Composant | Rôle |
|---|---|---|
| `sup.mission.store.v1` | MissionStore | CRUD missions |
| `sup.mission.context.v1` | MissionContext | Contexte mission |
| `sup.mission.model.v1` | Mission | Modèle mission |
| `sup.mission.executor.v1` | SUPRAMissionExecutor | Exécution mission |
| `sup.mission.observer.v1` | SUPRAMissionObserver | Observation conditions |
| `sup.mission.proposal.v1` | SUPRAMissionProposalEngine | Propositions mission |
| `sup.mission.queue.auto.v1` | AutoMissionQueue | File auto |

### BRIDGE (2)

| ID CAnnoNico | Composant | Rôle |
|---|---|---|
| `sup.bridge.opencode.v1` | OpenCodeBridge | Pont commandes OpenCode |
| `sup.bridge.megabus.v1` | SUPRATerminalMegabusBridge | Pont IPC inter-terminal |

### ADAPTER (3)

| ID CAnnoNico | Composant | Rôle |
|---|---|---|
| `sup.adapter.runtime.json.v1` | JSONRuntimeSource | Source JSON |
| `sup.adapter.runtime.opencode.v1` | OpenCodeRuntimeSource | Source OpenCode |
| `sup.adapter.chat.runtime.v1` | SUPRAChatRuntimeAdapter | Adaptateur HTTP chat |

### MEMORY (4)

| ID CAnnoNico | Composant | Rôle |
|---|---|---|
| `sup.memory.multistore.v1` | MultiMemoryStore | Agrégateur 5 sources |
| `sup.memory.conversation.v1` | ConversationMemoryStore | Conversations ChatGPT |
| `sup.memory.snapshot.v1` | CAnnoNicoSnapshotStore | Cache TTL CAnnoNico |

### DECISION (3)

| ID CAnnoNico | Composant | Rôle |
|---|---|---|
| `sup.model.decision.authority.v1` | SUPRADecisionAuthority | Types autorité |
| `sup.decision.store.v1` | DecisionStore | Décisions architecturales |

### EVIDENCE (1)

| ID CAnnoNico | Composant | Rôle |
|---|---|---|
| `sup.mission.evidence.loader.v1` | SUPRAMissionEvidenceLoader | Chargement preuves |

### DATASET (1)

| ID CAnnoNico | Composant | Rôle |
|---|---|---|
| `sup.dataset.runtime.models.v1` | RuntimeModels | Modèles traces runtime |

### RESOURCE (1)

| ID CAnnoNico | Composant | Rôle |
|---|---|---|
| `sup.resource.governor.v1` | SUPRAResourceGovernor | Monitoring ressources |

### UI (64)

Vues SwiftUI dans le projet. Composants principaux :
- ContentView (3521 lignes)
- SUPRAOSProductRootView
- SUPRAAutonomyControlView
- SUPRADecisionEngineView
- +60 autres vues SwiftUI

### EXTERNAL (1)

| ID CAnnoNico | Composant | Rôle |
|---|---|---|
| `sup.runtime.gabriel.v1` | SUPRAGabrielConductorRuntime | Interface Gabriel Python |

---

## Registres (registry) — 11 fichiers JSON

| Fichier | Type |
|---|---|
| CANONICAL_ADAPTERS.json | Registre adaptateurs |
| CANONICAL_BRIDGES.json | Registre bridges |
| CANONICAL_MODULES.json | Registre modules |
| CANONICAL_PACKAGES.json | Registre packages |
| CANONICAL_PROJECTS.json | Registre projets |
| CANONICAL_REGISTRY.json | Registre environnement twin |
| CANONICAL_RUNTIME.json | Registre runtime |
| CANONICAL_SERVICES.json | Registre services |
| CANONICAL_WORKERS.json | Registre workers |
| .kernel/registry/agents.json | Registre agents |
| .kernel/runtime/node_identity.json | Identité nœud |

---

## Shell scripts — 18 fichiers de support

Installation (2), bootstrap (2), audit (3), découverte (4), recovery (2), mémoire (2), parallèle (1), Xcode (1), composition (3).
