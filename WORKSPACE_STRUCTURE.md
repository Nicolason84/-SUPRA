# WORKSPACE_STRUCTURE.md

## Structure du Workspace SUPRA AI LAB

**Root:** `/Users/nicolasalonso/Desktop/NOVA_OS/SUPRA`
**Date:** 2026-07-28
**Branch:** develop (12 commits ahead of origin/develop)

---

## 1. Arborescence Principale (Niveau 1)

```
SUPRA/
├── _FOUNDATION_MEMORY/           # Mémoire fondatrice persistante
├── _MISSIONS/                    # Dossiers de missions
├── _NON_RUNTIME_ARCHITECTURE/    # Architecture hors runtime
├── _SUPRA_BACKUPS/               # Sauvegardes système
├── _VERIFICATIONS/               # Rapports de vérification
├── .analysis/                    # Analyses statiques
├── .backup_ui_model/             # Backup modèle UI
├── .cannonico/                   # Système CAnnoNico (missions, output)
├── .git/                         # Repository Git
├── .kernel/                      # Kernel SUPRA (contrats, modèles, providers)
├── .opencode/                    # Configuration OpenCode (agents, workflows)
├── .overnight_audit/             # Audit nocturne
├── .restore_build/               # Restauration build
├── .supra_node_manifest.json     # Manifest node bootstrap
├── .supra_node_status.json       # Statut node
├── .supra_reports/               # Rapports runtime
├── {/                            # Dossier racine (artefact)
├── agent_execution.json          # Exécution agents
├── agent_results/                # Résultats agents
├── AGENTS.md                     # Définition agents SUPRA
├── ALPHA_IMPLEMENTATION_PLAN.md  # Plan implémentation Alpha
├── ALPHA01_RELEASE_AUDIT.md      # Audit release Alpha 01
├── ALPHA02_EXECUTION_PACKAGE.md  # Package exécution Alpha 02
├── Artifacts/                    # Artefacts générés (26 sous-dossiers)
├── BASELINE_ACTION_PLAN.md       # Plan action baseline
├── BASELINE_CERTIFICATION_REPORT.md
├── BASELINE_ISSUES.md
├── build/                        # Build artifacts
├── BUILD_LOG.md
├── BUILD_STATUS.md
├── build.log
├── CANNO_*.md/json               # Composants CAnnoNico
├── CANON_*.md/json               # Registres canoniques
├── CHANGELOG_ALPHA01.md
├── CLEANUP_PLAN.md
├── consensus_*.json
├── CONTINUITY.md / _GAP_REPORT.md
├── CONTROL_TOWER_STATUS.json
├── critical_path.json / .md
├── dashboard_snapshot.json
├── delegation_trace.json
├── DEPENDENCY_*.md/json
├── docs/                         # Documentation
├── DUPLICATE_REGISTRY.json
├── ENVIRONMENT_*.json/.md
├── Evidence/                     # Preuves d'exécution
├── EXECUTION_*.md/json           # Rapports exécution
├── EXECUTIVE_*.md/json           # Rapports exécutifs
├── EXECUTIVE_ARCHIVES/
├── FAILURE_MATRIX.md
├── FEATURE_CLASSIFICATION.md
├── FINAL_REPORT.md
├── Freeze/ / FREEZE_*.md/json    # Gels de version
├── GIT_CLEANUP_PLAN.md
├── GIT_HYGIENE_REPORT.md
├── GLOBAL_*.json
├── GO_SUPRA*.sh                  # Scripts d'orchestration
├── Governance/                   # Gouvernance
├── HANDOFF.md
├── Inbox/ / Outbox/              # Boîtes de réception/envoi
├── INTELLIGENCE_SOURCE_MAP.md
├── job_metrics.json
├── KEEP_MATRIX.md
├── knowledge_*.json              # Graphes de connaissance
├── LESSONS_LEARNED.md
├── LOOP_ENGINE.md
├── MACOS_PERMISSION_*.md         # Rapports permissions macOS
├── MASTER_ROADMAP.md
├── MEMORY_CONNECTION_MAP.md
├── metrics.json
├── MISSION_*.md/json             # Centre de missions
├── Missions/                     # Dossiers missions
├── model_selection.json
├── MODULE_*.json
├── NEXT_*.md
├── NOVA_*.md                     # Rapports fondation NOVA
├── NUCLEO_*.md/json              # Architecture Nucleo
├── opencode.json / .bak          # Config OpenCode
├   PACKAGE_*.json
├   Packages/                     # Packages Swift
├   parallel_groups.json
├   PATCH_REPORT.md
├   PENDING_TASKS.md
├   phase*_extract_*.sh           # Scripts d'extraction
├   PREMATCH_LOT1.md
├   priority_metrics.json
├   PROJECT_*.json
├   provider_*.json
├   queue_metrics.json
├   RELEASE_*.md/json
├   Reports/                      # Rapports générés
├   resource_allocation.json
├   REUSE_CATALOG.md
├   RISK_MATRIX.md
├   ROOT_CAUSE_ANALYSIS.md
├   router_decision.json
├   routing_trace.json
├   RUNTIME_*.md/json/log         # Rapports runtime
├   SUPRA/                        # Code source principal (Swift)
├   SUPRA_*.md/json/sh            # Spécifications SUPRA
├   SUPRA_AST_PLATFORM/           # Plateforme AST
├   SUPRA_E2E_PROOF_HARNESS_V1/
├   SUPRA_HANDOFF_*.md
├   SUPRA_HANDOFF_OPENCODE_V2_1/
├   SUPRA_RUNTIME/                # Runtime SUPRA
├   SUPRA_RUNTIME.sh
├   SUPRA.xcodeproj/              # Projet Xcode
├   SUPRATests/                   # Tests
├   TEST_RECOVERY_PREMATCH.md
├   twin_*.json                   # Jumeaux numériques
├   UDCL_SPECIFICATION.md
├   ULTIMATE_CONSOLIDATION_REPORT.md
├   universe_*.json
├   VALIDATION_PROTOCOL.md
├   validation_trace.json
├   version.json
├   WORK_SUMMARY.md
├   worker_trace.json
└── workspace_*.json              # État workspace
```

