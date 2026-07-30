# SUPRA WORKSPACE RISK MATRIX

**Version**: 1.0  
**Status**: VALIDATED  
**Category**: Workspace Validation  
**Path**: `SUPRA_WORKSPACE_RISK_MATRIX.md`

---

## Matrice des Risques — Migration Workspace SUPRA

### Échelle

| Niveau | Impact | Probabilité |
|--------|--------|-------------|
| 1 | Très Faible | Improbable (<5%) |
| 2 | Faible | Rare (5-20%) |
| 3 | Moyen | Possible (20-50%) |
| 4 | Élevé | Probable (50-80%) |
| 5 | Critique | Certain (>80%) |

---

## Risques Identifiés

### R1 — Perte de données lors d'un déplacement

| Champ | Valeur |
|-------|--------|
| **Description** | Un fichier est écrasé ou perdu pendant un `mv` vers une destination existante |
| **Impact** | 4 — Élevé |
| **Probabilité** | 2 — Faible (si backup fait) |
| **Niveau** | **8** — MOYEN |
| **Symptômes** | Fichier manquant, doublon, contenu tronqué |
| **Mitigation** | Backup complet avant chaque phase ; `cp` au lieu de `mv` pour les données critiques ; vérification checksum post-mouvement |
| **Rollback** | Restauration depuis le backup ; reverse `mv` |
| **Responsable** | Builder |

### R2 — Rupture de références Xcode

| Champ | Valeur |
|-------|--------|
| **Description** | Déplacement de dossiers référencés par des chemins absolus dans le projet Xcode (xcodeproj) |
| **Impact** | 4 — Élevé |
| **Probabilité** | 3 — Possible |
| **Niveau** | **12** — ÉLEVÉ |
| **Symptômes** | Xcode ne trouve plus les fichiers, échec de build |
| **Mitigation** | Vérifier les références Xcode avant tout déplacement ; utiliser des references relatives ; regénérer le xcodeproj si nécessaire |
| **Rollback** | Restauration du xcodeproj depuis backup |
| **Responsable** | Builder + Architect |

### R3 — Écrasement de `SUPRA_SCRIPTS/` existant

| Champ | Valeur |
|-------|--------|
| **Description** | Phase 0 déplace 30 scripts vers `SUPRA_SCRIPTS/` sans vérifier le contenu existant, causant des collisions |
| **Impact** | 3 — Moyen |
| **Probabilité** | 4 — Probable (contenu inconnu) |
| **Niveau** | **12** — ÉLEVÉ |
| **Symptômes** | Scripts écrasés ou mélangés |
| **Mitigation** | Vérifier le contenu de `SUPRA_SCRIPTS/` avant Phase 0 ; backup du dossier ; merge manuel si conflit |
| **Rollback** | Restauration depuis backup |
| **Responsable** | Builder |

### R4 — Échec de compression de `SUPRA_BUILD/import/`

| Champ | Valeur |
|-------|--------|
| **Description** | La compression de 65535 fichiers (~4.5 GB) échoue (timeout, espace disque insuffisant, fichier corrompu) |
| **Impact** | 3 — Moyen |
| **Probabilité** | 3 — Possible |
| **Niveau** | **9** — MOYEN |
| **Symptômes** | Archive corrompue, processus interrompu, espace disque plein |
| **Mitigation** | Vérifier l'espace disque avant (min 10 GB libre) ; compression par lots de 5000 fichiers ; vérification checksum post-archive |
| **Rollback** | Conservation des fichiers source jusqu'à vérification de l'archive |
| **Responsable** | Builder |

### R5 — Confusion de snapshots lors de la consolidation

| Champ | Valeur |
|-------|--------|
| **Description** | 5 Core copies (BISECT, FRESH, MODEL_TEST, RECOVERY, EVIDENCE) sont mélangées ou mal identifiées pendant le merge |
| **Impact** | 2 — Faible |
| **Probabilité** | 3 — Possible |
| **Niveau** | **6** — FAIBLE |
| **Symptômes** | Dossier mal nommé, date incorrecte |
| **Mitigation** | Identifier chaque snapshot par sa date et son contenu avant le merge ; manifeste JSON associé |
| **Rollback** | Restauration depuis backup |
| **Responsable** | Builder |

### R6 — Suppression accidentelle de données temporaires non backupées

| Champ | Valeur |
|-------|--------|
| **Description** | Purge de `SUPRA_TEMP/` ou fichiers Desktop supprimant des données non backupées |
| **Impact** | 2 — Faible |
| **Probabilité** | 2 — Rare (backup complet avant) |
| **Niveau** | **4** — TRÈS FAIBLE |
| **Symptômes** | Donnée manquante |
| **Mitigation** | Backup avant chaque purge ; vérification visuelle ; période de rétention de 7 jours |
| **Rollback** | Restauration depuis backup |
| **Responsable** | Builder |

### R7 — Dégradation des performances macOS (Finder, Spotlight)

