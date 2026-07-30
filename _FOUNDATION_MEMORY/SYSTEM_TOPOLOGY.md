# SYSTEM TOPOLOGY — SUPRA FOUNDATION MEMORY V1

**Mission**: SUPRA_FOUNDATION_MEMORY_SYSTEM_V1  
**Date**: 2026-07-24T17:35:00Z

---

## 1. Topologie Physique

```
┌─────────────────────────────────────────────────────┐
│                iMac arm64 — macOS 26.5               │
│  ~29 GB utilisés sur le disque (dont 28 GB DD)      │
│                                                       │
│  ~/Desktop/         (29 GB) — espace de travail      │
│  ~/NOVA_OS/         (5.3 GB) — projets iOS           │
│  ~/NOVA_BUILD_SYSTEM (10 MB) — orchestration         │
│  ~/NOVA_LABS/       (1.3 MB) — R&D                   │
│  ~/Documents/       (12 KB) — minimal                │
└─────────────────────────────────────────────────────┘
```

---

## 2. Topologie des Projets

```
Desktop/NOVA_OS/
├── SUPRA/                     [29 GB]  ← CANONIQUE — macOS App
│   ├── SUPRA/                  (114 .swift)
│   ├── Packages/               (CAnnoNicoIntegrationPackage)
│   ├── SUPRA_AST_PLATFORM/     (orphan)
│   ├── FREEZE_SUPRA_*×5/       (à archiver)
│   ├── _SUPRA_BACKUPS/          
│   ├── _MISSIONS/              
│   ├── _VERIFICATIONS/          
│   ├── docs/                   
│   ├── Artifacts/              
│   └── SUPRA.xcodeproj/        
│
├── SUPRA_BISECT/              [17 MB]  ← ABANDONNÉ
│   ├── SUPRA/                  (29 .swift)
│   └── SUPRA.xcodeproj/
│
├── SUPRA_RECOVERY/            [11 MB]  ← ABANDONNÉ
│   ├── CHAT/                   
│   ├── BRIDGE/                 
│   ├── HEALTH/                 
│   └── BASELINE/               
│
├── MEMORY_CORE/               [0 B]
└── _IMMUNITY/                 [0 B]

NOVA_OS/
├── NICO_APP_IOS/
│   ├── NICO_APP/              [1.7 MB] ← ACTIF — iOS App
│   ├── NICO_APP_CLEAN/        [5.3 GB] ← DUPLICATE
│   └── NICO_APP_BACKUP*/      [GIT]    ← ABANDONNÉ
└── HELENE_APP_IOS/
    └── SUPRA_HELENE/           [408 KB] ← ACTIF — iOS App standalone

Desktop/
├── SUPRA_VIDEO_SWAP_V3/       [49 MB]  ← ACTIF — Multi-package
├── SUPRA_VIDEO_SWAP_APP_V1/   [20 MB]  ← LEGACY
├── SUPRA_TEMP/                [33 MB]  ← TEMPORAIRE
├── SUPRA_PROJECTS/            [13 MB]  ← ARCHIVE
├── SUPRA_SCRIPTS/             [0 B]    ← VIDE
└── SUPRA_* log/txt files      [236 MB] ← LOGS RECOVERY
```

---

## 3. Topologie des Dépendances Réseau

```
                    ┌──────────────────┐
                    │  SUPRA (macOS)    │
                    │  Build: PASS      │
                    └────────┬─────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
   ┌──────────────────┐ ┌──────────┐ ┌──────────────┐
   │CAnnoNicoIntegration│ │OpenCode  │ │Gabriel        │
   │Package            │ │Bridge    │ │ConductorRuntime│
   │(local SPM)       │ │          │ │               │
   └────────┬─────────┘ └──────────┘ └──────────────┘
            │
    ┌───────┼───────┬───────┐
    │       │       │       │
    ▼       ▼       ▼       ▼
  Contracts Puchero NicoApp VideoSwap
            Memory  Adapter Adapter
              │       │       │
              │       ▼       │
              │   NICO_APP    │
              │   (iOS)       │
              │               ▼
              │        SUPRA_VIDEO_
              │        SWAP_V3
              │
              ▼
        Puchero Memory
        (externe)
```

---

## 4. Topologie des Vues SwiftUI

