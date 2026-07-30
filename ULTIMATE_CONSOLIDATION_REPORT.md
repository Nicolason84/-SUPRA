# SUPRA Ultimate Consolidation V1

**Mission :** `SUPRA_ULTIMATE_CONSOLIDATION_V1`  
**Nature :** audit, consolidation et feuille de route — aucune implémentation  
**Cible :** une application unique, **SUPRA Executive OS**, alimentée par un Runtime canonique partagé  
**État du dépôt observé :** 28 juillet 2026

---

## 1. Décision exécutive

SUPRA ne doit pas recevoir une nouvelle interface. La consolidation doit s’effectuer autour de la chaîne d’entrée déjà la plus mûre :

```text
SUPRAOperationalCoreApp (@main)
  └── SUPRAOSProductRootView
        └── ExecutiveWindow
              └── 12 espaces fonctionnels
```

`ExecutiveWindow` devient l’unique shell de navigation. `RuntimeDiagnosticsView` fournit la base de l’espace Runtime. `SUPRAOSWorkspaceExplorerView` fournit la base de l’espace Workspace. `ContentView`, héritage du Workspace V5, n’est plus une racine produit : ses composants utiles sont extraits ou adaptés dans les espaces canoniques. Les autres dashboards deviennent des sources de composants, puis des façades de compatibilité temporaires, avant suppression différée.

La consolidation du Runtime précède toute suppression d’interface. Un propriétaire unique, `SUPRACompositionRoot`, expose un `RuntimeKernel`; celui-ci publie atomiquement un `RuntimeSnapshot` versionné. Les onze moteurs demandés sont des façades sur les implémentations existantes, non onze réécritures.

Cette mission ne propose aucune nouvelle fonctionnalité. Elle réorganise, adapte et déduplique l’existant.

---

## 2. Périmètre, méthode et limites

### 2.1 Méthode

Le rapport repose sur :

- l’inventaire statique du dépôt et des déclarations Swift ;
- l’identification de la racine `@main`, des shells, des vues, stores, services, moteurs et providers ;
- la lecture ciblée des documents d’architecture, d’exécution, de Runtime, de Mission, Knowledge, Discovery, Decision et Workspace présents ;
- la comparaison structurelle des trois générations d’interface ;
- les audits Explorer, Auditor et Architect exécutés avant la présente écriture ;
- l’état Git observé avant création de ce rapport.

Les nombres sont des résultats d’inventaire statique. Une déclaration imbriquée est comptée comme déclaration ; un fichier peut appartenir à plusieurs catégories (par exemple View + ObservableObject). Les répertoires de sauvegarde, gels et quarantaine sont distingués du code actif.

### 2.2 Limites de lecture

Le dépôt inventorié contient environ **887 fichiers**. Il n’est pas honnête d’affirmer que chaque ligne de chaque snapshot, rapport, archive, sauvegarde et artefact a été lue intégralement. La lecture a été exhaustive pour la structure et les noms de fichiers, puis ciblée sur les sources et documents nécessaires aux décisions de consolidation.

Les documents explicitement demandés suivants sont **absents sous ces noms à la racine** :

- `README` / `README.md` racine (un `SUPRA_AST_PLATFORM/README.md` existe, mais ne remplace pas un README produit) ;
- `CURRENT_STATE` / `CURRENT_STATE.md` ;
- `PATCH_REPORT` / `PATCH_REPORT.md` ;
- `RFC` / `RFC.md`.

Les documents voisins effectivement présents — notamment `SUPRA_STATE.json`, `BUILD_STATUS.md`, `EXECUTION_REPORT.md`, `SUPRA_EXECUTION_REPORT.md`, `NEXT_MISSION.md`, les rapports Runtime, Architecture et Freeze — ont servi de substituts partiels. Cette substitution est une limite de traçabilité et non une preuve que les documents demandés existent.

### 2.3 Baseline Git préexistante

Le dépôt était déjà **dirty avant cette mission**. Les modifications suivies observées incluaient :

- `DEPENDENCY_MAP.md` ;
- `SUPRA.xcodeproj/project.pbxproj` ;
- plusieurs sources Swift, dont `ArtifactReader.swift`, `CAnnoNicoIntegrationBridge.swift`, `ContentView.swift`, `ConversationMemoryStore.swift`, `DecisionInboxView.swift`, `Mission.swift`, `MissionCenterView.swift`, `MissionDetailView.swift`, `MissionStore.swift`, `SUPRAApp.swift` et `SUPRAOperationalControlCenterView.swift`.

De très nombreux fichiers et répertoires étaient également non suivis, notamment les rapports, freezes, JSON, nouvelles sources Swift, tests et dossiers `.cannonico`, `.kernel`, `.opencode`, `.supra_reports`. Cette mission ne les attribue pas à la consolidation, ne les réécrit pas et ne tente pas de les nettoyer. Le seul artefact autorisé par cette mission est le présent rapport.

---

## 3. Inventaire consolidé

### 3.1 Volumétrie

| Catégorie | Quantité observée | Remarque |
|---|---:|---|
| Fichiers du dépôt inventorié | ~887 | inclut sources, rapports, snapshots, freezes et sauvegardes |
| Fichiers Swift | 276 | 224 actifs sous `SUPRA/`, 9 tests, 20 AST, 5 liés à des packages/adapters, 18 sauvegarde/quarantaine |
| Déclarations SwiftUI `View` | ~96 | réparties dans 63 fichiers actifs contenant au moins une View |
| Types observables | ~114 | `ObservableObject` / observation, dont plusieurs états concurrents |
| `struct` | ~416 | modèles, snapshots, DTO, vues et composants |
| `class` / `actor` | ~128 | stores, services, moteurs et orchestrateurs |
| `enum` | ~169 | navigation, statuts, événements et domaines |
| `protocol` | ~11 | providers, runtime sources et contrats |
| JSON | ~190 | environ 192 selon inclusion des ressources et répertoires techniques |
| Markdown | ~153 | architecture, exécution, preuves, continuité et gels |
| Scripts/launchers | 28 dans l’inventaire global | 27 scripts actifs listés ci-dessous ; un artefact supplémentaire apparaît selon inclusion des sauvegardes |

### 3.2 Views SwiftUI

Les ~96 déclarations de View se trouvent principalement dans les 63 fichiers actifs suivants :

```text
CockpitRuntimeView.swift
CommandCenterView.swift
ContentView.swift
ContinuityView.swift
ConversationTwinView.swift
DashboardView.swift
DecisionAuthorityView.swift
DecisionDetailView.swift
DecisionInboxView.swift
DecisionRow.swift
EvidenceExplorerView.swift
ExecutiveMissionControlView.swift
ExecutiveWindow.swift
ExecutiveWorkflowListView.swift
FileSystemCardView.swift
HealthView.swift
IntelligenceView.swift
MemoryView.swift
MissionCenterView.swift
MissionCopilotView.swift
MissionDetailView.swift
MissionGraphView.swift
MissionRow.swift
MissionTimelineView.swift
MissionView.swift
MultiMemoryView.swift
ProjectsCardView.swift
RootCauseExplainerView.swift
RuntimeDiagnosticsView.swift
RuntimeView.swift
SUPRAAutonomyControlView.swift
SUPRABusinessDemoView.swift
SUPRACardSystemV1.swift
SUPRAChatView.swift
SUPRACompanionView.swift
SUPRADecisionRoomView.swift
SUPRAEnvironmentCommandCenterView.swift
SUPRAEvolutionEngineView.swift
SUPRAEvolutionRoomView.swift
SUPRAExplainLayer.swift
SUPRAImmersiveSpaceView.swift
SUPRAMacPotentialMap.swift
SUPRAMemoryLensView.swift
SUPRAOSCommandCenterView.swift
SUPRAOSDesignSystem.swift
SUPRAOSGlobalSearchView.swift
SUPRAOSHomeView.swift
SUPRAOSLiveView.swift
SUPRAOSMissionCanvasView.swift
SUPRAOSProductRootView.swift
SUPRAOSTwinCenterView.swift
SUPRAOSUniverseView.swift
SUPRAOSWorkspaceExplorerView.swift
SUPRAOperationalControlCenterView.swift
SUPRAOperationalCoreView.swift
SUPRARecommendationCenter.swift
SUPRAResourceIntelligenceView.swift
SUPRASpatialNavigatorView.swift
SUPRAWorldMapView.swift
SettingsView.swift
SupraControlCenterView.swift
TotalControlTowerView.swift
WorkerPoolView.swift
```

Les sous-vues imbriquées expliquent l’écart entre 63 fichiers et ~96 déclarations. `SUPRA/Infrastructure/` et `SUPRA/Models/` complètent cet inventaire. `SUPRA/UI/` ne contient actuellement que `.gitkeep`; aucun répertoire `SUPRA/Stores/` n’existe dans le corpus visible.

### 3.3 ViewModels, stores et états observables

Les propriétaires d’état principaux sont :

- stores produit : `MissionStore`, `DecisionStore`, `ConversationMemoryStore`, `MultiMemoryStore`, `ExecutiveMissionControlStore`, `ControlCenterStore`, `CAnnoNicoSnapshotStore`, `SUPRAEnvironmentSnapshotStore` ;
- états/shells : `ControlTowerState`, `SUPRACommandCenterState`, `ExecutiveCockpitFoundation`, `ExecutiveDemoMode`, `SUPRAOSFoundation` ;
- runtime/boot : `ExecutiveBootManager`, `RuntimeDataService`, `RuntimeGateway`, `RuntimeMonitor`, `OpenCodeClient`, `OpenCodeBridge` ;
- knowledge/workspace : `NOVAKnowledgeKernel`, `KnowledgeContextEngine`, `KnowledgeExplorer`, `KnowledgeGraph`, `KnowledgeStatistics`, `WorkspaceDiscovery`, `WorkspaceIndexer`, `WorkspaceKnowledgeGraph`, `WorkspaceMemory`, `WorkspaceGovernor`, `WorkspaceRecommendation`, `WorkspaceStatistics` ;
- intelligence/twins/universe : `SUPRAIntelligenceEngine`, `SUPRAIntelligenceGraph`, `SUPRAWorldModel`, `UniverseEngine`, `UniverseGraph`, `UniverseNavigator`, `UniverseSearch`, `UniverseTimeline`, `TwinAnalytics`, `TwinBindings`, `TwinComparison`, `TwinExplorer`, `TwinFactory`, `TwinLifecycle`, `TwinRegistry`, `TwinRenderer`, `TwinSynchronizer`, `TwinUniverse` ;
- orchestration : `SUPRACompositionRoot`, `SUPRAMissionBroker`, `SUPRAMissionExecutor`, `SUPRAMissionObserver`, `SUPRAMissionProposalEngine`, `SUPRAExecutionPipeline`, `SUPRAExecutionPlanner`, `SUPRAExecutor`, `SUPRAScheduler`, `SUPRAWorkerFabric`, `SUPRAProviderBroker`, `SUPRAProviderRegistry`, `SUPRARoutingPolicy`, `SUPRACapabilityBroker` ;
- opérations : `ContinuityManager`, `ProtectedFolderAccessCoordinator`, `SUPRAPassiveRefreshCoordinator`, `SUPRABackgroundScheduler`, `SUPRAResourceGovernor`, `SUPRARuntimeEvents`, `SUPRARuntimeGraph`, `SUPRARuntimeLogger`, `SUPRARuntimeMetrics`, `SUPRARuntimeRegistry`.

La quantité de propriétaires observables est une dette majeure : l’objectif n’est pas de les supprimer immédiatement, mais de les placer derrière un flux de snapshot unique.

### 3.4 Models

Les familles de modèles actives sont :

- Mission : `Mission.swift`, `MissionContext.swift`, `MissionProposal.swift`, `ExecutiveMissionControlModels.swift`, `ExecutiveWorkflow.swift`, `ExecutiveTimeline.swift` ;
- Runtime : `RuntimeModels.swift`, `RuntimeConnectionState.swift`, `RuntimeEvent.swift`, `RuntimeHealth.swift`, `RuntimeSourceProtocol.swift`, `ControlTowerState.swift` ;
- Workspace : `WorkspaceModels.swift`, `WorkspaceObject.swift`, `WorkspaceConfiguration.swift`, `WorkspaceRecommendation.swift`, `WorkspaceStatistics.swift` ;
- Knowledge : `KnowledgeObject.swift`, `KnowledgeIdentity.swift`, `KnowledgeSource.swift`, `KnowledgeRelation.swift`, `KnowledgeRelationship.swift`, `KnowledgeLineage.swift`, `KnowledgeAuthority.swift` ;
- Environment/Twin : `SUPRAEnvironmentBrief.swift`, `SUPRAEnvironmentPotential.swift`, `SUPRAEnvironmentWorldModel.swift`, `SUPRADataTwin.swift`, `SUPRADeveloperTwin.swift`, `SUPRAHardwareTwin.swift`, `SUPRASoftwareTwin.swift`, `TwinIdentity.swift`, `TwinBindings.swift`, `TwinLifecycle.swift` ;
- Decision/Insight : `SUPRADecisionAuthority.swift`, `SUPRAInsight.swift`, `SUPRARecommendationCenter.swift` ;
- Provider/worker : `SUPRAProviderProtocols.swift`, `SUPRAModelRegistry.swift`, `SUPRARoutingPolicy.swift`, `SUPRAWorkerFabric.swift` ;
- Universe/graph : `ExecutiveGraph.swift`, `SUPRAIntelligenceGraph.swift`, `SUPRARuntimeGraph.swift`, `UniverseGraph.swift`, `WorkspaceKnowledgeGraph.swift` ;
- canonical/extracted : `CAnnoNicoObject.swift` et les modèles sous `SUPRA/Models/`.

Les modèles historiques sous `_NON_RUNTIME_ARCHITECTURE/`, `_SUPRA_BACKUPS/` et `.mechanical_extract_backup_*` sont des archives, pas une deuxième source de vérité.

### 3.5 Services et Managers

Services et coordinations explicites :

```text
ArtifactReader
CAnnoNicoSnapshotStore
ContinuityManager
ConversationMemoryStore
DecisionStore
ExecutiveBootManager
ExecutiveMissionControlStore
MissionStore
MultiMemoryStore
ProtectedFolderAccessCoordinator
RuntimeDataService
RuntimeGateway
RuntimeMonitor
SUPRAEnvironmentSnapshotStore
SUPRAPassiveRefreshCoordinator
```

Infrastructures associées :

```text
SUPRA/Infrastructure/SUPRAMissionEvidenceLoader.swift
SUPRA/Infrastructure/SUPRASystemIntegrity.swift
SUPRA/Infrastructure/SUPRATerminalMegabusBridge.swift
CAnnoNicoIntegrationBridge.swift
SUPRACanonicalWorldAccess.swift
SUPRAEnvironmentResolver.swift
SUPRAEnvironmentSnapshotStore.swift
```

### 3.6 Runtime

Les composants Runtime identifiés sont :

```text
ExecutiveBootManager.swift
RuntimeConnectionState.swift
RuntimeDataService.swift
RuntimeEvent.swift
RuntimeEventSource.swift
RuntimeGateway.swift
RuntimeHealth.swift
RuntimeModels.swift
RuntimeMonitor.swift
RuntimeSourceProtocol.swift
SUPRAChatRuntimeAdapter.swift
SUPRACompositionRoot.swift
SUPRAGabrielConductorRuntime.swift
SUPRARuntimeEvents.swift
SUPRARuntimeGraph.swift
SUPRARuntimeLogger.swift
SUPRARuntimeMetrics.swift
SUPRARuntimeRegistry.swift
```

Vues Runtime existantes : `RuntimeDiagnosticsView`, `RuntimeView`, `CockpitRuntimeView`, `HealthView`, `RootCauseExplainerView`, ainsi que les panneaux Runtime intégrés à `ContentView`, `ExecutiveWindow`, `TotalControlTowerView`, `SUPRAOperationalControlCenterView` et `SUPRAOSLiveView`.

