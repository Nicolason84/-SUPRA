# STARTUP_PROFILE.md

## Profil du démarrage — répartition du temps par étage

**Date** : 2026-07-31 · Source : trace `[BOOT]` du run instrumenté (voir STARTUP_TIMELINE.md).

---

## 1. Vue d'ensemble

```
APP_START ──────────────────────────────────────────────────────────┐
   │  119 ms  Cold start (dyld + frameworks + création fenêtre)     │
WINDOW_CREATED ─────────────────────────────────────────────────────┤
   │    9 ms  Construction de la vue racine                         │
ROOT_VIEW_READY ────────────────────────────────────────────────────┤
   │    5 ms  onAppear (nucleo, governor, monitor, tower, runtime,  │
   │          state, missions) — 100 % main thread, rapide          │
ONAPPEARE_COMPLETE ── BOOT_VIEW_APPEARED ───────────────────────────┤
   │ 4728 ms  PHOENIX BOOT (async, main thread libre)               │
PHOENIX_BOOT_DONE ──────────────────────────────────────────────────┤
   │   (attente interaction utilisateur — écran « Start Boot »)     │
EXEC_BOOT (clic) ───────────────────────────────────────────────────┤
   │  316 ms  Boot manager (FIRST_BOOT)                             │
EXEC_BOOT_COMPLETE ─────────────────────────────────────────────────┘
```

## 2. Répartition du temps du Phoenix boot (4728 ms)

| Engine / phase | Durée | % du boot Phoenix | Cumul |
|----------------|------:|------------------:|------:|
| **executive-context-engine** | 4160.6 ms | **88.0 %** | 88.0 % |
| **presence-engine** | 507.0 ms | **10.7 %** | 98.7 % |
| digital-twin-runtime | 56.0 ms | 1.2 % | 99.9 % |
| identity-runtime | 0.8 ms | <0.1 % | 99.9 % |
| vision-engine | 0.2 ms | <0.1 % | 99.9 % |
| oeil-perception-layer | 0.2 ms | <0.1 % | 99.9 % |
| executive-distance-engine | 0.0 ms | <0.1 % | 99.9 % |
| register engines | ~0 ms | — | — |
| snapshot pipeline | 0 ms | — | — |
| health check | 1 ms | — | — |
| premier snapshot | 1 ms | — | — |

**99.9 % du temps de boot Phoenix = 2 engines (context 88 % + presence 10.7 %).**

## 3. Profil d'exécution

### 3.1 Concurrence réelle
- `PHOENIX_BOOT` s'exécute dans `Task { }` créé dans `.onAppear` → hérite du MainActor.
- Les engines sont `@MainActor` : boot **séquentiel** (ordre = itération dictionary, non déterministe).
- **Aucun blocage du main thread** : chaque délai long est une `await` (Task.sleep, Task.detached avec timeout) — le main actor rend la main pendant les attentes.
- Durée réelle = somme des durées engines (pas de parallélisme).

### 3.2 Où part le temps (attributions)
| Catégorie | Durée | Source |
|-----------|------:|--------|
| Sonde réseau bornée (timeout 4 s, sandbox bloque ICMP) | ~4160 ms | context-engine → scanContext → detectNetwork |
| Sleep délibéré « dramatique » | ~507 ms | presence-engine → `Task.sleep(500ms)` |
| Sondes de présence de services (async, 3 s max) | ~56 ms | twin sync (4 sondes, réussies/résolues vite ici) |
| Travail réel (enregistrements, timers, events, snapshots) | ~10 ms | tous les autres étages |

### 3.3 Charge main thread pendant le boot
- Main thread actif : onAppare (5 ms) + phases ≤1 ms ≈ **25 ms** sur 4880 ms.
- Main thread en attente async (idle boucle AppKit) : ~4.85 s → **UI réactive pendant tout le boot** (prouvé par RUNTIME_PROOF : 0 frame bloquant, clics traités).

## 4. Faites notables

1. **Ordre des engines non déterministe** (itération de `[String: ExecutiveEngine]`).
   Le context-engine (le plus lent) s'est exécuté en dernier dans ce run ; selon l'ordre,
   la progression UI varie mais la durée totale est identique (séquentiel).
2. **`WINDOW_CREATED` × 5** : la vue racine est réinstanciée plusieurs fois par SwiftUI
   (évaluations du body + transition boot→cockpit). Coût unitaire < 1 ms, sans impact.
3. **Phase interactive** : après le boot automatique, l'app attend le clic « Start Boot »
   (316 ms pour le boot manager en FIRST_BOOT).
4. **Cold start 119 ms** : coût système (dyld + chargement frameworks + création fenêtre),
   mono-occurrence, hors contrôle applicatif.
