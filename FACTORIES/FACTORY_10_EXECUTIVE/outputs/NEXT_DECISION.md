# NEXT DECISION — FOUNDATION ERA · EXECUTIVE BOOTSTRAP V1

## Status: RECOMMENDED — awaiting ratification

| Property | Value |
|----------|-------|
| **Version** | NEXT_DECISION_FOUNDATION_ERA_V1 |
| **Date** | 2026-07-31 |
| **Authority** | FACTORY_10_EXECUTIVE — ligne de développement V2 |
| **Baseline** | BUILD_CERTIFIED_V1 (immuable, commit `7488aa0`) |
| **Mission** | EXECUTIVE BOOTSTRAP V1 — FOUNDATION ERA |
| **Mode** | Architecture First (terminé) |

---

## CONTEXTE

La mission FOUNDATION ERA (architecture-first) a produit 8 livrables certifiés par FACTORY_01_ARCHITECTURE. L'évaluation de readiness est **READY** (10/10 critères, EXECUTION_READINESS.md).

## DÉCISION PROPOSÉE

**CONTINUE — autoriser l'implémentation de MIGRATION_PLAN étape 1 (Foundation Layer : `FileSystemPort`)**

### Règles de transition

1. **BUILD_CERTIFIED_V1 reste immuable** — aucune modification de la baseline
2. Toute implémentation se fait sur `executive-runtime-v2`
3. Chaque étape de MIGRATION_PLAN est un commit isolé et réversible
4. **Gate obligatoire par étape** : build ✅ + tests 139/139 ✅ avant de continuer
5. Aucune modification des fonctionnalités métier (Mission → Decision → Execution → Evidence → Memory)
6. Aucune nouvelle UI
7. Aucun `waitUntilExit` — toute lecture git devient asynchrone ou stockée
8. Budget performance STARTUP_PROFILE : cold start ≤ 130 ms, boot manager ≤ 350 ms, main thread libre

### Périmètre autorisé (étape 1)

| Composant | Détail |
|-----------|--------|
| `StorageLocations` | enum des 8 répertoires + artefacts canoniques |
| `FileSystemPort` | read / write atomique / exists / createDirectory / list / migrate |
| `ApplicationSupportLocator` | résolution `~/Library/Application Support/SUPRA` |
| Tests | in-memory FS injecté + dossiers temporaires |

### Hors périmètre (étapes suivantes)

- Étape 2 (ExecutiveBootstrap, ArtifactRegistry, ContinuityEngine) : décision séparée à la fin de l'étape 1
- Étape 3 (bascule du Runtime) : décision séparée à la fin de l'étape 2
- Étape 4 (certification) : décision séparée à la fin de l'étape 3

### Statut de la mission FOUNDATION ERA

| Élément | Statut |
|---------|--------|
| Architecture | ✅ CERTIFIED (8/8 livrables) |
| Readiness | ✅ READY (10/10 critères) |
| Implémentation | ⏳ EN ATTENTE de ratification de cette décision |

---

## ALTERNATIVES SI REFUSÉE

| Décision | Conséquence |
|----------|-------------|
| **ADAPT** | réduire le périmètre V1 (ex. bootstrap seul, sans registry) |
| **REPLAN** | retour FACTORY_01 pour révision des livrables |
| **HALT** | geler la mission, prioriser une autre initiative V2 |

---

*Décision proposée par FACTORY_10_EXECUTIVE — mission FOUNDATION ERA.*