### 3.7 Providers et APIs

Providers :

```text
KnowledgeProvider.swift
ConversationKnowledgeProvider.swift
DecisionKnowledgeProvider.swift
GitKnowledgeProvider.swift
PDFKnowledgeProvider.swift
ReportKnowledgeProvider.swift
SUPRAOllamaProvider.swift
SUPRAProviderProtocols.swift
SUPRAProviderRegistry.swift
SUPRAProviderBroker.swift
OpenCodeBridge.swift
OpenCodeClient.swift
```

APIs et frontières externes observées :

- OpenCode local via `OpenCodeClient` et `OpenCodeBridge`; `OpenCodeRuntimeSource` est un placeholder/point d’intégration préparé, pas la preuve d’une source Runtime OpenCode pleinement fonctionnelle ;
- chat local HTTP `127.0.0.1:18765/v1/chat` et santé `127.0.0.1:18765/v1/health` ;
- Ollama local, base `localhost:11434`, endpoints `/api/tags` et `/api/generate` ;
- Git via `Process` dans `GitKnowledgeProvider` ;
- système de fichiers via `FileManager`, bookmarks de dossiers protégés et lecteurs d’artefacts ;
- macOS via AppKit/`NSWorkspace`, processus système et métriques machine ;
- contrats/adapters locaux `CAnnoNicoContracts`, `NicoAppAdapter`, `PucheroMemoryAdapter`, `VideoSwapAdapter` ;
- AST Swift via `SwiftParser`, `SwiftSyntax` et la bibliothèque locale `SUPRAAST`.

Il n’existe pas de justification à ajouter une nouvelle API pour la consolidation.

### 3.8 Workers, exécution et ordonnancement

```text
AutoMissionQueue.swift
SUPRABackgroundScheduler.swift
SUPRACapabilityBroker.swift
SUPRAExecutionPipeline.swift
SUPRAExecutionPlanner.swift
SUPRAExecutor.swift
SUPRAMissionBroker.swift
SUPRAMissionExecutor.swift
SUPRAProviderBroker.swift
SUPRAScheduler.swift
SUPRAWorkerFabric.swift
WorkerPoolView.swift
```

Ces composants doivent rester opérationnels et être observés par le Runtime canonique ; ils ne doivent pas être dupliqués par un nouveau scheduler.

### 3.9 JSON par familles

Les ~190 JSON se répartissent en :

- **état/runtime** : `SUPRA_STATE.json`, `RUNTIME_STATUS.json`, `CONTROL_TOWER_STATUS.json`, `runtime_metrics.json`, `runtime_diagnostics.json`, `runtime_trace.json`, `SUPRA_RUNTIME_GRAPH.json`, `SUPRA_PRODUCT_RUNTIME_READINESS.json`, `SUPRA_RUNTIME_SMOKE_TEST.json` ;
- **mission/exécution** : `mission_graph.json`, `mission_graph_metrics.json`, `execution_plan.json`, `execution_graph.json`, `execution_trace.json`, `validation_trace.json`, `agent_execution.json`, `agent_results/`, `delegation_trace.json`, `consensus_report.json`, `consensus_trace.json`, `critical_path.json` ;
- **providers/routage/workers** : `provider_metrics.json`, `provider_selection.json`, `model_selection.json`, `router_decision.json`, `routing_trace.json`, `worker_trace.json`, `scheduler_trace.json`, `queue_metrics.json`, `job_metrics.json`, `parallel_groups.json`, `resource_allocation.json` ;
- **knowledge** : `knowledge_kernel.json`, `knowledge_graph.json`, `knowledge_identity.json`, `knowledge_sources.json`, `knowledge_relations.json`, `knowledge_relationships.json`, `knowledge_lineage.json`, `knowledge_authority.json`, `knowledge_statistics.json`, `knowledge_context_examples.json` ;
- **workspace/universe/twin** : `workspace_index.json`, `workspace_graph.json`, `workspace_memory.json`, `workspace_governance.json`, `workspace_recommendations.json`, `workspace_statistics.json`, `universe_graph.json`, `universe_registry.json`, `universe_statistics.json`, `twin_registry.json`, `twin_bindings.json`, `twin_lifecycle.json`, `twin_relationships.json` ;
- **registres canoniques** : `CANONICAL_REGISTRY.json`, `CANONICAL_MODULES.json`, `CANONICAL_SERVICES.json`, `CANONICAL_WORKERS.json`, `CANONICAL_ADAPTERS.json`, `CANONICAL_BRIDGES.json`, `CANONICAL_PACKAGES.json`, `CANONICAL_PROJECTS.json`, `CANONICAL_RUNTIME.json`, ainsi que `MODULE_*`, `PACKAGE_*`, `PROJECT_*`, `SERVICE_RELATIONS.json` ;
- **graphes et inventaires** : `GLOBAL_GRAPH.json`, `GLOBAL_VIEW.json`, `GLOBAL_WORKSPACE.json`, `SUPRA_DEPENDENCY_GRAPH.json`, `SUPRA_SYMBOL_GRAPH.json`, `SUPRA_FUNCTIONAL_AUTHORITY*.json`, `SUPRA_FUNCTIONAL_FLOW*.json`, `NUCLEO_COMPONENT_INVENTORY.json` ;
- **diagnostic/build/recovery** : `SUPRA_BUILD_DIAGNOSTIC.json`, `SUPRA_BUILD_SETTINGS_DIAGNOSTIC.json`, `SUPRA_XCODE_LIST_DIAGNOSTIC.json`, `SUPRA_INDEX_*`, `SUPRA_STORAGE_*`, `SUPRA_*_RECOVERY.json`, `SUPRA_FULL_ENVIRONMENT_VERIFICATION_LATEST.json` ;
- **gouvernance/freezes/preuves** : `Governance/*.json`, `FREEZE_REGISTRY.json`, manifests de freeze, preuves sous `Artifacts/`, `Evidence/`, `_VERIFICATIONS/` et `SUPRA_E2E_PROOF_HARNESS_V1/` ;
- **configuration locale** : `opencode.json`, `.supra_node_manifest.json`, `.supra_node_status.json`, registres `.cannonico` et `.kernel`.

Ces fichiers ne doivent pas devenir 190 sources de vérité. Le RuntimeSnapshot doit enregistrer leur provenance, leur fraîcheur et les erreurs de lecture.

### 3.10 Scripts et launchers — liste active complète

```text
GO_SUPRA.sh
GO_SUPRA_COMPOSITION_ROOT_AUDIT.sh
GO_SUPRA_DISCOVER_INSTANTIATIONS.sh
GO_SUPRA_DISCOVER_SINGLETONS.sh
GO_SUPRA_EXPORT_COMPOSITION_FILES.sh
GO_SUPRA_EXTRACT_COMPOSITION_ROOT.sh
GO_SUPRA_FIX_MODEL.sh
GO_SUPRA_GLOBAL_AUDIT.sh
GO_SUPRA_INSTALL.sh
GO_SUPRA_INSTANCE_AUDIT.sh
GO_SUPRA_MEMORY_RECONNECT.sh
GO_SUPRA_MEMORY_WIRING_DISCOVERY.sh
GO_SUPRA_MISSION_TEST.sh
GO_SUPRA_PARALLEL_V1.sh
GO_SUPRA_RECOVERY.sh
GO_SUPRA_RUNTIME_BOOTSTRAP.sh
GO_SUPRA_VALIDATE.sh
GO_SUPRA_VALIDATE_V3.sh
GO_SUPRA_XCODE_RECOVERY.sh
Governance/validate_governance.sh
SUPRA_BOOTSTRAP_V3.sh
SUPRA_INSTALLER_V2.sh
SUPRA_NODE_STATUS.sh
SUPRA_NODE_UNINSTALL.sh
phase1_extract_models.sh
phase2_extract_bridges.sh
phase3_extract_globals.sh
```

`GO_SUPRA.sh` est le launcher opérationnel principal. Les launchers spécialisés restent des outils de validation/récupération ; ils ne doivent pas chacun amorcer une composition différente.

### 3.11 Dépendances

- Apple : SwiftUI, Foundation, Combine, AppKit, CryptoKit, CommonCrypto, CoreGraphics, UniformTypeIdentifiers, `os`, XCTest ;
- package local `SUPRA_AST_PLATFORM` : produits `SUPRAAST` et `supra-ast`, dépendant des modules hôte Xcode `SwiftParser` et `SwiftSyntax` via flags de toolchain ;
- adapters/contrats locaux : `CAnnoNicoContracts`, `NicoAppAdapter`, `PucheroMemoryAdapter`, `VideoSwapAdapter` ;
- services locaux : OpenCode, Ollama, Git et système de fichiers macOS.

La configuration Xcode et les Packages sont hors mutation pour cette mission.

---

## 4. Étude des trois générations

| Génération | Fonction | Architecture | UX/navigation | Qualité et réutilisabilité | Dette |
|---|---|---|---|---|---|
| Workspace V5 (`ContentView`) | vue panoramique historique : fichiers, projets, mémoire, chat, connaissance et commandes | très grande vue agrégatrice avec logique et sous-composants imbriqués | riche mais dense ; plusieurs paradigmes dans un même écran | excellente réserve de composants et de comportements éprouvés | monolithe, couplage UI/I/O, navigation parallèle, endpoints et actions intégrés |
| Executive Cockpit (`ExecutiveWindow` et vues Executive) | pilotage missions, décisions, continuité, preuves, synthèse exécutive | shell plus clair, sections spécialisées, stores dédiés | meilleure hiérarchie et meilleure aptitude à devenir le shell unique | maturité produit la plus élevée ; composants Mission/Decision réutilisables | états parfois distincts du Runtime, chevauchements entre cockpit/control centers |
| Runtime Dashboard (`RuntimeDiagnosticsView` et vues Runtime/Control Tower) | santé, boot, événements, providers, workers, métriques et diagnostic | collecte Runtime distribuée entre managers/services/registries | lisible pour l’opérationnel mais dupliquée dans plusieurs dashboards | diagnostics et preuves solides, bonne granularité | plusieurs représentations de santé, polling et snapshots concurrents |

### Conclusion comparative

- **Shell à garder :** Executive Cockpit / `ExecutiveWindow`.
- **Runtime à garder :** capacités de `RuntimeDiagnosticsView` et ses sources existantes.
- **Workspace à garder :** `SUPRAOSWorkspaceExplorerView`, enrichi seulement par adaptation des composants Workspace V5 utiles.
- **Workspace V5 :** source de composants, jamais quatrième shell.
- **Control Tower, Operational Control Center, Command Center et variantes :** sources temporaires, non destinations.

---

## 5. Doublons et dette

### 5.1 Doublons majeurs

1. **Racines et shells** : `ContentView`, `ExecutiveWindow`, `SUPRAOSProductRootView`, `SUPRAOperationalCoreView`, `SUPRAOSCommandCenterView`, `CommandCenterView`, `TotalControlTowerView`, `SupraControlCenterView`.
2. **Dashboards** : `DashboardView`, `SUPRAOSHomeView`, panneaux dashboard de `ContentView`, `SUPRAOperationalControlCenterView`, `SUPRAEnvironmentCommandCenterView`.
3. **Runtime/santé** : `RuntimeDiagnosticsView`, `RuntimeView`, `CockpitRuntimeView`, `HealthView`, `TotalControlTowerView`, `SUPRAOSLiveView`.
4. **Mission** : `MissionView`, `MissionCenterView`, `ExecutiveMissionControlView`, `SUPRAOSMissionCanvasView`, panneaux de `ContentView`.
5. **Décision** : `DecisionInboxView`, `DecisionAuthorityView`, `SUPRADecisionRoomView`.
6. **Memory/Knowledge** : `MemoryView`, `MultiMemoryView`, `SUPRAMemoryLensView`, `IntelligenceView`, `KnowledgeExplorer` et panneaux V5.
7. **Workspace/Universe/Twin** : plusieurs explorateurs et cartes représentant les mêmes ressources sous des taxonomies différentes.
8. **Stores et snapshots** : nombreux `ObservableObject` capables de publier des versions divergentes d’un même état.
9. **Design** : composants historiques locaux versus composants `SUPRAOS*`.

### 5.2 Dette technique

- source de vérité non unique et fraîcheur rarement explicite ;
- logique I/O et appels réseau/processus dans ou près des vues ;
- grandes vues monolithiques, particulièrement `ContentView` ;
- modèles sémantiquement proches mais non alignés ;
- multiples boucles de rafraîchissement/polling ;
- racines d’application et composition roots historiques encore visibles ;
- données de démonstration/fallback susceptibles de masquer une indisponibilité réelle ;
- JSON nombreux sans contrat transversal de provenance ;
- archives et snapshots proches du code actif ;
- baseline Git très sale, rendant l’attribution des changements difficile ;
- README/state/RFC canoniques manquants.

---

## 6. Matrice de fusion des 12 espaces

`REMOVE` signifie ici **retrait différé**, uniquement après preuve d’équivalence et absence de références.

| Espace cible | Décision | Sources conservées/fusionnées | Destination et justification |
|---|---|---|---|
| Dashboard | **KEEP + MERGE** | base canonique: Dashboard de `ExecutiveWindow`/Executive Cockpit; apports ciblés de `SUPRAOSHomeView` et cartes mûres de `DashboardView` | La destination reste explicitement le Dashboard Executive Cockpit dans `ExecutiveWindow`, alimenté par `RuntimeSnapshot`; les apports sont des composants, jamais un shell concurrent |
| Mission | **KEEP + MERGE** | `MissionCenterView`, `MissionDetailView`, `MissionTimelineView`, `MissionGraphView`, capacités d’`ExecutiveMissionControlView` et `SUPRAOSMissionCanvasView` | `Mission` canonique ; garder les flux exécutables existants, fusionner visualisations, retirer les listes concurrentes |
| Runtime | **KEEP + REWRITE (binding seulement)** | `RuntimeDiagnosticsView`, `RootCauseExplainerView`, `HealthView`, événements/metrics existants | Conserver l’UX diagnostique ; remplacer ses multiples sources observées par un binding `RuntimeSnapshot`, sans réécrire les collecteurs |
| Workspace | **KEEP + MERGE** | `SUPRAOSWorkspaceExplorerView`, `FileSystemCardView`, `ProjectsCardView`, indexation et cartes ciblées de `ContentView` | Explorateur unique ; les composants V5 sont adaptés, jamais embarqués comme un second dashboard |
| Knowledge | **MERGE** | `KnowledgeExplorer`, `IntelligenceView`, `MemoryView`, `MultiMemoryView`, `SUPRAMemoryLensView`, graphes/lineage | Espace Knowledge unique distinguant mémoire, objets, relations et provenance ; supprimer les navigations Memory autonomes après migration |
| Discovery | **MERGE** | capacités extraites de `WorkspaceDiscovery`, `SUPRAPluginDiscovery` et de la découverte Environment/Universe | Destination canonique: espace Discovery dans `ExecutiveWindow`; après extraction et parité, retrait différé du shell `SUPRAEnvironmentCommandCenterView`; aucune nouvelle capacité de scan |
| Decisions | **KEEP + MERGE** | `DecisionInboxView`, `DecisionDetailView`, `DecisionRow`, `DecisionAuthorityView`, capacités de `SUPRADecisionRoomView` | Inbox comme point d’entrée, détail/autorité fusionnés ; une seule mutation via `DecisionEngine` |
| Evidence | **KEEP + MERGE** | `EvidenceExplorerView`, `SUPRAMissionEvidenceLoader`, ArtifactReader, preuves Runtime/Freeze | Explorateur unique avec provenance ; intégrer les liens depuis Mission/Runtime plutôt que dupliquer les lecteurs |
| Providers | **MERGE** | `SUPRAProviderRegistry`, `SUPRAProviderBroker`, `SUPRAOllamaProvider`, OpenCode et providers Knowledge | État/configuration unique, lecture depuis ProviderEngine ; retirer les panneaux provider dupliqués |
| Reports | **MERGE** | `ReportKnowledgeProvider`, rapports/freeze existants, cartes de continuité | Index de rapports existants, filtré et lié aux preuves ; ne pas créer un nouveau générateur |
| Developer | **MERGE** | `WorkerPoolView`, graphes Runtime, scheduler, AST, diagnostics, `SUPRAResourceIntelligenceView` | Espace technique unique ; déplacer ici les panneaux non exécutifs des control towers |
| Settings | **KEEP + MERGE** | `SettingsView`, réglages OpenCode, chemins Runtime, permissions protégées | Réglages uniques ; aucune configuration dupliquée dans les écrans métier |

