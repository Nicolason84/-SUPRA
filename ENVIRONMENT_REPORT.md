# ENVIRONMENT REPORT — SUPRA ENVIRONMENT TWIN V1

**Date**: 2026-07-24T17:26:00Z  
**Machine**: Nicolas Alonso iMac (arm64, macOS 26.5)  
**Mission**: SUPRA_ENVIRONMENT_TWIN_V1

---

## 1. Architecture Globale

```
~/Desktop/NOVA_OS/SUPRA/              (29 GB)  ← CANONIQUE (build PASS)
~/Desktop/NOVA_OS/SUPRA_BISECT/       (17 MB)  ← copie bissection
~/Desktop/NOVA_OS/SUPRA_RECOVERY/     (11 MB)  ← 4 snapshots recovery
~/NOVA_OS/NICO_APP_IOS/               (5.3 GB) ← 3 projets iOS
~/NOVA_OS/HELENE_APP_IOS/             (0.4 MB) ← SUPRA_HELENE standalone
~/NOVA_BUILD_SYSTEM/                  (10 MB)  ← orchestration builds
~/NOVA_LABS/COHERENCE_ENGINE_V1/      (1.3 MB) ← web engine (abandonné)
~/Desktop/SUPRA_VIDEO_SWAP_V3/        (49 MB)  ← VideoSwap V3 (actif)
~/Desktop/SUPRA_VIDEO_SWAP_APP_V1/    (20 MB)  ← VideoSwap V1 (legacy)
~/Desktop/SUPRA_TEMP/                 (33 MB)  ← dossier temporaire
~/Desktop/SUPRA_PROJECTS/             (13 MB)  ← projets divers
```

### Flux de dépendances

```
NOVA_BUILD_SYSTEM (orchestre)
       │
       ▼
SUPRA ←→ CAnnoNicoIntegrationPackage ←→ NicoAppAdapter → NICO_APP
       │                                  VideoSwapAdapter → VideoSwap V3
       │                                  PucheroMemoryAdapter → Puchero Memory
       │
       ├──→ SUPRA_HELENE (intégré dans NICO_APP)
```

---

## 2. Carte des Projets

| Projet | Type | Statut | Build | Swift Files | Git | Taille |
|--------|------|--------|-------|-------------|-----|--------|
| **SUPRA** | macOS SwiftUI | **ACTIF** | PASS | 114 | oui (develop) | 29 GB |
| NICO_APP | iOS SwiftUI | ACTIF | ? | ~800 | oui | 1.7 MB |
| NICO_APP_CLEAN | iOS SwiftUI | ACTIF | ? | ~800 | oui | 5.3 GB |
| HELENE_APP | iOS SwiftUI | ACTIF | ? | ~200 | oui | 408 KB |
| SUPRA_VIDEO_SWAP_V3 | Multi-Package | ACTIF | ? | 293 | non | 49 MB |
| NOVA_BUILD_SYSTEM | Build/Python | ACTIF | - | 0 | oui | 10 MB |
| SUPRA_BISECT | macOS SwiftUI | ABANDONNÉ | ? | 29 | non | 17 MB |
| SUPRA_RECOVERY | 4 variantes | ABANDONNÉ | ? | 97 | non | 11 MB |
| SUPRA_VIDEO_SWAP_V1 | iOS/macOS App | LEGACY | ? | ~100 | non | 20 MB |
| COHERENCE_ENGINE_V1 | Web/JS | ABANDONNÉ | - | 0 | oui | 1.3 MB |
| SUPRA_TEMP | Dossier temp | ABANDONNÉ | - | 0 | non | 33 MB |

---

## 3. Graphe des Dépendances Détectées

### Bridges actifs (connectent SUPRA au monde extérieur)

| Bridge | Connecte | Via |
|--------|----------|-----|
| CAnnoNicoIntegrationBridge | SUPRA → tout | Canonical |
| NicoAppAdapter | SUPRA → NICO_APP | CAnnoNicoIntegrationPackage |
| VideoSwapAdapter | SUPRA → VideoSwap V3 | CAnnoNicoIntegrationPackage |
| PucheroMemoryAdapter | SUPRA → Puchero Memory | CAnnoNicoIntegrationPackage |
| SUPRAChatRuntimeAdapter | Interne SUPRA | - |
| SUPRAGabrielConductorRuntime | Interne SUPRA | - |
| OpenCodeBridge | SUPRA → OpenCode | - |

### Modules internes SUPRA (114 fichiers)

- **31 Vues SwiftUI** (ContentView, DashboardView, MissionCenterView, etc.)
- **15 Stores/Services** (MissionStore, DecisionStore, RuntimeDataService, etc.)
- **25 Engines/Moteurs** (ContextEngine, KnowledgeGraph, Twin*, Universe*, Workspace*)
- **6 Bridges** (CAnnoNico, OpenCode, ChatRuntime, GabrielConductor)
- **6 Adapters** (dans CAnnoNicoIntegrationPackage)
- **11 Modules Twin** (TwinAnalytics, TwinBindings, TwinComparison, etc.)
- **4 Registries** (TwinRegistry, WorkspaceIndexer, etc.)

---

## 4. Doublons Identifiés

| Type | Description | Risque |
|------|-------------|--------|
| Projet fork | SUPRA_RECOVERY (4 variantes, 97 fichiers) | Faible |
| Projet fork | SUPRA_BISECT (29 fichiers) | Faible |
| App duplicate | NICO_APP vs NICO_APP_CLEAN (5.3 GB) | **Moyen** |
| App duplicate | HELENE dans NICO_APP vs standalone | **Moyen** |
| Version duplicate | VideoSwap V1 (20 MB) vs V3 (49 MB) | **Moyen** |
| Logs recovery | 3 fichiers ~236 MB sur le Bureau | Faible |
| Freezes | 17 freezes/snapshots (~50 MB) | Faible |

**Espace total estimé récupérable**: ~350 MB (hors DerivedData Xcode)

---

## 5. Recommandations

1. **SUPRA est le seul projet canonique** — les autres sont des forks/snapshots
2. **Consolider SUPRA_RECOVERY dans SUPRA** après vérification des différences
3. **Supprimer SUPRA_BISECT** après stabilisation du build
4. **Nettoyer les logs recovery** sur le Bureau (236 MB)
5. **Choisir entre NICO_APP et NICO_APP_CLEAN** comme source unique
6. **Archiver les FREEZE_SUPRA_*** dans `_SUPRA_BACKUPS/`
7. **Purger SUPRA_TEMP** (33 MB de travail temporaire)
8. **Migrer VideoSwap V1 → V3** si V1 n'est plus utilisé
9. **Vider les DerivedData Xcode** (cause probable des 29 GB de SUPRA)
10. **Documenter le rôle de chaque projet** dans AGENTS.md

---

## 6. Modules Non Exploités (Orphelins)

| Module | Projet | Raison |
|--------|--------|--------|
| SUPRA_AST_PLATFORM | SUPRA | Package présent mais non référencé |
| COHERENCE_ENGINE | NOVA_LABS | HTML/JS, aucune intégration Swift |
| SUPRA_SCRIPTS | Desktop | Dossier vide |
| SUPRA_XCODE_IDENTITY | Desktop | Dossier vide |
| SUPRA_V4 | Desktop | Dossier vide |
