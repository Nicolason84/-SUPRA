# NAMBROCAHORA — FOUNDATION

## Fondation du Temps Canonique de SUPRA

| Propriété | Valeur |
|---|---|
| **Nom** | NAMBROCAHORA — Canonical Time Reference |
| **Version** | NAMBROCAHORA_V1 |
| **Date** | 2026-07-29 |
| **Statut** | LIVRABLE AUDIT — FONDATION |
| **Autorité** | SUPRA Constitution — Article 2 |
| **Loi applicable** | Loi 3 : Le Runtime se synchronise exclusivement en NAMBROCAHORA |

---

## 1. PHILOSOPHIE NAMBROCAHORA

NAMBROCAHORA n'est pas un moteur de découverte temporelle.
NAMBROCAHORA n'est pas un clock physique.
NAMBROCAHORA n'est pas un timestamp système.

NAMBROCAHORA est le **temps canonique de SUPRA**.

Le temps machine reste un temps brut.
Avant d'être utilisé par le Runtime, tout horodatage doit être traduit en NAMBROCAHORA.

Le Runtime ne raisonne jamais directement sur le temps système.
Il raisonne exclusivement sur NAMBROCAHORA.

---

## 2. DÉFINITION FORMELLE

### 2.1 NAMBROCAHORA tick

```
NAMBROCAHORA_TICK ::= INT64

Valeur : Compte monotone croissant depuis l'initialisation du système
Unité : Ticks logiques (pas de correspondance fixe avec le temps physique)
Premier tick : 0 (l'instant de l'initialisation du Runtime)
Incrément : +1 par événement traité par le Runtime
```

### 2.2 Propriétés de NAMBROCAHORA

| Propriété | Description | Implication |
|-----------|-------------|-------------|
| **Monotone** | Les ticks ne reculent jamais | La causalité est garantie |
| **Total order** | Tout événement a un tick unique | L'ordre total est préservé |
| **Logique** | Pas de correspondance physique directe | Indépendant de l'horloge machine |
| **Immutable** | Un tick ne peut être modifié après affectation | Traçabilité garantie |
| **Unique** | Chaque événement a un tick différent | Pas d'ambiguïté temporelle |
| **Compact** | INT64 — 8 octets | Efficace pour le stockage et la comparaison |
| **Portable** | Indépendant de la plateforme | Fonctionne sur macOS, Linux, iOS |

### 2.3 Pourquoi INT64 et pas un format complexe

| Considération | Réponse |
|---------------|---------|
| Pourquoi pas ISO8601 ? | ISO8601 est un format de projection, pas une référence interne |
| Pourquoi pas UUID ? | UUID n'a pas d'ordre total, pas de causalité |
| Pourquoi pas Date() ? | Date() est un temps machine, le Runtime ne l'utilise pas |
| Pourquoi pas Unix timestamp ? | Unix timestamp dépend de l'horloge système, pas canonique |
| Pourquoi pas un timestamp logique (Lamport) ? | Lamport est trop complexe pour le cas d'usage ; un simple compte monotone suffit |
| Pourquoi INT64 ? | Sufficient for billions of ticks; compact; fast comparison |

---

## 3. NAMBROCAHORA vs TEMPS MACHINE

```
TEMPS MACHINE (brut)                    NAMBROCAHORA (canonique)
────────────────────────                ──────────────────────────
Date()                                  NAMBROCAHORA.tick()
ISO8601 date string                     tick: INT64
Unix timestamp (ms)                     tick: INT64
uuid()                                  eventId → derived from tick
System.currentTimeMillis()              tick: INT64
 mach_absolute_time()                   tick: INT64
 CACurrentMediaTime()                   tick: INT64
 ProcessInfo.processInfo.systemUptime   tick: INT64
```

### 3.1 Règle de Conversion

