# ARTIFACT_REGISTRY_SPEC.md

## Spécification du registre central des artefacts — V1

| Field | Value |
|-------|-------|
| **Version** | ARTIFACT_REGISTRY_SPEC_V1 |
| **Date** | 2026-07-31 |
| **Autorité** | FACTORY_01_ARCHITECTURE — mission FOUNDATION ERA |
| **Statut** | SPECIFICATION |
| **Localisation cible** | `~/Library/Application Support/SUPRA/` |

---

## 1. Objectif

Supprimer **toute lecture directe du système de fichiers depuis les modules Runtime**.

Le Registry est l'**unique** point d'accès aux artefacts. Le Runtime appelle une API sémantique — jamais une API de chemins.

```
AVANT (interdit à terme)                     APRÈS (cible)
─────────────────────────                    ─────────────────────────
fm.contents(atPath:                          ArtifactRegistry.shared
  "\(projectRoot)/RUNTIME_STATUS.json")        .runtimeStatus()
                                              ArtifactRegistry.shared
URL(fileURLWithPath:                            .buildStatus()
  "\(projectRoot)/BUILD_STATUS.md")          ArtifactRegistry.shared
                                                .continuity()
String(contentsOf: ...)                       ArtifactRegistry.shared
                                                .nextMission()
                                              ArtifactRegistry.shared
                                                .missionQueue()
```

---

## 2. Responsabilités

Le Registry décide :

| Décision | Détail |
|----------|--------|
| **Où lire** | Localisation physique de chaque artefact (Application Support/SUPRA, avec repli compatible sur le workspace historique) |
| **Où écrire** | Écriture atomique via `FileSystemPort`, sous `State/ Runtime/ Artifacts/ Continuity/ Missions/` |
| **Comment migrer** | Politique de version : lecture → migration → écriture, orchestrée avec `ContinuityEngine` |
| **Quelles valeurs par défaut retourner** | Chaque API retourne un modèle typé **toujours valide**, jamais un état `not found` |

---

## 3. Catalogue d'artefacts (V1)

| Artefact | Localisation canonique | Modèle retourné | Source actuelle |
|----------|------------------------|-----------------|-----------------|
| `SUPRA_STATE.json` | `State/` | `RuntimeState` | racine workspace |
| `RUNTIME_STATUS.json` | `Runtime/` | `RuntimeStatus` | racine workspace |
| `runtime_diagnostics.json` | `Runtime/` | `RuntimeDiagnostics` | racine workspace |
| `BOOT_REPORT.json` | `Runtime/` | `BootReport` | (nouveau) |
| `BUILD_STATUS.md` | `Continuity/` | `BuildStatus` | racine workspace (absent → anomalie résiduelle) |
| `CONTINUITY.md` | `Continuity/` | `ContinuityInfo` | racine workspace |
| `NEXT_MISSION.md` | `Continuity/` | `MissionInfo` | racine workspace |
| `MISSION_QUEUE.json` | `Missions/` | `MissionQueue` | (nouveau) |
| `MANIFEST.json` | `Artifacts/` | `ArtifactManifest` | racine workspace |
| `INDEX.json` | `Artifacts/` | `ArtifactIndex` | racine workspace |
| `ESTATE_STATE.json` | `Artifacts/` | `EstateState` | racine workspace |
| `proofs/LOT{1,2,3}_INSTALLATION_PROOF.json` | `Artifacts/proofs/` | `LotProof[]` | `proofs/` workspace |
| `version.json` | `State/` | `WorkspaceVersion` | racine workspace |
| `Snapshots/*` | `Snapshots/` | `Snapshot` | (nouveau, via ContinuityEngine) |
| `Logs/*` | `Logs/` | — | (nouveau) |

---

## 4. API publique (contrat V1)

```swift
public struct ArtifactRegistry {
    public static let shared: ArtifactRegistry

    // Lecture sémantique — jamais de nil « not found »
    public func runtimeStatus() -> RuntimeStatus
    public func buildStatus() -> BuildStatus
    public func continuity() -> ContinuityInfo
    public func nextMission() -> MissionInfo
    public func missionQueue() -> MissionQueue
    public func diagnostics() -> RuntimeDiagnostics
    public func manifest() -> ArtifactManifest
    public func index() -> ArtifactIndex
    public func estate() -> EstateState
    public func lotProofs() -> [LotProof]
    public func version() -> WorkspaceVersion
    public func bootReport() -> BootReport?

    // Écriture — seul point d'entrée d'écriture pour le Runtime
    public func write(_ update: RegistryUpdate) throws

    // Support
    public func refresh()                    // revalidation après migration/externe
    public func register(observer: RegistryObserver)  // notification de changement
}
```

### 4.1 Sémantique des appels du Runtime

| Appel | Retour garanti | Si artefact absent/corrompu |
|-------|----------------|------------------------------|
| `runtimeStatus()` | `RuntimeStatus` | `.degraded` avec raisons structurées — état runtime valide |
| `buildStatus()` | `BuildStatus` | `.unknown` + `reason: "ARTIFACT_MISSING"` |
| `continuity()` | `ContinuityInfo` | session vide **valide** (`currentMission: nil`, `resumeAvailable: false`) |
| `nextMission()` | `MissionInfo` | mission par défaut `FOUNDATION ERA` (premier lancement) |
| `missionQueue()` | `MissionQueue` | file vide **valide** (`items: []`) |
| `diagnostics()` | `RuntimeDiagnostics` | diagnostics de repli avec statuts `UNAVAILABLE` — jamais de crash |

