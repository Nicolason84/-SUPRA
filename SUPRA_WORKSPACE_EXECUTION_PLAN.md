# SUPRA WORKSPACE EXECUTION PLAN

**Version**: 1.0  
**Status**: VALIDATED  
**Category**: Workspace Validation  
**Path**: `SUPRA_WORKSPACE_EXECUTION_PLAN.md`

---

## Ordre Officiel de Migration

### Structure générale

```
Gate 0 ──> Backup ──> Phase 0 ──> Gate 1 ──> Phase 1 ──> Gate 2 ──> Phase 2 ──> Gate 3 ──> Phase 3 ──> Gate 4
              ↑            ↑              ↑              ↑              ↑              ↑
              ├── Quick Wins (P0) avant Phase 0
              ├── Phase 0 : Desktop Files (P1)
              ├── Phase 1 : NOVA_OS Siblings (P2)
              ├── Phase 2 : Desktop Dirs (P3)
              └── Phase 3 : Core Internal (P4)
```

---

## Étape 0 — Quick Wins (Pré-Phase 0)

| Champ | Valeur |
|-------|--------|
| **Prérequis** | Aucun |
| **Entrée** | Desktop avec ~95 items |
| **Sortie** | Desktop avec ~43 items |
| **Actions** | Voir `SUPRA_WORKSPACE_QUICK_WINS.md` |
| **Validation** | Desktop < 50 items |
| **Rollback** | Reverse mv pour chaque action |
| **Durée** | 20 minutes |
| **Risque** | Négligeable |

---

## Étape 1 — Backup Complet

