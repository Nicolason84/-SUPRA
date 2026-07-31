# STARTUP_TIMELINE.md

## Timeline complète du démarrage — Startup Profiling

**Date** : 2026-07-31 · **Build** : `executive-runtime-v2` + instrumentation timeline
**Source** : `/tmp/proof_startup_timeline.log` (trace stdout, marqueurs `[BOOT]`)
**Méthode** : build Debug + lancement `open -a` + capture stdout ; aucun refactoring.

---

## 1. Trace brute (timestamps relatifs à APP_START)

```
t(ms)   étape
  0     [BOOT] APP_START
119     [BOOT] WINDOW_CREATED          (vue racine instanciée par WindowGroup)
128     [BOOT] ROOT_VIEW_READY
128     [BOOT] ONAPPEAR_BEGIN
130     [BOOT] NUCLEO_STARTED
130     [BOOT] GOVERNOR_STARTED
130     [BOOT] MONITOR_STARTED
130     [BOOT] TOWER_LOADED
131     [BOOT] RUNTIME_LOADED           (kernel : 0 composants — manifest absent, état dégradé connu)
131     [BOOT] STATE_CONFIGURED
133     [BOOT] MISSIONS_LOADED
133     [BOOT] PHOENIX_BOOT_TASK_LAUNCHED
133     [BOOT] ONAPPARE_COMPLETE
133     [BOOT] BOOT_VIEW_APPEARED
154     [BOOT] PHOENIX_BOOT_BEGIN
155     [BOOT] PHOENIX_REGISTER_ENGINES_BEGIN
155     [BOOT] PHOENIX_REGISTER_ENGINES_END
155     [BOOT] PHOENIX_RUNTIME_CORE_BOOT_BEGIN
155     [BOOT] ENGINE_executive-distance-engine_BEGIN
155     [BOOT] ENGINE_executive-distance-engine_END      duration=0.0 ms
155     [BOOT] ENGINE_presence-engine_BEGIN
662     [BOOT] ENGINE_presence-engine_END                duration=507.0 ms
662     [BOOT] ENGINE_identity-runtime_BEGIN
663     [BOOT] ENGINE_identity-runtime_END                duration=0.8 ms
663     [BOOT] ENGINE_vision-engine_BEGIN
663     [BOOT] ENGINE_vision-engine_END                   duration=0.2 ms
663     [BOOT] ENGINE_oeil-perception-layer_BEGIN
663     [BOOT] ENGINE_oeil-perception-layer_END           duration=0.2 ms
663     [BOOT] ENGINE_digital-twin-runtime_BEGIN
718     [BOOT] ENGINE_TWIN_SYNC_BEGIN
773     [BOOT] ENGINE_TWIN_SYNC_END
773     [BOOT] ENGINE_digital-twin-runtime_END            duration=56.0 ms
774     [BOOT] ENGINE_executive-context-engine_BEGIN
774     [BOOT] ENGINE_CONTEXT_SCAN_BEGIN
4934    [BOOT] ENGINE_CONTEXT_SCAN_END
4934    [BOOT] ENGINE_executive-context-engine_END        duration=4160.6 ms
4934    [BOOT] PHOENIX_RUNTIME_CORE_BOOT_END              duration=4725.5 ms
4934    [BOOT] PHOENIX_SNAPSHOT_PIPELINE_BEGIN
4934    [BOOT] PHOENIX_SNAPSHOT_PIPELINE_END
4934    [BOOT] PHOENIX_HEALTH_CHECK_BEGIN
4935    [BOOT] PHOENIX_HEALTH_CHECK_END
4935    [BOOT] PHOENIX_FIRST_SNAPSHOT_BEGIN
4936    [BOOT] PHOENIX_FIRST_SNAPSHOT_END
4936    [BOOT] PHOENIX_BOOT_DONE
4936    [BOOT] PHOENIX_BOOT_COMPLETE
─────── Phase interactive (clic utilisateur « Start Boot ») ───────
        [BOOT] EXEC_BOOT_START
        [BOOT] CONTINUITY_PACK_MISSING          (first boot — pas de pack)
        [BOOT] EXEC_BOOT_COMPLETE state=FIRST_BOOT   duration=316 ms
```

Note : `WINDOW_CREATED` apparaît 5× au total (instanciations répétées de la vue racine
par SwiftUI pendant le rendu initial + transition boot→cockpit) — comportement framework
normal, sans impact de durée.

## 2. Durée par étage

| Étage | Début | Fin | Durée |
|-------|-------|-----|------:|
| Cold start (APP_START → WINDOW_CREATED) | 0 | 119 ms | **119 ms** |
| Fenêtre → vue racine | 119 | 128 ms | 9 ms |
| onAppear racine (nucleo/governor/monitor/tower/runtime/state/missions) | 128 | 133 ms | 5 ms |
| Apparition boot view | 133 | 133 ms | 0 ms |
| **Phoenix boot complet** | 154 | 4936 ms | **4728 ms** |
| ├─ Register engines (7) | 155 | 155 ms | 0 ms |
| ├─ **Runtime core boot (7 engines)** | 155 | 4934 ms | **4725 ms** |
| │  ├─ distance-engine | | | 0.0 ms |
| │  ├─ **presence-engine** | | | **507.0 ms** |
| │  ├─ identity-runtime | | | 0.8 ms |
| │  ├─ vision-engine | | | 0.2 ms |
| │  ├─ oeil-perception-layer | | | 0.2 ms |
| │  ├─ digital-twin-runtime | | | 56.0 ms |
| │  └─ **executive-context-engine** | | | **4160.6 ms** |
| ├─ Snapshot pipeline | 4934 | 4934 ms | 0 ms |
| ├─ Health check | 4934 | 4935 ms | 1 ms |
| └─ Premier snapshot | 4935 | 4936 ms | 1 ms |
| **EXEC_BOOT (interactif — clic « Start Boot »)** | | | **316 ms** |

## 3. Totaux

| Métrique | Valeur |
|----------|-------:|
| Startup automatique (APP_START → PHOENIX_BOOT_DONE) | **4.88 s** |
| Dont temps main thread actif (onAppear + phases ≤1 ms) | ≈ 25 ms |
| Dont attentes async (sleeps + sondes bornées) | ≈ 4.72 s |
| Boot manager (interactif, clic utilisateur) | 316 ms |
| Ordre d'exécution des engines | itération de dictionary (non déterministe) |