---

## 2. Code Source Principal: SUPRA/

```
SUPRA/
├── App Entry Points
│   ├── SUPRAApp.swift
│   ├── SUPRACommandCenterApp.swift
│   └── SUPRAOperationalCoreApp.swift
│
├── Core Models (Extractions)
│   ├── Mission.swift
│   ├── MissionStore.swift
│   ├── DecisionStore.swift
│   ├── ConversationMemoryStore.swift
│   ├── ArtifactReader.swift
│   ├── SUPRAState.json
│   └── version.json
│
├── Executive Layer
│   ├── ExecutiveBootManager.swift
│   ├── ExecutiveCockpitFoundation.swift
│   ├── ExecutiveGraph.swift
│   ├── ExecutiveMemory.swift
│   ├── ExecutiveMissionControlModels.swift
│   ├── ExecutiveMissionControlStore.swift
│   ├── ExecutiveMissionControlView.swift
│   ├── ExecutiveSearch.swift
│   ├── ExecutiveTimeline.swift
│   ├── ExecutiveWindow.swift
│   ├── ExecutiveWorkflow.swift
│   ├── ExecutiveWorkflowListView.swift
│   └── SUPRAExecutiveCockpit*.md (rapports)
│
├── Runtime Layer
│   ├── RuntimeGateway.swift
│   ├── RuntimeConnectionState.swift
│   ├── RuntimeEvent.swift / RuntimeEventSource.swift
│   ├── RuntimeHealth.swift
│   ├── RuntimeMonitor.swift
│   ├── RuntimeSourceProtocol.swift
│   ├── RuntimeView.swift
│   ├── SUPRARuntimeEvents.swift
│   ├── SUPRARuntimeGraph.swift
│   ├── SUPRARuntimeLogger.swift
│   ├── SUPRARuntimeMetrics.swift
│   ├── SUPRARuntimeRegistry.swift
│   ├── SUPRARuntimeProofTests.swift
│   └── SUPRAExecutor.swift
│
├── Intelligence & Knowledge
│   ├── KnowledgeAuthority.swift
│   ├── KnowledgeContextEngine.swift
│   ├── KnowledgeExplorer.swift
│   ├── KnowledgeGraph.swift
│   ├── KnowledgeIdentity.swift
│   ├── KnowledgeLineage.swift
│   ├── KnowledgeObject.swift
│   ├── KnowledgeProvider.swift
│   ├── KnowledgeRelation.swift
│   ├── KnowledgeRelationship.swift
│   ├── KnowledgeSource.swift
│   ├── KnowledgeStatistics.swift
│   ├── ContextEngine.swift
│   ├── ConversationKnowledgeProvider.swift
│   ├── ConversationTwinView.swift
│   ├── GitKnowledgeProvider.swift
│   ├── PDFKnowledgeProvider.swift
│   ├── ReportKnowledgeProvider.swift
│   ├── NOVAKnowledgeKernel.swift
│   ├── SUPRAIntelligenceEngine.swift
│   ├── SUPRAIntelligenceGraph.swift
│   ├── SUPRAIntelligenceState.swift
│   └── SUPRAInsight.swift
│
├── Memory & Twin Systems
│   ├── TwinAnalytics.swift
│   ├── TwinBindings.swift
│   ├── TwinComparison.swift
│   ├── TwinExplorer.swift
│   ├── TwinFactory.swift
│   ├── TwinIdentity.swift
│   ├── TwinLifecycle.swift
│   ├── TwinRegistry.swift
│   ├── TwinRenderer.swift
│   ├── TwinSynchronizer.swift
│   ├── TwinUniverse.swift
│   ├── SUPRADataTwin.swift
│   ├── SUPRADeveloperTwin.swift
│   ├── SUPRAHardwareTwin.swift
│   ├── SUPRASoftwareTwin.swift
│   ├── MultiMemoryState.swift
│   ├── MultiMemoryStore.swift
│   ├── MultiMemoryView.swift
│   ├── MemoryView.swift
│   ├── SUPRAMemoryLensView.swift
│   └── ContinuityManager.swift
│
├── Mission & Execution
│   ├── MissionContext.swift
│   ├── MissionCopilotView.swift
│   ├── MissionGraphView.swift
│   ├── MissionProposal.swift
│   ├── MissionProposalEngine.swift
│   ├── MissionTimelineView.swift
│   ├── MissionView.swift
│   ├── AutoMissionQueue.swift
│   ├── SUPRAMissionBroker.swift
│   ├── SUPRAMissionExecutor.swift
│   ├── SUPRAMissionObserver.swift
│   ├── SUPRAMissionProposalEngine.swift
│   ├── SUPRAExecutionPipeline.swift
│   ├── SUPRAExecutionPlanner.swift
│   ├── SUPRAExecutor.swift
│   ├── SUPRAEnvironmentAutoMissions.swift
│   ├── SUPRAEnvironmentCommandCenterView.swift
│   └── SUPRAEnvironmentResolver.swift
│
├── Decision Engine
│   ├── SUPRADecisionAuthority.swift
│   ├── SUPRADecisionEngine.swift
│   ├── SUPRADecisionRoomView.swift
│   ├── DecisionAuthorityView.swift
│   ├── DecisionInboxView.swift
│   └── DecisionKnowledgeProvider.swift
│
├── UI Components (Views)
│   ├── ContentView.swift
│   ├── DashboardView.swift
│   ├── HealthView.swift
│   ├── IntelligenceView.swift
│   ├── MissionCenterView.swift
│   ├── MissionDetailView.swift
│   ├── SettingsView.swift
│   ├── CommandCenterView.swift
│   ├── CockpitRuntimeView.swift
│   ├── ControlTowerState.swift
│   ├── TotalControlTowerView.swift
│   ├── SUPRAOperationalControlCenterView.swift
│   ├── SUPRAOSCommandCenterView.swift
│   ├── SUPRAOSHomeView.swift
│   ├── SUPRAOSLiveView.swift
│   ├── SUPRAOSMissionCanvasView.swift
│   ├── SUPRAOSProductRootView.swift
│   ├── SUPRAOSTwinCenterView.swift
│   ├── SUPRAOSUniverseView.swift
│   ├── SUPRAOSWorkspaceExplorerView.swift
│   ├── SUPRAOSGlobalSearchView.swift
│   ├── SUPRAOSDesignSystem.swift
│   ├── SUPRAOSFoundation.swift
│   ├── UniverseDashboard.swift
│   ├── UniverseNavigator.swift
│   ├── UniverseSearch.swift
│   ├── UniverseTimeline.swift
│   ├── WorkerPoolView.swift
│   ├── ProjectsCardView.swift
│   ├── FileSystemCardView.swift
│   ├── EvidenceExplorerView.swift
│   ├── RootCauseExplainerView.swift
│   ├── RuntimeDiagnosticsView.swift
│   ├── SUPRAAliveDemo.swift
│   ├── SUPRABusinessDemoView.swift
│   ├── SUPRACompanionView.swift
│   ├── SUPRAAutonomyControlView.swift
│   ├── SUPRAEvolutionEngineView.swift
│   ├── SUPRAEvolutionRoomView.swift
│   ├── SUPRASpatialNavigatorView.swift
│   ├── SUPRAWorldMapView.swift
│   └── UI/ (dossier)
│
├── Orchestration & Coordination
│   ├── SUPRACompositionRoot.swift
│   ├── SUPRACommandCenterState.swift
│   ├── SUPRACapabilityBroker.swift
│   ├── SUPRAProviderBroker.swift
│   ├── SUPRAProviderRegistry.swift
│   ├── SUPRAProviderProtocols.swift
│   ├── SUPRAModelRegistry.swift
│   ├── SUPRARoutingPolicy.swift
│   ├── SUPRAPluginDiscovery.swift
│   ├── SUPRAPluginRegistry.swift
│   ├── SUPRAPluginSpecification.md
│   ├── SUPRAWorkerFabric.swift
│   ├── SUPRAScheduler.swift
│   ├── SUPRABackgroundScheduler.swift
│   ├── SUPRAPassiveRefreshCoordinator.swift
│   ├── SUPRAOptimizationCopilot.swift
│   ├── SUPRAResourceGovernor.swift
│   ├── SUPRAResourceIntelligenceEngine.swift
│   ├── SUPRAResourceIntelligenceView.swift
│   ├── SUPRAMonetizationEngine.swift
│   ├── SUPRAEvolutionEngine.swift
│   ├── SUPRAEnvironmentBrief.swift
│   ├── SUPRAEnvironmentPotential.swift
│   ├── SUPRAEnvironmentSnapshotStore.swift
│   ├── SUPRAEnvironmentWorldModel.swift
│   ├── SUPRAWorldModel.swift
│   ├── SUPRANucleoOrchestrator.swift
│   ├── CAnnoNicoIntegrationBridge.swift
│   ├── CAnnoNicoObject.swift
│   ├── CAnnoNicoSnapshotStore.swift
│   └── OpenCodeBridge.swift / OpenCodeClient.swift
│
├── Providers & Integrations
│   ├── SUPRAOllamaProvider.swift
│   ├── ProtectedFolderAccessCoordinator.swift
│   └── WorkspaceConfiguration.swift
│
└── Tests (SUPRATests/)
    ├── ExecutiveMissionControlTests.swift
    ├── ExecutiveWorkflowTests.swift
    ├── ProtectedFolderAccessCoordinatorTests.swift
    ├── SUPRAMissionExecutionTests.swift
    ├── SUPRARuntimeProofTests.swift
    └── SUPRATests.swift
```