```
SUPRAApp.swift (@main)
  └── SupraControlCenterView
        ├── ControlCenterStore
        ├── DashboardView
        ├── DecisionInboxView
        │     ├── DecisionStore
        │     ├── DecisionRow
        │     └── DecisionDetailView
        └── MissionCenterView
              ├── MissionStore
              ├── MissionRow
              ├── MissionDetailView
              ├── MissionTimelineView
              └── MissionGraphView

[Non instancié]
  ContentView
    ├── 11 sous-vues internes
    ├── SUPRAExecutiveStore (interne)
    └── [Gabriel Conductor, CAnnoNico, divers modèles]

[OS Shell — non relié à l'entry point]
  SUPRAOSCommandCenterView
    ├── SUPRAOSHomeView
    ├── SUPRAOSLiveView
    ├── SUPRAOSMissionCanvasView
    ├── SUPRAOSProductRootView
    ├── SUPRAOSTwinCenterView
    ├── SUPRAOSUniverseView
    ├── SUPRAOSGlobalSearchView
    └── SUPRAOSWorkspaceExplorerView

[Autres vues indépendantes]
  RuntimeView, SettingsView, SUPRAChatView,
  WorkerPoolView, EvidenceExplorerView,
  CockpitNavigation, SUPRAExecutiveCockpitView

[Univers]  
  UniverseDashboard, UniverseNavigator,
  UniverseSearch, UniverseTimeline
```

---

## 5. Topologie des Engines

```
Knowledge Graph
  ├── KnowledgeGraph (central)
  ├── KnowledgeAuthority
  ├── KnowledgeExplorer
  ├── KnowledgeIdentity
  ├── KnowledgeLineage
  ├── KnowledgeRelation / Relationship
  ├── KnowledgeSource
  ├── KnowledgeStatistics
  └── KnowledgeContextEngine

Executive Cockpit
  ├── ExecutiveCockpitFoundation
  ├── ExecutiveGraph
  ├── ExecutiveMemory
  ├── ExecutiveSearch
  └── ExecutiveTimeline

Twin System
  ├── TwinAnalytics
  ├── TwinBindings
  ├── TwinComparison
  ├── TwinExplorer
  ├── TwinFactory
  ├── TwinIdentity
  ├── TwinLifecycle
  ├── TwinRegistry
  ├── TwinRenderer
  ├── TwinSynchronizer
  └── TwinUniverse

Universe Engine
  ├── UniverseEngine
  ├── UniverseGraph
  ├── UniverseDashboard
  ├── UniverseNavigator
  ├── UniverseSearch
  └── UniverseTimeline

Workspace Intelligence
  ├── WorkspaceGovernor
  ├── WorkspaceIndexer
  ├── WorkspaceKnowledgeGraph
  ├── WorkspaceMemory
  ├── WorkspaceDiscovery
  ├── WorkspaceRecommendation
  └── WorkspaceStatistics

Context Engine
  ├── ContextEngine
  └── KnowledgeContextEngine
```

---

## 6. Topologie des Freezes et Archives

```
FREEZES ACTIFS (dans SUPRA/)
  FREEZE_SUPRA_ARCHITECTURE_INDEX_20260723T104017Z/
  FREEZE_SUPRA_FUNCTIONAL_AUTHORITY_20260723T105323Z/
  FREEZE_SUPRA_GRAPHS_20260723T103701Z/
  FREEZE_SUPRA_PRODUCT_BUILD_20260723T120033Z/
  FREEZE_SUPRA_RUNTIME_PROOF_20260723T120605Z/

SNAPSHOTS (SUPRA_RECOVERY/)
  CHAT/    BRIDGE/    HEALTH/    BASELINE/

VIDEOSWAP FREEZES (dans V1 et V3)
  FINAL_PATCH_V1_20260715_123604/
  FOUNDATION_CORE_V1_20260715_162406/
  MEDIA_ENGINE_V1_20260715_163015/
  IMPORT_ENGINE_V1_20260715_165840/
  URL_ENGINE_V1_20260715_171912/

LOGS RECOVERY (sur Bureau ~236 MB)
  SUPRA_TOTAL_RECOVERY_20260724_152930.txt
  SUPRA_TOTAL_RECOVERY_20260724_153101.txt
  SUPRA_RECOVERY_V2_20260724_153402.txt
```