### Écrans/shells voués au retrait différé

Après validation de parité : `ContentView` comme racine, `CommandCenterView`, `SupraControlCenterView`, `TotalControlTowerView`, `SUPRAOSCommandCenterView`, `SUPRAOperationalCoreView` comme shell alternatif, `SUPRAOperationalControlCenterView`, `SUPRAEnvironmentCommandCenterView` et les anciennes vues Dashboard/Runtime devenues redondantes. Leurs composants internes utiles doivent d’abord être adaptés et couverts par tests.

---

## 7. Catalogue de consolidation

### 7.1 Composants conservés

- chaîne `SUPRAOperationalCoreApp` → `SUPRAOSProductRootView` → `ExecutiveWindow` ;
- `SUPRAOSDesignSystem` ;
- `MissionStore`, `DecisionStore`, `ConversationMemoryStore` derrière façades ;
- `RuntimeDiagnosticsView` et les collecteurs Runtime existants ;
- `SUPRAOSWorkspaceExplorerView`, Workspace index/graph/memory ;
- `DecisionInboxView` et composants de détail ;
- `EvidenceExplorerView` et loaders de preuves ;
- registries/brokers providers et workers ;
- CompositionRoot, Runtime graph/events/metrics/logger ;
- Knowledge providers et kernel existants.

### 7.2 Composants fusionnés

- cartes de Dashboard et de Control Tower vers Dashboard/Developer ;
- flux Mission des générations V5/Executive/Canvas vers Mission ;
- santé/boot/events/providers/workers vers Runtime ;
- mémoire, intelligence, graphes et lineage vers Knowledge ;
- discovery Workspace/Environment/Plugin vers Discovery ;
- inbox, authority et room vers Decisions ;
- preuves, freezes, rapports et continuité vers Evidence/Reports.

### 7.3 Composants supprimés — uniquement après migration

- shells alternatifs ;
- navigation parallèle ;
- stores UI dupliquant un domaine déjà couvert par le snapshot ;
- modèles de démonstration utilisés en production ;
- boucles de polling redondantes ;
- vues devenues de simples doublons.

Aucune suppression n’est autorisée tant que les critères de parité, tests, provenance et rollback ne sont pas satisfaits.

---

## 8. Architecture cible unique

```text
SUPRAOperationalCoreApp
└── SUPRAOSProductRootView
    └── ExecutiveWindow
        ├── Dashboard
        ├── Mission
        ├── Runtime
        ├── Workspace
        ├── Knowledge
        ├── Discovery
        ├── Decisions
        ├── Evidence
        ├── Providers
        ├── Reports
        ├── Developer
        └── Settings

SUPRACompositionRoot                    (owner unique)
└── RuntimeKernel
    ├── 11 Engine Facades
    ├── RuntimeSnapshotStore            (publication atomique)
    └── Existing adapters/services      (aucune duplication)
```

Règles :

1. une seule instanciation de chaque service stateful ;
2. aucune View ne lance directement un second Runtime ;
3. commandes émises vers les engines, lectures effectuées depuis le snapshot ;
4. chaque valeur possède provenance, horodatage et état de fraîcheur ;
5. une indisponibilité est affichée comme telle, jamais remplacée silencieusement par une démo ;
6. adapters temporaires marqués et retirables ;
7. aucune modification Xcode/Package dans la consolidation UI.

---

## 9. Runtime canonique

### 9.1 Contrat de snapshot

```swift
struct RuntimeSnapshot: Sendable, Codable {
    let schemaVersion: Int
    let revision: UInt64
    let generatedAt: Date
    let runtimeID: String

    let missions: MissionSnapshot
    let memory: MemorySnapshot
    let knowledge: KnowledgeSnapshot
    let decisions: DecisionSnapshot
    let discovery: DiscoverySnapshot
    let evidence: EvidenceSnapshot
    let providers: ProviderSnapshot
    let workspace: WorkspaceSnapshot
    let health: HealthSnapshot
    let recovery: RecoverySnapshot
    let freeze: FreezeSnapshot

    let provenance: [SnapshotProvenance]
    let freshness: [SnapshotFreshness]
    let warnings: [RuntimeWarning]
    let errors: [RuntimeErrorRecord]
}
```

Ce contrat est une cible d’architecture, pas une demande d’implémentation dans cette mission. La publication doit être atomique : une révision ne mélange jamais deux instants de collecte incompatibles. `schemaVersion` permet la migration ; `revision` ordonne les publications ; `generatedAt` et `freshness` empêchent une donnée ancienne d’apparaître comme actuelle.

### 9.2 Mapping des onze engines — façades de l’existant

| Façade cible | Implémentations existantes derrière la façade | Responsabilité |
|---|---|---|
| MissionEngine | `MissionStore`, `SUPRAMissionBroker`, `SUPRAMissionExecutor`, `SUPRAMissionObserver`, `SUPRAExecutionPipeline`, `AutoMissionQueue` | commandes et état Mission |
| MemoryEngine | `ConversationMemoryStore`, `MultiMemoryStore`, `WorkspaceMemory`, `ExecutiveMemory` | lecture/écriture mémoire avec provenance |
| KnowledgeEngine | `NOVAKnowledgeKernel`, `KnowledgeContextEngine`, graphes et providers Knowledge | objets, relations, lineage, contexte |
| DecisionEngine | `DecisionStore`, `SUPRADecisionEngine`, `SUPRADecisionAuthority` | inbox, arbitrage et statut |
| DiscoveryEngine | `WorkspaceDiscovery`, `SUPRAPluginDiscovery`, `SUPRAEnvironmentResolver` | résultats de découverte existants |
| EvidenceEngine | `ArtifactReader`, `SUPRAMissionEvidenceLoader`, loaders Runtime/Freeze | index et validation des preuves |
| ProviderEngine | `SUPRAProviderRegistry`, `SUPRAProviderBroker`, `SUPRAOllamaProvider`, OpenCode | disponibilité, sélection et métriques |
| WorkspaceEngine | `WorkspaceIndexer`, `WorkspaceKnowledgeGraph`, `WorkspaceGovernor`, `WorkspaceStatistics` | index, ressources et gouvernance |
| HealthEngine | `ExecutiveBootManager`, `RuntimeDataService`, `RuntimeMonitor`, `SUPRARuntimeMetrics` | santé agrégée et fraîcheur |
| RecoveryEngine | `ContinuityManager`, mécanismes/scripts de recovery observables | état, préconditions et preuves de récupération |
| FreezeEngine | registres/manifests Freeze, intégrité système, rapports de certification | état gelé, revision et conformité |

Les engines ne possèdent pas chacun une copie de données. Ils adaptent les commandes et contribuent à une publication par le `RuntimeSnapshotStore`.

---

## 10. Design System unique

La fondation est `SUPRAOSDesignSystem.swift`. Aucun second système de tokens ne doit être créé.

- **Palette :** couleurs sémantiques `supra*` existantes ; statut success/warning/error/info cohérent.
- **Typographie :** échelle unique (display, title, section, body, metadata, mono) ; mêmes poids et espacements dans les 12 espaces.
- **Iconographie :** SF Symbols, mapping stable par domaine ; une icône ne change pas de sens entre écrans.
- **Navigation :** sidebar unique d’`ExecutiveWindow`, 12 destinations, navigation contextuelle dans le panneau de contenu.
- **Hiérarchie :** titre, synthèse, actions, contenu, preuves et métadonnées dans cet ordre.
- **Grille :** grille adaptative unique, espacements et rayons issus des tokens `SUPRAOS`.
- **Composants :** réutiliser `SUPRAOSStatCard` et les cartes/pills/badges déjà présents ; convertir les variantes historiques par adapters/styles.
- **États :** loading, empty, stale, unavailable et error explicites ; jamais de faux “healthy”.
- **Accessibilité :** labels, contraste, navigation clavier, Dynamic Type et réductions de mouvement vérifiés.

---

## 11. Plan d’exécution séquentiel (sans implémentation)

### Étape 0 — Geler et rendre la baseline attribuable

Capturer status Git, build, tests, captures des trois générations et inventaire des routes. Ne pas nettoyer les changements préexistants.

### Étape 1 — Contrats et ownership

Documenter le contrat `RuntimeSnapshot`, les onze sous-snapshots, provenance/freshness/errors et le propriétaire unique `SUPRACompositionRoot`.

### Étape 2 — Adapters Runtime

Créer, lors d’une mission ultérieure, des adapters en lecture autour des stores/services existants. Aucun remplacement fonctionnel.

### Étape 3 — Publication atomique

Introduire un store de snapshot versionné ; comparer ses valeurs aux états historiques en mode shadow, sans changer l’UI.

### Étape 4 — Shell unique

Fixer `ExecutiveWindow` comme navigation unique et mapper les douze espaces sans retirer les anciennes routes.

### Étape 5 — Migration espace par espace

Ordre recommandé : Runtime → Dashboard → Mission → Decisions → Workspace → Knowledge → Evidence → Discovery → Providers → Reports → Developer → Settings. Chaque espace bascule séparément vers le snapshot.

### Étape 6 — Design System

Normaliser tokens et composants en conservant les comportements ; faire une validation visuelle par espace.

### Étape 7 — Parité et shadow validation

Comparer anciennes/nouvelles vues sur mêmes snapshots, événements et commandes. Mesurer écart, fraîcheur, latence et erreurs.

### Étape 8 — Retrait différé

Débrancher d’abord les routes alternatives ; observer ; supprimer ensuite seulement les shells et états devenus sans références.

### Étape 9 — Certification

Build/test complet, smoke Runtime réel, validation des missions/décisions/preuves, audit de singletons, captures finales et freeze.

Chaque étape doit être un lot réversible. Aucune étape ne doit ajouter une fonctionnalité.

---

## 12. Risques et mitigations

| Risque | Niveau | Mitigation |
|---|---|---|
| rupture d’un flux Runtime lors de l’unification | Critique | adapters en lecture, shadow mode, bascule domaine par domaine, rollback |
| divergence entre stores historiques et snapshot | Élevé | revision atomique, comparateur de parité, provenance/freshness obligatoires |
| double exécution mission/provider/worker | Critique | CompositionRoot owner unique, audit des singletons et tests d’idempotence |
| perte de composant mature pendant suppression | Élevé | inventaire des usages, extraction préalable, suppression différée |
| fallback/demo masque une panne réelle | Élevé | état `unavailable/stale/error` explicite, bannir fallback silencieux |
| régression UX due à une fusion trop large | Élevé | migration écran par écran, captures de référence, tests clavier/accessibilité |
| monolithe déplacé de `ContentView` vers un autre fichier | Élevé | frontières par espace et sous-vues, logique hors View |
| performance dégradée par snapshot global | Moyen/Élevé | diffs par domaine, cadence maîtrisée, mesure CPU/mémoire/latence |
| incompatibilité de schéma JSON | Élevé | `schemaVersion`, décodage tolérant, fixtures historiques |
| baseline Git dirty empêche l’attribution | Élevé | manifest de baseline et diff par lot ; ne jamais mélanger cleanup et consolidation |
| archives prises pour code actif | Moyen | exclusions explicites des backups/freezes/quarantaines |
| modification accidentelle Xcode/Package | Élevé | garde de chemin, revue diff et validation que ces fichiers sont inchangés |

---

## 13. Critères de validation

La consolidation est acceptée seulement si tous les points suivants sont prouvés :

1. un seul `@main` produit actif : `SUPRAOperationalCoreApp` ;
2. un seul shell visible : `ExecutiveWindow` ;
3. exactement douze destinations canoniques, sans quatrième dashboard ;
4. une seule instance stateful de chaque service Runtime ;
5. toutes les vues canoniques lisent un même `RuntimeSnapshot` révisionné ;
6. les onze domaines du snapshot sont présents et typés ;
7. chaque donnée critique expose source, date et fraîcheur ;
8. aucune commande Mission/Decision/Provider n’est exécutée deux fois ;
9. parité fonctionnelle des flux Mission, Decision, Workspace, Knowledge, Evidence et Runtime ;
10. indisponibilité OpenCode/Ollama/fichier représentée sans donnée fictive ;
11. routes historiques débranchées avant suppression physique ;
12. aucune régression de build ni des tests existants ;
13. tests ajoutés ultérieurement pour atomicité, monotonie des révisions, stale data, erreurs partielles et recovery ;
14. validation visuelle aux tailles de fenêtre minimales, nominales et larges ;
15. navigation clavier, VoiceOver labels, contraste et Dynamic Type vérifiés ;
16. CPU, mémoire et cadence de polling au moins équivalents à la baseline ;
17. aucun changement non requis à `SUPRA.xcodeproj`, aux Packages ou aux dépendances ;
18. aucun fichier de backup/freeze utilisé comme source Runtime active ;
19. rapport de diff démontrant que chaque composant supprimé a une destination ou une justification ;
20. rollback documenté et testé pour chaque lot ;
21. build Release signé et smoke test du launcher canonique ;
22. preuve finale qu’une seule application SUPRA Executive OS est livrée.

---

## 14. Conclusion

La version ultime de SUPRA ne nécessite pas un nouveau produit, mais une autorité claire. L’autorité d’interface doit être `ExecutiveWindow`; l’autorité de composition, `SUPRACompositionRoot`; l’autorité de lecture, un `RuntimeSnapshot` atomique partagé ; l’autorité visuelle, `SUPRAOSDesignSystem`.

La stratégie sûre est de conserver les implémentations mûres, de les placer derrière onze façades, de migrer les douze espaces un par un, puis de retirer les doublons uniquement après preuve de parité. Ce chemin produit une seule application cohérente sans casser le Runtime, sans créer une quatrième interface et sans introduire de nouvelle fonctionnalité.

---

## Annexe A — Périmètre de comptage reproductible

Les inventaires sont produits par `rg --files` depuis la racine. Cette commande respecte `.gitignore` et exclut donc implicitement les fichiers ignorés, caches et produits de build; elle ne décrit pas le disque brut. Le **corpus logique** de la mission est le corpus visible `rg --files`, avec exclusions documentées: le présent rapport est exclu de la baseline Markdown; les deux sentinelles `SUPRA_DEPENDENCY_GRAPH.EMPTY.json` et `SUPRA_SYMBOL_GRAPH.EMPTY.json` sont exclues du corpus JSON logique mais restent signalées. Ainsi: 887 fichiers logiques à la baseline d’audit, 190 JSON logiques et 153 Markdown préexistants. Le disque visible courant contient 192 `.json` et 154 `.md` avec les deux sentinelles et ce rapport. Les répertoires ignorés/build peuvent augmenter le nombre brut et ne sont pas couverts.

Commandes de reproduction :

```sh
rg --files
rg --files -g "*.json" | grep -v -E "SUPRA_(DEPENDENCY_GRAPH|SYMBOL_GRAPH)\.EMPTY\.json$"
rg --files -g "*.md" | grep -v "^ULTIMATE_CONSOLIDATION_REPORT\.md$"
```

## Annexe B — Déclarations Swift actives, type vers fichier

### B.1 Views SwiftUI

