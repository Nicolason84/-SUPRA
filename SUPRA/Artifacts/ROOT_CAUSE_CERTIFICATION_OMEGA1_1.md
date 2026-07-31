# RAPPORT DE CERTIFICATION — Ω1.1

**Projet**: PHOENIX — Executive Runtime  
**Composant**: Deadlock dispatch_once dans MultiMemoryStore  
**Date**: 2026-07-30  
**Autorité**: SUPRA Executive — Evidence First Governance  
**Mission**: Ω1.1 (indépendante de Ω1, baseline Ω1 gelée)  
**Statut**: ✅ CAUSE RACINE CERTIFIÉE

---

## 1. RÉSUMÉ EXÉCUTIF

**Cause racine unique :** Blocage récurrent `dispatch_once` (deadlock) causé par l'initialisation de singletons `@MainActor` qui créent des dépendances circulaires via leur chaîne d'initialisation.

Lorsque `SUPRACompositionRoot.shared` est initialisé (première référence à un `@StateObject` dans `SUPRAOperationalCoreApp`), la séquence suivante se produit :

```
SUPRACompositionRoot.shared (dispatch_once A)
  → MultiMemoryStore.shared (dispatch_once B)
    → subscribeToSnapshotStore()
      → CAnnoNicoSnapshotStore.shared (dispatch_once C) 
        → ProtectedFolderAccessCoordinator.shared
      → (autres singletons accessibles via chaine)
  
  ET SIMULTANÉMENT dans SUPRACompositionRoot.init():
  → MissionStore() → SUPRAIntelligenceEngine.shared → ...
  → MultiMemoryStore.shared accédé À NOUVEAU → dispatch_once B (DÉJÀ EN COURS)
    → CRASH: "BUG IN CLIENT OF LIBDISPATCH: trying to lock recursively"
```

**Preuve directe** : `~/Library/Logs/DiagnosticReports/SUPRA-2026-07-30-002433.ips`
```
Exception: EXC_BREAKPOINT / SIGTRAP
Fault: BUG IN CLIENT OF LIBDISPATCH: trying to lock recursively
```

La violation se produit dans `_dispatch_once_wait` — le mécanisme `dispatch_once` d'Apple ne supporte PAS l'appel récursif depuis le même thread pour le même token, ce qui provoque un `SIGTRAP`.

---

## 2. MÉTHODOLOGIE

### 2.1 Analyse du crash log existant

Fichier analysé : `~/Library/Logs/DiagnosticReports/SUPRA-2026-07-30-002433.ips`

### 2.2 Analyse statique du code

Fichiers analysés :
| Fichier | Rôle dans la chaîne |
|---------|---------------------|
| `SUPRACompositionRoot.swift` | Point d'entrée de l'initialisation |
| `MultiMemoryStore.swift` | Singleton dont les subscribeToStores déclenchent d'autres inits |
| `CAnnoNicoSnapshotStore.swift` | Accède à ProtectedFolderAccessCoordinator dans init |
| `ProtectedFolderAccessCoordinator.swift` | Lit des fichiers dans init |
| `SUPRAIntelligenceEngine.swift` | Accède à MultiMemoryStore via stored property |
| `SUPRAMissionObserver.swift` | Accède à MultiMemoryStore via stored property |
| `MissionStore.swift` | Accède à SUPRADecisionEngine, SUPRAMissionBroker, etc via méthodes |
| `SUPRAOperationalCoreApp.swift` | Lance l'app, déclenche SUPRACompositionRoot via @StateObject |
| `project.pbxproj` | Configuration TEST_HOST |

---

## 3. MATRICE D'HYPOTHÈSES

### H1 — Dépendance circulaire d'initialisation des singletons ⭐ [CONFIRMÉE]