---

## 3. Artefacts & Rapports: Artifacts/

```
Artifacts/
├── ENGINE_CONTRACTS.md
├── ENGINE_FEDERATION_ARCHITECTURE.md
├── ENGINE_REGISTRY.json
├── ENGINE_ROUTING_MATRIX.tsv
├── LOCAL_PROVIDER_PROOF.md / V2.md
├── SUPRA_AUTONOMOUS_NODE_PROOF_AND_FREEZE_V1_20260725_031618/
├   SUPRA_CODESIGN_REPAIR_20260725_053300/
├   SUPRA_ENVIRONMENT_TWIN_METRICS.json
├   SUPRA_ENVIRONMENT_TWIN_PROOF.md
├   SUPRA_ENVIRONMENT_TWIN_TEST_REPORT.md
├   SUPRA_PERSONAL_INTELLIGENCE_OS_V1_FREEZE.md
├   SUPRA_TERMINAL_CHECK_20260725_053102/
├   SUPRA_TOTAL_IMAC_TWIN_PREFLIGHT.md
├   ZERO_COST_ENGINE_FEDERATION_FREEZE.md
├   ZERO_COST_TOOLCHAIN_AUDIT.md
├   diagnostics/
├   exports/
├   freezes/
├   graphs/
├   logs/
└   reports/
```