```text
CockpitRuntimeView → SUPRA/CockpitRuntimeView.swift
CommandCenterView → SUPRA/CommandCenterView.swift
CommandPalette → SUPRA/ExecutiveWindow.swift
ContentView → SUPRA/ContentView.swift
ContinuityView → SUPRA/ContinuityView.swift
ConversationTwinView → SUPRA/ConversationTwinView.swift
DashboardView → SUPRA/DashboardView.swift
DecisionAuthorityView → SUPRA/DecisionAuthorityView.swift
DecisionDetailView → SUPRA/DecisionDetailView.swift
DecisionInboxView → SUPRA/DecisionInboxView.swift
DecisionRow → SUPRA/DecisionRow.swift
EvidenceExplorerView → SUPRA/EvidenceExplorerView.swift
ExecutiveBootView → SUPRA/SUPRAOSProductRootView.swift
ExecutiveCockpit → SUPRA/ExecutiveWindow.swift
ExecutiveHeader → SUPRA/ExecutiveWindow.swift
ExecutiveInspector → SUPRA/ExecutiveWindow.swift
ExecutiveMissionControlView → SUPRA/ExecutiveMissionControlView.swift
ExecutiveNotifications → SUPRA/ExecutiveWindow.swift
ExecutivePanel → SUPRA/ExecutiveWindow.swift
ExecutiveSidebar → SUPRA/ExecutiveWindow.swift
ExecutiveStatusBar → SUPRA/ExecutiveWindow.swift
ExecutiveWindow → SUPRA/ExecutiveWindow.swift
ExecutiveWorkflowListView → SUPRA/ExecutiveWorkflowListView.swift
ExecutiveWorkspace → SUPRA/ExecutiveWindow.swift
FileSystemCardView → SUPRA/FileSystemCardView.swift
HealthView → SUPRA/HealthView.swift
IntelligenceView → SUPRA/IntelligenceView.swift
MemoryView → SUPRA/MemoryView.swift
MissionCenterView → SUPRA/MissionCenterView.swift
MissionCopilotView → SUPRA/MissionCopilotView.swift
MissionDetailView → SUPRA/MissionDetailView.swift
MissionGraphView → SUPRA/MissionGraphView.swift
MissionRow → SUPRA/MissionRow.swift
MissionTimelineView → SUPRA/MissionTimelineView.swift
MissionView → SUPRA/MissionView.swift
MultiMemoryView → SUPRA/MultiMemoryView.swift
ProjectsCardView → SUPRA/ProjectsCardView.swift
RootCauseExplainerView → SUPRA/RootCauseExplainerView.swift
RuntimeDiagnosticsView → SUPRA/RuntimeDiagnosticsView.swift
RuntimeView → SUPRA/RuntimeView.swift
SUPRAActionCard → SUPRA/SUPRACardSystemV1.swift
SUPRAAutonomyControlView → SUPRA/SUPRAAutonomyControlView.swift
SUPRABusinessDemoView → SUPRA/SUPRABusinessDemoView.swift
SUPRACard → SUPRA/SUPRACardSystemV1.swift
SUPRAChatView → SUPRA/SUPRAChatView.swift
SUPRACompanionView → SUPRA/SUPRACompanionView.swift
SUPRADecisionRoomView → SUPRA/SUPRADecisionRoomView.swift
SUPRAEnvironmentCommandCenterView → SUPRA/SUPRAEnvironmentCommandCenterView.swift
SUPRAEvolutionEngineView → SUPRA/SUPRAEvolutionEngineView.swift
SUPRAEvolutionRoomView → SUPRA/SUPRAEvolutionRoomView.swift
SUPRAExplainButton → SUPRA/SUPRAExplainLayer.swift
SUPRAImmersiveSpaceView → SUPRA/SUPRAImmersiveSpaceView.swift
SUPRAInfoRow → SUPRA/SUPRACardSystemV1.swift
SUPRALiveBoardsRootView → SUPRA/ContentView.swift
SUPRAMacPotentialMap → SUPRA/SUPRAMacPotentialMap.swift
SUPRAMemoryLensView → SUPRA/SUPRAMemoryLensView.swift
SUPRAMetricRow → SUPRA/SUPRACardSystemV1.swift
SUPRAOSBadge → SUPRA/SUPRAOSDesignSystem.swift
SUPRAOSButton → SUPRA/SUPRAOSDesignSystem.swift
SUPRAOSCard → SUPRA/SUPRAOSDesignSystem.swift
SUPRAOSCommandCenterView → SUPRA/SUPRAOSCommandCenterView.swift
SUPRAOSGlobalSearchView → SUPRA/SUPRAOSGlobalSearchView.swift
SUPRAOSGradientBackground → SUPRA/SUPRAOSDesignSystem.swift
SUPRAOSHomeView → SUPRA/SUPRAOSHomeView.swift
SUPRAOSLiveView → SUPRA/SUPRAOSLiveView.swift
SUPRAOSMissionCanvasView → SUPRA/SUPRAOSMissionCanvasView.swift
SUPRAOSProductRootView → SUPRA/SUPRAOSProductRootView.swift
SUPRAOSSectionHeader → SUPRA/SUPRAOSDesignSystem.swift
SUPRAOSStatCard → SUPRA/SUPRAOSDesignSystem.swift
SUPRAOSTwinCenterView → SUPRA/SUPRAOSTwinCenterView.swift
SUPRAOSUniverseView → SUPRA/SUPRAOSUniverseView.swift
SUPRAOSWorkspaceExplorerView → SUPRA/SUPRAOSWorkspaceExplorerView.swift
SUPRAOperationalControlCenterView → SUPRA/SUPRAOperationalControlCenterView.swift
SUPRAOperationalCoreView → SUPRA/SUPRAOperationalCoreView.swift
SUPRARecommendationCenter → SUPRA/SUPRARecommendationCenter.swift
SUPRAResourceIntelligenceView → SUPRA/SUPRAResourceIntelligenceView.swift
SUPRASpatialNavigatorView → SUPRA/SUPRASpatialNavigatorView.swift
SUPRAStatCard → SUPRA/SUPRACardSystemV1.swift
SUPRAStatusCard → SUPRA/SUPRACardSystemV1.swift
SUPRATimelineEntry → SUPRA/SUPRACardSystemV1.swift
SUPRAWorldMapView → SUPRA/SUPRAWorldMapView.swift
SettingsView → SUPRA/SettingsView.swift
SupraControlCenterView → SUPRA/SupraControlCenterView.swift
TotalControlTowerView → SUPRA/TotalControlTowerView.swift
WorkerPoolView → SUPRA/WorkerPoolView.swift
```

### B.2 ObservableObject / ViewModels / Stores / Managers

```text
BusinessWorker → SUPRA/SUPRAWorkerFabric.swift
CAnnoNicoSnapshotStore → SUPRA/CAnnoNicoSnapshotStore.swift
ContextEngine → SUPRA/ContextEngine.swift
ContinuityManager → SUPRA/ContinuityManager.swift
ControlCenterStore → SUPRA/ControlCenterStore.swift
ControlTowerState → SUPRA/ControlTowerState.swift
ConversationMemoryStore → SUPRA/ConversationMemoryStore.swift
DecisionStore → SUPRA/DecisionStore.swift
ExecutiveBootManager → SUPRA/ExecutiveBootManager.swift
ExecutiveCockpitFoundation → SUPRA/ExecutiveCockpitFoundation.swift
ExecutiveDemoMode → SUPRA/ExecutiveDemoMode.swift
ExecutiveGraph → SUPRA/ExecutiveGraph.swift
ExecutiveMemory → SUPRA/ExecutiveMemory.swift
ExecutiveMissionControlStore → SUPRA/ExecutiveMissionControlStore.swift
ExecutiveSearch → SUPRA/ExecutiveSearch.swift
ExecutiveTimeline → SUPRA/ExecutiveTimeline.swift
ExecutiveWorkflowRegistry → SUPRA/ExecutiveWorkflow.swift
KnowledgeContextEngine → SUPRA/KnowledgeContextEngine.swift
KnowledgeExplorer → SUPRA/KnowledgeExplorer.swift
KnowledgeGraph → SUPRA/KnowledgeGraph.swift
KnowledgeStatistics → SUPRA/KnowledgeStatistics.swift
MemoryWorker → SUPRA/SUPRAWorkerFabric.swift
MissionContext → SUPRA/MissionContext.swift
MissionStore → SUPRA/MissionStore.swift
MultiMemoryStore → SUPRA/MultiMemoryStore.swift
NOVAKnowledgeKernel → SUPRA/NOVAKnowledgeKernel.swift
OpenCodeBridge → SUPRA/OpenCodeBridge.swift
OpenCodeClient → SUPRA/OpenCodeClient.swift
OptimizationWorker → SUPRA/SUPRAWorkerFabric.swift
ProtectedFolderAccessCoordinator → SUPRA/ProtectedFolderAccessCoordinator.swift
RuntimeDataService → SUPRA/RuntimeDataService.swift
RuntimeGateway → SUPRA/RuntimeGateway.swift
RuntimeMonitor → SUPRA/RuntimeMonitor.swift
RuntimeWorker → SUPRA/SUPRAWorkerFabric.swift
SUPRABackgroundScheduler → SUPRA/SUPRABackgroundScheduler.swift
SUPRABusinessPlatform → SUPRA/SUPRABusinessPlatform.swift
SUPRACommandCenterState → SUPRA/SUPRACommandCenterState.swift
SUPRACompanionViewModel → SUPRA/SUPRACompanionView.swift
SUPRACompositionRoot → SUPRA/SUPRACompositionRoot.swift
SUPRADataTwin → SUPRA/SUPRADataTwin.swift
SUPRADeveloperTwin → SUPRA/SUPRADeveloperTwin.swift
SUPRAEnvironmentAutoMissions → SUPRA/SUPRAEnvironmentAutoMissions.swift
SUPRAEnvironmentResolver → SUPRA/SUPRAEnvironmentResolver.swift
SUPRAEnvironmentSnapshotStore → SUPRA/SUPRAEnvironmentSnapshotStore.swift
SUPRAEnvironmentWorldModel → SUPRA/SUPRAEnvironmentWorldModel.swift
SUPRAEvolutionEngine → SUPRA/SUPRAEvolutionEngine.swift
SUPRAExecutiveStore → SUPRA/ContentView.swift
SUPRAHardwareTwin → SUPRA/SUPRAHardwareTwin.swift
SUPRAIntelligenceEngine → SUPRA/SUPRAIntelligenceEngine.swift
SUPRAIntelligenceGraph → SUPRA/SUPRAIntelligenceGraph.swift
SUPRAMacPotential → SUPRA/SUPRAMacPotentialMap.swift
SUPRAMissionExecutor → SUPRA/SUPRAMissionExecutor.swift
SUPRAMissionObserver → SUPRA/SUPRAMissionObserver.swift
SUPRAMissionProposalEngine → SUPRA/SUPRAMissionProposalEngine.swift
SUPRANucleoOrchestrator → SUPRA/SUPRANucleoOrchestrator.swift
SUPRAOSFoundation → SUPRA/SUPRAOSFoundation.swift
SUPRAOptimizationCopilot → SUPRA/SUPRAOptimizationCopilot.swift
SUPRAPassiveRefreshCoordinator → SUPRA/SUPRAPassiveRefreshCoordinator.swift
SUPRARecommendationEngine → SUPRA/SUPRARecommendationCenter.swift
SUPRAResourceGovernor → SUPRA/SUPRAResourceGovernor.swift
SUPRAResourceIntelligence → SUPRA/SUPRAResourceIntelligenceView.swift
SUPRAResourceIntelligenceEngine → SUPRA/SUPRAResourceIntelligenceEngine.swift
SUPRASoftwareTwin → SUPRA/SUPRASoftwareTwin.swift
SUPRAWorkerFabric → SUPRA/SUPRAWorkerFabric.swift
SUPRAWorldMapState → SUPRA/SUPRAWorldMapView.swift
SUPRAWorldModel → SUPRA/SUPRAWorldModel.swift
TraceStore → SUPRA/SUPRANucleoOrchestrator.swift
TwinAnalytics → SUPRA/TwinAnalytics.swift
TwinBindings → SUPRA/TwinBindings.swift
TwinComparisonEngine → SUPRA/TwinComparison.swift
TwinExplorer → SUPRA/TwinExplorer.swift
TwinFactory → SUPRA/TwinFactory.swift
TwinLifecycleManager → SUPRA/TwinLifecycle.swift
TwinRegistry → SUPRA/TwinRegistry.swift
TwinRenderer → SUPRA/TwinRenderer.swift
TwinSynchronizer → SUPRA/TwinSynchronizer.swift
TwinUniverse → SUPRA/TwinUniverse.swift
UniverseDashboard → SUPRA/UniverseDashboard.swift
UniverseEngine → SUPRA/UniverseEngine.swift
UniverseGraph → SUPRA/UniverseGraph.swift
UniverseNavigator → SUPRA/UniverseNavigator.swift
UniverseSearch → SUPRA/UniverseSearch.swift
UniverseTimelineEngine → SUPRA/UniverseTimeline.swift
WorkspaceDiscovery → SUPRA/WorkspaceDiscovery.swift
WorkspaceGovernor → SUPRA/WorkspaceGovernor.swift
WorkspaceIndexer → SUPRA/WorkspaceIndexer.swift
WorkspaceKnowledgeGraph → SUPRA/WorkspaceKnowledgeGraph.swift
WorkspaceMemoryStore → SUPRA/WorkspaceMemory.swift
WorkspaceRecommendationEngine → SUPRA/WorkspaceRecommendation.swift
WorkspaceStatisticsService → SUPRA/WorkspaceStatistics.swift
CAnnoNicoSnapshotStore → SUPRA/CAnnoNicoSnapshotStore.swift
ContinuityManager → SUPRA/ContinuityManager.swift
ControlCenterStore → SUPRA/ControlCenterStore.swift
ConversationMemoryStore → SUPRA/ConversationMemoryStore.swift
DecisionStore → SUPRA/DecisionStore.swift
ExecutiveBootManager → SUPRA/ExecutiveBootManager.swift
ExecutiveMissionControlStore → SUPRA/ExecutiveMissionControlStore.swift
MissionStore → SUPRA/MissionStore.swift
MultiMemoryStore → SUPRA/MultiMemoryStore.swift
ProtectedFolderAccessCoordinator → SUPRA/ProtectedFolderAccessCoordinator.swift
RuntimeDataService → SUPRA/RuntimeDataService.swift
SUPRACompanionViewModel → SUPRA/SUPRACompanionView.swift
SUPRAEnvironmentSnapshotStore → SUPRA/SUPRAEnvironmentSnapshotStore.swift
SUPRAExecutiveStore → SUPRA/ContentView.swift
SUPRAPassiveRefreshCoordinator → SUPRA/SUPRAPassiveRefreshCoordinator.swift
TraceStore → SUPRA/SUPRANucleoOrchestrator.swift
TwinLifecycleManager → SUPRA/TwinLifecycle.swift
WorkspaceMemoryStore → SUPRA/WorkspaceMemory.swift
WorkspaceStatisticsService → SUPRA/WorkspaceStatistics.swift
```

### B.3 Modèles, services, Runtime, providers, workers et protocoles

