# EXECUTIVE_BOOTSTRAP.md

## Charte de mission — EXECUTIVE BOOTSTRAP V1

| Field | Value |
|-------|-------|
| **Mission** | EXECUTIVE BOOTSTRAP V1 — Industrialisation du Runtime SUPRA |
| **Codename** | FOUNDATION ERA |
| **Priority** | CRITICAL |
| **Mode** | Architecture First |
| **Date** | 2026-07-31 |
| **Autorité** | FACTORY_10_EXECUTIVE — ligne de développement V2 (NEXT_DECISION V2_TRANSITION_V1) |
| **Baseline** | BUILD_CERTIFIED_V1 (immuable, commit `7488aa0`) |
| **Branche** | `executive-runtime-v2` |
| **Verdict Sprint 0** | ✅ Terminé — build stable, tests 139/139, runtime interactif, Main Thread non bloqué |
| **Artefacts** | 8 livrables d'architecture (voir § 6) |

---

## 1. Contexte

Sprint 0 est considéré comme terminé :

| État constaté | Verdict |
|---------------|---------|
| Build stable | ✅ BUILD SUCCEEDED, 0 erreur, 0 warning actionnable |
| Tests PASS | ✅ 139/139 |
| Runtime interactif | ✅ |
| Navigation opérationnelle | ✅ |
| Main Thread non bloqué | ✅ (prouvé par STARTUP_PROFILE.md — 25 ms de charge main sur 4.88 s de boot Phoenix) |
| Startup validé | ✅ (cold start 119 ms, fenêtre < 10 ms) |

**Anomalies résiduelles** : absence d'artefacts attendus (`BUILD_STATUS.md`, `CONTINUITY.md`, `NEXT_MISSION.md`, …) → symptôme d'une **dépendance directe du Runtime aux chemins du workspace** : quand l'artefact manque, le Runtime affiche `... not found`.

Le Runtime est stable. La priorité n'est plus la stabilisation : elle devient **l'industrialisation**.

---

## 2. Objectif global

Transformer le Runtime SUPRA en architecture canonique composée de couches strictement séparées :

```
Foundation Layer
    ↓
Infrastructure Layer
    ↓
Runtime Layer
    ↓
Domain Layer
```

Chaque couche possède **une responsabilité unique**. Aucune couche ne traverse la couche inférieure pour accéder au système de fichiers.

---

## 3. Analyse de l'existant (constat d'entrée)

L'architecture actuelle fait reposer la persistance et la lecture d'artefacts directement sur des composants Runtime :

| Composant existant | Rôle | Problème constaté |
|--------------------|------|-------------------|
| `SUPRAEnvironmentResolver` | Résout `projectRoot` | Exposition de chemins bruts (`workspaceRoot`), point de fuite de la persistance |
| `ExecutiveBootManager` | Séquences de boot, vérification du continuity pack | Lecture directe `FileManager.contents(atPath:)` sur 7 fichiers racine ; spawn git avec `process.waitUntilExit()` (bloquant) |
| `ContinuityManager` | Chargement d'état, diagnostics d'artefacts | Lecture directe de 9+ fichiers racine ; spawn git bloquant ; log `... not found` à chaque absence |
| `ArtifactReader` | Lecture LOT1/2/3, BUILD_STATUS, MANIFEST, ESTATE, INDEX | `URL(fileURLWithPath:)` construits à la main, chemins câblés en dur |
| `BootstrapGovernance` | Analyse statique du graphe de dépendances (lecture de sources) | Hors périmètre persistance ; à conserver comme contrôle |

**Conséquence** : 4 composants Runtime connaissent les chemins du système de fichiers. La logique métier est entrelacée avec la logique de persistance.

---

## 4. Architecture cible — principes directeurs

| Principe | Énoncé |
|----------|--------|
| **Single Environment Entry** | `ExecutiveBootstrap` est le **seul** composant autorisé à préparer l'environnement d'exécution |
| **Single Artifact Access** | `ArtifactRegistry` est le **seul** point d'accès aux artefacts pour le Runtime |
| **Single Persistence Owner** | `ContinuityEngine` est le **seul** responsable de la persistance et de la synchronisation mémoire ↔ disque |
| **Business Purity** | Le Mission Runtime ne connaît ni disque, ni chemins, ni migrations |
| **No `... not found`** | Le premier lancement installe des artefacts minimaux **valides** : le Runtime ne doit jamais afficher `... not found` sur un premier lancement normal |
| **Never Reinstall** | Les lancements suivants n'exécutent que Validation → Migration éventuelle → Publication du rapport |

---

## 5. Les 4 phases

| Phase | Livrable principal | Responsabilité unique |
|-------|--------------------|-----------------------|
| **Phase 1 — Executive Bootstrap V1** | `ExecutiveBootstrap` | Préparer l'environnement d'exécution : premier lancement, version du workspace, création `Application Support/SUPRA`, sous-répertoires, installation des artefacts minimaux, vérification de cohérence, Boot Report |
| **Phase 2 — Artifact Registry V1** | `ArtifactRegistry` | API unique d'accès aux artefacts : `runtimeStatus()`, `buildStatus()`, `continuity()`, `nextMission()`, `missionQueue()` — décide où lire/écrire, comment migrer, quelles valeurs par défaut retourner |
| **Phase 3 — Continuity Engine V1** | `ContinuityEngine` | Reprise de session, snapshots, restauration, migrations, synchronisation mémoire ↔ disque. Les fichiers deviennent un **support de persistance**, plus jamais la logique métier |
| **Phase 4 — Mission Runtime V1** | `MissionRuntime` | Uniquement la séquence métier : Mission → Decision → Execution → Evidence → Memory. Aucune connaissance du disque |

