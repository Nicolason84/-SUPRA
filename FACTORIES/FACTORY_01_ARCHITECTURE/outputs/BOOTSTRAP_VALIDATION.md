# BOOTSTRAP_VALIDATION.md

## Stratégie de validation — EXECUTIVE BOOTSTRAP V1

| Field | Value |
|-------|-------|
| **Version** | BOOTSTRAP_VALIDATION_V1 |
| **Date** | 2026-07-31 |
| **Autorité** | FACTORY_01_ARCHITECTURE — mission FOUNDATION ERA |
| **Statut** | SPECIFICATION |

---

## 1. Objectif

Valider que le Runtime démarre **toujours** dans un environnement valide, sans régression de performance, sans modification des fonctionnalités métier.

---

## 2. Scénarios de validation

### S1 — Premier lancement (environnement vierge)

| Étape | Vérification | Attendu |
|-------|--------------|---------|
| Préparation | supprimer `~/Library/Application Support/SUPRA` | absent |
| Lancement | `detectEnvironment()` | `FIRST_LAUNCH` |
| Création | 8 répertoires | `State/ Runtime/ Artifacts/ Continuity/ Snapshots/ Logs/ Cache/ Missions/` |
| Installation | 8 artefacts minimaux | `SUPRA_STATE.json`, `RUNTIME_STATUS.json`, `runtime_diagnostics.json`, `BOOT_REPORT.json`, `BUILD_STATUS.md`, `CONTINUITY.md`, `NEXT_MISSION.md`, `MISSION_QUEUE.json` |
| Cohérence | chaque artefact | lisible + décodable + valide (checksums dans BOOT_REPORT.json) |
| API Registry | les 5 appels métier | valeurs **valides**, zéro `not found` |
| Résultat | BOOT_REPORT.json | `launchKind: firstLaunch`, `environmentStatus: created`, artefacts `8/8` |

### S2 — Lancements suivants (environnement installé)

| Étape | Vérification | Attendu |
|-------|--------------|---------|
| Lancement | `detectEnvironment()` | `INSTALLED` |
| Validation | artefacts attendus | tous lisibles et cohérents |
| Migration | version workspace == version artefacts | aucune migration déclenchée |
| Non-réinstallation | compteur d'installation | **0 création** (aucun `PREPARE_ENVIRONMENT`) |
| Résultat | BOOT_REPORT.json | `launchKind: validation` |

### S3 — Migration (version artefacts < version workspace)

| Étape | Vérification | Attendu |
|-------|--------------|---------|
| Préparation | artefact v2.0 installé, workspace v2.2 | divergence détectée |
| Migration | `ContinuityEngine.migrateIfNeeded()` | migrations v2.0→v2.1→v2.2 appliquées |
| Résultat | BOOT_REPORT.json | `launchKind: migration`, rapport des migrations |

### S4 — Artefact corrompu (dégradation gracieuse)

| Étape | Vérification | Attendu |
|-------|--------------|---------|
| Préparation | corrompre `RUNTIME_STATUS.json` | JSON invalide |
| Appel | `registry.runtimeStatus()` | modèle valide `.degraded` + raison structurée |
| Affichage | UI | aucune chaîne `... not found` |
| Résultat | BOOT_REPORT.json | avertissement `ARTIFACT_CORRUPTED` |

### S5 — Non-régression fonctionnelle

| Vérification | Attendu |
|--------------|---------|
| Séquence métier Mission → Decision → Execution → Evidence → Memory | inchangée |
| Navigation | opérationnelle |
| Main Thread | non bloqué pendant le boot |
| Aucune nouvelle UI | diff de vues vide |

---

## 3. Tests automatisés

| Test | Couvre | Référence |
|------|--------|-----------|
| `FirstLaunchTest` | S1 | BOOTSTRAP_ARCHITECTURE § 8 (3) |
| `SubsequentLaunchTest` | S2 | BOOTSTRAP_ARCHITECTURE § 8 (4) |
| `MigrationTest` | S3 | ARTIFACT_REGISTRY_SPEC § 9 |
| `RegistryAccessTest` | Single Artifact Access | ARTIFACT_REGISTRY_SPEC § 9 |
| `LayeringTest` | interdits de couche | BOOTSTRAP_ARCHITECTURE § 8 (1) |
| `MainThreadTest` | aucun blocage main actor | BOOTSTRAP_ARCHITECTURE § 8 (5) |
| `LegacyArtifactTest` | lecture des artefacts racine existants | ARTIFACT_REGISTRY_SPEC § 10 |

Exécution : `xcodebuild test` — les 139 tests existants **doivent** rester verts, les nouveaux s'y ajoutent.

---

## 4. Budget performance (référence STARTUP_PROFILE.md)

| Métrique | Référence mesurée | Budget après migration | Tolérance |
|----------|-------------------|------------------------|-----------|
| Cold start → `WINDOW_CREATED` | 119 ms | ≤ 130 ms | +10 % |
| Construction vue racine | 9 ms | ≤ 12 ms | +3 ms |
| `onAppear` (light init) | 5 ms | ≤ 10 ms | +5 ms |
| Boot Phoenix (async, main libre) | 4 728 ms | inchangé (hors périmètre) | — |
| Boot manager (`EXEC_BOOT`) | 316 ms | ≤ 350 ms | +10 % |
| Charge main thread pendant boot | 25 ms | ≤ 30 ms | +5 ms |

Mesure : instrumentation `[BOOT]` existante (STARTUP_TIMELINE.md), comparée avant/après chaque étape de MIGRATION_PLAN.md.

---

## 5. Gates de validation

| Gate | Critère | Validateur |
|------|---------|------------|
| INPUT | artefacts d'architecture certifiés (8 livrables) | FACTORY_01 |
| EXECUTION | chaque étape MIGRATION_PLAN produite avec build+tests verts | SUPRA-Runtime / Builder |
| OUTPUT | S1–S5 passés + budget performance respecté + 0 violation de couche | FACTORY_07_QUALITY |
| CERTIFICATION | preuves rassemblées (tests, profilage, analyse statique) | FACTORY_06_PROOF |
| EXECUTIVE | décision CONTINUE / ADAPT / REPLAN / HALT | FACTORY_10_EXECUTIVE |

---

## 6. Preuves exigées

| Preuve | Source |
|--------|--------|
| `BOOT_REPORT.json` (S1 et S2) | Bootstrap |
| Résultats `xcodebuild test` | Xcode |
| STARTUP_TIMELINE avant/après | instrumentation `[BOOT]` |
| Rapport d'analyse statique (patterns interdits) | BootstrapGovernance étendu |
| Diff des vues (vide) | git |
| Checksums des artefacts installés | BOOT_REPORT.json |

---

## 7. Critère global de succès

> **Le Runtime démarre toujours dans un environnement valide.**
> Aucun module métier n'accède directement au système de fichiers.
> Aucun `... not found` sur un premier lancement normal.

---

**END OF BOOTSTRAP_VALIDATION** — produit par FACTORY_01_ARCHITECTURE, mission FOUNDATION ERA.