```
TOUT temps machine doir être traduit en NAMBROCAHORA avant utilisation par le Runtime.

Conversion :
  1. Le temps machine est capté (Date(), systemUptime, etc.)
  2. TUV5 compile cette capture en un événement CANNoNICO
  3. CANNoNICO attribue un NAMBROCAHORA tick à cet événement
  4. Le tick est stocké comme référence temporelle CANNoNICO
  5. Le temps machine est projeté vers ISO8601 UNIQUEMENT par le Projection Engine

Exemple :
  AVANT :
    mission.createdAt = Date()  // 2026-07-29T14:30:00Z
    runtime.stored("createdAt", mission.createdAt)
  
  APRÈS :
    mission.tick = NAMBROCAHORA.tick()  // 42_000_001
    runtime.storeCANNoNICO("createdAtTick", mission.tick)
    // Le temps ISO8601 est projeté par le Projection Engine si nécessaire
```

---

## 4. NAMBROCAHORA OPÉRATIONS

### 4.1 Opérations Fondamentales

| Opération | Signature | Description |
|-----------|-----------|-------------|
| `now()` | `NAMBROCAHORA.now() → NAMBROCAHORA_TICK` | Retourne le tick actuel du Runtime |
| `advance()` | `NAMBROCAHORA.advance() → NAMBROCAHORA_TICK` | Incrémente le compteur et retourne le nouveau tick |
| `elapsed(from:)` | `NAMBROCAHORA.elapsed(from: NAMBROCAHORA_TICK) → INT64` | Retourne le nombre de ticks écoulés depuis un tick |
| `compare(a:b:)` | `NAMBROCAHORA.compare(a: INT64, b: INT64) → Comparison` | Compare deux ticks (-1, 0, +1) |
| `format(tick:)` | `NAMBROCAHORA.format(tick: INT64) → ISO8601_STRING` | Projette un tick vers ISO8601 (pour la projection UI/API) |
| `parse(iso8601:)` | `NAMBROCAHORA.parse(ISO8601_STRING) → NAMBROCAHORA_TICK` | Convertit un ISO8601 projeté en tick (pour l'ingestion) |
| `isBefore(a:b:)` | `NAMBROCAHORA.isBefore(a: INT64, b: INT64) → BOOLEAN` | a est-il avant b ? |
| `isAfter(a:b:)` | `NAMBROCAHORA.isAfter(a: INT64, b: INT64) → BOOLEAN` | a est-il après b ? |

### 4.2 Implémentation de Référence

```swift
public enum NAMBROCAHORA: Sendable {
    public static var currentTick: INT64 { get }
    public static func advance() -> INT64
    public static func elapsed(from tick: INT64) -> INT64
    public static func compare(_ a: INT64, _ b: INT64) -> ComparisonResult
    public static func format(_ tick: INT64) → String  // ISO8601 projection
    public static func parse(_ iso8601: String) → INT64 // reverse projection
    public static func isBefore(_ a: INT64, _ b: INT64) → Bool
    public static func isAfter(_ a: INT64, _ b: INT64) → Bool
}
```

---

## 5. NAMBROCAHORA × LES ENTITÉS TEMPORALES

### 5.1 Mapping des Entités Temporelles

| Entité | Champ Temporal Actuel | Champ NAMBROCAHORA Cible | Type |
|--------|----------------------|---------------------------|------|
| Snapshot | `generatedAt: Date` | `generatedAtTick: INT64` | NAMBROCAHORA |
| Mission | `createdAt, updatedAt` | `createdAtTick, updatedAtTick` | NAMBROCAHORA |
| Decision | `timestamp` | `tick` | NAMBROCAHORA |
| Event | `date` | `tick` | NAMBROCAHORA |
| Compilation (TUV5) | `timestamp` | `tick` | NAMBROCAHORA |
| Log Entry | `timestamp` | `tick` | NAMBROCAHORA |
| Version | `date` | `tick` | NAMBROCAHORA |
| State Transition | `timestamp` | `tick` | NAMBROCAHORA |
| Execution Gate | `date` | `tick` | NAMBROCAHORA |
| Registry Entry | `lastUpdated` | `lastUpdatedTick` | NAMBROCAHORA |
| Health Check | `lastRun` | `lastRunTick` | NAMBROCAHORA |
| Metric Point | `recordedAt` | `recordedAtTick` | NAMBROCAHORA |
| Session | `lastActive` | `lastActiveTick` | NAMBROCAHORA |
| Memory Frame | `timestamp` | `tick` | NAMBROCAHORA |
| Evidence | `date` | `tick` | NAMBROCAHORA |
| Trace | `timestamp` | `tick` | NAMBROCAHORA |
| Runtime Status | `lastCheck` | `lastCheckTick` | NAMBROCAHORA |
| Workspace State | `modifiedAt` | `modifiedAtTick` | NAMBROCAHORA |
| Runtime Service | `startedAt` | `startedAtTick` | NAMBROCAHORA |
| Workflow Step | `executedAt` | `executedAtTick` | NAMBROCAHORA |

### 5.2 Règles d'Utilisation NAMBROCAHORA

**RÈGLE 1** : Aucune entité temporelle ne peut stocker un `Date` système directement.

**RÈGLE 2** : Tout `Date système` capturé doit être immédiatement converti en NAMBROCAHORA tick via TUV5.

**RÈGLE 3** : Le Runtime ne peut jamais lire un `Date` système — il ne lit que des NAMBROCAHORA ticks.

**RÈGLE 4** : La projection vers ISO8601 est effectuée par le Projection Engine, uniquement quand le format externe l'exige.

**RÈGLE 5** : La conversion inverse (ISO8601 → tick) est effectuée par TUV5 lors de l'ingestion de connaissance externe.

**RÈGLE 6** : Les ticks sont toujours stockés en tant qu'INT64 — jamais en tant que strings.

**RÈGLE 7** : Le premier tick du système est 0. Chaque tick suivant est le précédent +1.

**RÈGLE 8** : En cas de redémarrage du Runtime, le compteur reprend le dernier tick connu +1 (persistance du tick final).

---

## 6. NAMBROCAHORA DANS LA PIPELINE CANONIQUE

```
Connaissance brute
  │
  ▼
TUV5 (compile et attribue NAMBROCAHORA)
  │  ← TUV5 convertit tous les timestamps en NAMBROCAHORA ticks
  │  ← TUV5 attribue un tick à chaque événement de compilation
  ▼
Connaissance compacte (CANNoNICO)
  │  ← CANNoNICO stocke uniquement des NAMBROCAHORA ticks
  │  ← CANNoNICO utilise les ticks pour l'ordre causal
  ▼
Runtime
  │  ← Le Runtime raisonne uniquement en NAMBROCAHORA ticks
  │  ← Le Runtime compare, trie et ordonne via NAMBROCAHORA
  │
  ├──→ Snapshot events utilisent NAMBROCAHORA.tick()
  ├──→ Traces utilisent NAMBROCAHORA.tick()
  ├──→ Missions utilisent NAMBROCAHORA.tick()
  ├──→ Événements utilisent NAMBROCAHORA.tick()
  ├──→ Décisions utilisent NAMBROCAHORA.tick()
  ├──→ Journaux utilisent NAMBROCAHORA.tick()
  ├──→ Versions utilisent NAMBROCAHORA.tick()
  ├──→ États utilisent NAMBROCAHORA.tick()
  ├──→ Compteurs utilisent NAMBROCAHORA.tick()
  └──→ Execution Gates utilisent NAMBROCAHORA.tick()
  │
  ▼
Projection Engine
  │  ← Le Projection Engine projette NAMBROCAHORA ticks vers ISO8601 pour UI/API
  │  ← Le Projection Engine projette NAMBROCAHORA ticks vers Bash timestamps pour scripts
  ▼
Format externes (Swift, JSON, Bash, Markdown, UI, API)
  │  ← Les formats externes reçoivent soit
  │    - ticks INT64 (pour les systèmes qui les comprennent)
  │    - ISO8601 (pour les systèmes qui n'utilisent pas CANNoNICO)
```

---

## 7. NAMBROCAHORA ET LES 5 LOIS

| Loi | Application NAMBROCAHORA |
|-----|--------------------------|
| Loi 1 | Le tick NAMBROCAHORA est une connaissance — il représente l'ordre causal du système |
| Loi 2 | Le Runtime ne raisonne que sur NAMBROCAHORA — jamais sur le temps machine |
| Loi 3 | La synchronisation est exclusivement via NAMBROCAHORA ticks — c'est la référence temporelle unique |
| Loi 4 | TUV5 transforme les timestamps machine en NAMBROCAHORA — il compile le temps |
| Loi 5 | NAMBROCAHORA enrichit le Runtime en fournissant une temporalité fiable sans créer de complexité |

---

## 8. NAMBROCAHORA × PROJECTION ENGINE

```
NAMBROCAHORA INT64 tick
     │
     ├──→ Projection → ISO8601 (pour Swift UI/API)
     │        format(tick) → "2026-07-29T14:30:00Z"
     │
     ├──→ Projection → Unix ms (pour Bash scripts)
     │        format(tick) → "1719678600000"
     │
     ├──→ Projection → ISO8601 (pour JSON API)
     │        format(tick) → "2026-07-29T14:30:00Z"
     │
     ├──→ Projection → Relative (pour Markdown docs)
     │        format(tick) → "42 ticks ago"
     │
     └──→ Projection → Human-readable (pour UI)
              format(tick) → "il y a 42 ticks"
```

---

## 9. NAMBROCAHORA — CONTRAINTES

| Contrainte | Règle | Exigence |
|------------|-------|----------|
| C-NAMBRO-01 | Le tick ne doit jamais reculer | Si le tick system est inférieur, c'est une erreur |
| C-NAMBRO-02 | Le tick doit être stocké en INT64 | Aucun format string pour le stockage interne |
| C-NAMBRO-03 | La conversion tick→ISO8601 doit être bijective | Tout tick peut être reconverti |
| C-NAMBRO-04 | Le tick doit être persistant entre redémarrages | Le dernier tick est sauvegardé |
| C-NAMBRO-05 | Deux événements ne peuvent avoir le même tick | Unicité garantie par l'avancement monotone |
| C-NAMBRO-06 | Les ticks de publication TUV5 doivent être consécutifs | Pas de gaps autorisés |
| C-NAMBRO-07 | Le tick zéro est réservé à l'initialisation | tick=0 = instant de création du système |

---

## 10. ENTITÉS OBLIGATOIRES NAMBROCAHORA

Ces entités DOIVENT utiliser NAMBROCAHORA comme référence temporelle unique :

| # | Entité | Champ NAMBROCAHORA | Obligation |
|---|--------|---------------------|------------|
| 1 | Snapshot | `generatedAtTick` | Obligatoire |
| 2 | Trace | `tick` | Obligatoire |
| 3 | Mission | `createdAtTick, updatedAtTick` | Obligatoire |
| 4 | Événement | `tick` | Obligatoire |
| 5 | Décision | `tick` | Obligatoire |
| 6 | Journal | `tick` | Obligatoire |
| 7 | Version | `tick` | Obligatoire |
| 8 | État | `transitionTick` | Obligatoire |
| 9 | Compteur | `lastTick` | Obligatoire |
| 10 | Execution Gate | `gateTick` | Obligatoire |
| 11 | Compilation TUV5 | `compiledAtTick` | Obligatoire |
| 12 | CANNoNICO Entity | `createdAtTick, modifiedAtTick` | Obligatoire |
| 13 | Relation CANNoNICO | `establishedAtTick` | Obligatoire |
| 14 | Connaissance CANNoNICO | `publishedAtTick` | Obligatoire |

---

*NAMBROCAHORA Foundation V1 — SUPRA ULTIMATE CONSOLIDATED*
*Audit exécuté le 2026-07-29*
