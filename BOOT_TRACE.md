# BOOT_TRACE.md

## Trace de démarrage — Runtime Hang Investigation

**Source** : `/tmp/boot_trace_v2.log` — lancement automatisé du build final (4 fixes appliqués).
**Date** : 2026-07-31 · Branche `executive-runtime-v2` · `xcodebuild -scheme SUPRA -configuration Debug build`

```
[BOOT] APP_START                 t=807156789.867   (0.000s)
[BOOT] ROOT_VIEW_READY           t=807156789.984   (0.117s)
[BOOT] ONAPPEAR_BEGIN            t=807156789.984   (0.117s)
[BOOT] NUCLEO_STARTED            t=807156789.986   (0.119s)
[BOOT] GOVERNOR_STARTED          t=807156789.986   (0.119s)
[BOOT] MONITOR_STARTED           t=807156789.987   (0.120s)
[BOOT] TOWER_LOADED              t=807156789.987   (0.120s)
[BOOT] RUNTIME_LOADED            t=807156789.988   (0.121s)
[BOOT] STATE_CONFIGURED          t=807156789.988   (0.121s)
[BOOT] MISSIONS_LOADED           t=807156789.990   (0.123s)
[BOOT] PHOENIX_BOOT_TASK_LAUNCHED t=807156789.990  (0.123s)
[BOOT] ONAPPEAR_COMPLETE         t=807156789.990   (0.123s)
[BOOT] BOOT_VIEW_APPEARED        t=807156789.990   (0.123s)
[BOOT] PHOENIX_BOOT_BEGIN        t=807156790.005   (0.138s)
[BOOT] PHOENIX_BOOT_COMPLETE     t=807156794.723   (4.718s)  ← ping borné en arrière-plan
```

## Synthèse

| Métrique | Valeur |
|----------|--------|
| APP_START → ONAPPEAR_COMPLETE | **123 ms** (séquence main thread, aucune attente) |
| Main thread pendant le boot Phoenix | **jamais bloqué** (boucle AppKit active — preuve `sample`) |
| Boot Phoenix complet | 4.72 s (borne du probe réseau 4 s + grace — en `Task.detached`) |
| Stabilité à t+33 s | app vivante, **0 sample `waitUntilExit`** sur le main thread |
| Sous-processus suspendus | **aucun** (ping terminé par le timeout borné) |

## Remarques

- La ligne `SUPRA_EXECUTIVE_PLATFORM_REGISTRY.json` (manquant) est un état dégradé
  préexistant du kernel loader hors périmètre de cette mission (pas un blocage).
- Le doublement des marqueurs `ROOT_VIEW_READY/ONAPPEAR_*` correspond à la double
  évaluation de `WindowGroup` par SwiftUI (comportement framework, sans impact).