---

## 4. Kernel SUPRA: .kernel/

```
.kernel/
├── contracts/
│   └── protocols.list
├── models/
│   └── models.list
├── modules/
│   └── files.list
├── providers/
│   └── providers.list
├── registry/
│   └── agents.json
├── runtime/
│   └── node_identity.json
└── workspaces/
    └── directories.list
```

---

## 5. CAnnoNico: .cannonico/

```
.cannonico/
├── missions/
│   └── MISSION_001_BOOT.md
└── output/ (créé par mission)
```

---

## 6. Rapports SUPRA: .supra_reports/

```
.supra_reports/
├── app_bootstrap.txt
├── build.log / buildsettings*.txt
├── composition_root/
├── composition_sources/
├── configure*.txt
├── conversation*.txt
├── create_*.txt
├── decision_*.txt
├   indexers.txt
├   kg_*.txt
├   knowledge*.txt
└   (autres rapports d'introspection)
```

---

## 7. Documentation: docs/

```
docs/
└── releases/ (notes de version)
```

---

## 8. Fichiers de Configuration Clés

| Fichier | Description |
|---------|-------------|
| `opencode.json` | Config principale OpenCode (agents, modèles, skills, workflows) |
| `AGENTS.md` | Définition des 9 agents SUPRA avec permissions |
| `.gitignore` | Exclusions Git |
| `SUPRA.xcodeproj/project.pbxproj` | Projet Xcode |
| `Package.swift` | (si présent) Package Swift |

