# BLOCKING_STAGE.md

## Étages dépassant 100 ms — identification des causes

**Critère** : tout étage de démarrage dont la durée mesurée excède 100 ms (trace `[BOOT]`,
run instrumenté — voir STARTUP_TIMELINE.md / STARTUP_PROFILE.md).

---

## 3 étages dépassent 100 ms

| # | Étage | Durée mesurée | Seuil | Statut |
|---|-------|--------------:|------:|--------|
| 1 | `executive-context-engine` (boot) | **4160.6 ms** | 100 ms | ⚠️ Dominant (88 % du boot Phoenix) |
| 2 | `presence-engine` (boot) | **507.0 ms** | 100 ms | ⚠️ Volontaire |
| 3 | Cold start (APP_START → WINDOW_CREATED) | **119 ms** | 100 ms | ℹ️ Système, mono-occurrence |

---

## Étage 1 — `executive-context-engine` : 4160.6 ms

### Ce qui est mesuré
`ENGINE_executive-context-engine_BEGIN → END` couvre `boot()` → `scanContext()` (4160 ms
mesurés par `ENGINE_CONTEXT_SCAN_BEGIN → END`).

### Pourquoi
`scanContext()` appelle séquentiellement `detectMissions → detectProviders →
detectSystemLoad → detectNetwork → detectServices → detectDashboard`, en `await`.
Le coût vient de **`detectNetwork()`** :
- Il lance une sonde réseau (`Process` ping) dans une `Task.detached` avec **timeout global
  de 4 s** (FIX-1 du hang — avant : `waitUntilExit` sans borne sur le main thread).
- L'app est **sandboxée** (`com.apple.security.app-sandbox`, seul `network.client` est
  accordé) → les paquets **ICMP du ping ne sortent pas** → le sous-processus ne se termine
  jamais et la sonde atteint **systématiquement son timeout de 4 s**.
- `scanContext` attend la sonde (`await`) → **4160 ms** ≈ 4000 ms de timeout + ~160 ms
  de démarrage/setup.

### Caractérisation
- **Non bloquant** : la sonde est `Task.detached`, le main thread reste libre
  (prouvé : 0 frame bloquant aux `sample` des RUNTIME_PROOF).
- **Déterministe dans cet environnement** : ≈ 4.16 s à chaque boot et à chaque scan
  périodique (timer 15 s).
- **Pas une régression** : c'est le comportement borné post-fix. En environnement non
  sandboxé avec réseau autorisé, le ping répondrait en ms et l'étage chuterait < 100 ms.
- **Coût total pour l'utilisateur** : +4.16 s sur l'écran de boot avant de pouvoir cliquer
  « Start Boot ».

---

## Étage 2 — `presence-engine` : 507.0 ms

### Ce qui est mesuré
`ENGINE_presence-engine_BEGIN → END` couvre `boot()`.

### Pourquoi
`PresenceEngine.boot()` contient (ligne 85) :

```swift
// Phase 2: Establish presence
try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s for dramatic effect
```

Un **sommeil volontaire de 500 ms** commenté « for dramatic effect » (effet dramatique de
l'éveil de SUPRA). 507 ms mesurés = 500 ms + overhead de scheduling.

### Caractérisation
- **Non bloquant** : `Task.sleep` suspend l'acteur, le main thread reste libre.
- **Volontaire / délibéré** : aucun travail effectué pendant l'étage.
- **Pas un bug** — un choix de mise en scène qui allonge le boot de 0.5 s à chaque démarrage.

---

## Étage 3 — Cold start : 119 ms

### Ce qui est mesuré
`APP_START → WINDOW_CREATED` : de l'`init()` de l'App à la première instanciation de la
vue racine par `WindowGroup`.

### Pourquoi
C'est le **coût de démarrage système** : lancement du binaire (dyld), chargement des
frameworks (SwiftUI, AppKit, Foundation…), première évaluation du scene graph SwiftUI et
création de la fenêtre par le window server. Aucun code applicatif bloquant dans cet
intervalle (l'`init` de l'App ne fait que logger).

### Caractérisation
- **Mono-occurrence** : une seule fois au lancement.
- **Hors contrôle applicatif** : coût framework/système, typique d'une app SwiftUI
  macOS (~100-150 ms sur cette machine).
- Non bloquant, non optimisable côté application (hors refactoring, hors périmètre).

---

## Synthèse

| Étage | Type | Bloque le main thread ? | Action recommandée |
|-------|------|:---:|---|
| context-engine 4160 ms | Sonde réseau bornée (sandbox ICMP) | Non | (Hors périmètre profiling) : si souhaité, passer la sonde en fire-and-forget pour ne pas retarder le boot, ou détecter la sandbox et raccourcir le timeout |
| presence-engine 507 ms | Sleep délibéré « dramatique » | Non | (Hors périmètre) : réduire/supprimer le sleep si le boot doit être plus rapide |
| Cold start 119 ms | Coût système SwiftUI/AppKit | Non | Aucune (système) |

**Aucun étage > 100 ms ne bloque le main thread.** Les 4.72 s d'attente du boot Phoenix
sont des suspensions async (sondes bornées + sleep délibéré) — l'UI reste réactive.
