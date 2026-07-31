# RUNTIME_LAYER_DIAGRAM.md

## Diagramme des couches du Runtime — EXECUTIVE BOOTSTRAP V1

| Field | Value |
|-------|-------|
| **Version** | RUNTIME_LAYER_DIAGRAM_V1 |
| **Date** | 2026-07-31 |
| **Autorité** | FACTORY_01_ARCHITECTURE — mission FOUNDATION ERA |
| **Statut** | SPECIFICATION |

---

## 1. Diagramme des couches

```
┌────────────────────────────────────────────────────────────────────────────────┐
│  DOMAIN LAYER — la logique métier                                              │
│                                                                                │
│  ┌──────────────────────────────────────────────────────────────────────────┐  │
│  │  MISSION RUNTIME                                                         │  │
│  │  Mission ──► Decision ──► Execution ──► Evidence ──► Memory              │  │
│  │  (MissionStore · DecisionStore · SUPRAMissionExecutor · Evidence ·       │  │
│  │   MultiMemoryStore)                                                      │  │
│  │                                                                          │  │
│  │  ZÉRO dépendance : disque · chemins · migrations · FileManager           │  │
│  └──────────────────────────────────────────────────────────────────────────┘  │
├────────────────────────────────────────────────────────────────────────────────┤
│  RUNTIME LAYER — l'état et l'orchestration                                    │
│                                                                                │
│  ┌───────────────────────┐  ┌───────────────────────┐  ┌───────────────────┐  │
│  │ RuntimeDataService    │  │ RuntimeMonitor        │  │ BootOrchestrator  │  │
│  │ (état runtime publié) │  │ (santé, événements)   │  │ (séquence de boot)│  │
│  └──────────┬────────────┘  └──────────┬────────────┘  └─────────┬─────────┘  │
│             │                          │                        │             │
│             └──────────┬───────────────┴────────────────────────┘             │
│                        │                                                      │
│                        ▼  (appels API uniquement — jamais de chemins)          │
├────────────────────────────────────────────────────────────────────────────────┤
│  INFRASTRUCTURE LAYER — l'accès et la persistance                              │
│                                                                                │
│  ┌───────────────────────────┐  ┌─────────────────────────────┐                │
│  │  ARTIFACT REGISTRY        │  │  CONTINUITY ENGINE          │                │
│  │  runtimeStatus()          │  │  prepareSession()           │                │
│  │  buildStatus()            │  │  snapshot() / restore()     │                │
│  │  continuity()             │  │  migrateIfNeeded()          │                │
│  │  nextMission()            │  │  syncMemoryToDisk()         │                │
│  │  missionQueue()           │  └──────────────┬──────────────┘                │
│  └────────────┬──────────────┘                 │                               │
│               │                                │                               │
│               ▼                                ▼                               │
│  ┌───────────────────────────────────────────────────────────────┐             │
│  │  EXECUTIVE BOOTSTRAP                                          │             │
│  │  (premier lancement · installation · cohérence · Boot Report) │             │
│  └────────────────────────────┬──────────────────────────────────┘             │
│                               │                                                │
│                               ▼                                                │
├────────────────────────────────────────────────────────────────────────────────┤
│  FOUNDATION LAYER — le système de fichiers                                     │
│                                                                                │
│  ┌─────────────────────────────────────────────────────────────┐               │
│  │  FILESYSTEM PORT                                            │               │
│  │  read / write(atomic) / exists / createDirectory / migrate  │               │
│  │  cible : ~/Library/Application Support/SUPRA/               │               │
│  │  (State · Runtime · Artifacts · Continuity · Snapshots ·     │               │
│  │   Logs · Cache · Missions)                                  │               │
│  └─────────────────────────────────────────────────────────────┘               │
└────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Règles de dépendance

| Règle | Énoncé |
|-------|--------|
| R1 | Chaque couche ne dépend que de la couche **directement inférieure** |
| R2 | Aucune dépendance ascendante (Domain n'est jamais importé par Infrastructure) |
| R3 | Aucun saut de couche (Runtime n'importe jamais Foundation directement) |
| R4 | Seule l'Infrastructure accède au système de fichiers |
| R5 | Seul le Registry expose des artefacts ; seul le ContinuityEngine persiste |
| R6 | Le Bootstrap est le seul créateur de l'environnement |

### Violations actuelles à éliminer (mapping as-is → to-be)

| Composant actuel | Violation | Cible |
|------------------|-----------|-------|
| `ExecutiveBootManager` | lit `fm.contents(atPath:)` à la racine (7 fichiers) | `BootOrchestrator` (Runtime) + `ExecutiveBootstrap` (Infrastructure) |
| `ExecutiveBootManager` | `process.waitUntilExit()` (git) | suppression — lecture git async par le Bootstrap, stockée dans SUPRA_STATE.json |
| `ContinuityManager` | lit 9+ fichiers racine, spawn git bloquant | `ContinuityEngine` + `ArtifactRegistry` |
| `ArtifactReader` | `URL(fileURLWithPath:)` câblés en dur | `ArtifactRegistry` |
| `SUPRAEnvironmentResolver` | expose `projectRoot` (chemins bruts) | remplacé par `FileSystemPort` (résolution encapsulée) |

---

## 3. Composants cibles par couche

### 3.1 Domain Layer
- `MissionRuntime` (Mission → Decision → Execution → Evidence → Memory)
- `MissionStore` · `DecisionStore` · `SUPRAMissionExecutor` · `MultiMemoryStore` · modèles métier

### 3.2 Runtime Layer
- `BootOrchestrator` (séquence de boot sans IO)
- `RuntimeDataService` (état publié)
- `RuntimeMonitor` · `SUPRARuntimeEvents` · `ControlTowerState`

### 3.3 Infrastructure Layer
- `ExecutiveBootstrap` · `ArtifactRegistry` · `ContinuityEngine`
- `BootReport` / diagnostics typés

### 3.4 Foundation Layer
- `FileSystemPort` (Application Support/SUPRA)
- `AtomicFileWriter` · `StorageLocations` (enum des localisations)

---

## 4. Flux de données cible

```
                 ┌─────────────┐
                 │    UI       │  (inchangée — aucune nouvelle UI)
                 └──────┬──────┘
                        │  valeurs publiées
                        ▼
   ┌────────────────────────────────────┐
   │ RUNTIME LAYER (RuntimeDataService) │
   └──────┬─────────────────────────┬───┘
          │  runtimeStatus()        │  continuity() / nextMission()
          ▼                         ▼
   ┌─────────────────────┐   ┌─────────────────────┐
   │  ARTIFACT REGISTRY  │   │  CONTINUITY ENGINE  │
   └──────┬──────────────┘   └──────────┬──────────┘
          │        │  write(update)     │  snapshot()/sync
          ▼        ▼                    ▼
   ┌─────────────────────────────────────────────┐
   │  FILESYSTEM PORT — Application Support/SUPRA │
   └─────────────────────────────────────────────┘
```

---

## 5. Budget de couches (ce qui est interdit par couche)

| Couche | Interdit | Autorisé |
|--------|----------|----------|
| Domain | tout IO, tout chemin, tout `FileManager` | modèles, séquences métier, règles |
| Runtime | IO direct, `URL(fileURLWithPath:)` | état, orchestration, événements — via API Registry/ContinuityEngine |
| Infrastructure | logique métier, UI | accès, persistance, migration, défauts sémantiques |
| Foundation | logique, décisions de défaut | opérations élémentaires atomiques |

---

## 6. Prêt pour les évolutions

| Évolution future | Sans augmentation de couplage grâce à |
|------------------|---------------------------------------|
| Nouvel artefact | ajout au catalogue Registry + modèle typé |
| Nouvelle version de schéma | migration déclarative dans le Registry |
| Nouveau support de persistance (iCloud, SQLite) | remplacement de `FileSystemPort` (protocole) |
| Nouvelle source d'artefacts (réseau, API) | nouvelle implémentation de port en Foundation |
| Nouvelle séquence métier | Mission Runtime seul modifié (Domain) |

---

**END OF RUNTIME_LAYER_DIAGRAM** — produit par FACTORY_01_ARCHITECTURE, mission FOUNDATION ERA.
