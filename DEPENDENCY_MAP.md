# SUPRA Dependency Map V1

Mission : `SUPRA_DEPENDENCY_MAP_V1`  
Périmètre analysé :

- `SUPRA.xcodeproj/project.pbxproj`
- `SUPRA/ContentView.swift`
- `SUPRA/SUPRAApp.swift`

Analyse statique en lecture seule des sources. Ce rapport est le seul fichier créé.

## Synthèse

```text
SUPRAApp (@main)
└── SupraControlCenterView
    ├── ControlCenterStore
    │   ├── ArtifactReader
    │   └── Snapshot / ArtifactStatus
    ├── DecisionInboxView
    │   ├── DecisionStore
    │   ├── Decision
    │   ├── DecisionRow
    │   └── DecisionDetailView
    └── MissionCenterView
        ├── MissionStore
        ├── Mission
        ├── MissionRow
        └── MissionDetailView

ContentView (compilé dans la cible, mais non instancié par SUPRAApp)
├── SUPRAExecutiveStore et modèles SUPRA* déclarés dans ContentView.swift
├── SUPRAGabrielConductorRuntime / SUPRAGabrielConductorSnapshot
├── SUPRACAnnoNicoIntegration
│   └── package local CAnnoNicoIntegration
└── SwiftUI / Combine / AppKit / Foundation / CryptoKit
```

Le projet utilise un `PBXFileSystemSynchronizedRootGroup` sur le dossier `SUPRA`. En conséquence, les fichiers Swift présents dans ce dossier appartiennent implicitement à la cible, même si la phase `PBXSourcesBuildPhase` ne les énumère pas individuellement.

## 1. `SUPRA.xcodeproj/project.pbxproj`

### Cible et sources Swift

La cible macOS `SUPRA` produit `SUPRA.app`. Son groupe racine synchronisé inclut les 18 sources Swift suivantes :

| Rôle | Fichiers |
|---|---|
| Point d’entrée | `SUPRA/SUPRAApp.swift` |
| Views | `SUPRA/ContentView.swift`, `SUPRA/SupraControlCenterView.swift`, `SUPRA/DecisionInboxView.swift`, `SUPRA/DecisionRow.swift`, `SUPRA/DecisionDetailView.swift`, `SUPRA/MissionCenterView.swift`, `SUPRA/MissionRow.swift`, `SUPRA/MissionDetailView.swift` |
| Stores | `SUPRA/ControlCenterStore.swift`, `SUPRA/DecisionStore.swift`, `SUPRA/MissionStore.swift` |
| Models | `SUPRA/Snapshot.swift`, `SUPRA/Decision.swift`, `SUPRA/Mission.swift` |
| Lecture / intégration / runtime | `SUPRA/ArtifactReader.swift`, `SUPRA/CAnnoNicoIntegrationBridge.swift`, `SUPRA/SUPRAGabrielConductorRuntime.swift` |

### Package Swift local

```text
SUPRA target
└── product CAnnoNicoIntegration
    └── Packages/CAnnoNicoIntegrationPackage
        ├── CAnnoNicoContracts
        ├── PucheroMemoryAdapter ──> CAnnoNicoContracts
        ├── NicoAppAdapter ────────> CAnnoNicoContracts
        └── VideoSwapAdapter ──────> CAnnoNicoContracts
```

Le package est local, déclaré par `XCLocalSwiftPackageReference`, puis :

- ajouté à `packageProductDependencies` de la cible ;
- lié dans `PBXFrameworksBuildPhase` sous le produit `CAnnoNicoIntegration` ;
- défini avec Swift Tools 6.0 et une plateforme minimale macOS 14 ;
- sans dépendance SwiftPM distante déclarée.

Le produit agrège quatre targets/modules. `ContentView.swift` importe directement `CAnnoNicoContracts`. `CAnnoNicoIntegrationBridge.swift` importe les quatre modules et construit le snapshot d’intégration.

### Frameworks et réglages ayant un effet de dépendance

