# BOOTSTRAP_ARCHITECTURE.md

## Architecture canonique du Runtime SUPRA — EXECUTIVE BOOTSTRAP V1

| Field | Value |
|-------|-------|
| **Version** | BOOTSTRAP_ARCH_V1 |
| **Date** | 2026-07-31 |
| **Autorité** | FACTORY_01_ARCHITECTURE — mission FOUNDATION ERA |
| **Statut** | SPECIFICATION — prêt pour implémentation sous décision exécutive |

---

## 1. Architecture cible — 4 couches

```
┌─────────────────────────────────────────────────────────────────────┐
│ DOMAIN LAYER                                                        │
│   Mission Runtime                                                   │
│   Mission → Decision → Execution → Evidence → Memory                │
│   Aucune connaissance : disque, chemins, migrations                 │
├─────────────────────────────────────────────────────────────────────┤
│ RUNTIME LAYER                                                        │
│   RuntimeDataService · MissionStore · DecisionStore · RuntimeMonitor │
│   Boot orchestration · État runtime · Événements                    │
│   Accès aux artefacts UNIQUEMENT via l'API du Registry               │
├─────────────────────────────────────────────────────────────────────┤
│ INFRASTRUCTURE LAYER                                                 │
│   ArtifactRegistry (accès artefacts)   ·  ContinuityEngine (persistance)│
│   ExecutiveBootstrap (environnement)   ·  BootReport / Diagnostics  │
│   Seule couche qui parle au système de fichiers                     │
├─────────────────────────────────────────────────────────────────────┤
│ FOUNDATION LAYER                                                     │
│   FileSystem Port (Application Support/SUPRA)                       │
│   Application Support · Security-Scoped Access · Atomic IO          │
│   Pas de logique : opérations élémentaires uniquement               │
└─────────────────────────────────────────────────────────────────────┘
```

**Règle de flux** : chaque couche ne dépend que de la couche directement inférieure. Une dépendance descendante directe vers `Foundation Layer` depuis `Runtime Layer` est **interdite** (violation de couche).

---

## 2. Responsabilités uniques

| Composant cible | Couche | Responsabilité unique | Remplacé |
|-----------------|--------|-----------------------|----------|
| `ExecutiveBootstrap` | Infrastructure | Préparer l'environnement d'exécution (1er lancement, version, création, installation, cohérence, rapport) | `ExecutiveBootManager` (partiel) |
| `ArtifactRegistry` | Infrastructure | Point d'accès unique aux artefacts — API sémantique, localisation, défauts, migration | `ArtifactReader`, lectures directes `ContinuityManager` |
| `ContinuityEngine` | Infrastructure | Reprise de session, snapshots, restauration, migrations, sync mémoire ↔ disque | `ContinuityManager` (partiel) |
| `FileSystemPort` | Foundation | Opérations élémentaires atomiques sur `Application Support/SUPRA` | `SUPRAEnvironmentResolver` + `FileManager` dispersés |
| `MissionRuntime` | Domain | Séquence métier Mission → Decision → Execution → Evidence → Memory | `SUPRAExecutionPipeline` + `SUPRAMissionExecutor` (orchestration, sans IO) |
| `BootOrchestrator` | Runtime | Séquence de boot métier : phasage, progression, états — sans IO directe | `ExecutiveBootManager` (orchestration) |

---

## 3. Contrats de couches

### 3.1 Foundation Layer — `FileSystemPort`

```
interface FileSystemPort {
    func url(for location: StorageLocation) throws -> URL      // résolution de localisation
    func read(_ location: StorageLocation) throws -> Data
    func write(_ data: Data, to location: StorageLocation) throws
    func exists(_ location: StorageLocation) -> Bool
    func createDirectory(_ location: StorageLocation) throws
    func list(_ location: StorageLocation) throws -> [String]
    func migrate(from: StorageLocation, to: StorageLocation) throws
}
```

- Atomicité garantie (écriture temp + rename).
- Aucune logique métier, aucune décision de défaut, aucune politique de version.
- Testable par injection de localisation (in-memory dans les tests).

### 3.2 Infrastructure Layer — accès artefacts

```
interface ArtifactRegistry {
    func runtimeStatus() -> RuntimeStatus
    func buildStatus() -> BuildStatus
    func continuity() -> ContinuityInfo
    func nextMission() -> MissionInfo
    func missionQueue() -> MissionQueue
    func diagnostics() -> RuntimeDiagnostics
    func bootReport() -> BootReport?
    func write(_ update: RegistryUpdate) throws          // seul point d'écriture Runtime→Registry
}
```

```
interface ContinuityEngine {
    func prepareSession() async throws -> SessionContext
    func snapshot() async throws -> SnapshotID
    func restore(_ id: SnapshotID) async throws -> SessionContext
    func migrateIfNeeded() async throws
    func syncMemoryToDisk() async throws
    func lastSession() -> SessionContext?
}
```

```
interface ExecutiveBootstrap {
    func run() async -> BootReport
    var phase: BootPhase { get }                          // FIRST_LAUNCH | VALIDATION | READY
    var environmentState: EnvironmentState { get }
}
```

### 3.3 Runtime Layer

Le Runtime consomme exclusivement les contrats ci-dessus. Il ne manipule jamais :

- `FileManager` directement
- `URL(fileURLWithPath:)` vers des artefacts
- des chaînes de chemins

### 3.4 Domain Layer

Le Mission Runtime consomme des modèles typés (décisions, missions, evidences) fournis par le Runtime. Il n'a **aucune** dépendance vers les couches Infrastructure/Foundation.

---

## 4. Séquences de boot

### 4.1 Premier lancement (`FIRST_LAUNCH`)

