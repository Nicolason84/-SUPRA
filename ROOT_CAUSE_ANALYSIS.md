# ROOT_CAUSE_ANALYSIS.md

## Analyse de cause racine — Runtime Hang Investigation

### 1. Symptôme

L'application devient **immédiatement inresponsive** après le lancement : l'écran de boot
Executive apparaît, puis macOS affiche le beachball avant toute interaction utilisateur.

### 2. Méthode de diagnostic

1. **Instrumentation** : marqueurs structurés `[BOOT]` (stdout, flushé) à chaque étape de
   démarrage (`APP_START` → `ONAPPEAR_COMPLETE` → `PHOENIX_BOOT_*`).
2. **Lancement automatisé** : exécution du binaire app via pty, capture de la trace.
3. **Échantillonnage des threads** : `sample <pid>` pendant le gel → stack du main thread.
4. **Vérification des sous-processus orphelins** : `pgrep` des enfants suspendus.

### 3. Preuve 1 — le stack d'échantillonnage (100 % du main thread)

```
Thread_1274113 com.apple.main-thread (2610/2610 échantillons)
  └─ closure #1 closure #1 closure #1 in SUPRAOperationalCoreApp.body.getter :65
       └─ PhoenixRuntime.boot()                                    PhoenixRuntime.swift:93
            └─ ExecutiveRuntimeCore.boot()                         ExecutiveRuntimeCore.swift:167
                 └─ ExecutiveRuntimeCore.initializeEngines()       ExecutiveRuntimeCore.swift:330
                      └─ ExecutiveContextEngine.boot()             ExecutiveContextEngine.swift:72
                           └─ scanContext()                        ExecutiveContextEngine.swift:123
                                └─ detectNetwork()                 ExecutiveContextEngine.swift:211
                                     └─ -[NSConcreteTask waitUntilExit]
                                          └─ _CFRunLoopRunSpecificWithOptions
                                               └─ mach_msg  ← attente infinie
```

### 4. Preuve 2 — le sous-processus orphelin

```
7953 /sbin/ping -c 1 -t 2 8.8.8.8   ← encore vivant après 60+ s
```

Le `ping` ne sort **jamais** (ICMP contraint par la sandbox du runtime), et
`waitUntilExit()` sur le thread principal attend indéfiniment.

### 5. Preuve 3 — pourquoi la chaîne entière s'exécute sur le main thread

- `Task { await PhoenixRuntime.shared.boot() }` est créé dans `.onAppear` (contexte
  `@MainActor`) → la closure **hérite du MainActor**.
- `boot()` et tous les `engine.boot()` sont `@MainActor` → aucun vrai point de
  suspension hors acteur : la chaîne s'exécute **séquentiellement sur le main thread**.
- `detectNetwork()` étant synchrone, aucun yield n'est possible avant la fin du `ping`.

### 6. Cause racine

> **`ExecutiveContextEngine.detectNetwork()` exécute `Process(ping)` + `waitUntilExit()`
> sans timeout sur le main thread pendant le boot Phoenix. Le sous-processus ne se
> termine jamais → blocage permanent du main thread → beachball immédiat.**

### 7. Patterns aggravants identifiés au même endroit (blocage main récurrent)

| Fichier | Fonction | Impact |
|---------|----------|--------|
| `DigitalTwinRuntime.syncServices()` | 4 `Process` + `waitUntilExit()` | ~190 ms de gel à chaque sync (boot + 10 s) |
| `ExecutiveContextEngine.detectServices()` | 3 `Process` + `waitUntilExit()` | gel à chaque scanContext (15 s) |
| `VisionEngine.scanGitChanges()` | 3 `Process` + `waitUntilExit()` | gel à chaque tick watcher (10 s) |

### 8. Éléments écartés (faux suspects)

| Suspect | Verdict |
|---------|---------|
| Sémaphores `SUPRARuntimeLoop` (120 s) | hors chemin de démarrage (validation xcodebuild) |
| Boucles `while !Task.isCancelled` | toutes asynchrones (`Task.sleep`) |
| Scans de fichiers (`enumerator`) | hors chemin de boot prouvé, bornés |
| `readCurrentGitCommit/Branch` du boot manager | locaux (ms), non échantillonnés comme bloquants |

### 9. Conclusion

Le beachball est causé par **une seule ligne bloquante** (`waitUntilExit` sans timeout
sur le main thread) dans le chemin de boot Phoenix, aggravée par trois occurrences
récurrentes du même anti-pattern. Le fix rétablit la réactivité totale de l'UI.