```text
AccessError [enum] → SUPRA/ProtectedFolderAccessCoordinator.swift
AgentCommand [struct] → SUPRA/ControlTowerState.swift
AgentExecution [struct] → SUPRA/RuntimeModels.swift
AgentInfo [struct] → SUPRA/ControlTowerState.swift
AgentPerformanceSummary [struct] → SUPRA/RuntimeModels.swift
AgentResult [struct] → SUPRA/RuntimeModels.swift
ArtifactDiag [struct] → SUPRA/ContinuityManager.swift
ArtifactStatus [struct] → SUPRA/Snapshot.swift
AutoMissionQueue [struct] → SUPRA/AutoMissionQueue.swift
BackgroundTask [struct] → SUPRA/SUPRABackgroundScheduler.swift
BootPhase [enum] → SUPRA/ExecutiveBootManager.swift
BootState [enum] → SUPRA/ExecutiveBootManager.swift
BootStep [struct] → SUPRA/ExecutiveBootManager.swift
BootStepStatus [enum] → SUPRA/ExecutiveBootManager.swift
BottleneckEntry [struct] → SUPRA/RuntimeModels.swift
BuildArtifacts [struct] → SUPRA/ControlTowerState.swift
BuildDiagnostic [struct] → SUPRA/ControlTowerState.swift
BuildInfo [struct] → SUPRA/ControlTowerState.swift
BusinessWorker [class] → SUPRA/SUPRAWorkerFabric.swift
CAnnoNicoSnapshotState [struct] → SUPRA/CAnnoNicoSnapshotStore.swift
CAnnoNicoSnapshotStore [class] → SUPRA/CAnnoNicoSnapshotStore.swift
CPUMetrics [struct] → SUPRA/RuntimeModels.swift
CanonicalEnvironmentState [struct] → SUPRA/SUPRACanonicalWorldAccess.swift
CanonicalMemoryState [struct] → SUPRA/SUPRACanonicalWorldAccess.swift
CanonicalMissionState [struct] → SUPRA/SUPRACanonicalWorldAccess.swift
CanonicalMultiMemoryState [struct] → SUPRA/SUPRACanonicalWorldAccess.swift
CanonicalProjectState [struct] → SUPRA/SUPRACanonicalWorldAccess.swift
CanonicalResourceState [struct] → SUPRA/SUPRACanonicalWorldAccess.swift
CanonicalRuntimeState [struct] → SUPRA/SUPRACanonicalWorldAccess.swift
CockpitRuntimeView [struct] → SUPRA/CockpitRuntimeView.swift
CockpitState [struct] → SUPRA/ExecutiveCockpitFoundation.swift
CodingKeys [enum] → SUPRA/ControlTowerState.swift
CodingKeys [enum] → SUPRA/ExecutiveMissionControlModels.swift
CodingKeys [enum] → SUPRA/Models/SUPRARecord.swift
CodingKeys [enum] → SUPRA/Models/SUPRASection.swift
CodingKeys [enum] → SUPRA/RuntimeModels.swift
CodingKeys [enum] → SUPRA/SUPRAGabrielConductorRuntime.swift
CodingKeys [enum] → SUPRA/SUPRAOllamaProvider.swift
CommandCenterActions [struct] → SUPRA/SUPRACommandCenterState.swift
CommandCenterCannonico [struct] → SUPRA/SUPRACommandCenterState.swift
CommandCenterCopilot [struct] → SUPRA/SUPRACommandCenterState.swift
CommandCenterDecision [struct] → SUPRA/SUPRACommandCenterState.swift
CommandCenterIntelligence [struct] → SUPRA/SUPRACommandCenterState.swift
CommandCenterMissions [struct] → SUPRA/SUPRACommandCenterState.swift
CommandCenterMultiMemory [struct] → SUPRA/SUPRACommandCenterState.swift
CommandCenterResources [struct] → SUPRA/SUPRACommandCenterState.swift
CommandCenterRuntime [struct] → SUPRA/SUPRACommandCenterState.swift
CommandCenterSnapshot [struct] → SUPRA/SUPRACommandCenterState.swift
CommandCenterSystemHealth [struct] → SUPRA/SUPRACommandCenterState.swift
CompleteEnvironmentState [struct] → SUPRA/SUPRAEnvironmentWorldModel.swift
ContextQuery [struct] → SUPRA/WorkspaceModels.swift
ContextResult [struct] → SUPRA/WorkspaceModels.swift
ContextResultItem [struct] → SUPRA/WorkspaceModels.swift
ContinuityManager [class] → SUPRA/ContinuityManager.swift
ContinuityState [struct] → SUPRA/ContinuityManager.swift
ControlTowerState [class] → SUPRA/ControlTowerState.swift
ConversationKnowledgeProvider [class] → SUPRA/ConversationKnowledgeProvider.swift
ConversationTwinView [struct] → SUPRA/ConversationTwinView.swift
CriticalPathMetrics [struct] → SUPRA/RuntimeModels.swift
CustomerTwin [struct] → SUPRA/SUPRABusinessPlatform.swift
DashboardSnapshot [struct] → SUPRA/RuntimeModels.swift
DashboardWidget [struct] → SUPRA/UniverseDashboard.swift
DashboardWidgetType [enum] → SUPRA/UniverseDashboard.swift
DataSnapshot [struct] → SUPRA/SUPRADataTwin.swift
Decision [struct] → SUPRA/Decision.swift
DecisionAuthority [enum] → SUPRA/SUPRADecisionAuthority.swift
DecisionAuthorityView [struct] → SUPRA/DecisionAuthorityView.swift
DecisionCategory [enum] → SUPRA/SUPRADecisionAuthority.swift
DecisionDetailView [struct] → SUPRA/DecisionDetailView.swift
DecisionEvidence [struct] → SUPRA/SUPRADecisionAuthority.swift
DecisionHistory [struct] → SUPRA/SUPRABusinessPlatform.swift
DecisionImpact [enum] → SUPRA/SUPRADecisionAuthority.swift
DecisionInboxView [struct] → SUPRA/DecisionInboxView.swift
DecisionKnowledgeProvider [class] → SUPRA/DecisionKnowledgeProvider.swift
DecisionRow [struct] → SUPRA/DecisionRow.swift
DecisionStore [class] → SUPRA/DecisionStore.swift
DecisionVerdict [struct] → SUPRA/SUPRADecisionAuthority.swift
Delegation [struct] → SUPRA/RuntimeModels.swift
DelegationTrace [struct] → SUPRA/RuntimeModels.swift
Dependency [struct] → SUPRA/Mission.swift
DerivedDataInfo [struct] → SUPRA/ControlTowerState.swift
DeveloperSnapshot [struct] → SUPRA/SUPRADeveloperTwin.swift
DivergenceReport [struct] → SUPRA/ExecutiveBootManager.swift
EnvironmentHealth [struct] → SUPRA/SUPRABusinessPlatform.swift
EnvironmentSnapshotProgress [struct] → SUPRA/SUPRAEnvironmentSnapshotStore.swift
Evidence [struct] → SUPRA/Decision.swift
ExecutionGraph [struct] → SUPRA/RuntimeModels.swift
ExecutionGraphEdge [struct] → SUPRA/RuntimeModels.swift
ExecutionGraphNode [struct] → SUPRA/RuntimeModels.swift
ExecutionGraphSummary [struct] → SUPRA/RuntimeModels.swift
ExecutionRecord [struct] → SUPRA/SUPRAMissionExecutor.swift
ExecutionStatus [enum] → SUPRA/SUPRAMissionExecutor.swift
ExecutiveAgentSnapshot [struct] → SUPRA/ExecutiveMissionControlModels.swift
ExecutiveAgentStatePublishing [protocol] → SUPRA/ExecutiveMissionControlModels.swift
ExecutiveAgentStatus [enum] → SUPRA/ExecutiveMissionControlModels.swift
ExecutiveAlertKind [enum] → SUPRA/ExecutiveMissionControlModels.swift
ExecutiveAlertSeverity [enum] → SUPRA/ExecutiveMissionControlModels.swift
ExecutiveBootManager [class] → SUPRA/ExecutiveBootManager.swift
ExecutiveBuildStatus [enum] → SUPRA/ExecutiveMissionControlModels.swift
ExecutiveFreezeStatus [enum] → SUPRA/ExecutiveMissionControlModels.swift
ExecutiveHeartbeatPublishing [protocol] → SUPRA/ExecutiveMissionControlModels.swift
ExecutiveMissionControlStore [class] → SUPRA/ExecutiveMissionControlStore.swift
ExecutiveMissionControlView [struct] → SUPRA/ExecutiveMissionControlView.swift
ExecutiveMissionSnapshot [struct] → SUPRA/ExecutiveMissionControlModels.swift
ExecutiveProviderAdapter [protocol] → SUPRA/ExecutiveMissionControlModels.swift
ExecutiveProviderSnapshot [struct] → SUPRA/ExecutiveMissionControlModels.swift
ExecutiveRuntimeAlert [struct] → SUPRA/ExecutiveMissionControlModels.swift
ExecutiveRuntimeEvent [struct] → SUPRA/ExecutiveMissionControlModels.swift
ExecutiveRuntimeSnapshot [struct] → SUPRA/ExecutiveMissionControlModels.swift
ExecutiveWorkspace [struct] → SUPRA/ExecutiveWindow.swift
FileScanSnapshot [struct] → SUPRA/ConversationMemoryStore.swift
Filter [enum] → SUPRA/DecisionStore.swift
Filter [enum] → SUPRA/MissionStore.swift
FreezeMetadata [struct] → SUPRA/ExecutiveBootManager.swift
FreezeValidity [enum] → SUPRA/ExecutiveBootManager.swift
GitCommit [struct] → SUPRA/ControlTowerState.swift
GitKnowledgeProvider [class] → SUPRA/GitKnowledgeProvider.swift
GitReposInfo [struct] → SUPRA/RuntimeModels.swift
GovernanceIssue [struct] → SUPRA/WorkspaceGovernor.swift
GovernanceIssueType [enum] → SUPRA/WorkspaceGovernor.swift
GovernanceSeverity [enum] → SUPRA/WorkspaceGovernor.swift
GraphEdge [struct] → SUPRA/WorkspaceModels.swift
GraphMetrics [struct] → SUPRA/RuntimeModels.swift
GraphNode [struct] → SUPRA/WorkspaceModels.swift
HardwareSnapshot [struct] → SUPRA/SUPRAHardwareTwin.swift
HealthIndicator [struct] → SUPRA/RuntimeDiagnosticsView.swift
HealthIndicators [struct] → SUPRA/RuntimeModels.swift
HealthResponse [struct] → SUPRA/SUPRAChatRuntimeAdapter.swift
HealthView [struct] → SUPRA/HealthView.swift
HeavyProcess [struct] → SUPRA/RuntimeModels.swift
HistoryEntry [struct] → SUPRA/Decision.swift
HumanGate [enum] → SUPRA/Decision.swift
JSONRuntimeSource [class] → SUPRA/RuntimeEventSource.swift
KnowledgeAuthority [enum] → SUPRA/KnowledgeAuthority.swift
KnowledgeAuthorityRecord [struct] → SUPRA/KnowledgeAuthority.swift
KnowledgeBase [struct] → SUPRA/SUPRABusinessPlatform.swift
KnowledgeContextEngine [class] → SUPRA/KnowledgeContextEngine.swift
KnowledgeContextItem [struct] → SUPRA/KnowledgeContextEngine.swift
KnowledgeContextResult [struct] → SUPRA/KnowledgeContextEngine.swift
KnowledgeExplorer [class] → SUPRA/KnowledgeExplorer.swift
KnowledgeExplorerQuery [struct] → SUPRA/KnowledgeExplorer.swift
KnowledgeExplorerResult [struct] → SUPRA/KnowledgeExplorer.swift
KnowledgeGraph [class] → SUPRA/KnowledgeGraph.swift
KnowledgeGraphData [struct] → SUPRA/KnowledgeObject.swift
KnowledgeGraphStatistics [struct] → SUPRA/KnowledgeObject.swift
KnowledgeIdentity [struct] → SUPRA/KnowledgeIdentity.swift
KnowledgeIdentityRegistry [struct] → SUPRA/KnowledgeIdentity.swift
KnowledgeLineage [struct] → SUPRA/KnowledgeLineage.swift
KnowledgeLineageGraph [struct] → SUPRA/KnowledgeLineage.swift
KnowledgeObject [struct] → SUPRA/KnowledgeObject.swift
KnowledgeObjectType [enum] → SUPRA/KnowledgeObject.swift
KnowledgeProvider [protocol] → SUPRA/KnowledgeProvider.swift
KnowledgeRelation [struct] → SUPRA/KnowledgeRelation.swift
KnowledgeRelationship [struct] → SUPRA/KnowledgeRelationship.swift
KnowledgeRelationshipType [struct] → SUPRA/KnowledgeRelationship.swift
KnowledgeSource [struct] → SUPRA/KnowledgeSource.swift
KnowledgeSourceType [enum] → SUPRA/KnowledgeSource.swift
KnowledgeStatistics [class] → SUPRA/KnowledgeStatistics.swift
LastRuntimeMission [struct] → SUPRA/ControlTowerState.swift
LevelAssessment [struct] → SUPRA/RuntimeModels.swift
LogFilter [enum] → SUPRA/RuntimeDiagnosticsView.swift
MemorySourceInfo [struct] → SUPRA/MultiMemoryState.swift
MemoryWorker [class] → SUPRA/SUPRAWorkerFabric.swift
Mission [struct] → SUPRA/Mission.swift
MissionCenterMetrics [struct] → SUPRA/ControlTowerState.swift
MissionCenterView [struct] → SUPRA/MissionCenterView.swift
MissionContext [class] → SUPRA/MissionContext.swift
MissionContextRequest [struct] → SUPRA/MissionContext.swift
MissionContextResult [struct] → SUPRA/MissionContext.swift
MissionCopilotView [struct] → SUPRA/MissionCopilotView.swift
MissionCounts [struct] → SUPRA/RuntimeModels.swift
MissionDetailView [struct] → SUPRA/MissionDetailView.swift
MissionGraphMetrics [struct] → SUPRA/RuntimeModels.swift
MissionGraphView [struct] → SUPRA/MissionGraphView.swift
MissionOverview [struct] → SUPRA/SUPRABusinessPlatform.swift
MissionProposal [struct] → SUPRA/MissionProposal.swift
MissionRow [struct] → SUPRA/MissionRow.swift
MissionStore [class] → SUPRA/MissionStore.swift
MissionTimelineView [struct] → SUPRA/MissionTimelineView.swift
MissionValueMetrics [struct] → SUPRA/SUPRAMonetizationEngine.swift
MissionView [struct] → SUPRA/MissionView.swift
Mode [enum] → SUPRA/MissionCenterView.swift
MultiMemorySnapshot [struct] → SUPRA/MultiMemoryState.swift
NOVAKnowledgeKernel [class] → SUPRA/NOVAKnowledgeKernel.swift
NavigationPath [struct] → SUPRA/UniverseNavigator.swift
NextAction [struct] → SUPRA/Decision.swift
NodeStatus [enum] → SUPRA/SUPRARuntimeGraph.swift
NodeType [enum] → SUPRA/SUPRARuntimeGraph.swift
NucleoExecutor [enum] → SUPRA/SUPRANucleoOrchestrator.swift
NucleoHealth [struct] → SUPRA/SUPRANucleoOrchestrator.swift
Objective [struct] → SUPRA/Mission.swift
ObservationEvent [struct] → SUPRA/SUPRAMissionObserver.swift
ObservationType [enum] → SUPRA/SUPRAMissionObserver.swift
OllamaGenerateRequest [struct] → SUPRA/SUPRAOllamaProvider.swift
OllamaGenerateResponse [struct] → SUPRA/SUPRAOllamaProvider.swift
OpenCodeRuntimeSource [class] → SUPRA/RuntimeEventSource.swift
OptimizationWorker [class] → SUPRA/SUPRAWorkerFabric.swift
PDFKnowledgeProvider [class] → SUPRA/PDFKnowledgeProvider.swift
ParallelizationMetrics [struct] → SUPRA/RuntimeModels.swift
PermissionState [enum] → SUPRA/ProtectedFolderAccessCoordinator.swift
PipelineMetrics [struct] → SUPRA/RuntimeModels.swift
PipelineStepState [struct] → SUPRA/ContinuityManager.swift
Priority [enum] → SUPRA/Decision.swift
Priority [enum] → SUPRA/Mission.swift
ProjectsInfo [struct] → SUPRA/RuntimeModels.swift
ProtectedFolderAccessCoordinator [class] → SUPRA/ProtectedFolderAccessCoordinator.swift
ProtectedFolderEntry [struct] → SUPRA/ProtectedFolderAccessCoordinator.swift
ProtectedFolderSnapshot [struct] → SUPRA/ProtectedFolderAccessCoordinator.swift
ProviderMetrics [struct] → SUPRA/RuntimeModels.swift
ProviderMetricsAggregate [struct] → SUPRA/RuntimeModels.swift
ProviderMetricsEntry [struct] → SUPRA/RuntimeModels.swift
ProviderStatus [struct] → SUPRA/RuntimeModels.swift
ProviderUtilization [struct] → SUPRA/RuntimeModels.swift
RecommendationAction [enum] → SUPRA/WorkspaceRecommendation.swift
RecommendationPriority [enum] → SUPRA/WorkspaceRecommendation.swift
RecoverableConfidence [enum] → SUPRA/RuntimeModels.swift
RefreshState [enum] → SUPRA/RuntimeModels.swift
RelationType [enum] → SUPRA/KnowledgeRelation.swift
ReportKnowledgeProvider [class] → SUPRA/ReportKnowledgeProvider.swift
ResourceMetrics [struct] → SUPRA/RuntimeModels.swift
ResourceSnapshot [struct] → SUPRA/SUPRAResourceGovernor.swift
RuntimeConnectionState [enum] → SUPRA/RuntimeConnectionState.swift
RuntimeData [struct] → SUPRA/RuntimeModels.swift
RuntimeDataService [class] → SUPRA/RuntimeDataService.swift
RuntimeDiagnosticsView [struct] → SUPRA/RuntimeDiagnosticsView.swift
RuntimeEvent [struct] → SUPRA/RuntimeEvent.swift
RuntimeEventType [enum] → SUPRA/RuntimeEvent.swift
RuntimeGateway [class] → SUPRA/RuntimeGateway.swift
RuntimeGatewayEvent [enum] → SUPRA/RuntimeGateway.swift
RuntimeHealth [struct] → SUPRA/RuntimeHealth.swift
RuntimeMetrics [struct] → SUPRA/RuntimeModels.swift
RuntimeMonitor [class] → SUPRA/RuntimeMonitor.swift
RuntimeSmokeTest [struct] → SUPRA/ControlTowerState.swift
RuntimeSourceMode [enum] → SUPRA/RuntimeSourceProtocol.swift
RuntimeSourceProtocol [protocol] → SUPRA/RuntimeSourceProtocol.swift
RuntimeStatus [struct] → SUPRA/RuntimeGateway.swift
RuntimeTrace [struct] → SUPRA/RuntimeModels.swift
RuntimeView [struct] → SUPRA/RuntimeView.swift
RuntimeWorker [class] → SUPRA/SUPRAWorkerFabric.swift
SUPRAActionRuntime [enum] → SUPRA/ContentView.swift
SUPRABackgroundScheduler [class] → SUPRA/SUPRABackgroundScheduler.swift
SUPRACapability [enum] → SUPRA/SUPRAProviderProtocols.swift
SUPRACapabilityBroker [class] → SUPRA/SUPRACapabilityBroker.swift
SUPRAChatExecutionState [enum] → SUPRA/SUPRAChatView.swift
SUPRAChatRuntimeAdapter [class] → SUPRA/SUPRAChatRuntimeAdapter.swift
SUPRAChatRuntimeError [enum] → SUPRA/SUPRAChatRuntimeAdapter.swift
SUPRAChatRuntimeHealthState [enum] → SUPRA/SUPRAChatView.swift
SUPRAChatRuntimeProtocol [protocol] → SUPRA/SUPRAChatRuntimeAdapter.swift
SUPRACommandCenterState [class] → SUPRA/SUPRACommandCenterState.swift
SUPRACompanionViewModel [class] → SUPRA/SUPRACompanionView.swift
SUPRADataTwin [class] → SUPRA/SUPRADataTwin.swift
SUPRADecisionEngine [class] → SUPRA/SUPRADecisionEngine.swift
SUPRADecisionInboxLiveView [struct] → SUPRA/ContentView.swift
SUPRADecisionRoomView [struct] → SUPRA/SUPRADecisionRoomView.swift
SUPRADeveloperTwin [class] → SUPRA/SUPRADeveloperTwin.swift
SUPRAEnvironmentAutoMissions [class] → SUPRA/SUPRAEnvironmentAutoMissions.swift
SUPRAEnvironmentSnapshotStore [class] → SUPRA/SUPRAEnvironmentSnapshotStore.swift
SUPRAEnvironmentWorldModel [class] → SUPRA/SUPRAEnvironmentWorldModel.swift
SUPRAEvent [struct] → SUPRA/SUPRARuntimeLogger.swift
SUPRAExecutionContext [struct] → SUPRA/SUPRAProviderProtocols.swift
SUPRAExecutionMode [enum] → SUPRA/SUPRAMissionBroker.swift
SUPRAExecutionPipeline [class] → SUPRA/SUPRAExecutionPipeline.swift
SUPRAExecutionPlan [struct] → SUPRA/SUPRAMissionBroker.swift
SUPRAExecutionRequest [struct] → SUPRA/SUPRAProviderProtocols.swift
SUPRAExecutionSlot [struct] → SUPRA/SUPRAScheduler.swift
SUPRAExecutiveModel [struct] → SUPRA/ContentView.swift
SUPRAExecutor [protocol] → SUPRA/SUPRAProviderProtocols.swift
SUPRAGabrielConductorRuntime [enum] → SUPRA/SUPRAGabrielConductorRuntime.swift
SUPRAGabrielConductorSnapshot [struct] → SUPRA/SUPRAGabrielConductorRuntime.swift
SUPRAGabrielWorkerSnapshot [struct] → SUPRA/SUPRAGabrielConductorRuntime.swift
SUPRAHardwareTwin [class] → SUPRA/SUPRAHardwareTwin.swift
SUPRAHumanStage [enum] → SUPRA/Models/SUPRAHumanStage.swift
SUPRAIntelligenceState [struct] → SUPRA/SUPRAIntelligenceState.swift
SUPRALiveBoardsModel [class] → SUPRA/ContentView.swift
SUPRALiveSnapshot [struct] → SUPRA/ContentView.swift
SUPRAMetricPoint [struct] → SUPRA/SUPRARuntimeMetrics.swift
SUPRAMissionBroker [class] → SUPRA/SUPRAMissionBroker.swift
SUPRAMissionExecutor [class] → SUPRA/SUPRAMissionExecutor.swift
SUPRAMissionObserver [class] → SUPRA/SUPRAMissionObserver.swift
SUPRAMissionProposalEngine [class] → SUPRA/SUPRAMissionProposalEngine.swift
SUPRAModelEntry [struct] → SUPRA/SUPRAModelRegistry.swift
SUPRAModelRegistry [class] → SUPRA/SUPRAModelRegistry.swift
SUPRAOSMissionCanvasView [struct] → SUPRA/SUPRAOSMissionCanvasView.swift
SUPRAOSTwinCenterView [struct] → SUPRA/SUPRAOSTwinCenterView.swift
SUPRAOSUniverseView [struct] → SUPRA/SUPRAOSUniverseView.swift
SUPRAOSWorkspaceExplorerView [struct] → SUPRA/SUPRAOSWorkspaceExplorerView.swift
SUPRAOllamaProvider [class] → SUPRA/SUPRAOllamaProvider.swift
SUPRAOrchestrationAction [enum] → SUPRA/SUPRADecisionEngine.swift
SUPRAOrchestrationDecision [struct] → SUPRA/SUPRADecisionEngine.swift
SUPRAOrchestrationExecutor [class] → SUPRA/SUPRAExecutor.swift
SUPRAOrchestrationStep [struct] → SUPRA/SUPRADecisionEngine.swift
SUPRAPassiveRefreshCoordinator [class] → SUPRA/SUPRAPassiveRefreshCoordinator.swift
SUPRAPipelineStage [enum] → SUPRA/SUPRARuntimeLogger.swift
SUPRAPlugin [protocol] → SUPRA/SUPRAPluginRegistry.swift
SUPRAPricingModel [struct] → SUPRA/SUPRAMonetizationEngine.swift
SUPRAProvider [protocol] → SUPRA/SUPRAProviderProtocols.swift
SUPRAProviderBroker [class] → SUPRA/SUPRAProviderBroker.swift
SUPRAProviderConfiguration [struct] → SUPRA/SUPRAProviderProtocols.swift
SUPRAProviderError [enum] → SUPRA/SUPRAProviderBroker.swift
SUPRAProviderMetrics [struct] → SUPRA/SUPRARuntimeMetrics.swift
SUPRAProviderModelDeclaration [struct] → SUPRA/SUPRAPluginDiscovery.swift
SUPRAProviderPlugin [protocol] → SUPRA/SUPRAPluginDiscovery.swift
SUPRAProviderPluginDeclaration [struct] → SUPRA/SUPRAPluginDiscovery.swift
SUPRAProviderPluginRegistry [class] → SUPRA/SUPRAPluginDiscovery.swift
SUPRAProviderPowerMetadata [struct] → SUPRA/SUPRAProviderRegistry.swift
SUPRAProviderRegistry [class] → SUPRA/SUPRAProviderRegistry.swift
SUPRAProviderResponse [struct] → SUPRA/SUPRAProviderProtocols.swift
SUPRAProviderSelection [struct] → SUPRA/SUPRARoutingPolicy.swift
SUPRAProviderType [enum] → SUPRA/SUPRAProviderProtocols.swift
SUPRARecord [struct] → SUPRA/Models/SUPRARecord.swift
SUPRARuntimeEdge [struct] → SUPRA/SUPRARuntimeGraph.swift
SUPRARuntimeEvent [struct] → SUPRA/SUPRARuntimeEvents.swift
SUPRARuntimeEventType [enum] → SUPRA/SUPRARuntimeEvents.swift
SUPRARuntimeEvents [class] → SUPRA/SUPRARuntimeEvents.swift
SUPRARuntimeGraph [class] → SUPRA/SUPRARuntimeGraph.swift
SUPRARuntimeLogger [class] → SUPRA/SUPRARuntimeLogger.swift
SUPRARuntimeMetrics [class] → SUPRA/SUPRARuntimeMetrics.swift
SUPRARuntimeNode [struct] → SUPRA/SUPRARuntimeGraph.swift
SUPRARuntimeRegistry [class] → SUPRA/SUPRARuntimeRegistry.swift
SUPRAScheduler [class] → SUPRA/SUPRAScheduler.swift
SUPRASection [struct] → SUPRA/Models/SUPRASection.swift
SUPRASoftwareTwin [class] → SUPRA/SUPRASoftwareTwin.swift
SUPRASource [struct] → SUPRA/Models/SUPRASource.swift
SUPRAStructureMode [enum] → SUPRA/Models/SUPRAStructureMode.swift
SUPRATransmissionLocksSnapshot [struct] → SUPRA/SUPRATransmissionLocks.swift
SUPRAUnderstanding [struct] → SUPRA/SUPRADecisionEngine.swift
SUPRAWorkerFabric [class] → SUPRA/SUPRAWorkerFabric.swift
SUPRAWorkspaceLiveView [struct] → SUPRA/ContentView.swift
SUPRAWorldMapState [class] → SUPRA/SUPRAWorldMapView.swift
SUPRAWorldModel [class] → SUPRA/SUPRAWorldModel.swift
SUPRAWorldSnapshot [struct] → SUPRA/SUPRAWorldModel.swift
SampleState [enum] → SUPRA/RuntimeModels.swift
ScanMode [enum] → SUPRA/SUPRAEnvironmentSnapshotStore.swift
ScoredObject [struct] → SUPRA/KnowledgeContextEngine.swift
ServicesInfo [struct] → SUPRA/RuntimeModels.swift
SlotStatus [enum] → SUPRA/SUPRAScheduler.swift
Snapshot [struct] → SUPRA/Snapshot.swift
SoftwareApplication [struct] → SUPRA/SUPRASoftwareTwin.swift
SoftwareSnapshot [struct] → SUPRA/SUPRASoftwareTwin.swift
Sort [enum] → SUPRA/DecisionStore.swift
Sort [enum] → SUPRA/MissionStore.swift
SourceState [enum] → SUPRA/SUPRAEnvironmentResolver.swift
Status [enum] → SUPRA/Decision.swift
Status [enum] → SUPRA/Mission.swift
StepStatus [enum] → SUPRA/ContinuityManager.swift
StorageInfo [struct] → SUPRA/RuntimeModels.swift
SyncChange [struct] → SUPRA/TwinSynchronizer.swift
SyncChangeType [enum] → SUPRA/TwinSynchronizer.swift
SystemMetricState [enum] → SUPRA/RuntimeModels.swift
SystemMetricsSnapshot [struct] → SUPRA/RuntimeModels.swift
Task [struct] → SUPRA/Mission.swift
TimelineEntry [struct] → SUPRA/Mission.swift
TimelineEvent [struct] → SUPRA/ExecutiveTimeline.swift
TimelineEventType [enum] → SUPRA/ExecutiveTimeline.swift
TowerActiveAgents [struct] → SUPRA/ControlTowerState.swift
TowerBuilds [struct] → SUPRA/ControlTowerState.swift
TowerGitState [struct] → SUPRA/ControlTowerState.swift
TowerMissionItem [struct] → SUPRA/ControlTowerState.swift
TowerMissions [struct] → SUPRA/ControlTowerState.swift
TowerNextAction [struct] → SUPRA/ControlTowerState.swift
TowerProcesses [struct] → SUPRA/ControlTowerState.swift
TowerReferences [struct] → SUPRA/ControlTowerState.swift
TowerStatus [struct] → SUPRA/ControlTowerState.swift
TowerStatusMeta [struct] → SUPRA/ControlTowerState.swift
TowerSystemHealth [struct] → SUPRA/ControlTowerState.swift
TowerWarning [struct] → SUPRA/ControlTowerState.swift
TraceStep [struct] → SUPRA/RuntimeModels.swift
TransmissionDecision [struct] → SUPRA/SUPRATransmissionContract.swift
TwinAnalytics [class] → SUPRA/TwinAnalytics.swift
TwinAnalyticsSnapshot [struct] → SUPRA/TwinAnalytics.swift
TwinBinding [struct] → SUPRA/TwinBindings.swift
TwinBindings [class] → SUPRA/TwinBindings.swift
TwinBlueprint [struct] → SUPRA/TwinFactory.swift
TwinComparison [struct] → SUPRA/TwinComparison.swift
TwinComparisonEngine [class] → SUPRA/TwinComparison.swift
TwinDifference [struct] → SUPRA/TwinComparison.swift
TwinExplorer [class] → SUPRA/TwinExplorer.swift
TwinExplorerQuery [struct] → SUPRA/TwinExplorer.swift
TwinExplorerResult [struct] → SUPRA/TwinExplorer.swift
TwinFactory [class] → SUPRA/TwinFactory.swift
TwinIdentity [struct] → SUPRA/TwinIdentity.swift
TwinLifecycle [struct] → SUPRA/TwinLifecycle.swift
TwinLifecycleEvent [enum] → SUPRA/TwinLifecycle.swift
TwinLifecycleManager [class] → SUPRA/TwinLifecycle.swift
TwinRegistry [class] → SUPRA/TwinRegistry.swift
TwinRenderLayout [struct] → SUPRA/TwinRenderer.swift
TwinRenderedEdge [struct] → SUPRA/TwinRenderer.swift
TwinRenderedNode [struct] → SUPRA/TwinRenderer.swift
TwinRenderer [class] → SUPRA/TwinRenderer.swift
TwinStatus [enum] → SUPRA/TwinIdentity.swift
TwinSynchronizer [class] → SUPRA/TwinSynchronizer.swift
TwinTransitionRecord [struct] → SUPRA/TwinLifecycle.swift
TwinType [enum] → SUPRA/TwinIdentity.swift
TwinUniverse [class] → SUPRA/TwinUniverse.swift
TwinVersionRecord [struct] → SUPRA/TwinLifecycle.swift
TwinVisualConfig [struct] → SUPRA/TwinRenderer.swift
UniverseDashboard [class] → SUPRA/UniverseDashboard.swift
UniverseDashboardSnapshot [struct] → SUPRA/UniverseDashboard.swift
UniverseEngine [class] → SUPRA/UniverseEngine.swift
UniverseGraph [class] → SUPRA/UniverseGraph.swift
UniverseGraphEdge [struct] → SUPRA/UniverseGraph.swift
UniverseGraphNode [struct] → SUPRA/UniverseGraph.swift
UniverseMode [enum] → SUPRA/UniverseEngine.swift
UniverseNavigator [class] → SUPRA/UniverseNavigator.swift
UniverseSearch [class] → SUPRA/UniverseSearch.swift
UniverseSearchResult [struct] → SUPRA/UniverseSearch.swift
UniverseSearchScope [enum] → SUPRA/UniverseSearch.swift
UniverseState [struct] → SUPRA/TwinUniverse.swift
UniverseTimelineEngine [class] → SUPRA/UniverseTimeline.swift
UniverseTimelineEvent [struct] → SUPRA/UniverseTimeline.swift
UniverseTimelineEventType [enum] → SUPRA/UniverseTimeline.swift
WorkerPermission [enum] → SUPRA/SUPRAWorkerFabric.swift
WorkerPoolView [struct] → SUPRA/WorkerPoolView.swift
WorkerProtocol [protocol] → SUPRA/SUPRAWorkerFabric.swift
WorkerResult [struct] → SUPRA/SUPRAWorkerFabric.swift
WorkerStatus [enum] → SUPRA/SUPRAWorkerFabric.swift
WorkerSummary [struct] → SUPRA/RuntimeModels.swift
WorkspaceConfiguration [struct] → SUPRA/WorkspaceConfiguration.swift
WorkspaceDiscovery [class] → SUPRA/WorkspaceDiscovery.swift
WorkspaceGovernor [class] → SUPRA/WorkspaceGovernor.swift
WorkspaceGraph [struct] → SUPRA/WorkspaceModels.swift
WorkspaceIndex [struct] → SUPRA/WorkspaceModels.swift
WorkspaceIndexer [class] → SUPRA/WorkspaceIndexer.swift
WorkspaceKnowledgeGraph [class] → SUPRA/WorkspaceKnowledgeGraph.swift
WorkspaceMemory [struct] → SUPRA/WorkspaceModels.swift
WorkspaceMemoryEntry [struct] → SUPRA/WorkspaceModels.swift
WorkspaceMemoryStore [class] → SUPRA/WorkspaceMemory.swift
WorkspaceMetadata [struct] → SUPRA/WorkspaceModels.swift
WorkspaceObject [struct] → SUPRA/WorkspaceModels.swift
WorkspaceObjectFactory [actor] → SUPRA/WorkspaceObject.swift
WorkspaceObjectType [enum] → SUPRA/WorkspaceModels.swift
WorkspaceRecommendation [struct] → SUPRA/WorkspaceRecommendation.swift
WorkspaceRecommendationEngine [class] → SUPRA/WorkspaceRecommendation.swift
WorkspaceRelation [struct] → SUPRA/WorkspaceModels.swift
WorkspaceRuntimeModule [enum] → SUPRA/SUPRAOSWorkspaceExplorerView.swift
WorkspaceStatistics [struct] → SUPRA/WorkspaceModels.swift
WorkspaceStatisticsService [class] → SUPRA/WorkspaceStatistics.swift
WorldDecisionSection [struct] → SUPRA/SUPRAWorldModel.swift
WorldIntelligenceSection [struct] → SUPRA/SUPRAWorldModel.swift
WorldMemorySection [struct] → SUPRA/SUPRAWorldModel.swift
WorldMissionSection [struct] → SUPRA/SUPRAWorldModel.swift
WorldResourceSection [struct] → SUPRA/SUPRAWorldModel.swift
WorldRuntimeSection [struct] → SUPRA/SUPRAWorldModel.swift
XcodeInfo [struct] → SUPRA/RuntimeModels.swift
XcodeStatus [enum] → SUPRA/RuntimeModels.swift
```

