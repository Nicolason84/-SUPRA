# MIGRATION_PLAN.md

## Plan de migration vers l'architecture canonique — FOUNDATION ERA

| Field | Value |
|-------|-------|
| **Version** | MIGRATION_PLAN_V1 |
| **Date** | 2026-07-31 |
| **Autorité** | FACTORY_01_ARCHITECTURE — mission FOUNDATION ERA |
| **Statut** | SPECIFICATION — exécution soumise à décision exécutive |
| **Principe** | Aucune régression · Aucune régression Startup · Fonctionnalités métier intactes |

---

## 1. Objectif

Passer de l'état actuel (Runtime ↔ système de fichiers direct) à l'architecture cible (4 couches, Single Writer d'environnement, Single Artifact Access, Single Persistence Owner) **sans jamais casser le build, les tests ou le démarrage**.

---

## 2. État actuel (point de départ)

| Élément | Fichier | Rôle actuel |
|---------|---------|-------------|
| Résolution de racine | `SUPRAEnvironmentResolver.swift` | expose `projectRoot` (chemins bruts) |
| Boot + continuité | `ExecutiveBootManager.swift` | 7 lectures directes, 2 spawn git bloquants (`waitUntilExit`) |
| Continuité d'état | `ContinuityManager.swift` | 9+ lectures directes, spawn git bloquant, logs `not found` |
| Lecture artefacts | `ArtifactReader.swift` | `URL(fileURLWithPath:)` câblés (LOT1-3, BUILD_STATUS, MANIFEST, ESTATE, INDEX) |
| Contrôle d'architecture | `BootstrapGovernance.swift` | analyse statique — **à conserver et étendre** |
| Artefacts runtime | racine workspace | SUPRA_STATE.json, RUNTIME_STATUS.json, runtime_diagnostics.json, CONTINUITY.md, NEXT_MISSION.md, version.json, proofs/, MANIFEST.json, ESTATE_STATE.json, INDEX.json |

---

## 3. Stratégie générale

```
Étape 1 : Foundation (FileSystemPort)      — aucune modification du comportement
Étape 2 : Infrastructure (Bootstrap+Registry+ContinuityEngine) — nouveaux composants, doublons fonctionnels temporaires
Étape 3 : Bascule (runtime → Registry)     — suppressions des lectures directes
Étape 4 : Certification                     — validation complète, rapport
```

**Règle de sécurité** : chaque étape est un commit isolé sur `executive-runtime-v2`, build + tests 139/139 obligatoires avant passage à l'étape suivante. Rollback = `git revert` de l'étape.

---

## 4. Étapes détaillées

### Étape 1 — Foundation Layer : `FileSystemPort`

| Action | Détail |
|--------|--------|
| Créer `StorageLocations` | enum des 8 répertoires + artefacts canoniques |
| Créer `FileSystemPort` | read / write atomique / exists / createDirectory / list / migrate |
| Créer `ApplicationSupportLocator` | résolution `~/Library/Application Support/SUPRA` (best practice Apple) |
| Tests | in-memory FS injecté + vrais dossiers temporaires |
| Gate | build ✅, tests ✅, zéro changement de comportement |

### Étape 2 — Infrastructure Layer : nouveaux composants

| Action | Détail |
|--------|--------|
| Créer `ExecutiveBootstrap` | `detectEnvironment()` → FIRST_LAUNCH/INSTALLED ; `prepareEnvironment()` (8 dossiers + 8 artefacts minimaux) ; `verifyCoherence()` ; `publishBootReport()` |
| Créer `ArtifactRegistry` | API V1 (ARTIFACT_REGISTRY_SPEC § 4), résolution Application Support → repli workspace, défauts sémantiques, migrations |
| Créer `ContinuityEngine` | `prepareSession()`, `snapshot()`, `restore()`, `migrateIfNeeded()`, `syncMemoryToDisk()` |
| Brancher dans `SUPRACompositionRoot` | nouveaux services gouvernés (BootstrapGovernance étendu) |
| Tests | FirstLaunchTest (env vierge), LegacyArtifactTest (lecture racine) |
| Gate | build ✅, tests ✅ — **l'ancien code n'est pas encore touché** (compatibilité garantie) |

### Étape 3 — Bascule du Runtime vers le Registry

| Action | Détail |
|--------|--------|
| `ExecutiveBootManager` → `BootOrchestrator` | l'orchestration reste, chaque lecture devient un appel Registry ; git lu **une fois** en async par le Bootstrap, stocké dans SUPRA_STATE.json ; suppression des `waitUntilExit()` |
| `ContinuityManager` → `ContinuityEngine` | toutes les lectures directes remplacées par appels Registry ; les logs `not found` disparaissent (défauts sémantiques) |
| `ArtifactReader` → supprimé | remplacé par `ArtifactRegistry` |
| `SUPRAEnvironmentResolver` → restreint | `projectRoot` n'est plus exposé aux composants Runtime (réservation pour outils d'analyse) |
| Migration des artefacts | première exécution : copie des artefacts racine existants vers Application Support/SUPRA (lecture seule du workspace), puis écritures canoniques |
| Analyse statique | BootstrapGovernance étendu : patterns interdits dans Runtime/Domain = 0 occurrence |
| Tests | les 6 tests d'architecture (BOOTSTRAP_ARCHITECTURE § 8) |
| Gate | build ✅, tests 139/139 + nouveaux ✅, STARTUP_PROFILE sans régression |

