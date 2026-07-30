# FOUNDATION MEMORY — SUPRA SYSTEM V1

**Mission**: SUPRA_FOUNDATION_MEMORY_SYSTEM_V1  
**Date**: 2026-07-24T17:35:00Z  
**Mode**: READ_ONLY INDUSTRIEL

---

## 1. Identité du Système

| Attribut | Valeur |
|----------|--------|
| Nom | SUPRA |
| Type | macOS App (SwiftUI) |
| Machine | Nicolas Alonso iMac (arm64, macOS 26.5) |
| IDE | Xcode 16 (Swift 6.0) |
| Projet canonique | `/Users/nicolasalonso/Desktop/NOVA_OS/SUPRA` |
| Git | develop |
| Build | PASS |
| Taille | 29 GB (dont ~28 GB DerivedData) |

---

## 2. Architecture Fondatrice

```
SUPRAApp (@main)
  └── SupraControlCenterView (entry point actif)
        ├── ControlCenterStore
        ├── DecisionInboxView → DecisionStore
        └── MissionCenterView  → MissionStore

ContentView (compilé, non instancié)
  ├── SUPRAExecutiveStore (interne)
  ├── 11 sous-vues internes
  ├── CAnnoNicoIntegrationBridge
  ├── SUPRAGabrielConductorRuntime
  └── CAnnoNicoContracts (import direct)
```

### Capacités Fondatrices (16 identifiées)

| Capacité | Composants | Statut |
|----------|-----------|--------|
| Mission Management | MissionStore, MissionCenterView, MissionDetailView, MissionTimelineView, MissionGraphView | Actif |
| Decision Inbox | DecisionStore, DecisionInboxView, DecisionDetailView, DecisionRow | Actif |
| Control Center | ControlCenterStore, SupraControlCenterView | Actif |
| Runtime Monitoring | RuntimeMonitor, RuntimeView, RuntimeDataService, RuntimeGateway, RuntimeHealth | Actif |
| Knowledge Graph | KnowledgeGraph, KnowledgeAuthority, KnowledgeExplorer, KnowledgeIdentity, KnowledgeLineage, KnowledgeRelation, KnowledgeSource, KnowledgeStatistics | Actif |
| Executive Cockpit | ExecutiveCockpitFoundation, ExecutiveGraph, ExecutiveMemory, ExecutiveSearch, ExecutiveTimeline | Actif |
| Digital Twin | TwinAnalytics, TwinBindings, TwinComparison, TwinExplorer, TwinFactory, TwinIdentity, TwinLifecycle, TwinRegistry, TwinRenderer, TwinSynchronizer, TwinUniverse | Actif |
| Universe Engine | UniverseEngine, UniverseGraph, UniverseDashboard, UniverseNavigator, UniverseSearch, UniverseTimeline | Actif |
| Workspace Intelligence | WorkspaceGovernor, WorkspaceIndexer, WorkspaceKnowledgeGraph, WorkspaceMemory, WorkspaceDiscovery, WorkspaceRecommendation, WorkspaceStatistics | Actif |
| Chat / Conductor | SUPRAChatView, SUPRAChatRuntimeAdapter, SUPRAGabrielConductorRuntime | Actif |
| Knowledge Providers | ConversationKnowledgeProvider, DecisionKnowledgeProvider, GitKnowledgeProvider, PDFKnowledgeProvider, ReportKnowledgeProvider | Actif |
| Artifact Reading | ArtifactReader, Snapshot | Actif |
| Integration Bridge | CAnnoNicoIntegrationBridge, CAnnoNicoObject, NicoAppAdapter, VideoSwapAdapter, PucheroMemoryAdapter | Actif |
| OpenCode Bridge | OpenCodeBridge, OpenCodeClient | Actif |
| SUPRA OS Shell | SUPRAOSCommandCenterView, SUPRAOSHomeView, SUPRAOSLiveView, SUPRAOSMissionCanvasView, SUPRAOSProductRootView, SUPRAOSTwinCenterView, SUPRAOSUniverseView, SUPRAOSGlobalSearchView, SUPRAOSWorkspaceExplorerView, SUPRAOSDesignSystem, SUPRAOSFoundation | Actif |
| VideoSwap Engine | MediaEngine, URLEngine, ImportEngine, Foundation, Core (V3) | Actif |

---

## 3. Projets Connus

### Actifs (6)
1. **SUPRA** — Canonique, build PASS, 114 fichiers Swift
2. **NICO_APP** — iOS, ~800 fichiers Swift, Git
3. **NICO_APP_CLEAN** — iOS duplicate, 5.3 GB
4. **HELENE_APP** — iOS standalone, 408 KB
5. **SUPRA_VIDEO_SWAP_V3** — Multi-package, 293 fichiers Swift
6. **NOVA_BUILD_SYSTEM** — Orchestration Python/Shell, 10 MB

### Abandonnés (4)
- SUPRA_BISECT, SUPRA_RECOVERY (4 variants), COHERENCE_ENGINE_V1, SUPRA_TEMP

### Archives (3)
- SUPRA_VIDEO_SWAP_V1, SUPRA_PROJECTS, _DESKTOP_CLEAN_ARCHIVE

---

## 4. Vues SwiftUI (34 identifiées)

**Entry point**: `SUPRAApp.swift` instancie `SupraControlCenterView`  
**Orpheline**: `ContentView.swift` compilé mais non instancié (contient 11 sous-vues)