```
APP_START (main thread, < 10 ms de travail)
  │
  ├── LIGHT INIT (obligatoire avant fenêtre) :
  │     └── ExecutiveBootstrap.detectEnvironment() → FIRST_LAUNCH
  │          (lecture légère : existence d'un marqueur d'installation)
  │
  ▼
WINDOW_CREATED (UI immédiate, pas de blocage)
  │
  ▼
BOOT TASK (async, main actor libéré pendant les awaits)
  │
  ├── 1. PREPARE_ENVIRONMENT
  │     ├── créer Application Support/SUPRA
  │     ├── créer State/ Runtime/ Artifacts/ Continuity/ Snapshots/ Logs/ Cache/ Missions/
  │     └── installer les 8 artefacts minimaux (voir EXECUTIVE_BOOTSTRAP § 5.2)
  ├── 2. VERIFY_COHERENCE
  │     ├── chaque artefact installé = lisible + décodable + valide
  │     └── checksums enregistrés dans BOOT_REPORT.json
  ├── 3. PUBLISH_BOOT_REPORT
  │     └── BOOT_REPORT.json (statut : ENVIRONMENT_CREATED, artefacts : 8/8)
  └── 4. READY → runtimeStatus().state = .ready
```

**Garantie** : à l'issue du premier lancement, toute requête `runtimeStatus()`, `buildStatus()`, `continuity()`, `nextMission()`, `missionQueue()` retourne des valeurs **valides** — jamais `... not found`.

### 4.2 Lancements suivants (`VALIDATION`)

```
APP_START
  │
  ├── LIGHT INIT : detectEnvironment() → INSTALLED (marqueur présent)
  │
  ▼
BOOT TASK (async)
  │
  ├── 1. VALIDATE
  │     ├── vérifier chaque artefact attendu (lisible, décodable, cohérent)
  │     └── comparer version du workspace ↔ version des artefacts
  ├── 2. MIGRATE_IF_NEEDED
  │     └── ContinuityEngine.migrateIfNeeded() (politique de migration Registry)
  ├── 3. RESTORE_SESSION
  │     └── ContinuityEngine.restore(dernier snapshot) si disponible
  ├── 4. PUBLISH_REPORT
  │     └── BOOT_REPORT.json (statut : VALIDATED | MIGRATED | RESTORED)
  └── 5. READY
```

**Règle d'or** : jamais de réinstallation. `PREPARE_ENVIRONMENT` n'est exécuté que si `detectEnvironment() == FIRST_LAUNCH`.

---

## 5. États du Bootstrap

| État | Signification |
|------|---------------|
| `IDLE` | Bootstrap non exécuté |
| `FIRST_LAUNCH` | Aucun environnement — installation requise |
| `INSTALLED` | Environnement présent et cohérent |
| `VALIDATING` | Vérification des artefacts en cours |
| `MIGRATING` | Migration de version en cours |
| `READY` | Environnement valide, Runtime opérationnel |
| `DEGRADED` | Artefact manquant/corrompu mais service dégradé garanti |
| `FAILED` | Échec d'installation/vérification — rapport produit, jamais de crash silencieux |

En `DEGRADED`, le Registry retourne les valeurs par défaut spécifiées (ARTIFACT_REGISTRY_SPEC § 6) et le Runtime continue de fonctionner. **Jamais** d'affichage `... not found` : le défaut est sémantique.

---

## 6. Interdits formels (contraintes d'architecture)

| Interdit | Justification |
|----------|---------------|
| `FileManager.fileExists(atPath:)` dans les couches Runtime/Domain | Lecture directe du FS |
| `URL(fileURLWithPath:)` construit hors de la Foundation/Infrastructure | Fuite de chemins |
| `process.waitUntilExit()` dans le boot | Blocage main thread |
| Lecture directe des fichiers métier hors Registry | Violation du Single Artifact Access |
| Écriture hors `ArtifactRegistry.write` / `ContinuityEngine` | Violation du Single Persistence Owner |
| Réinstallation d'artefacts si l'environnement existe | Violation de Never Reinstall |

---

## 7. Compatibilité descendante

- Les artefacts actuels à la racine du workspace (`SUPRA_STATE.json`, `RUNTIME_STATUS.json`, `runtime_diagnostics.json`, `CONTINUITY.md`, `NEXT_MISSION.md`, `version.json`, `proofs/LOT*.json`, `MANIFEST.json`, `ESTATE_STATE.json`, `INDEX.json`) restent **lisibles** : le Registry les lit d'abord, puis bascule vers `Application Support/SUPRA` selon la politique de migration (MIGRATION_PLAN.md étape 3).
- Aucune fonctionnalité métier n'est modifiée pendant la transition.

---

## 8. Tests d'architecture

Les invariants ci-dessus sont vérifiables par analyse statique (`BootstrapGovernance` étendu) et par tests unitaires :

1. **LayeringTest** : aucune référence `FileManager`/`URL(fileURLWithPath:)` dans `Domain Layer` et `Runtime Layer`.
2. **RegistryAccessTest** : tout accès artefact passe par `ArtifactRegistry` (toute autre lecture est détectée).
3. **FirstLaunchTest** : environnement absent → 8/8 artefacts créés, `BOOT_REPORT` valide, aucune exception `not found`.
4. **SubsequentLaunchTest** : environnement présent → aucune création, validation + rapport.
5. **MainThreadTest** : aucune opération bloquante sur le main actor (profilage STARTUP_TIMELINE).
6. **MigrationTest** : version ancienne → migration → artefacts à jour, défauts corrects.

---

**END OF BOOTSTRAP_ARCHITECTURE** — produit par FACTORY_01_ARCHITECTURE, mission FOUNDATION ERA.