| Champ | Valeur |
|-------|--------|
| **Description** | Déplacement massif de fichiers provoque une réindexation Spotlight ou un ralentissement Finder |
| **Impact** | 1 — Très Faible |
| **Probabilité** | 4 — Probable |
| **Niveau** | **4** — TRÈS FAIBLE |
| **Symptômes** | Finder lent, Spotlight en cours d'indexation |
| **Mitigation** | Exécuter les opérations lourdes en dehors des heures de travail ; ajouter les dossiers volumineux aux exclusions Spotlight |
| **Rollback** | Aucun nécessaire (effet temporaire) |
| **Responsable** | — |

### R8 — Incohérence Workspace Index après migration

| Champ | Valeur |
|-------|--------|
| **Description** | L'Index n'est pas mis à jour après une phase de migration, créant un décalage entre la réalité et la documentation |
| **Impact** | 3 — Moyen |
| **Probabilité** | 3 — Possible |
| **Niveau** | **9** — MOYEN |
| **Symptômes** | L'Index référence des chemins qui n'existent plus |
| **Mitigation** | Mettre à jour l'Index immédiatement après chaque phase ; validation croisée par Audit |
| **Rollback** | Correction manuelle de l'Index |
| **Responsable** | Builder + Auditor |

### R9 — Rollback impossible après Phase 2

| Champ | Valeur |
|-------|--------|
| **Description** | La création de nouveaux dossiers (Products/, Archives/, Snapshots/) et le déplacement massif rendent le rollback complexe |
| **Impact** | 4 — Élevé |
| **Probabilité** | 2 — Faible |
| **Niveau** | **8** — MOYEN |
| **Symptômes** | Impossible de revenir à l'état initial simplement |
| **Mitigation** | Snapshot du système de fichiers avant Phase 2 ; script de rollback préparé à l'avance ; tests en dry-run |
| **Rollback** | Script de rollback pré-écrit + restauration depuis Time Machine |
| **Responsable** | Architect + Builder |

### R10 — Erreur humaine (mauvais chemin, mauvaise cible)

| Champ | Valeur |
|-------|--------|
| **Description** | Un opérateur déplace un dossier vers la mauvaise destination |
| **Impact** | 3 — Moyen |
| **Probabilité** | 3 — Possible |
| **Niveau** | **9** — MOYEN |
| **Symptômes** | Dossier à un emplacement inattendu |
| **Mitigation** | Scripts de migration automatisés (pas de commandes manuelles) ; dry-run avant exécution ; double validation |
| **Rollback** | Reverse `mv` |
| **Responsable** | Builder |

---

## Synthèse

| # | Risque | I | P | Niveau | Mitigation | Rollback |
|---|--------|---|---|--------|------------|----------|
| R1 | Perte de données | 4 | 2 | MOYEN | Backup complet | Restauration backup |
| R2 | Rupture références Xcode | 4 | 3 | **ÉLEVÉ** | Vérification préalable | Restauration xcodeproj |
| R3 | Écrasement SUPRA_SCRIPTS/ | 3 | 4 | **ÉLEVÉ** | Vérification pré-contenu | Restauration backup |
| R4 | Échec compression import/ | 3 | 3 | MOYEN | Espace disque + lots | Conservation source |
| R5 | Confusion snapshots | 2 | 3 | FAIBLE | Manifeste + dates | Restauration backup |
| R6 | Suppression accidentelle | 2 | 2 | TRÈS FAIBLE | Backup + vérification | Restauration backup |
| R7 | Perf macOS | 1 | 4 | TRÈS FAIBLE | Exclusions Spotlight | Aucun |
| R8 | Incohérence Index | 3 | 3 | MOYEN | MAJ immédiate | Correction manuelle |
| R9 | Rollback impossible P2 | 4 | 2 | MOYEN | Snapshot + script pré-écrit | Time Machine |
| R10 | Erreur humaine | 3 | 3 | MOYEN | Scripts automatisés | Reverse mv |

### Risques résiduels (après mitigation)

| # | Risque résiduel | Niveau résiduel | Acceptable ? |
|---|-----------------|-----------------|--------------|
| R1 | Perte de données | TRÈS FAIBLE | ✅ Oui |
| R2 | Rupture Xcode | FAIBLE | ✅ Oui (avec vérification) |
| R3 | Écrasement scripts | FAIBLE | ✅ Oui (avec backup) |
| R4 | Échec compression | FAIBLE | ✅ Oui (lots) |
| R5 | Confusion snapshots | TRÈS FAIBLE | ✅ Oui |
| R6 | Suppression accidentelle | TRÈS FAIBLE | ✅ Oui |
| R7 | Perf macOS | TRÈS FAIBLE | ✅ Oui |
| R8 | Incohérence Index | FAIBLE | ✅ Oui |
| R9 | Rollback impossible | FAIBLE | ✅ Oui |
| R10 | Erreur humaine | FAIBLE | ✅ Oui |

**Conclusion**: Tous les risques sont couverts par une mitigation et un rollback.  
Aucun risque résiduel n'est inacceptable.