Groupes fonctionnels:
- **Control Center**: SupraControlCenterView, DashboardView
- **Missions**: MissionCenterView, MissionDetailView, MissionTimelineView, MissionGraphView, MissionRow
- **Décisions**: DecisionInboxView, DecisionDetailView, DecisionRow
- **Runtime**: RuntimeView
- **OS Shell**: SUPRAOSCommandCenterView, SUPRAOSHomeView, SUPRAOSLiveView, SUPRAOSMissionCanvasView, SUPRAOSProductRootView, SUPRAOSTwinCenterView, SUPRAOSUniverseView, SUPRAOSGlobalSearchView, SUPRAOSWorkspaceExplorerView
- **Chat**: SUPRAChatView
- **Univers**: UniverseDashboard, UniverseNavigator, UniverseSearch, UniverseTimeline
- **Workers**: WorkerPoolView
- **Design**: SUPRAOSDesignSystem, SUPRAOSFoundation

---

## 5. Services (16 identifiés)

- **Stores**: MissionStore, DecisionStore, ControlCenterStore
- **Runtime**: RuntimeDataService, RuntimeGateway, RuntimeMonitor, RuntimeConnectionState, RuntimeEventSource
- **Knowledge**: ConversationKnowledgeProvider, DecisionKnowledgeProvider, GitKnowledgeProvider, PDFKnowledgeProvider, ReportKnowledgeProvider, KnowledgeProvider (protocol)
- **Workspace**: WorkspaceGovernor, WorkspaceIndexer

---

## 6. Bridges / Adapters

| Bridge | Type | Connecte |
|--------|------|----------|
| CAnnoNicoIntegrationBridge | Bridge central | SUPRA → tous adapters |
| CAnnoNicoObject | Bridge model | Données CAnnoNico |
| OpenCodeBridge | Bridge CLI | SUPRA → OpenCode |
| OpenCodeClient | Client API | SUPRA → OpenCode |
| SUPRAChatRuntimeAdapter | Runtime adapter | Chat interne |
| SUPRAGabrielConductorRuntime | Conductor | Runtime Gabriel |
| NicoAppAdapter | Adapter (package) | SUPRA → NICO_APP iOS |
| VideoSwapAdapter | Adapter (package) | SUPRA → VideoSwap V3 |
| PucheroMemoryAdapter | Adapter (package) | SUPRA → Puchero Memory |

---

## 7. Projets Git (8 dépôts)

| Repo | Statut | Branche |
|------|--------|---------|
| SUPRA | Actif | develop |
| NICO_APP | Actif | - |
| NICO_APP_CLEAN | Actif | - |
| HELENE_APP (SUPRA_HELENE) | Actif | - |
| NOVA_BUILD_SYSTEM | Actif | - |
| COHERENCE_ENGINE_V1 | Abandonné | - |
| NICO_APP BACKUP | Abandonné | - |

---

## 8. Packages Swift (12 identifiés)

**Canonique**: CAnnoNicoIntegrationPackage (5 targets, utilisé par SUPRA)  
**Orphelin**: SUPRA_AST_PLATFORM (non référencé)  
**VideoSwap**: 6 packages V1 (legacy), 5 packages V3 (actif)

---

## 9. Doublants et Espace Récupérable

| Doublon | Type | Gain estimé |
|---------|------|-------------|
| DerivedData Xcode | Cache build | ~28 GB |
| Logs recovery Bureau | Fichiers logs | 236 MB |
| SUPRA_TEMP | Dossier temp | 33 MB |
| FREEZE_SUPRA_* 5 dossiers | Freezes | 12 MB |
| SUPRA_VIDEO_SWAP_V1 | Version legacy | 20 MB |
| SUPRA_PROJECTS | Références | 13 MB |
| SUPRA_BISECT | Fork | 17 MB |
| SUPRA_RECOVERY | 4 snapshots | 11 MB |
| **Total** | | **~28.3 GB** |

---

## 10. Actions de Nettoyage (13 identifiées)

**Haute priorité** (5):
1. Nettoyer DerivedData Xcode → 28 GB
2. Archiver logs recovery Bureau → 236 MB
3. Archiver SUPRA_TEMP → 33 MB
4. Archiver FREEZE_SUPRA_* → 12 MB
5. Renommer backups .bak

**Priorité moyenne** (5):
6-10: Archiver V1, Archiver PROJECTS, Fusionner RECOVERY, Choisir NICO_APP, Déplacer BISECT

**Basse priorité** (3):
11-13: Archive Desktop, DerivedData récurrent, Consolider HELENE

---

## 11. Références Croisées

- **Document canonique le plus important**: `SUPRA_WORKFLOW_V1.md`
- **Architecture**: `SUPRA_AI_LAB_ARCHITECTURE_V1.md`, `SUPRA_LAB_ARCHITECTURE_V1.md`
- **Routeur**: `SUPRA_ROUTER_SPECIFICATION_V1.md`
- **Modèles**: `SUPRA_MODEL_REGISTRY_V1.md`
- **Agents**: `SUPRA_AGENT_REGISTRY_V1.md`
- **Dépendances**: `DEPENDENCY_MAP.md`
- **Analyse runtime**: `SUPRA_EXECUTIVE_COCKPIT_V2_REPORT.md`