- SDK/cible : macOS, deployment target `26.5`.
- Swift de la cible : `SWIFT_VERSION = 5.0`, avec isolation par défaut `MainActor` et Approachable Concurrency.
- Framework produit explicitement lié : `CAnnoNicoIntegration`.
- Connexions réseau sortantes activées dans le sandbox.
- Accès aux fichiers choisis par l’utilisateur : lecture seule.
- Réseau local autorisé par la clé ATS générée.
- Aucune dépendance de cible Xcode (`dependencies = ()`).
- Aucun framework Apple n’est inscrit explicitement dans la phase Frameworks ; les modules Apple sont résolus via le SDK.

## 2. `SUPRA/ContentView.swift`

### Imports directs

| Module | Usage principal |
|---|---|
| `SwiftUI` | `View`, navigation, composants UI, property wrappers d’état |
| `Combine` | `ObservableObject`, `@Published` du store interne |
| `AppKit` | APIs macOS, notamment couleurs/espace de travail natifs |
| `Foundation` | fichiers, URL, JSON/Codable, réseau, dates, processus et données |
| `CryptoKit` | calcul/validation SHA-256 des actions |
| `CAnnoNicoContracts` | `CAnnoNicoIntegrationSnapshot` et `CAnnoNicoSourceReference` |

### Dépendances Swift externes au fichier

| Symbole utilisé | Déclaré dans | Relation |
|---|---|---|
| `SUPRAGabrielConductorSnapshot` | `SUPRA/SUPRAGabrielConductorRuntime.swift` | État du conducteur Gabriel |
| `SUPRAGabrielConductorRuntime` | `SUPRA/SUPRAGabrielConductorRuntime.swift` | Chargement et lancement du runtime Gabriel |
| `SUPRACAnnoNicoIntegration` | `SUPRA/CAnnoNicoIntegrationBridge.swift` | Fabrique le snapshot des adapters |
| `CAnnoNicoIntegrationSnapshot` | target package `CAnnoNicoContracts` | Modèle de snapshot d’intégration |
| `CAnnoNicoSourceReference` | target package `CAnnoNicoContracts` | Modèle de référence/source |

Le bridge CAnnoNico ajoute les dépendances transitives suivantes :

- `PucheroMemoryAdapter` ;
- `NicoAppAdapter` ;
- `VideoSwapAdapter` ;
- leurs types communs issus de `CAnnoNicoContracts`.

### Store

`ContentView` possède directement :

```swift
@StateObject private var store = SUPRAExecutiveStore()
```

`SUPRAExecutiveStore` est déclaré dans le même fichier. Il dépend de `Combine` (`ObservableObject`, `@Published`) et de `Foundation` pour charger/décoder les modèles et flux locaux. Il ne dépend pas de `ControlCenterStore`, `DecisionStore` ou `MissionStore`.

### Models déclarés dans le fichier

Les modèles et types métier directement contenus dans `ContentView.swift` sont :

- pont terminal : `SUPRATerminalMegabusEnvelope`, `SUPRATerminalMegabusBridge` ;
- preuves : `SUPRAMissionEvidencePayload`, `SUPRAMissionEvidenceLoader` ;
- intégrité : `SUPRASystemIntegritySnapshot`, `SUPRASystemIntegrityLoader` ;
- navigation humaine : `SUPRAStructureMode`, `SUPRAHumanStage` ;
- chat/actions : `SUPRAChatMessage`, `SUPRAChatRequest`, `SUPRAChatResponse`, `SUPRAActionManifest`, `SUPRAActionDefinition`, `SUPRAActionError`, `SUPRAActionRuntime` ;
- modèle exécutif : `SUPRAExecutiveModel`, `SUPRASystem`, `SUPRAMetrics`, `SUPRASection`, `SUPRARecord`, `SUPRASource`, `SUPRAAlert` ;
- flux sémantiques privés : `SUPRASemanticProjectsFeed`, `SUPRASemanticProject`, `SUPRASemanticProductsFeed`, `SUPRASemanticProduct`, `SUPRAFacadeCandidate`, `SUPRASemanticFacadeConnection`, `SUPRASemanticFeedError` ;
- live boards : `SUPRALiveSection`, `SUPRALiveSnapshot`.

### Views déclarées dans le fichier

- `ContentView` ;
- `SUPRALiveBoardsRootView` ;
- `SUPRAWorkspaceLiveView` ;
- `SUPRAArchitectureLiveView` ;
- `SUPRAAuthorityLiveView` ;
- `SUPRAStorageLiveView` ;
- `SUPRADecisionInboxLiveView` ;
- `SUPRASystemLiveView` ;
- composants privés `SUPRADetailPage`, `SUPRAHeader`, `SUPRAStatusCard`, `SUPRAActionCard`.

