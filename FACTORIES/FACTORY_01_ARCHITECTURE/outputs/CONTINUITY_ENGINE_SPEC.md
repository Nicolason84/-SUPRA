# CONTINUITY_ENGINE_SPEC.md

## Spécification du moteur de continuité — V1

| Field | Value |
|-------|-------|
| **Version** | CONTINUITY_ENGINE_SPEC_V1 |
| **Date** | 2026-07-31 |
| **Autorité** | FACTORY_01_ARCHITECTURE — mission FOUNDATION ERA |
| **Statut** | SPECIFICATION |
| **Localisation cible** | `~/Library/Application Support/SUPRA/` |

---

## 1. Objectif

Faire des fichiers un **support de persistance** — jamais la logique métier.

Le `ContinuityEngine` est l'unique responsable de la persistance :

| Responsabilité | Contenu |
|----------------|---------|
| Reprise de session | Restaurer le contexte de la session précédente au démarrage |
| Snapshots | Capturer l'état runtime à des points déterministes |
| Restauration | Recharger un snapshot (dernier, ou explicite) |
| Migrations | Faire évoluer le format des artefacts entre versions |
| Synchronisation mémoire ↔ disque | Flush déterministe de l'état mémoire vers le disque |

---

## 2. Cycle de vie

```
                    ┌──────────────┐
                    │   APP START  │
                    └──────┬───────┘
                           ▼
                  ┌─────────────────┐
                  │ detectEnvironment│─── FIRST_LAUNCH ──► ExecutiveBootstrap.prepareEnvironment()
                  └────────┬────────┘
                           │ INSTALLED
                           ▼
                  ┌─────────────────┐
                  │  migrateIfNeeded │─── migrations versionnées
                  └────────┬────────┘
                           ▼
                  ┌─────────────────┐
                  │ restoreSession  │─── dernier snapshot valide
                  └────────┬────────┘
                           ▼
                  ┌─────────────────┐
                  │  runtime actif   │
                  └────────┬────────┘
                           ▼
                  ┌─────────────────┐
                  │ syncMemoryToDisk │─── à chaque point de cohérence
                  └────────┬────────┘
                           ▼
                  ┌─────────────────┐
                  │  snapshot()      │─── fin de session / événement majeur
                  └─────────────────┘
```

---

## 3. Interface publique (contrat V1)

```swift
public final class ContinuityEngine {
    public static let shared: ContinuityEngine

    // Reprise
    public func prepareSession() async throws -> SessionContext
    public func lastSession() -> SessionContext?

    // Snapshots
    public func snapshot() async throws -> SnapshotID
    public func restore(_ id: SnapshotID) async throws -> SessionContext
    public func availableSnapshots() -> [SnapshotInfo]

    // Migrations
    public func migrateIfNeeded() async throws
    public var schemaVersion: Int { get }

    // Synchronisation
    public func syncMemoryToDisk() async throws
    public func scheduleSync(every interval: TimeInterval)   // Timer différé, hors main actor

    // Support
    public func register(store: ContinuityStore)             // stores métier participant à la continuité
}
```

---

## 4. Session et continuité

### 4.1 SessionContext

```swift
public struct SessionContext: Codable {
    public var sessionID: String
    public var startedAt: Date
    public var previousSessionID: String?
    public var mission: MissionInfo?
    public var runtime: RuntimeStatus
    public var snapshots: [SnapshotInfo]
    public var divergence: DivergenceReport?      // si version workspace ≠ version artefacts
}
```

### 4.2 Reprise de session

```
prepareSession():
  1. dernière session connue (CONTINUITY.md + SUPRA_STATE.json via Registry)
  2. divergence éventuelle (version workspace ↔ version artefacts) → rapport structuré
  3. restauration du dernier snapshot valide si disponible
  4. publication du contexte au Runtime (RuntimeDataService) — aucune lecture directe
```

En l'absence de session antérieure : `SessionContext` **vide mais valide** (jamais d'erreur `not found`).

---

## 5. Snapshots

### 5.1 Politique de capture

| Déclencheur | Type | Cadence |
|-------------|------|---------|
| Fin de boot | `BOOT` | 1 par lancement |
| Fin de session / quittage | `SESSION_END` | 1 par session |
| Événement majeur (décision, certification) | `EVENT` | sur occurrence |
| Timer de synchronisation | `PERIODIC` | intervalle configurable (défaut : non actif en V1, à la demande) |

### 5.2 Format

```
Snapshots/
└── snapshot_<ISO8601>.json
    {
      "id": "snap_<UUID>",
      "capturedAt": "<ISO8601>",
      "kind": "BOOT" | "SESSION_END" | "EVENT" | "PERIODIC",
      "sessionID": "...",
      "payload": { ...état runtime sérialisé... },
      "checksum": "sha256:...",
      "supraVersion": "2.2.0"
    }
```