---

## 9. Scripts d'Orchestration: GO_SUPRA*.sh

| Script | Fonction |
|--------|----------|
| `GO_SUPRA.sh` | Lanceur principal |
| `GO_SUPRA_INSTALL.sh` | Installation |
| `GO_SUPRA_BOOTSTRAP.sh` / `V3.sh` | Bootstrap |
| `GO_SUPRA_VALIDATE.sh` / `V3.sh` | Validation |
| `GO_SUPRA_RUNTIME_BOOTSTRAP.sh` | Bootstrap runtime |
| `GO_SUPRA_RECOVERY.sh` | Récupération |
| `GO_SUPRA_GLOBAL_AUDIT.sh` | Audit global |
| `GO_SUPRA_COMPOSITION_ROOT_AUDIT.sh` | Audit composition root |
| `GO_SUPRA_MEMORY_RECONNECT.sh` | Reconnexion mémoire |
| `GO_SUPRA_MISSION_TEST.sh` | Test mission |
| `GO_SUPRA_PARALLEL_V1.sh` | Exécution parallèle |
| `GO_SUPRA_XCODE_RECOVERY.sh` | Récupération Xcode |
| `SUPRA_NODE_STATUS.sh` / `UNINSTALL.sh` | Gestion node |

---

## 10. Métriques Clés

- **Fichiers Swift:** ~228 dans `SUPRA/`
- **Fichiers de test:** 5 dans `SUPRATests/`
- **Documents Markdown:** 100+ à la racine
- **Artefacts JSON:** 50+ registres et graphes
- **Scripts Shell:** 20+ scripts `GO_SUPRA*.sh`
- **Commits ahead:** 12 sur `develop`
- **Fichiers modifiés non commités:** 14 (selon `git status`)
- **Dossiers untracked:** 100+ (artefacts, rapports, logs)

---

## 11. Architecture Haute Niveau

```
┌─────────────────────────────────────────────────────────────┐
│                     SUPRA AI LAB                            │
│  Personal Intelligence OS - macOS ARM64                     │
├─────────────────────────────────────────────────────────────┤
│  Executive Shell        │  Runtime Engine                   │
│  (Cockpit, Missions)    │  (Gateway, Health, Metrics)       │
├─────────────────────────┼───────────────────────────────────┤
│  Intelligence Layer     │  Memory & Twin System             │
│  (Knowledge, Graph, LLM)│  (MultiMemory, Twins, Continuity) │
├─────────────────────────┼───────────────────────────────────┤
│  Orchestration          │  Providers & Integrations         │
│  (Composition, Router,  │  (Ollama, CAnnoNico, OpenCode)    │
│   Workers, Scheduler)   │                                   │
└─────────────────────────┴───────────────────────────────────┘
```

---

*Généré automatiquement lors de CAMP_BASE_01_EXECUTION*