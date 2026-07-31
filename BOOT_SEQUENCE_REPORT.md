# BOOT_SEQUENCE_REPORT.md

## Séquence de démarrage — Runtime Hang Investigation

### 1. Architecture de démarrage observée

```
SUPRAOperationalCoreApp (App, @main)
 ├─ init(): APP_START
 ├─ @StateObject singletons (compositionRoot, nucleo, state, governor, snapshotStore, bootManager)
 ├─ WindowGroup → SUPRAOSProductRootView (ROOT_VIEW_READY)
 │    ├─ ExecutiveBootView (BOOT_VIEW_APPEARED) — écran de boot visuel
 │    └─ ExecutiveWindow (cockpit / Home) — après boot complet
 └─ .onAppear (MainActor, synchrone):
      NUCLEO_STARTED → GOVERNOR_STARTED → MONITOR_STARTED → TOWER_LOADED
      → RUNTIME_LOADED → STATE_CONFIGURED → MISSIONS_LOADED
      → PHOENIX_BOOT_TASK_LAUNCHED (Task) → ONAPPEAR_COMPLETE

PhoenixRuntime.boot() (Task @MainActor hérité):
  initializeEngines() → pour chaque engine (ordre dict):
    ├─ ExecutiveContextEngine.boot()  → scanContext() → detectNetwork() ⚠️
    │                                                    → detectServices() ⚠️
    ├─ DigitalTwinRuntime.boot()      → performSync() → syncServices() ⚠️
    ├─ VisionEngine.boot()            → watchers → scanGitChanges() ⚠️ (timer 10s)
    ├─ PresenceEngine / IdentityRuntime / OeilPerceptionLayer / SUPRAExecutiveDistanceEngine
  → startSnapshotPipeline() (timer 2s) → performHealthCheck() → publishSnapshot()
```

### 2. Chronologie mesurée (build final, 4 fixes)

| Fenêtre | Durée | État main thread |
|---------|------:|------------------|
| APP_START → ONAPPEAR_COMPLETE | **123 ms** | actif (travail léger) |
| ONAPPEAR_COMPLETE → PHOENIX_BOOT_BEGIN | 15 ms | idle boucle AppKit |
| PHOENIX_BOOT_BEGIN → PHOENIX_BOOT_COMPLETE | **4.72 s** | **libre** (boucle AppKit) — probes en arrière-plan |
| Stabilité t+0 → t+33 s | 33 s | 0 échantillon bloquant (3 captures `sample`) |

### 3. Éléments NOT bloquants (éliminés par preuve)

| Élément | Preuve d'élimination |
|---------|---------------------|
| Singletons `@StateObject` init | trace : APP_START → ROOT_VIEW_READY en 117 ms |
| `nucleo.start()`, `governor.startMonitoring()`, `runtimeMonitor.start()` | NUCLEO/GOVERNOR/MONITOR_STARTED en ≤ 2 ms chacun |
| `controlTowerState.load()` (lectures JSON synchrones) | TOWER_LOADED +2 ms |
| `runtimeKernel.load()` | RUNTIME_LOADED +1 ms (manifest manquant = état dégradé préexistant, non bloquant) |
| `state.configure/loadMissions()` | +2 ms |
| Heartbeat boucles (`while !Task.isCancelled` + `Task.sleep`) | asynchrones par conception (`Task.sleep`), jamais échantillonnées sur le main thread |
| Sémaphores `SUPRARuntimeLoop` (120 s) | non invoquées au démarrage (validation xcodebuild uniquement) |
| Boucles de scan BFS (`while !queue.isEmpty`) | bornées par la taille des données, jamais échantillonnées au boot |

### 4. Éléments bloquants identifiés (par échantillonnage `sample`)

| # | Localisation | Pattern | Gravité |
|---|--------------|---------|---------|
| 1 | `ExecutiveContextEngine.detectNetwork()` | `Process(ping)` + `waitUntilExit()` sur main, **sans timeout**, sous-processus ne sortant jamais | **HANG (beachball immédiat)** |
| 2 | `DigitalTwinRuntime.syncServices()` | 4 × `Process` + `waitUntilExit()` sur main (boot + toutes les 10 s) | Blocage main récurrent (189/2592 échantillons) |
| 3 | `ExecutiveContextEngine.detectServices()` | 3 × `Process` + `waitUntilExit()` sur main (chaque scanContext, 15 s) | Blocage main récurrent |
| 4 | `VisionEngine.scanGitChanges()` | 3 × `Process` + `waitUntilExit()` sur main (watcher, 10 s) | Blocage main récurrent |