### 5.3 Rétention (V1)

| Politique | Valeur |
|-----------|--------|
| Conservation | 10 derniers snapshots |
| Élagage | au-delà de 10, suppression du plus ancien, sauf `SESSION_END` récents (3 conservés) |
| Corruption | checksum invalide → snapshot ignoré, avertissement dans le Boot Report |

---

## 6. Migrations

### 6.1 Principe

La version du workspace est la référence (`version.json`, `supra_state_version`). Le moteur compare la version des artefacts installés et applique les migrations **ordonnées** du Registry.

```
migrateIfNeeded():
  targetVersion = version.workspace            (ex. 2.2.0)
  currentVersion = artefacts[].schemaVersion
  si currentVersion == targetVersion → retour
  si currentVersion < targetVersion  → exécuter migrations[currentVersion → targetVersion]
  si currentVersion > targetVersion  → downgrade refusé, marqué, rapport
```

### 6.2 Registre de migrations (V1, initialement vide)

| Artefact | De | À | Migration |
|----------|----|----|-----------|
| (aucune en V1) | — | — | le format V1 est le format initial |

Chaque future évolution de schéma **doit** déclarer une migration — c'est la règle qui rend le Runtime évolutif sans couplage.

---

## 7. Synchronisation mémoire ↔ disque

### 7.1 Principe

- La mémoire (singletons `@Published`) est la **vérité vivante** du Runtime.
- Le disque est une **projection durable** de cette vérité.
- La synchronisation est **pilotée** (points de cohérence), jamais opportuniste à chaque mutation.

### 7.2 Points de cohérence (V1)

| Point | Moment | Contenu persisté |
|-------|--------|-------------------|
| `BOOT_READY` | fin de boot | RUNTIME_STATUS.json, BOOT_REPORT.json |
| `SESSION_END` | fin de session | snapshot + SUPRA_STATE.json (mission courante) |
| `DECISION` | décision exécutive produite | MISSION_QUEUE.json, CONTINUITY.md |
| `MANUAL_SYNC` | action utilisateur / outil | état complet |

### 7.3 Exigence d'atomicité

Chaque écriture passe par `FileSystemPort.write` (temp + rename). Un crash ne laisse jamais d'artefact **partiellement écrit** : soit l'ancien état, soit le nouveau.

---

## 8. Mapping avec l'existant (à remplacer)

| Composant actuel | Fonctions absorbées par ContinuityEngine |
|------------------|------------------------------------------|
| `ContinuityManager.load()` | `prepareSession()` + lecture Registry |
| `ContinuityManager.resumeSession()` | `restore(lastSnapshot)` + `prepareSession()` |
| `ExecutiveBootManager.resumeSession()` | `restore(lastSnapshot)` |
| Lectures directes `fm.contents` (SUPRA_STATE, RUNTIME_STATUS, CONTINUITY.md, NEXT_MISSION.md, BUILD_STATUS.md) | appels Registry (`state()`, `runtimeStatus()`, `continuity()`, `nextMission()`, `buildStatus()`) |
| `loadGitState()` (spawn git + waitUntilExit) | supprimé en V1 : le commit est lu une fois par le Bootstrap (async) et **stocké** dans SUPRA_STATE.json |
| `ArtifactDiag` (diagnostic d'artefacts) | `diagnostics()` du Registry (statuts typés, pas de chemins) |

---

## 9. Interdictions

| Interdit | Raison |
|----------|--------|
| Lecture/écriture disque hors ContinuityEngine/Registry/FileSystemPort | Single Persistence Owner |
| `waitUntilExit()` | Blocage main thread — interdit par contrainte |
| Snapshots en mémoire seulement | La durabilité est l'objectif même du moteur |
| Sync à chaque mutation d'état | Coût IO inutile, non-déterministe |
| Logique métier dans le moteur | Les fichiers ne représentent pas la logique métier |

---

## 10. Définition de Done du Continuity Engine

| Critère | Preuve |
|---------|--------|
| Reprise de session depuis snapshot | SessionEndTest : snapshot → relance → même mission/état |
| Restauration du dernier snapshot valide | RestoreTest : 3 snapshots → dernier restauré |
| Migration versionnée | MigrationTest : artefact v2.0 → v2.2 appliquée, rapport |
| Sync mémoire ↔ disque aux points de cohérence | SyncPointTest : chaque point produit l'artefact attendu |
| Aucune occurrence des interdits | rapport d'analyse statique |
| Aucune régression startup | budget STARTUP_PROFILE (BOOTSTRAP_VALIDATION.md § 4) |

---

**END OF CONTINUITY_ENGINE_SPEC** — produit par FACTORY_01_ARCHITECTURE, mission FOUNDATION ERA.