### 5.1 Emplacement de persistance cible

```
~/Library/Application Support/SUPRA/
├── State/          → SUPRA_STATE.json, session_state.json
├── Runtime/        → RUNTIME_STATUS.json, runtime_diagnostics.json, runtime_metrics.json
├── Artifacts/      → MANIFEST.json, INDEX.json, ESTATE_STATE.json, proofs/ (LOT1..3)
├── Continuity/     → CONTINUITY.md, NEXT_MISSION.md, BUILD_STATUS.md
├── Snapshots/      → snapshots horodatés (continuity/session)
├── Logs/           → journaux runtime
├── Cache/          → données régénérables
└── Missions/       → MISSION_QUEUE.json, mission_history.json
```

Conformité aux bonnes pratiques Apple : lancement rapide, initialisation minimale avant affichage UI, traitements lourds différés, préparation de l'environnement au premier lancement, persistance dans Application Support, validations et migrations aux lancements suivants.

### 5.2 Artefacts minimaux installés au premier lancement

| Artefact | Contenu minimal |
|----------|-----------------|
| `SUPRA_STATE.json` | version workspace, build, missions, timestamp |
| `RUNTIME_STATUS.json` | statut build `SUCCEEDED`, artefacts disponibles, validation |
| `runtime_diagnostics.json` | pipeline_diagnostics, runtime_status, artifact diagnostics |
| `BOOT_REPORT.json` | rapport du premier lancement : environnement créé, artefacts installés, cohérence vérifiée |
| `BUILD_STATUS.md` | statut build lisible, `Build Version:` |
| `CONTINUITY.md` | marqueur `Generated:`, contexte de session précédente vide |
| `NEXT_MISSION.md` | en-tête `## Mission:` avec mission par défaut (`FOUNDATION ERA`) |
| `MISSION_QUEUE.json` | file de missions vide/initiale |

---

## 6. Livrables de la mission

| # | Artefact | Contenu |
|---|----------|---------|
| 1 | `EXECUTIVE_BOOTSTRAP.md` | **Ce document** — charte, mandat, constat, principes |
| 2 | `BOOTSTRAP_ARCHITECTURE.md` | Architecture canonique, contrats de couches, séquences de boot |
| 3 | `ARTIFACT_REGISTRY_SPEC.md` | Spécification du registre : catalogue, API, localisation, défauts, migration |
| 4 | `CONTINUITY_ENGINE_SPEC.md` | Spécification du moteur : reprise, snapshots, restauration, migrations, sync |
| 5 | `RUNTIME_LAYER_DIAGRAM.md` | Diagramme des 4 couches, composants, frontières, dépendances interdites |
| 6 | `MIGRATION_PLAN.md` | Plan de migration en 4 étapes, zéro régression, budget performance |
| 7 | `BOOTSTRAP_VALIDATION.md` | Stratégie de validation : scénarios 1er lancement / lancements suivants, budget perf |
| 8 | `EXECUTION_READINESS.md` | Verdict de readiness et décision exécutive requise pour la Phase 1 d'implémentation |

---

## 7. Contraintes impératives

| Contrainte | Détail |
|------------|--------|
| Aucune régression Startup | Les mesures STARTUP_PROFILE.md (cold start 119 ms, boot manager 316 ms) sont la référence |
| Aucun blocage Main Thread | Aucune opération bloquante sur le main actor |
| Aucun `waitUntilExit` | Interdiction formelle — tout spawn de process devient asynchrone ou supprimé |
| Aucune opération lourde avant la création de la première fenêtre | Initialisation minimale, différée ensuite |
| Préserver les performances mesurées | Budget performance défini dans BOOTSTRAP_VALIDATION.md |
| Ne pas modifier les fonctionnalités métier | La séquence Mission → Decision → Execution → Evidence → Memory est intacte |
| Ne pas introduire de nouvelle UI | Aucun changement de vue |
| Aucun refactoring non justifié | Chaque changement est motivé par les 4 phases |

---

## 8. Critères de succès

| # | Critère |
|---|---------|
| 1 | Le Runtime démarre **toujours** dans un environnement valide |
| 2 | Aucun module métier n'accède directement au système de fichiers |
| 3 | Le Bootstrap est l'unique point d'entrée de l'environnement d'exécution |
| 4 | Le Registry est l'unique point d'accès aux artefacts |
| 5 | Le Continuity Engine est l'unique responsable de la persistance |
| 6 | Le Mission Runtime est exclusivement responsable de l'exécution métier |
| 7 | L'architecture est prête pour les évolutions futures sans augmentation du couplage inter-couches |

---

## 9. Gouvernance

- **Architecture First** : la présente mission produit les artefacts d'architecture (§ 6). L'implémentation Swift fait l'objet d'une décision exécutive séparée (EXECUTION_READINESS.md).
- **Single Writer** : toute modification de fichier est réalisée par le writer de session (SUPRA-Builder).
- **Evidence** : chaque décision d'architecture est référencée dans les livrables (constat d'entrée, mesures STARTUP_PROFILE, code existant).
- **Baseline** : BUILD_CERTIFIED_V1 reste immuable ; le développement se poursuit sur `executive-runtime-v2`.

---

**END OF EXECUTIVE_BOOTSTRAP** — produit par FACTORY_01_ARCHITECTURE, mission FOUNDATION ERA.
