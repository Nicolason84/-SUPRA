# RUNTIME_PROOF_XCODE.md

## Reproduction du lancement Xcode Debug (configuration utilisateur)

**Date** : 2026-07-31 · **Build** : `executive-runtime-v2` (commit `dc6af55`)
**Méthode** : lancement **réel via l'UI Xcode** (Cmd+R) — pas une simulation
**Artefacts** : `/tmp/proof_xcode/` (5 échantillons, capture fenêtre)

---

## RÉSULTAT : **AUCUN BEACHBALL**

Le lancement via Xcode Debug, identique à la configuration de l'utilisateur, ne produit
**aucun beachball**. Le main thread reste dans la boucle d'événements AppKit pendant toute
la fenêtre de 30 secondes.

---

## 1. Reproduction exacte du lancement Xcode

| Étape | Déroulement |
|-------|-------------|
| Ouverture projet | `open SUPRA.xcodeproj` dans Xcode (déjà en cours) |
| Activation Xcode | Xcode rendu frontmost |
| Scheme | `SUPRA` (LaunchAction : Debug, LLDB, `launchStyle=0`, cwd par défaut, aucune env var custom) |
| **Run** | **Cmd+R posté dans l'UI Xcode** (CGEventPost) |
| Processus | PID **13151** détecté après le build incrémental |
| Confirmation debugger | `ps` : statut **`SX`** — X = process tracé par LLDB |

Le process lancé par Xcode est bien celui de la dernière build (même DerivedData,
même binaire que les preuves précédentes).

## 2. Bilan 30 secondes (Xcode Debug)

| t | Vivant | CPU (%cpu/stat) | Fenêtres | Frontmost |
|---|:---:|:---:|:---:|:---:|
| 0 s | ✅ | 13,4 % / SX | 1 | **SUPRA** |
| 10 s | ✅ | 7,5 % / SX | 1 | SUPRA |
| 20 s | ✅ | 25,6 % / SX (cycle scan/snapshot) | 1 | SUPRA |
| 30 s | ✅ | 9,4 % / SX | 1 | SUPRA |
| Clic + 1 s | ✅ | — | 1 | SUPRA |

- **Main thread — 5/5 échantillons sains** (`sample` t=0/10/20/30 + final) :
  ```
  Thread_1321933: Main Thread (1595/1637/1740 échantillons)
  └─ -[NSApplication run] → nextEventMatchingMask → _CFRunLoopRunSpecificWithOptions
       → __CFRunLoopRun → __CFRunLoopServiceMachPort → mach_msg (attente d'événements)
  ```
- **0 occurrence de `waitUntilExit`** sur l'ensemble des échantillons.
- Fenêtre SUPRA présente (layer 0), capture analysée : **contenu UI réel rendu**
  (2940×1924, **42 palettes de couleurs**, 1185 px lumineux — thème sombre).
- **Interaction** : clic synthétique au centre de la fenêtre → l'app reste frontmost
  et vivante ; **AppleEvent `quit` traité** (app quittée gracieusement).
- Le démarrage atteint l'état idle (main thread idle dans la boucle d'événements,
  window server actif, aucun frame bloquant après le boot).

**=> Le RUNTIME_STATUS = PASS initial est confirmé dans les conditions exactes de l'utilisateur.**

---

## 3. Différences d'environnement documentées (RUNTIME_PROOF vs Xcode Debug)

Les deux exécutions utilisent **le même binaire** (même DerivedData), la même
configuration **Debug**, le **même sandbox** (`com.apple.security.app-sandbox=true`,
`network.client=true`), **aucune modification de code**. Les différences mesurées :

| # | Facteur | Run RUNTIME_PROOF (`open -a`) | Run Xcode Debug (utilisateur) | Impact |
|---|---------|-------------------------------|-------------------------------|--------|
| 1 | **Launcher** | LaunchServices (`open -a`) | Launcher LLDB d'Xcode | None mesuré |
| 2 | **Debugger** | aucun | **LLDB attaché** (statut ps `S` vs `SX`) | None mesuré |
| 3 | **`DYLD_INSERT_LIBRARIES`** | absent | `libLogRedirect.dylib`, `libBacktraceRecording.dylib`, **`libMainThreadChecker.dylib`**, `libRPAC.dylib`, `libViewDebuggerSupport.dylib` | None mesuré (le MainThreadChecker n'a signalé aucun blocage main) |
| 4 | **`DYLD_FRAMEWORK_PATH` / `DYLD_LIBRARY_PATH`** | absents | `.../Build/Products/Debug` + `PackageFrameworks` | None mesuré |
| 5 | **`__XCODE_BUILT_PRODUCTS_DIR_PATHS`** | absent | présent (chemin Debug) | None mesuré |
| 6 | **Working directory** | "/" (défaut LaunchServices) | **`~/Library/Containers/com.nicolasalonso.SUPRA/Data`** (container sandbox — `useCustomWorkingDirectory=NO` dans le scheme) | None mesuré (le code accède au projet via chemin absolu) |
| 7 | **`NSUnbufferedIO`** | absent | `YES` (console Xcode) | None mesuré |
| 8 | **Activation** | lancée en arrière-plan (activée plus tard via `open -a`) | **frontmost immédiat** par Xcode | None mesuré |
| 9 | **Stdout** | redirigé vers fichier (`/tmp/proof_run/stdout.log`) | console Xcode | Cosmétique (trace non capturable par fichier) |
| 10 | **Processus parent** | `launchd` | Xcode (via debugserver) | None mesuré |
| 11 | **Label du main thread (sample)** | `DispatchQueue_1: com.apple.main-thread` | `Thread_*: Main Thread` | Cosmétique (nommage du sampler) |
| 12 | **Horodatage run** | 04:12-04:20 | 04:24-04:28 | None |
| 13 | **CPU idle typique** | ~8 % | 7,5-13 % (pic 25,6 % à un cycle de scan) | Variation de charge normale (timers internes), pas de spin |

### Point de vigilance honnête
- La **seule différence de comportement réelle** (et non cosmétique) entre les deux runs :
  l'environnement `DYLD_INSERT_LIBRARIES` d'Xcode (dont `libMainThreadChecker`) et le
  cwd = container sandbox. Aucune de ces deux différences ne modifie le chemin de boot
  bloquant fixé (`detectNetwork`/`syncServices`/`detectServices`/`scanGitChanges` →
  probes async bornées), donc aucune n'est susceptible de recréer un beachball.
- Le pic CPU 25,6 % à t=20 s correspond à un cycle périodique de scan (comportement
  préexistant, borné) ; le main thread restait idle pendant ce pic (échantillon t=20 :
  `NSApplication run`, 0 frame bloquant) — la charge est portée par des threads
  d'arrière-plan.

## 4. Conclusion

Le lancement Xcode Debug reproduit **fidèlement** la configuration utilisateur
(debugger LLDB, launcher Xcode, env vars Xcode, cwd container sandbox, frontmost
immédiat). **Aucun beachball observé** : 5/5 échantillons main thread sains, fenêtre
rendue et interactive, quit gracieux.

**RUNTIME_STATUS = PASS — confirmé en environnement Xcode Debug.**