### Étape 4 — Certification

| Action | Détail |
|--------|--------|
| Certification FACTORY_06 | preuves : tests, analyse statique, profilage, scénarios premier lancement / lancements suivants |
| Quality gate FACTORY_07 | zéro violation de couche, zéro warning actionnable |
| Documentation | mise à jour des docs runtime (RUNTIME_FOUNDATION_V2 → V3 cible) |
| Rapport final | MIGRATION_COMPLETE_REPORT.md + mise à jour `.kernel/Runtime.json` |
| Décision exécutive | CONTINUE / ADAPT / HALT pour la suite (Phase 1 V2 roadmap) |

---

## 5. Ordre de suppression des lectures directes (priorité)

| # | Lecture directe (actuelle) | Remplacée par | Fichier impacté |
|---|----------------------------|---------------|-----------------|
| 1 | `RUNTIME_STATUS.json` | `registry.runtimeStatus()` | ExecutiveBootManager, ContinuityManager |
| 2 | `SUPRA_STATE.json` | `registry.state()` | ExecutiveBootManager, ContinuityManager |
| 3 | `CONTINUITY.md` | `registry.continuity()` | ExecutiveBootManager, ContinuityManager |
| 4 | `NEXT_MISSION.md` | `registry.nextMission()` | ContinuityManager |
| 5 | `BUILD_STATUS.md` | `registry.buildStatus()` | ContinuityManager, ArtifactReader |
| 6 | `version.json` | `registry.version()` | ContinuityManager |
| 7 | `proofs/LOT{1,2,3}.json` | `registry.lotProofs()` | ArtifactReader |
| 8 | `MANIFEST.json` / `ESTATE_STATE.json` / `INDEX.json` | `registry.manifest()` / `estate()` / `index()` | ArtifactReader, ContinuityManager |
| 9 | `runtime_diagnostics.json` | `registry.diagnostics()` | ContinuityManager |
| 10 | spawn git bloquants | supprimés (état git stocké) | ExecutiveBootManager, ContinuityManager |

---

## 6. Risques et mitigations

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Régression startup | FAIBLE (étape 3) | ÉLEVÉ | budget performance mesuré avant/après chaque étape (STARTUP_TIMELINE) |
| Perte d'artefacts hérités | FAIBLE | ÉLEVÉ | étape 3 : copie de migration lue depuis le workspace, jamais destructive |
| Régressions tests | MOYENNE | MOYEN | gate build+tests 139/139 à chaque étape, commits isolés réversibles |
| Couplage résiduel (lectures directes oubliées) | MOYENNE | MOYEN | analyse statique BootstrapGovernance étendue = gate obligatoire |
| Non-déterminisme du premier lancement (sandbox macOS) | FAIBLE | MOYEN | Application Support sans permission spéciale ; security-scoped access seulement si nécessaire |
| Chemin du workspace changé (démos) | FAIBLE | FAIBLE | le workspace reste la source Git ; la persistance est dans Application Support |

---

## 7. Critères de sortie (Definition of Done)

| Critère | État cible |
|---------|------------|
| Build | BUILD SUCCEEDED, 0 erreur, 0 warning actionnable |
| Tests | 139/139 existants + nouveaux tests (FirstLaunch, SubsequentLaunch, Registry, Continuity, Migration, Layering) |
| Performance | cold start ≤ 119 ms ± tolérance, boot manager ≤ 316 ms ± tolérance, Main Thread libre (STARTUP_PROFILE) |
| Couches | 0 occurrence des patterns interdits dans Runtime/Domain |
| Environnement | premier lancement : 8/8 artefacts, BOOT_REPORT valide ; lancements suivants : validation + rapport, jamais de réinstallation |
| Fonctionnalités | aucune modification métier (Mission → Decision → Execution → Evidence → Memory inchangée) |
| UI | aucune nouvelle vue |

---

## 8. Estimation

| Étape | Effort | Dépendance |
|-------|--------|------------|
| 1 — Foundation | S | aucune |
| 2 — Infrastructure | M | Étape 1 |
| 3 — Bascule Runtime | M | Étape 2 |
| 4 — Certification | S | Étape 3 |
| **Total** | **~2M+1S sessions** | — |

---

**END OF MIGRATION_PLAN** — produit par FACTORY_01_ARCHITECTURE, mission FOUNDATION ERA.