### B.4 APIs et frontières

- `OpenCodeClient`, `OpenCodeBridge` → `SUPRA/OpenCodeClient.swift`, `SUPRA/OpenCodeBridge.swift`.
- `OpenCodeRuntimeSource` (placeholder/intégration préparée) → `SUPRA/RuntimeEventSource.swift`.
- `SUPRAChatRuntimeAdapter` (HTTP local health) → `SUPRA/SUPRAChatRuntimeAdapter.swift`.
- client chat `/v1/chat` → `SUPRA/ContentView.swift`.
- `SUPRAOllamaProvider` (`/api/tags`, `/api/generate`) → `SUPRA/SUPRAOllamaProvider.swift`.
- `GitKnowledgeProvider` (`Process`/git) → `SUPRA/GitKnowledgeProvider.swift`.
- fichiers/artefacts → `SUPRA/ArtifactReader.swift`, `SUPRA/Infrastructure/SUPRAMissionEvidenceLoader.swift`, `SUPRA/ProtectedFolderAccessCoordinator.swift`.
- macOS/AppKit/processus → `SUPRA/RuntimeDataService.swift`, `SUPRA/SUPRAResourceGovernor.swift`, `SUPRA/ContentView.swift`.

## Annexe C — 190 JSON du corpus logique

Deux sentinelles présentes mais hors total logique: `SUPRA_DEPENDENCY_GRAPH.EMPTY.json`, `SUPRA_SYMBOL_GRAPH.EMPTY.json`.