**Règle** : un appel Registry ne throw jamais pour une absence d'artefact. Les échecs sont **encodés dans le modèle de retour** (statut + raison), ce qui supprime la classe entière des bugs `... not found`.

---

## 5. Politique de localisation (où lire / où écrire)

```
Ordre de résolution (read) :
  1. Application Support/SUPRA/<dossier>/<artefact>     (canonique)
  2. Racine workspace (compatibilité descendante, lire seul)
  3. Aucune → retour du défaut sémantique (§ 6)

Politique (write) :
  → Toujours Application Support/SUPRA (canonique), écriture atomique.
  → Ne jamais écrire à la racine du workspace (le workspace reste la vérité Git, pas le stockage runtime).
```

La politique de résolution est **encapsulée** dans le Registry. Le Runtime n'a aucun moyen (ni besoin) de connaître la localisation.

---

## 6. Valeurs par défaut (politique de repli)

| API | Défaut retourné |
|-----|-----------------|
| `runtimeStatus()` | `RuntimeStatus(state: .ready, environment: .created, build: .unknown, artifacts: [:])` |
| `buildStatus()` | `BuildStatus(status: .unknown, version: version.workspace, detail: "not installed yet")` |
| `continuity()` | `ContinuityInfo(currentMission: nil, previousMission: nil, nextMission: defaultMission, snapshotAvailable: false)` |
| `nextMission()` | `MissionInfo(id: "foundation-era", title: "FOUNDATION ERA", priority: .critical)` |
| `missionQueue()` | `MissionQueue(items: [], active: nil, status: .idle)` |

Tous les défauts sont **cohérents entre eux** : après un premier lancement, `continuity().nextMission` == `nextMission().title`.

---

## 7. Politique de migration

```
migrate(artefact, fromVersion, toVersion):
  1. si fromVersion == toVersion        → rien
  2. si fromVersion < toVersion          → appliquer les migrations ordonnées
       migrations[fromVersion...toVersion]
  3. si fromVersion > toVersion          → marquer downgrade, refuser, rapporter
```

Les migrations sont **spécifiques par artefact** et déclarées dans le Registry (table `migrations`), exécutées par `ContinuityEngine.migrateIfNeeded()`.

---

## 8. Modèles typés (contrats minimaux)

```swift
public struct RuntimeStatus: Codable {
    public var state: RuntimeState            // .ready | .degraded
    public var environment: EnvironmentState  // .created | .validated | .migrated
    public var build: BuildStatus
    public var artifacts: [String: ArtifactHealth]
}

public struct BuildStatus: Codable {
    public var status: BuildVerdict           // .succeeded | .failed | .unknown
    public var version: String
    public var detail: String
}

public struct ContinuityInfo: Codable {
    public var currentMission: String?
    public var previousMission: String?
    public var nextMission: String?
    public var snapshotAvailable: Bool
    public var lastSessionEnd: Date?
}

public struct MissionInfo: Codable {
    public var id: String
    public var title: String
    public var priority: String
    public var status: String
}

public struct MissionQueue: Codable {
    public var items: [MissionInfo]
    public var active: MissionInfo?
    public var status: QueueStatus
}

public struct BootReport: Codable {
    public var bootID: String
    public var launchedAt: Date
    public var launchKind: LaunchKind           // .firstLaunch | .validation | .migration
    public var environmentStatus: EnvironmentState
    public var artifactsInstalled: [String]
    public var artifactsValidated: [String]
    public var checksums: [String: String]
    public var warnings: [String]
}
```

---

## 9. Interdictions (validation statique)

La règle du Single Artifact Access est contrôlée par analyse statique :

| Pattern interdit (hors Infrastructure Layer) | Référence |
|-----------------------------------------------|-----------|
| `FileManager.default.fileExists(...)` | BootManager, ContinuityManager, ArtifactReader (état actuel) |
| `URL(fileURLWithPath:)` | ArtifactReader, ContinuityManager (état actuel) |
| `fm.contents(atPath:)` | BootManager, ContinuityManager (état actuel) |
| `String(contentsOf: url)` | ArtifactReader (état actuel) |
| Lecture directe des fichiers métier | tout module Domain/Runtime |

Toute occurrence dans les couches Domain/Runtime après migration = violation → blocage au gate QUALITY (FACTORY_07).

---

## 10. Définition de Done du Registry

| Critère | Preuve |
|---------|--------|
| API V1 complète et typée | tests unitaires des 8 appels lecture + write |
| Aucune occurrence des patterns interdits dans Runtime/Domain | rapport d'analyse statique (BootstrapGovernance étendu) |
| Défauts sémantiques vérifiés sur environnement vierge | FirstLaunchTest : les 8 appels retournent des modèles valides |
| Migration versionnée par artefact | MigrationTest v2.0 → v2.2 |
| Compatibilité descendante workspace | LegacyArtifactTest : lecture des artefacts racine existants |

---

**END OF ARTIFACT_REGISTRY_SPEC** — produit par FACTORY_01_ARCHITECTURE, mission FOUNDATION ERA.