| Champ | Valeur |
|-------|--------|
| **Prérequis** | Quick Wins terminés |
| **Entrée** | Workspace actuel |
| **Sortie** | Snapshot backup + checksums |
| **Actions** | 1. `tar -czf ~/Desktop/_SUPRA_BACKUPS/workspace_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C ~/Desktop .` |
| | 2. Générer SHA256 de tous les dossiers cibles |
| | 3. Copie de sécurité des dossiers critiques (SUPRA_SCRIPTS/, SUPRA_PROJECTS/) |
| **Validation** | Backup vérifié (checksum + taille) ; 2 copies |
| **Rollback** | N/A (c'est le backup) |
| **Durée** | 30-60 minutes (dépend de la taille) |
| **Risque** | Faible |

---

## Étape 2 — Phase 0 : Desktop Files Cleanup

| Champ | Valeur |
|-------|--------|
| **Prérequis** | Backup OK ; SUPRA_SCRIPTS/ content audité |
| **Entrée** | Fichiers Desktop dispersés |
| **Sortie** | Fichiers classés dans leurs dossiers cibles |
| **Actions** | 1. Déplacer 30 scripts vers SUPRA_SCRIPTS/ |
| | 2. Déplacer logs vers Logs/ |
| | 3. Déplacer rapports .txt vers Reports/ |
| | 4. Déplacer .md test vers SUPRA_TEMP/ |
| | 5. Déplacer .png vers Evidence/ |
| **Validation** | Aucun fichier .sh/.log/.txt/.md/.png à la racine du Desktop |
| **Rollback** | Reverse mv pour chaque opération |
| **Durée** | 15-30 minutes |
| **Risque** | Faible |

---

## Étape 3 — Phase 1 : NOVA_OS Sibling Consolidation

| Champ | Valeur |
|-------|--------|
| **Prérequis** | Phase 0 terminée et validée |
| **Entrée** | 5 snapshots Core dans NOVA_OS/ (BISECT, FRESH, MODEL_TEST, RECOVERY, EVIDENCE_READONLY) |
| **Sortie** | 1 snapshot consolidé dans SUPRA_PROJECTS/ |
| **Actions** | 1. Créer `SUPRA_PROJECTS/CORE_SNAPSHOTS/` |
| | 2. Créer un manifeste JSON listant chaque snapshot (date, taille, hash) |
| | 3. Déplacer chaque dossier dans `SUPRA_PROJECTS/CORE_SNAPSHOTS/` |
| | 4. Mettre à jour Workspace Index |
| **Validation** | Tous les snapshots sont dans SUPRA_PROJECTS/CORE_SNAPSHOTS/ ; aucun dans NOVA_OS/ |
| **Rollback** | Restauration depuis backup + reverse mv |
| **Durée** | 2-3 heures |
| **Risque** | Moyen |

---

## Étape 4 — Phase 2 : Desktop Directory Restructuring

| Champ | Valeur |
|-------|--------|
| **Prérequis** | Phase 1 terminée et validée ; snapshot système avant phase |
| **Entrée** | Desktop avec dossiers plats |
| **Sortie** | Desktop structuré : Products/, Archives/, Snapshots/, Scripts/ |
| **Actions** | (exécutées dans l'ordre) |
| | **Sous-phase 2a** : Créer les dossiers catégories |
| | - `mkdir ~/Desktop/Products ~/Desktop/Archives ~/Desktop/Snapshots ~/Desktop/Scripts` |
| | **Sous-phase 2b** : Déplacer produits |
| | - `SUPRA_VIDEO_SWAP_APP_V1/` → `Products/SUPRA_VIDEO_SWAP/V1/` |
| | - `SUPRA_VIDEO_SWAP_V3/` → `Products/SUPRA_VIDEO_SWAP/V3/` |
| | - `PLATFORM_CORE/` → `Products/PLATFORM_CORE/` |
| | - `*.app` → `Products/SUPRA_VIDEO_SWAP/Bundles/` |
| | **Sous-phase 2c** : Déplacer archives |
| | - `SUPRA_ARCHIVE/` → `Archives/SUPRA_ARCHIVE/` |
| | - Archives datées → `Archives/` |
| | **Sous-phase 2d** : Déplacer snapshots |
| | - `SUPRA_PROJECTS/` → `Snapshots/SUPRA_PROJECTS/` |
| | - Tous les snapshots datés → `Snapshots/` organisés par thème |
| | **Sous-phase 2e** : Archiver SUPRA_BUILD/import/ |
| | - Compression par lots de 5000 fichiers |
| | - Archive dans `Archives/External/SUPRA_BUILD_import.tar.gz` |
| | **Sous-phase 2f** : Déplacer scripts |
| | - SUPRA_SCRIPTS/ → Scripts/SUPRA_SCRIPTS/ |
| **Validation** | Desktop < 10 dossiers ; toutes les catégories créées |
| **Rollback** | Script de rollback pré-écrit ; restauration depuis snapshot |
| **Durée** | 4-6 heures |
| **Risque** | Élevé (nécessite validation Gate) |

---

## Étape 5 — Phase 3 : Core Internal Cleanup

| Champ | Valeur |
|-------|--------|
| **Prérequis** | Phase 2 terminée et validée |
| **Entrée** | SUPRA CORE actuel (inchangé depuis le début) |
| **Sortie** | Core organisé : archives déplacées, temporaires purgés |
| **Actions** | 1. Vérifier SUPRA_RUNTIME/Blocked/ — décider quoi faire |
| | 2. Archiver SUPRA_RUNTIME/Done/ si pertinent |
| | 3. Nettoyer les dossiers cachés temporaires (.mechanical_extract_backup*, .overnight_audit/, .restore_build/) |
| | 4. Mettre à jour Workspace Index |
| **Validation** | Core inchangé structurellement ; dossiers temporaires archivés |
| **Rollback** | Restauration depuis backup |
| **Durée** | 1-2 heures |
| **Risque** | Très faible |

---

## Synthèse des Étapes

| Étape | Nom | Durée | Risque | Dépend de |
|-------|-----|-------|--------|-----------|
| 0 | Quick Wins | 20 min | Négligeable | Aucune |
| 1 | Backup | 60 min | Faible | Étape 0 |
| 2 | Phase 0 | 30 min | Faible | Étape 1 |
| 3 | Phase 1 | 3 h | Moyen | Étapes 1-2 |
| 4 | Phase 2 | 6 h | Élevé | Étapes 1-3 |
| 5 | Phase 3 | 2 h | Très faible | Étapes 1-4 |
| | **Total** | **~13 h** | | |

### Répartition recommandée

| Jour | Fenêtre | Étapes | Durée |
|------|---------|--------|-------|
| Jour 1 | Matin | Quick Wins + Backup | 1.5 h |
| Jour 1 | Après-midi | Phase 0 + Phase 1 | 3.5 h |
| Jour 2 | Matin | Phase 2 (sous-phases a-c) | 3 h |
| Jour 2 | Après-midi | Phase 2 (sous-phases d-f) + Phase 3 | 4 h |
| Jour 2 | Fin | Validation finale + Rollback si nécessaire | 1 h |