```text
.supra_node_manifest.json
.supra_node_status.json
Artifacts/ENGINE_REGISTRY.json
Artifacts/SUPRA_AUTONOMOUS_NODE_PROOF_AND_FREEZE_V1_20260725_031618/freeze_manifest.json
Artifacts/SUPRA_ENVIRONMENT_TWIN_METRICS.json
CANNO_REGISTRY.json
CANNO_RELATIONS.json
CANONICAL_ADAPTERS.json
CANONICAL_BRIDGES.json
CANONICAL_MODULES.json
CANONICAL_PACKAGES.json
CANONICAL_PROJECTS.json
CANONICAL_REGISTRY.json
CANONICAL_RUNTIME.json
CANONICAL_SERVICES.json
CANONICAL_WORKERS.json
CONTROL_TOWER_STATUS.json
DUPLICATE_REGISTRY.json
ENVIRONMENT_INDEX.json
FREEZE_REGISTRY.json
FREEZE_SUPRA_ARCHITECTURE_INDEX_20260723T104017Z/FREEZE_MANIFEST.json
FREEZE_SUPRA_ARCHITECTURE_INDEX_20260723T104017Z/SUPRA_ARCHITECTURE_INDEX.json
FREEZE_SUPRA_FUNCTIONAL_AUTHORITY_20260723T105323Z/FREEZE_MANIFEST.json
FREEZE_SUPRA_FUNCTIONAL_AUTHORITY_20260723T105323Z/SUPRA_FUNCTIONAL_AUTHORITY_RECONCILED.json
FREEZE_SUPRA_GRAPHS_20260723T103701Z/FREEZE_MANIFEST.json
FREEZE_SUPRA_GRAPHS_20260723T103701Z/SUPRA_DEPENDENCY_GRAPH.json
FREEZE_SUPRA_GRAPHS_20260723T103701Z/SUPRA_RUNTIME_GRAPH.json
FREEZE_SUPRA_GRAPHS_20260723T103701Z/SUPRA_SYMBOL_GRAPH.json
FREEZE_SUPRA_PRODUCT_BUILD_20260723T120033Z/FREEZE_MANIFEST.json
FREEZE_SUPRA_PRODUCT_BUILD_20260723T120033Z/SUPRA_SYMLINK_OVERLAY_BUILD.json
FREEZE_SUPRA_RUNTIME_PROOF_20260723T120605Z/FREEZE_MANIFEST.json
FREEZE_SUPRA_RUNTIME_PROOF_20260723T120605Z/SUPRA_RUNTIME_SMOKE_TEST.json
GLOBAL_GRAPH.json
GLOBAL_VIEW.json
GLOBAL_WORKSPACE.json
Governance/adr_registry.json
Governance/authority_registry.json
Governance/capability_registry.json
Governance/constitution_registry.json
Governance/fitness_functions.json
Governance/quality_gates.json
MODULE_REGISTRY.json
MODULE_RELATIONS.json
NUCLEO_COMPONENT_INVENTORY.json
PACKAGE_REGISTRY.json
PACKAGE_RELATIONS.json
PROJECT_REGISTRY.json
PROJECT_RELATIONS.json
RUNTIME_STATUS.json
SERVICE_RELATIONS.json
SUPRA/Assets.xcassets/AccentColor.colorset/Contents.json
SUPRA/Assets.xcassets/AppIcon.appiconset/Contents.json
SUPRA/Assets.xcassets/Contents.json
SUPRA/SUPRA_EXECUTIVE_UI_MODEL.json
SUPRA/SUPRA_REMOTE_INTERFACE.json
SUPRA_ARCHITECTURE_INDEX.json
SUPRA_AST_PLATFORM/Sources/SUPRAAST/Resources/Rules.json
SUPRA_BRIDGE_DECLARATION_PROBE.json
SUPRA_BRIDGE_FUNCTIONAL_CLASSIFICATION.json
SUPRA_BUILD_DIAGNOSTIC.json
SUPRA_BUILD_SETTINGS_DIAGNOSTIC.json
SUPRA_BUILD_SPACE_RECOVERY.json
SUPRA_DEPENDENCY_GRAPH.json
SUPRA_E2E_PROOF_HARNESS_V1/Mission/mission.json
SUPRA_EXCLUDE_EXTRACTION_PLAN_REPORT.json
SUPRA_EXTRACTION_PLAN_EXCLUSION_BUILD.json
SUPRA_FULL_ENVIRONMENT_VERIFICATION_LATEST.json
SUPRA_FUNCTIONAL_AUTHORITY.json
SUPRA_FUNCTIONAL_AUTHORITY_RECONCILED.json
SUPRA_FUNCTIONAL_FLOW.json
SUPRA_FUNCTIONAL_FLOW_CHECK.json
SUPRA_INDEX_AVAILABILITY_DIAGNOSTIC.json
SUPRA_INDEX_PATH_BINDING.json
SUPRA_INLINE_MODEL_DEDUP_REPORT.json
SUPRA_PRODUCT_RUNTIME_READINESS.json
SUPRA_QUARANTINE_EXTRACTION_PLAN_REPORT.json
SUPRA_REAL_SWIFT_FILES.json
SUPRA_REAL_SWIFT_FILES_VALIDATED.json
SUPRA_RUNTIME_GRAPH.EMPTY.json
SUPRA_RUNTIME_GRAPH.json
SUPRA_RUNTIME_SMOKE_TEST.json
SUPRA_SAFE_XCODE_CACHE_RECOVERY.json
SUPRA_SPOTIFY_CACHE_RECOVERY.json
SUPRA_STATE.json
SUPRA_STORAGE_RECOVERY_AUDIT.json
SUPRA_STORAGE_TOP_ITEMS_AUDIT.json
SUPRA_SYMBOL_GRAPH.json
SUPRA_SYMLINK_OVERLAY_BUILD.json
SUPRA_VISUAL_VALIDATION_20260723.json
SUPRA_WORKSPACE_REGISTRY.json
SUPRA_XCODE_LIST_DIAGNOSTIC.json
_FOUNDATION_MEMORY/GLOBAL_KNOWLEDGE_GRAPH.json
_FOUNDATION_MEMORY/GLOBAL_MEMORY_INDEX.json
_FOUNDATION_MEMORY/MEMORY_ADAPTERS.json
_FOUNDATION_MEMORY/MEMORY_ARCHIVES.json
_FOUNDATION_MEMORY/MEMORY_BRIDGES.json
_FOUNDATION_MEMORY/MEMORY_CAPABILITIES.json
_FOUNDATION_MEMORY/MEMORY_CLEANUP.json
_FOUNDATION_MEMORY/MEMORY_CONVERSATIONS.json
_FOUNDATION_MEMORY/MEMORY_DECISIONS.json
_FOUNDATION_MEMORY/MEMORY_DEPENDENCIES.json
_FOUNDATION_MEMORY/MEMORY_DUPLICATES.json
_FOUNDATION_MEMORY/MEMORY_ENVIRONMENT.json
_FOUNDATION_MEMORY/MEMORY_FREEZES.json
_FOUNDATION_MEMORY/MEMORY_GIT.json
_FOUNDATION_MEMORY/MEMORY_MODULES.json
_FOUNDATION_MEMORY/MEMORY_PRODUCTS.json
_FOUNDATION_MEMORY/MEMORY_PROJECTS.json
_FOUNDATION_MEMORY/MEMORY_REPORTS.json
_FOUNDATION_MEMORY/MEMORY_RUNTIME.json
_FOUNDATION_MEMORY/MEMORY_SCRIPTS.json
_FOUNDATION_MEMORY/MEMORY_SERVICES.json
_FOUNDATION_MEMORY/MEMORY_SWIFTUI.json
_FOUNDATION_MEMORY/MEMORY_SWIFT_PACKAGES.json
_FOUNDATION_MEMORY/MEMORY_WORKERS.json
_FOUNDATION_MEMORY/MEMORY_XCODE.json
_MISSIONS/LOT5_SUPRA_CHAT_GATEWAY_V1/PRECHECK.json
_VERIFICATIONS/OLLAMA_STATUS_20260723_155802.json
_VERIFICATIONS/SUPRA_FULL_ENVIRONMENT_VERIFICATION_20260723_155802.json
agent_execution.json
agent_results/job_architect_result.json
agent_results/job_auditor_result.json
agent_results/job_reviewer_result.json
agent_results/supra_architect_provider_result.json
agent_results/supra_auditor_provider_result.json
agent_results/supra_auditor_result.json
agent_results/supra_explorer_result.json
agent_results/supra_reviewer_provider_result.json
agent_results/supra_reviewer_result.json
agent_results/swiftui_architecture_result.json
agent_results/swiftui_audit_result.json
agent_results/swiftui_exploration_result.json
agent_results/swiftui_research_result.json
agent_results/swiftui_review_result.json
consensus_report.json
consensus_trace.json
context_examples.json
critical_path.json
dashboard_snapshot.json
delegation_trace.json
dependency_graph.json
execution_graph.json
execution_plan.json
execution_trace.json
executive_cockpit_foundation.json
job_metrics.json
knowledge_authority.json
knowledge_context_examples.json
knowledge_graph.json
knowledge_identity.json
knowledge_kernel.json
knowledge_lineage.json
knowledge_relations.json
knowledge_relationships.json
knowledge_sources.json
knowledge_statistics.json
metrics.json
mission_center_metrics.json
mission_graph.json
mission_graph_metrics.json
model_selection.json
opencode.json
parallel_groups.json
priority_metrics.json
provider_metrics.json
provider_selection.json
queue_metrics.json
resource_allocation.json
router_decision.json
routing_trace.json
runtime_diagnostics.json
runtime_metrics.json
runtime_trace.json
scheduler_trace.json
supra_os_foundation.json
twin_bindings.json
twin_lifecycle.json
twin_registry.json
twin_relationships.json
universe_graph.json
universe_registry.json
universe_statistics.json
validation_trace.json
worker_trace.json
workspace_governance.json
workspace_graph.json
workspace_index.json
workspace_memory.json
workspace_recommendations.json
workspace_statistics.json
```

## Annexe D — 153 Markdown, rapports et snapshots texte

Statut de lecture: `[I]` = lecture intégrale attestée pendant la reprise; `[S]` = structure, métadonnées et passages ciblés inspectés; `[N]` = inventorié mais non lu intégralement. Par prudence et traçabilité, les fichiers pour lesquels aucune preuve de lecture intégrale n’est disponible sont marqués `[S/N]`. Cette annexe ne prétend donc pas satisfaire littéralement une lecture humaine intégrale des 153 documents. Les décisions du rapport reposent sur les documents ciblés et les audits croisés, pas sur une prétention de lecture exhaustive.