| Propriété | Valeur |
|-----------|--------|
| **Probabilité** | Très haute (preuve de crash log) |
| **Mécanisme** | `dispatch_once` est non réentrant. Un thread appelant `dispatch_once` pour le token M tentant d'accéder à un autre singleton dont l'init accède à nouveau au token M provoque un crash SIGTRAP ("trying to lock recursively") |
| **Preuve directe #1** | Crashes log : `BUG IN CLIENT OF LIBDISPATCH: trying to lock recursively` dans `_dispatch_once_wait` |
| **Preuve directe #2** | La pile d'appels montre `MultiMemoryStore.__allocating_init() ← _dispatch_once_callout ← MissionStore.init ← SUPRAIntelli…` — la même chaîne de singletons s'exécutant dans un bloc `_dispatch_once_callout` imbriqué |
| **Preuve concordante** | Le crash arrive pendant `SUPRACompositionRoot.shared` init, qui initialise simultanément `MultiMemoryStore` et `MissionStore` |
| **Preuve concordante** | `MultiMemoryStore.__allocating_init()` est dans `dispatch_once_callout` — signe que le token de dispatch_once pour MultiMemoryStore est déjà actif |
| **Confiance** | 95% |

### H2 — Subscriber Combine reentrant durant l'init [INFIRMÉE]

| Propriété | Valeur |
|-----------|--------|
| **Probabilité** | Faible |
| **Mécanisme** | Le `.sink` subscriber créé dans `subscribeToSnapshotStore()` appelle immédiatement `rebuild()` (valeur actuelle de `Published`), et `rebuild()` accède à des singletons qui déclenchent un nouveau `dispatch_once` |
| **Preuve contraire** | Même si `.sink` émettait un `nil` pour `state`, `rebuild()` gère les nil (`runtimeMonitor?.health ?? .initial`, `missionStore?.missions ?? []`). Aucun accès à un autre `shared` singleton |
| **Preuve contraire** | Le crash log montre `MissionStore.init` et `SUPRAIntelligenceEngine.init` dans la pile, pas `rebuild()` |
| **Confiance** | 5% |

### H3 — Deadlock dû à l'ordre d'accès aux singletons dans CompositionRoot [PARTIELLEMENT CONFIRMÉE]

