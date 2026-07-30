# ARCHITECTURE MAP — SUPRA FOUNDATION MEMORY V1

**Mission**: SUPRA_FOUNDATION_MEMORY_SYSTEM_V1  
**Date**: 2026-07-24T17:35:00Z

---

## 1. Architecture Logique

```
┌──────────────────────────────────────────────────────────┐
│                    UI LAYER (SwiftUI)                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐       │
│  │SUPRAApp  │  │ContentView│  │SUPRAOS Views (9) │       │
│  │@main     │  │(orphaned) │  │OS Shell layer    │       │
│  └────┬─────┘  └──────────┘  └──────────────────┘       │
│       │                                                  │
│  ┌────▼─────────────────────┐                            │
│  │  SupraControlCenterView  │                            │
│  └────┬────────────────┬────┘                            │
│       │                │                                 │
│  ┌────▼────┐    ┌──────▼──────┐                          │
│  │Decision │    │  Mission    │                          │
│  │ Inbox   │    │  Center     │                          │
│  └─────────┘    └─────────────┘                          │
├──────────────────────────────────────────────────────────┤
│                    SERVICE LAYER                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐       │
│  │Store     │  │Runtime   │  │Knowledge          │       │
│  │(3)       │  │Services  │  │Providers (5)      │       │
│  └──────────┘  └──────────┘  └──────────────────┘       │
├──────────────────────────────────────────────────────────┤
│                    ENGINE LAYER                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐│
│  │Knowledge │  │Executive │  │  Twin    │  │ Workspace││
│  │  Graph   │  │ Cockpit  │  │  System  │  │  Intel   ││
│  │(8 mods)  │  │(5 mods)  │  │(11 mods) │  │(7 mods)  ││
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘│
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐       │
│  │ Universe │  │ Context  │  │  Runtime         │       │
│  │ Engine   │  │ Engine   │  │  Monitor/Health  │       │
│  │(6 mods)  │  │(2 mods)  │  │  (5 mods)        │       │
│  └──────────┘  └──────────┘  └──────────────────┘       │
├──────────────────────────────────────────────────────────┤
│                    BRIDGE / ADAPTER LAYER                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐       │
│  │CAnnoNico │  │ OpenCode │  │Gabriel Conductor  │       │
│  │Bridge    │  │ Bridge   │  │Runtime            │       │
│  └────┬─────┘  └──────────┘  └──────────────────┘       │
│       │                                                  │
│  ┌────┴────┬────────┬────────────┐                       │
│  │Puchero  │NicoApp │VideoSwap   │                       │
│  │Memory   │Adapter │Adapter     │                       │
│  └─────────┴────────┴────────────┘                       │
├──────────────────────────────────────────────────────────┤
│                    PACKAGE LAYER                          │
│  ┌──────────────────────────────────────────┐            │
│  │  CAnnoNicoIntegrationPackage (5 targets) │            │
│  └──────────────────────────────────────────┘            │
└──────────────────────────────────────────────────────────┘
```

---

## 2. Architecture des Données

### Stores
```
ControlCenterStore ──> Snapshot, ArtifactStatus
DecisionStore      ──> Decision[] (chargement fichier)
MissionStore       ──> Mission[] (chargement fichier)
SUPRAExecutiveStore ──> modèles SUPRA* (dans ContentView)
```

### Flux de Données
```
ArtifactReader (fichiers locaux)
  └──→ ControlCenterStore
        └──→ SupraControlCenterView

FileManager (JSON)
  ├──→ DecisionStore ──→ DecisionInboxView
  └──→ MissionStore  ──→ MissionCenterView

Réseau local (URLSession)
  └──→ RuntimeGateway ──→ RuntimeMonitor
        └──→ RuntimeView
```

---

## 3. Architecture des Bridges

### Bridge CAnnoNico (intégration externe)
```
CAnnoNicoIntegrationBridge
  ├── import CAnnoNicoContracts (snapshot, references)
  ├── import PucheroMemoryAdapter (mémoire externe)
  ├── import NicoAppAdapter (NICO_APP iOS)
  └── import VideoSwapAdapter (VideoSwap engine)
```

### Bridge OpenCode (CLI)
```
OpenCodeBridge ←→ OpenCodeClient
  └── communication avec l'interface OpenCode
```

### Bridge Chat Runtime
```
SUPRAChatRuntimeAdapter ←→ SUPRAChatView
  └── adaptateur runtime pour les conversations
```

---

## 4. Architecture des Packages

### CAnnoNicoIntegrationPackage (canonique, local)
```
CAnnoNicoContracts (modèles partagés)
  ├── CAnnoNicoIntegrationSnapshot
  └── CAnnoNicoSourceReference

PucheroMemoryAdapter → dépend de Contracts
NicoAppAdapter      → dépend de Contracts
VideoSwapAdapter    → dépend de Contracts
CAnnoNicoIntegration (agrégateur)
  → dépend des 4 cibles ci-dessus
```

### SUPRA_AST_PLATFORM (orphelin)
Package présent dans le workspace mais non référencé dans le build.

---

## 5. Architecture des Freezes

Les 5 FREEZE_SUPRA_* sont des instantanés temporels du 23 juillet 2026:
- Architecture Index: état des index architecturaux
- Functional Authority: état des autorités fonctionnelles
- Graphs: état des graphes de dépendances
- Product Build: état du build produit
- Runtime Proof: état des preuves runtime

Tous sont à archiver dans `_SUPRA_BACKUPS/freezes/`.

---

## 6. Points d'Attention Architecturaux

1. **ContentView non instancié**: 11 sous-vues + SUPRAExecutiveStore compilés mais jamais utilisés
2. **OS Shell non connecté**: 9 vues SUPRAOS* non reliées à l'entry point
3. **Double architecture UI**: ControlCenter ET ContentView coexistent
4. **Package orphelin**: SUPRA_AST_PLATFORM présent mais non utilisé
5. **Bridges dupliqués**: NicoAppAdapter relie SUPRA à NICO_APP mais NICO_APP contient aussi SUPRA_HELENE
6. **Stores parallèles**: ControlCenterStore + DecisionStore + MissionStore + SUPRAExecutiveStore (interne à ContentView)