```text
AGENTS.md [S/N]
Artifacts/ENGINE_CONTRACTS.md [S/N]
Artifacts/ENGINE_FEDERATION_ARCHITECTURE.md [S/N]
Artifacts/LOCAL_PROVIDER_PROOF.md [S/N]
Artifacts/LOCAL_PROVIDER_PROOF_V2.md [S/N]
Artifacts/SUPRA_ENVIRONMENT_TWIN_PROOF.md [S/N]
Artifacts/SUPRA_ENVIRONMENT_TWIN_TEST_REPORT.md [S/N]
Artifacts/SUPRA_PERSONAL_INTELLIGENCE_OS_V1_FREEZE.md [S/N]
Artifacts/SUPRA_TOTAL_IMAC_TWIN_PREFLIGHT.md [S/N]
Artifacts/ZERO_COST_ENGINE_FEDERATION_FREEZE.md [S/N]
Artifacts/ZERO_COST_TOOLCHAIN_AUDIT.md [S/N]
BUILD_STATUS.md [S/N]
CANNONICO_ACCESS_AUDIT.md [S/N]
CANNO_COMPONENT_MAP.md [S/N]
CANNO_DISCOVERY_VALIDATION.md [S/N]
CANNO_DUPLICATE_VALIDATION.md [S/N]
CANNO_SYSTEM_GRAPH.md [S/N]
CAnnoNico_CONTINUITY_STANDARD.md [S/N]
CAnnoNico_DEVELOPMENT_GUIDE.md [S/N]
CAnnoNico_WORKFLOW_STANDARD.md [S/N]
CLEANUP_PLAN.md [S/N]
CONTINUITY.md [S/N]
CONTINUITY_GAP_REPORT.md [S/N]
DEPENDENCY_GRAPH.md [S/N]
DEPENDENCY_MAP.md [S/N]
ENVIRONMENT_REPORT.md [S/N]
EXECUTION_REPORT.md [S/N]
EXECUTIVE_ARCHIVES/2026-07-27_14-22-20/CONTINUITY.md [S/N]
EXECUTIVE_ARCHIVES/2026-07-27_14-22-20/CONTINUITY_GAP_REPORT.md [S/N]
EXECUTIVE_ARCHIVES/2026-07-27_14-22-20/EXECUTION_REPORT.md [S/N]
EXECUTIVE_ARCHIVES/2026-07-27_14-22-20/EXECUTIVE_SHELL_V1_EXECUTION_REPORT.md [S/N]
EXECUTIVE_ARCHIVES/2026-07-27_14-22-20/FINAL_REPORT.md [S/N]
EXECUTIVE_ARCHIVES/2026-07-27_14-22-20/FREEZE_AUDIT.md [S/N]
EXECUTIVE_ARCHIVES/2026-07-27_14-22-20/FREEZE_V1.md [S/N]
EXECUTIVE_ARCHIVES/2026-07-27_14-22-20/HANDOFF.md [S/N]
EXECUTIVE_ARCHIVES/2026-07-27_14-22-20/MACOS_PERMISSION_ARCHITECTURE_REPORT.md [S/N]
EXECUTIVE_ARCHIVES/2026-07-27_14-22-20/MACOS_PERMISSION_EXECUTION_REPORT.md [S/N]
EXECUTIVE_ARCHIVES/2026-07-27_14-22-20/NEXT_MISSION.md [S/N]
EXECUTIVE_ARCHIVES/2026-07-27_14-22-20/SESSION_SUMMARY.md [S/N]
EXECUTIVE_ARCHIVES/2026-07-27_14-22-20/SUPRA_EXECUTION_REPORT.md [S/N]
EXECUTIVE_ARCHIVES/CLOSE_SESSION_2026-07-27_14-23-54/FINAL_REPORT.md [S/N]
EXECUTIVE_ARCHIVES/CLOSE_SESSION_2026-07-27_14-23-54/FREEZE_V1.md [S/N]
EXECUTIVE_ARCHIVES/CLOSE_SESSION_2026-07-27_14-23-54/HANDOFF.md [S/N]
EXECUTIVE_ARCHIVES/CLOSE_SESSION_2026-07-27_14-23-54/LESSONS_LEARNED.md [S/N]
EXECUTIVE_ARCHIVES/CLOSE_SESSION_2026-07-27_14-23-54/MACOS_PERMISSION_ARCHITECTURE_REPORT.md [S/N]
EXECUTIVE_ARCHIVES/CLOSE_SESSION_2026-07-27_14-23-54/MACOS_PERMISSION_EXECUTION_REPORT.md [S/N]
EXECUTIVE_ARCHIVES/CLOSE_SESSION_2026-07-27_14-23-54/MACOS_PERMISSION_VALIDATION_REPORT.md [S/N]
EXECUTIVE_ARCHIVES/CLOSE_SESSION_2026-07-27_14-23-54/NEXT_MISSION.md [S/N]
EXECUTIVE_ARCHIVES/CLOSE_SESSION_2026-07-27_14-23-54/PENDING_TASKS.md [S/N]
EXECUTIVE_ARCHIVES/CLOSE_SESSION_2026-07-27_14-23-54/SUPRA_CONTINUITY_PACK.md [S/N]
EXECUTIVE_ARCHIVES/CLOSE_SESSION_2026-07-27_14-23-54/WORK_SUMMARY.md [S/N]
EXECUTIVE_CERTIFICATION_REPORT.md [S/N]
EXECUTIVE_COMPOSITION_ROOT.md [S/N]
EXECUTIVE_LOT1_REPORT.md [S/N]
EXECUTIVE_SHELL_V1_EXECUTION_REPORT.md [S/N]
EXECUTIVE_SUMMARY.md [S/N]
FAILURE_MATRIX.md [S/N]
FINAL_REPORT.md [S/N]
FREEZE_AUDIT.md [S/N]
FREEZE_EXECUTIVE_CERTIFIED_V1.md [S/N]
FREEZE_V1.md [S/N]
Freeze/SUPRA_EXECUTIVE_FREEZE_V3.md [S/N]
Freeze/SUPRA_EXECUTIVE_FREEZE_V4.md [S/N]
GIT_HYGIENE_REPORT.md [S/N]
Governance/PREMATCH_LOT0.md [S/N]
Governance/reports/LOT0_GOVERNANCE_REPORT.md [S/N]
HANDOFF.md [S/N]
INTELLIGENCE_SOURCE_MAP.md [S/N]
LESSONS_LEARNED.md [S/N]
MACOS_PERMISSION_ARCHITECTURE_REPORT.md [S/N]
MACOS_PERMISSION_EXECUTION_REPORT.md [S/N]
MACOS_PERMISSION_FINAL_REPORT.md [S/N]
MACOS_PERMISSION_VALIDATION_REPORT.md [S/N]
MEMORY_CONNECTION_MAP.md [S/N]
MISSION_CENTER_IMPLEMENTATION_REPORT.md [S/N]
MISSION_CENTER_REPORT.md [S/N]
MISSION_GRAPH_REPORT.md [S/N]
NEXT_ITERATION_OBJECTIVES.md [S/N]
NEXT_MISSION.md [S/N]
NOVA_KNOWLEDGE_OS_FOUNDATION_V1_REPORT.md [S/N]
NOVA_UNIVERSE_ENGINE_V1_REPORT.md [S/N]
NUCLEO_ARCHITECTURE.md [S/N]
NUCLEO_CLASSIFICATION.md [S/N]
NUCLEO_DEPENDENCY_GRAPH.md [S/N]
NUCLEO_DISCOVERY_REPORT.md [S/N]
NUCLEO_DUPLICATES.md [S/N]
PENDING_TASKS.md [S/N]
PREMATCH_LOT1.md [S/N]
REUSE_CATALOG.md [S/N]
ROOT_CAUSE_ANALYSIS.md [S/N]
RUNTIME_INTEGRATION_REPORT.md [S/N]
RUNTIME_RECONNECT_REPORT.md [S/N]
Reports/ConversationMemory/report_20260725_003313.md [S/N]
SESSION_SUMMARY.md [S/N]
SUPRA/SUPRA_EXECUTIVE_COCKPIT_V2_REPORT.md [S/N]
SUPRA/SUPRA_EXECUTIVE_COCKPIT_V3_REPORT.md [S/N]
SUPRA/SUPRA_WORKSPACE_INTELLIGENCE_V1_REPORT.md [S/N]
SUPRA_AGENT_REGISTRY_V1.md [S/N]
SUPRA_AI_LAB_ARCHITECTURE_V1.md [S/N]
SUPRA_ALIVE_IMPLEMENTATION.md [S/N]
SUPRA_ALIVE_ROADMAP.md [S/N]
SUPRA_ALIVE_RUNTIME.md [S/N]
SUPRA_AST_PLATFORM/README.md [S/N]
SUPRA_COMPOSITION_ROOT_V2_1_REPORT.md [S/N]
SUPRA_CONTINUITY_PACK.md [S/N]
SUPRA_DECISION_ENGINE.md [S/N]
SUPRA_EXECUTION_EVIDENCE.md [S/N]
SUPRA_EXECUTION_PIPELINE.md [S/N]
SUPRA_EXECUTION_REPORT.md [S/N]
SUPRA_EXECUTIVE_COCKPIT_REPORT.md [S/N]
SUPRA_EXECUTIVE_MISSION_CONTROL_V1_ARCHITECTURE.md [S/N]
SUPRA_GLOBAL_AUDIT.md [S/N]
SUPRA_HANDOFF_FOR_OPENCODE.md [S/N]
SUPRA_HANDOFF_OPENCODE_V2_1/BUILD_STATUS.md [S/N]
SUPRA_HANDOFF_OPENCODE_V2_1/CONTINUITY.md [S/N]
SUPRA_HANDOFF_OPENCODE_V2_1/FINAL_REPORT.md [S/N]
SUPRA_HANDOFF_OPENCODE_V2_1/FREEZE_V1.md [S/N]
SUPRA_HANDOFF_OPENCODE_V2_1/HANDOFF.md [S/N]
SUPRA_HANDOFF_OPENCODE_V2_1/NEXT_MISSION.md [S/N]
SUPRA_HANDOFF_OPENCODE_V2_1/SUPRA_COMPOSITION_ROOT_V2_1_REPORT.md [S/N]
SUPRA_HANDOFF_OPENCODE_V2_1/SUPRA_CONTINUITY_PACK.md [S/N]
SUPRA_JOB_SCHEDULER_REPORT.md [S/N]
SUPRA_KNOWLEDGE_GRAPH_V2_REPORT.md [S/N]
SUPRA_LAB_ARCHITECTURE_V1.md [S/N]
SUPRA_MISSION_CENTER_V1_FREEZE_REPORT.md [S/N]
SUPRA_MODEL_REGISTRY_V1.md [S/N]
SUPRA_OPENCODE_MISSION.md [S/N]
SUPRA_ORCHESTRATION_ARCHITECTURE.md [S/N]
SUPRA_OS_RUNTIME_REPAIR_REPORT.md [S/N]
SUPRA_OS_VALIDATION_REPORT.md [S/N]
SUPRA_PLUGIN_SPECIFICATION.md [S/N]
SUPRA_PRODUCT_FREEZE_V1_REPORT.md [S/N]
SUPRA_PROVIDER_ARCHITECTURE.md [S/N]
SUPRA_PROVIDER_RUNTIME_REPORT.md [S/N]
SUPRA_ROUTER_SPECIFICATION_V1.md [S/N]
SUPRA_RUNTIME_GAPS.md [S/N]
SUPRA_RUNTIME_GRAPH.md [S/N]
SUPRA_RUNTIME_MISSION_EVIDENCE_RESTORE_V1_REPORT.md [S/N]
SUPRA_RUNTIME_PROOF_V002.md [S/N]
SUPRA_WORKFLOW_V1.md [S/N]
TEST_RECOVERY_PREMATCH.md [S/N]
UDCL_SPECIFICATION.md [S/N]
VALIDATION_PROTOCOL.md [S/N]
WORK_SUMMARY.md [S/N]
_FOUNDATION_MEMORY/ARCHITECTURE_MAP.md [S/N]
_FOUNDATION_MEMORY/CLEANUP_PREPARATION.md [S/N]
_FOUNDATION_MEMORY/FOUNDATION_MEMORY.md [S/N]
_FOUNDATION_MEMORY/SYSTEM_TOPOLOGY.md [S/N]
_MISSIONS/LOT5_SUPRA_CHAT_GATEWAY_V1/CODEX_MISSION.md [S/N]
docs/README.md [S/N]
docs/SUPRA_EXECUTIVE_OS_CONSTITUTION_V1.md [S/N]
docs/SUPRA_EXECUTIVE_OS_GOVERNANCE.md [S/N]
docs/SUPRA_EXECUTIVE_OS_INDEX.md [S/N]
```

### Snapshots binaires et images

Les PNG ne sont pas inclus dans les 153 Markdown. Leurs noms et dimensions constituent un contrôle structurel; sans inspection visuelle explicite, ils ne sont pas déclarés vus. Une validation visuelle reste obligatoire avant consolidation.
- `Artifacts/proofs/SUPRA_CHAT_BOOTSTRAP_V1_DASHBOARD.png` — 3024×1964 — non inspecté visuellement dans cette reprise
- `Artifacts/proofs/SUPRA_CHAT_BOOTSTRAP_V1_PROOF.png` — 3160×1922 — non inspecté visuellement dans cette reprise
- `Artifacts/proofs/SUPRA_CHAT_RUNTIME_BRIDGE_V1_PROOF.png` — 2096×1922 — non inspecté visuellement dans cette reprise
- `Artifacts/proofs/SUPRA_CHAT_RUNTIME_HEALTH_V1_PROOF.png` — 3024×1964 — non inspecté visuellement dans cette reprise
- `Artifacts/proofs/SUPRA_CHAT_RUNTIME_HEALTH_V1_UNAVAILABLE.png` — 3024×1964 — non inspecté visuellement dans cette reprise
- `Artifacts/proofs/SUPRA_DECISION_INBOX_V1.png` — 3024×1964 — non inspecté visuellement dans cette reprise
- `Artifacts/proofs/SUPRA_DECISION_INBOX_V1_DASHBOARD.png` — 3024×1964 — non inspecté visuellement dans cette reprise
- `Artifacts/proofs/SUPRA_EXECUTIVE_DASHBOARD_RUNTIME_HEALTH_V1.png` — 3024×1964 — non inspecté visuellement dans cette reprise
- `Artifacts/proofs/SUPRA_EXECUTIVE_DASHBOARD_V1.png` — 3024×1964 — non inspecté visuellement dans cette reprise
- `Artifacts/proofs/SUPRA_MISSION_CENTER_V1.png` — 3024×1964 — non inspecté visuellement dans cette reprise
- `Artifacts/proofs/SUPRA_MISSION_CENTER_V1_DASHBOARD.png` — 3024×1964 — non inspecté visuellement dans cette reprise
- `Artifacts/proofs/SUPRA_MISSION_CENTER_V1_RELEASE_DASHBOARD.png` — 3024×1964 — non inspecté visuellement dans cette reprise
- `Artifacts/proofs/SUPRA_RUNTIME_MISSION_EVIDENCE_RESTORE_V1_PROOF.png` — 3024×1964 — non inspecté visuellement dans cette reprise
- `Artifacts/proofs/SUPRA_VISUAL_VALIDATION_MISSION_CENTER_V1_DASHBOARD.png` — 3024×1964 — non inspecté visuellement dans cette reprise
- `SUPRA_EXECUTIVE_SHELL_V1.png` — 3024×1964 — non inspecté visuellement dans cette reprise
- `SUPRA_EXECUTIVE_SHELL_V1_DASHBOARD.png` — 3024×1964 — non inspecté visuellement dans cette reprise
- `SUPRA_EXECUTIVE_SHELL_V1_FINAL.png` — 3024×1964 — non inspecté visuellement dans cette reprise