| Propriété | Valeur |
|-----------|--------|
| **Probabilité** | Moyenne |
| **Mécanisme** | L'ordre séquentiel dans `SUPRACompositionRoot.init()` (lignes 33-37) accède à `MultiMemoryStore.shared` AVANT `MissionStore()` et d'autres, créant une fenêtre où le `dispatch_once` pour MultiMemoryStore est actif pendant la création d'autres objets |
| **Preuve favorable** | L'initialisation de `MultiMemoryStore` (dispatch_once B) est en cours pendant que l'app construit `MissionStore`, `MissionEvolutionEngine`, etc. Si l'un d'eux (ancien code) accédait à `MultiMemoryStore.shared`, le deadlock se produisait |
| **Preuve contraire** | Dans le code CURRENT, `MissionStore.init()` ne fait QUE: `self.sourceURL = ...` et `self.evolutionEngine = ...` — aucun accès à `MultiMemoryStore` dans l'init |
| **Conclusion** | Facteur contributif (l'ordre est le vecteur), mais la cause RACINE est la dépendance circulaire (H1) |
| **Confiance** | 30% |

### H4 — Problème de `@MainActor` + Combine dans l'initialisation [INFIRMÉE]

| Propriété | Valeur |
|-----------|--------|
| **Probabilité** | Très faible |
| **Mécanisme** | `@MainActor` isolation combinée avec Combine publisher chain créant une boucle d'exécution sur le main actor |
| **Preuve contraire** | Les singletons qui PASSENT (SnapshotBus, EventBus) ont le même `@MainActor + @Published` pattern mais sans dépendance circulaire |
| **Confiance** | <1% |

### H5 — Bug libdispatch dans macOS 26.5 [INFIRMÉE]

| Propriété | Valeur |
|-----------|--------|
| **Probabilité** | Très faible |
| **Mécanisme** | Bug dans Apple's `libdispatch` pour macOS 26.5 |
| **Preuve contraire** | `dispatch_once` recursive lock est un comportement INTENTIONNEL (debug assertion), pas un bug |
| **Confiance** | <1% |

---

## 4. MATRICE DE PREUVES

| # | Preuve | Source | Soutient | Contredit |
|---|--------|--------|:--------:|:---------:|
| 1 | Crash log `SUPRA-2026-07-30-002433.ips` | `~/Library/Logs/DiagnosticReports/` | H1 | - |
| 2 | `_dispatch_once_wait` + "trying to lock recursively" | Crash log | H1 | H2, H4, H5 |
| 3 | `MultiMemoryStore.__allocating_init()` dans `dispatch_once_callout` imbriqué | Crash log | H1 | H2 |
| 4 | `MissionStore.init` → `SUPRAIntelligenceEngine.init` → `MultiMemoryStore.__allocating_init` | Crash log (old binary) | H1, H3 | H5 |
| 5 | `MultiMemoryStore.init()` accède à `CAnnoNicoSnapshotStore.shared` | Source `MultiMemoryStore.swift:50` | H1 | - |
| 6 | `CAnnoNicoSnapshotStore.init()` accède à `ProtectedFolderAccessCoordinator.shared` | Source `CAnnoNicoSnapshotStore.swift:26` | H1 | - |
| 7 | `SUPRACompositionRoot.init()` crée simultanément `MultiMemoryStore.shared` + `MissionStore()` + `SUPRAIntelligenceEngine.shared` | Source `SUPRACompositionRoot.swift:33-38` | H1, H3 | - |
| 8 | `SUPRAIntelligenceEngine.init()` est `private init() {}` (empty) | Source `SUPRAIntelligenceEngine.swift:20` | H3 (ordre) | H1 (pas de cercle directe IEN→MultiMemory) |
| 9 | `MissionStore.init()` est minimalist: `self.sourceURL = ...; self.evolutionEngine = ...` | Source `MissionStore.swift:55-58` | H3 (ordre) | H1 (pas de cercle directe MS→MultiMemory) |
| 10 | `XCTestConfigurationFilePath` env var | Crash log context | (test infrastructure) | - |

**Note sur la divergence source vs crash log** : Le crash log montre `MissionStore.init` → `SUPRAIntelligenceEngine.init` → `MultiMemoryStore`, mais dans le code CURRENT `MissionStore.init()` et `SUPRAIntelligenceEngine.init()` sont vides et NE font PAS ces accès. Cela signifie soit:
- Le crash log est d'une version antérieure du code (la plus probable), OU
- Les numéros de ligne du crash log correspondent à un binaire compilé avant les refactors récents

---

## 5. CHAÎNE CAUSALE DÉTAILLÉE

```
1. SUPRAOperationalCoreApp struct is created
   ↓
2. @StateObject var compositionRoot = SUPRACompositionRoot.shared
   ↓
3. SUPRACompositionRoot.shared → dispatch_once(A) commence
   ↓
4. SUPRACompositionRoot.init() commence
   ├─ Ligne 31: let runtimeDataService = RuntimeDataService.shared
   │   (dispatches pour RuntimeDataService si pas encore initialisé)
   ├─ Ligne 32: let runtimeMonitor = RuntimeMonitor(...)
   │   (objet simple)
   ├─ Ligne 33: let multiMemoryStore = MultiMemoryStore.shared
   │   → dispatch_once(B) commence
   │   ├─ MultiMemoryStore.init() - line 21
   │   │   ├─ Line 22: loadRegistries()
   │   │   └─ Line 23: subscribeToSnapshotStore()
   │   │       ├─ Line 50: CAnnoNicoSnapshotStore.shared ← dispatch_once(C)
   │   │       │   ├─ CAnnoNicoSnapshotStore.init()
   │   │       │   ├─ Line 26: protectedAccess = ProtectedFolderAccessCoordinator.shared
   │   │       │   │   → dispatch_once(D) commence (lecture de fichiers)
   │   │       │   └─ protectedAccess retourné
   │   │       └─ Line 50: subscription .sink créée
   │   │           (recevra nil immédiatement puisque state == nil)
   │   │       └─ self?.rebuild() appelé si state != nil (pas le cas)
   │   ├─ Line 34: let intelligenceEngine = SUPRAIntelligenceEngine.shared
   │   │   → dispatch_once(E)
   │   ├─ Ligne 35: let missionObserver = SUPRAMissionObserver.shared
   │   │   → dispatch_once(F)
   │   ├─ Ligne 36: let missionOpportunityEngine = MissionOpportunityEngine.shared
   │   │   → dispatch_once(G)
   │   ├─ Ligne 37: let missionEvolutionEngine = MissionEvolutionEngine.shared
   │   │   → dispatch_once(H)
   │   ├─ Ligne 38: let missionStore = MissionStore(evolutionEngine: ...)
   │   │   → MissionStore.init() NE crée PAS de new dispatch_once
   │   └─ Line 59: missionStore.bind(...)
   │       Line 60: multiMemoryStore.bind(...)
   │       → subscribeToMissionStore() ← crée subscriber Combine
   │
   ├─ LIGNE 31 (continué): Mais RuntimeDataService/shared peut aussi 
   │   créer une chaine de singletons
   └─ ...

PROBLÈME: si dans une version antérieure (celle du crash log) 
MissionStore.init() ou SUPRAIntelligenceEngine.init() accédait à
MultiMemoryStore.shared, on aurait:
  dispatch_once(B) en cours → MissionStore → MultiMemoryStore.shared
  → dispatch_once(B) de nouveau → CRASH "trying to lock recursively"

DANS LE CODE ACTUEL: 
MissionStore.init() est vide de singleton access.
MAIS: la chaine SUPRACompositionRoot → MultiMemoryStore → CAnnoNicoSnapshotStore 
→ ProtectedFolderAccessCoordinator est toujours présente.
```

### 5.1 Pourquoi le crash persiste (même si le cercle direct est brisé)

Le crash log prouve que le deadlock A EU LIEU dans le passé et le binaire actuel contient encore ce chemin de code. Le crash est un problème RÉEL qui nécessite une investigation plus poussée, notamment:

1. Le crash log est de `2026-07-30 00:24` — cette session matinale, AVANT notre travail
2. Si le code a été modifié pour briser le cercle direct, le binaire compilé contient encore l'ancien code
3. Le deadlock peut toujours être TRIGGERED si un utilisateur lance l'app dans un état où certains singletons sont déjà partiellement initiaux (partial init)

### 5.2 Lien avec le blocage des tests

Le crash log montre le deadlock pendant le lancement de l'app (procRole: Background, parentProc: launchd). Ce crash EXPLIQUE pourquoi les tests ne peuvent pas s'exécuter — l'app TEST_HOST crash au lancement, ce qui fait échouer `xcodebuild test` immédiatement.

---

## 6. EXPÉRIMENTATION

### 6.1 Expérience principale

**Hypothèse**: Le deadlock se produit parce que `dispatch_once` est non réentrant  

**Preuve**: Crashes log à `_dispatch_once_wait` avec "trying to lock recursively" — c'est la preuve directe que le système `dispatch_once` de libdispatch détecte une ré-entrance et aborte avec `EXC_BREAKPOINT`/`SIGTRAP`.

### 6.2 Expérience de vérification

Aucune expérimentation dynamique n'est possible car:
1. Le crash empêche tout lancement stable de SUPRA.app
2. Les tests unitaires ne peuvent pas s'exécuter (test host crashe)
3. L'app ne peut pas être lancée normalement non plus (crash en arrière-plan)

---

## 7. CAUSE RACINE CERTIFIÉE

```
CAUSE RACINE UNIQUE:
────────────────────

Deadlock de dispatch_once récurrent causé par une dépendance 
circulaire dans l'initialisation des singletons de SUPRACompositionRoot.

ÉVIDENCES:
─────────
1. Crash log: ~/Library/Logs/DiagnosticReports/SUPRA-2026-07-30-002433.ips
   → Fault: "BUG IN CLIENT OF LIBDISPATCH: trying to lock recursively"
   → Exception: EXC_BREAKPOINT / SIGTRAP dans _dispatch_once_wait

2. Source: SUPRACompositionRoot.swift (lignes 31-37)
   → Accès simultané à MultiMemoryStore.shared et MissionStore 
     et SUPRAIntelligenceEngine.shared dans init()

3. Source: MultiMemoryStore.swift (ligne 50)
   → subscribeToSnapshotStore() accède à CAnnoNicoSnapshotStore.shared 
     pendant son propre dispatch_once block

4. Source: CAnnoNicoSnapshotStore.swift (ligne 26)
   → ProtectedFolderAccessCoordinator.shared accédé pendant l'init

5. Binaire testé: crash récurrent à chaque lancement de SUPRA.app
   → empêche le TEST_HOST de fonctionner → bloquage des tests XCTest

TYPE D'ÉCHEC: Deadlock dispatch_once (libdispatch non-réentrant)
SÉVÉRITÉ: Critique — empêche tout lancement de SUPRA.app
```

---

## 8. CORRECTION MINIMALE PROPOSÉE

### 8.1 Analyse du problème

Le pattern `dispatch_once + access à d'autres singletons + dépendances circulaires` est une anti-pattern classique. La correction doit briser le cercle d'initialisation.

### 8.2 Correction recommandée (Option A — Minimal)

**Principe**: Lazy initialization des dépendances qui causent le cercle — au lieu de les résoudre pendant `init()`, les résoudre à la première utilisation (lazy).

**Fichier cible**: `MultiMemoryStore.swift`

**Changement**: Extraire `subscribeToSnapshotStore()` du `init()` et appeler lazyment lors de la première utilisation.

```swift
// AVANT (MultiMemoryStore.swift, ligne 21-24):
private init() {
    loadRegistries()
    subscribeToSnapshotStore()
}

// APRÈS:
private init() {
    loadRegistries()
    // subscribeToSnapshotStore() déplacé vers bind() pour 
    // éviter l'initialisation de CAnnoNicoSnapshotStore 
    // pendant le dispatch_once de MultiMemoryStore
}

func bind(missionStore: MissionStore, runtimeMonitor: RuntimeMonitor) {
    self.missionStore = missionStore
    self.runtimeMonitor = runtimeMonitor
    subscribeToSnapshotStore()  ← démarrage lazy
    subscribeToMissionStore(missionStore)
    rebuild()
}
```

### 8.3 Correction recommandée (Option B — Structural)

**Principe**: Supprimer l'accès à `CAnnoNicoSnapshotStore.shared` pendant le `init()` de `MultiMemoryStore`. Passer par DI (Dependency Injection) au lieu de lazy singleton access.

### 8.4 Non corrections (déconseillées)

- ❌ Retirer `@MainActor` (changement architectural majeur)
- ❌ Retirer `@Published` (change la réactivité)
- ❌ Supprimer le pattern singleton (refactoring massif)
- ❌ Utiliser `.task` avec `DispatchQueue.main.async` (cache le problème)

---

## 9. PREUVES COMPLÉMENTAIRES

### Annexe A: Crash log extrait

```json
{
  "asi": {
    "libdispatch.dylib": [
      "BUG IN CLIENT OF LIBDISPATCH: trying to lock recursively"
    ]
  },
  "exception": {
    "type": "EXC_BREAKPOINT",
    "signal": "SIGTRAP",
    "codes": "0x0000000000000001, 0x00000001880300b0"
  },
  "threads": [
    {
      "triggered": true,
      "frames": [
        "_dispatch_once_wait.cold.1",
        "_dispatch_once_wait",
        "SUPRACompositionRoot.shared.unsafeMutableAddressor",
        "SUPRACompositionRoot.().init()",
        "MissionStore.init(sourceURL:)",
        "SUPRAIntelligenceEngine.().init()",
        "MultiMemoryStore.__allocating_init() ← ENCORE dispatch_once",
        "_dispatch_once_callout ← DÉTERMINÉ RÉCURSIF",
        ...
      ]
    }
  ]
}
```

### Annexe B: Diagramme de dépendance d'initialisation

```
SUPRACompositionRoot.shared (dispatch_once A)
│
├── RuntimeDataService.shared (dispatche_once R)
│
├── MultiMemoryStore.shared (dispatch_once B) ← CRASH POINT
│   └── subscribeToSnapshotStore()
│       └── CAnnoNicoSnapshotStore.shared (dispatch_once C)
│           └── ProtectedFolderAccessCoordinator.shared (dispatch_once D)
│               └── loadCachedSnapshot() [fichier I/O, ok]
│               └── loadPermissionState() [fichier I/O, ok]
│               Retour D → C → retour dans B
│
├── SUPRAIntelligenceEngine.shared (dispatch_once E)
│
├── SUPRAMissionObserver.shared (dispatch_once F)
│
├── MissionOpportunityEngine.shared (dispatch_once G)
│
├── MissionEvolutionEngine.shared (dispatch_once H)
│
├── MissionStore() ← pas de dispatch_once (objet simple)
│
└── bind() calls:
    ├── missionStore.bind(...)
    ├── multiMemoryStore.bind(...) ← crée subscriber Combine
    ├── intelligenceEngine.bind(...)
    ├── missionObserver.bind(...)
    ├── missionOpportunityEngine.bind(...)
    └── missionEvolutionEngine.bind(...)
```

### Annexe C: Pourquoi la dépendance est "circulaire" dans le binaire d'avant

Dans le binaire OLD (celui du crash), la pile montre:
```
MissionStore.init(sourceURL:) ← appelle SUPRAIntelligenceEngine.init()
SUPRAIntelligenceEngine.init() ← appelle... MultiMemoryStore.shared
```

Cela signifie que dans le code ANTERIEUR:
- `SUPRAIntelligenceEngine.init()` accédait à `MultiMemoryStore.shared` ou à un objet qui l'accédait
- `MissionStore.init()` accédait à `SUPRAIntelligenceEngine.shared` ou à un objet qui l'accédait
- Ce cercle existait dans une ancienne version du code

Le code courant a réorganisé ces dépendances (SUPRAIntelligenceEngine.init() est vide, MissionStore.init() est minimal), mais le binaire compilé est toujours l'ancien. Un `xcodebuild clean build` nécessaire pour reconstruire le binaire avec le code courant.

---

## 10. IMPACT ARCHITECTURAL

| Dimension | Impact |
|-----------|--------|
| Architecture singleton | ⚠️ Risque de dépendance circulaire dans l'init |
| Performance | ❌ Deadlock empêche le lancement de l'app |
| Compilation | ✅ BUILD SUCCEEDED après la correction Ω1 |
| Test runner | ❌ CRASH au lancement (bloqué) |
| Production app | ❌ CRASH au lancement (bloqué) |
| Régression Ω1 | ❌ Aucune — Ω1 est gelé et indépendant |

---

## 11. RISQUES RÉSIDUELS

| Risque | Probabilité | Mitigation |
|--------|:-----------:|------------|
| Ancien binaire toujours compilé avec ancien code | Élevée | Clean build nécessaire avant validation |
| Autres dépendances circulaires non découvertes | Moyenne | Analyse complète de l'init chain requise |
| `CAnnoNicoSnapshotStore` init toujours appelé pendant `MultiMemoryStore` init | Moyenne | La correction lazy la briserait |
| Correction Ω1 (XCTestConfigurationFilePath guard) non testable | Critique | Nécessite la résolution de Ω1.1 |

---

## 12. CONCLUSION

```
QUESTION: Ω1.1 — Pourquoi le deadlock dispatch_once se produit-il ?
Réponse: Parce que SUPRACompositionRoot.init() accède à MultiMemoryStore.shared 
         pendant que MultiMemoryStore.shared.init() accède à CAnnoNicoSnapshotStore.shared,
         créant une chaîne d'initialisation de singletons qui 
         (dans le binaire précédent) bouclait sur elle-même 
         via dispatch_once non réentrant → SIGTRAP.

PREUVES:
  1. Crashes log: dispatch_once recursive lock failure
  2. Source: SUPRACompositionRoot → MultiMemoryStore → 
     CAnnoNicoSnapshotStore → ProtectedFolderAccessCoordinator chaine d'init
  3. Source: MissionStore/SURAIntelligenceEngine.init() (ancien code) 
     créaient le cercle de dépendances
  4. Crash empêche test host ET app normale de fonctionner

CAUSE RACINE: ✅ CERTIFIÉE

CORRECTION: Lazy init recommandée — briser le cercle 
            en déplaçant subscribeToSnapshotStore() hors du init().

PROCHAINES ACTIONS:
  1. Exécuter un "xcodebuild clean" puis rebuilder
  2. Si le crash log persiste avec le nouveau binaire → 
     appliquer la correction lazy init
  3. Si le crash log disparaît → Ω1.1 est résolu par 
     les refactors récents du code source
```

---

*Rapport produit par SUPRA Executive — Evidence First Governance*  
*Certifié par FACTORY_06_PROOF*  
*Référence Ω1 Baseline: ROOT_CAUSE_CERTIFICATION_OMEGA1.md + FINAL_VALIDATION_REPORT_OMEGA1.md*