Ces views consomment le store et les modèles internes au fichier. Elles sont distinctes des views produit `DecisionInboxView` et `MissionCenterView` utilisées par le point d’entrée courant.

### Dépendances runtime hors compilation

Le fichier dépend également, à l’exécution, de ressources locales et de services système :

- arborescences sous `~/NOVA_OS/` pour Megabus, preuves de mission, intégrité, modèles exécutifs et live boards ;
- lecture/écriture JSON et fichiers atomiques via `FileManager`/`FileHandle` ;
- appels réseau locaux via `URLSession` ;
- lancement de processus/scripts via Foundation/AppKit ;
- contrôle d’intégrité SHA-256 via CryptoKit.

Ces chemins sont des dépendances de données/runtime, pas des packages Swift.

## 3. `SUPRA/SUPRAApp.swift`

### Dépendances directes

- importe `SwiftUI` ;
- déclare `SUPRAApp: App` comme point d’entrée `@main` ;
- crée une `WindowGroup` ;
- instancie `SupraControlCenterView`.

### Graphe transitif du point d’entrée actif

| View / Store | Dépendances |
|---|---|
| `SupraControlCenterView` | `ControlCenterStore`, `Snapshot`, `ArtifactStatus`, `DecisionInboxView`, `MissionCenterView` |
| `ControlCenterStore` | `ArtifactReader`, `Snapshot`, Foundation, Combine |
| `DecisionInboxView` | `DecisionStore`, `DecisionRow`, `DecisionDetailView`, `Decision` |
| `DecisionStore` | `Decision`, Foundation, Combine |
| `MissionCenterView` | `MissionStore`, `MissionRow`, `MissionDetailView`, `Mission` |
| `MissionStore` | `Mission`, Foundation, Combine |

`ContentView` n’est pas référencé par `SUPRAApp.swift` ni par `SupraControlCenterView`. Il est compilé parce qu’il se trouve dans le groupe synchronisé de la cible, mais il n’est pas actuellement atteignable depuis la hiérarchie de views lancée par `@main`.

## Matrice finale

| Fichier analysé | Swift/modules | Stores | Models | Views | Packages |
|---|---|---|---|---|---|
| `project.pbxproj` | Toutes les sources du groupe `SUPRA`, SDK macOS | 3 stores de la cible | `Snapshot`, `Decision`, `Mission` + modèles internes à `ContentView` | 8 fichiers de views + views internes | `CAnnoNicoIntegrationPackage` local |
| `ContentView.swift` | SwiftUI, Combine, AppKit, Foundation, CryptoKit, CAnnoNicoContracts, runtime Gabriel, bridge CAnnoNico | `SUPRAExecutiveStore` interne | Modèles `SUPRA*` internes + contrats CAnnoNico + snapshot Gabriel | `ContentView` et 11 sous-views/composants internes | Produit local `CAnnoNicoIntegration` via la cible |
| `SUPRAApp.swift` | SwiftUI | Transitif : `ControlCenterStore`, `DecisionStore`, `MissionStore` | Transitif : `Snapshot`, `ArtifactStatus`, `Decision`, `Mission` | Direct : `SupraControlCenterView`; transitif : Decision Inbox et Mission Center | Aucun import direct ; package lié au niveau de la cible |

## Observations structurantes

1. Deux architectures UI coexistent : le dashboard produit démarré par `SUPRAApp`, et l’interface exécutive monolithique de `ContentView`.
2. Les stores produit sont séparés (`ControlCenterStore`, `DecisionStore`, `MissionStore`) ; `ContentView` conserve son propre `SUPRAExecutiveStore` dans le même fichier.
3. Le package CAnnoNico est une dépendance de cible, donc disponible à toutes les sources, mais seuls `ContentView.swift` et `CAnnoNicoIntegrationBridge.swift` l’importent actuellement.
4. Le groupe Xcode synchronisé rend l’appartenance des sources implicite : ajouter un `.swift` sous `SUPRA/` modifie potentiellement le graphe de compilation sans nouvelle entrée explicite dans `project.pbxproj`.
