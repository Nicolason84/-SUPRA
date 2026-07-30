# CLEANUP PREPARATION — SUPRA FOUNDATION MEMORY V1

**Mission**: SUPRA_FOUNDATION_MEMORY_SYSTEM_V1  
**Date**: 2026-07-24T17:35:00Z  
**Règle**: NE RIEN SUPPRIMER — simple préparation documentaire

---

## À CONSERVER

| Élément | Chemin | Justification | Risque |
|---------|--------|---------------|--------|
| SUPRA (canonique) | `~/Desktop/NOVA_OS/SUPRA` | Projet build PASS, Git, développement actif | Critique |
| CAnnoNicoIntegrationPackage | `SUPRA/Packages/CAnnoNicoIntegrationPackage` | Dépendance de build | Critique |
| NICO_APP | `~/NOVA_OS/NICO_APP_IOS/NICO_APP` | Projet iOS actif | Élevé |
| SUPRA_VIDEO_SWAP_V3 | `~/Desktop/SUPRA_VIDEO_SWAP_V3` | Projet actif (293 fichiers) | Moyen |
| NOVA_BUILD_SYSTEM | `~/NOVA_BUILD_SYSTEM` | Orchestration de builds | Moyen |
| HELENE_APP | `~/NOVA_OS/HELENE_APP_IOS/SUPRA_HELENE` | Standalone iOS actif | Moyen |

---

## À FUSIONNER

| Élément | Cible | Justification | Risque | Effort |
|---------|-------|---------------|--------|--------|
| SUPRA_RECOVERY/CHAT (Swift) | `SUPRA/SUPRA/` si différences | Récupérer correctifs potentiels | **Moyen** | Élevé |
| SUPRA_RECOVERY/BRIDGE (Swift) | `SUPRA/SUPRA/` si différences | Idem | **Moyen** | Élevé |
| SUPRA_RECOVERY/HEALTH (Swift) | `SUPRA/SUPRA/` si différences | Idem | **Moyen** | Élevé |
| SUPRA_RECOVERY/BASELINE (Swift) | `SUPRA/SUPRA/` si différences | Idem | **Moyen** | Élevé |

**Note**: Lancer `diff -rq SUPRA_RECOVERY SUPRA/SUPRA` pour détecter les différences avant toute fusion.

---

## À DÉPLACER

| Élément | Destination | Justification | Risque | Espace |
|---------|-------------|---------------|--------|--------|
| FREEZE_SUPRA_* (×5) | `SUPRA/_SUPRA_BACKUPS/freezes/` | Freezes temporels, pas dans racine | Faible | ~12 MB |
| SUPRA_BISECT | `SUPRA/_SUPRA_BACKUPS/bisect/` | Copie obsolète après build stable | Faible | 17 MB |
| SUPRA_RECOVERY | `SUPRA/_SUPRA_BACKUPS/recovery/` | Snapshots de récupération | Faible | 11 MB |
| Logs recovery Bureau (×3) | `SUPRA/_SUPRA_BACKUPS/logs/` | Logs de diagnostic | Faible | 236 MB |
| SUPRA_TEMP | `SUPRA/_SUPRA_BACKUPS/temp/` | Travail temporaire | Faible | 33 MB |

---

## À ARCHIVER

| Élément | Méthode | Justification | Espace |
|---------|---------|---------------|--------|
| SUPRA_VIDEO_SWAP_APP_V1 | Archivage (tar/zip) ou déplacement | Version legacy remplacée par V3 | 20 MB |
| SUPRA_PROJECTS | Archivage | Projets de référence, plus actifs | 13 MB |
| _DESKTOP_CLEAN_ARCHIVE | Archivage | Ancien ménage du Bureau | 4.4 MB |
| SUPRA_VIDEO_SWAP_V1_ARCHIVE | Déjà une archive, à déplacer | Double archivage | 0.2 MB |

---

## À SUPPRIMER ULTÉRIEUREMENT

| Élément | Quand | Justification | Espace |
|---------|-------|---------------|--------|
| DerivedData Xcode | Après validation build stable | Cache de compilation | **~28 GB** |
| SUPRA_BISECT | Après 1 semaine sans régression | Copie de bissection inutile | 17 MB |
| SUPRA_RECOVERY | Après fusion des différences | Snapshots récupérés | 11 MB |
| Logs recovery Bureau | Après archivage réussi | Logs de diagnostic | 236 MB |
| FREEZE_SUPRA_* | Après archivé dans _BACKUPS | Freezes temporels | 12 MB |
| ContentView backups (.bak) | Après vérification | Backups de version | Négligeable |
| SUPRA_TEMP | Après archivage | Travail temporaire | 33 MB |

---

## Estimation Totale de l'Espace Récupérable

| Catégorie | Espace | Priorité |
|-----------|--------|----------|
| DerivedData Xcode | ~28 GB | Haute |
| Logs recovery Bureau | 236 MB | Haute |
| FREEZE_SUPRA_* | ~12 MB | Haute |
| SUPRA_TEMP | 33 MB | Haute |
| SUPRA_BISECT | 17 MB | Moyenne |
| SUPRA_RECOVERY | 11 MB | Moyenne |
| SUPRA_VIDEO_SWAP_V1 | 20 MB | Moyenne |
| SUPRA_PROJECTS | 13 MB | Basse |
| _DESKTOP_CLEAN_ARCHIVE | 4.4 MB | Basse |
| **Total** | **~28.3 GB** | |

**Note**: Le DerivedData Xcode représente ~96% de l'espace récupérable.  
Les DerivedData se trouvent dans `~/Library/Developer/Xcode/DerivedData/`.

---

## Actions Sans Risque (Exécutables Immédiatement)

1. Renommer les fichiers `.bak` (ContentView backups) avec préfixe `_`
2. Supprimer les dossiers vides (SUPRA_SCRIPTS, SUPRA_V4, SUPRA_XCODE_IDENTITY)
3. Supprimer les `.DS_Store` superflus
4. Archiver les FREEZE_SUPRA_* dans `_SUPRA_BACKUPS/freezes/`

## Actions Nécessitant Prudence

5. Comparer SUPRA_RECOVERY vs SUPRA avant fusion
6. Nettoyer DerivedData Xcode (reconstruire après)
7. Choisir entre NICO_APP et NICO_APP_CLEAN
8. Consolider SUPRA_HELENE standalone/integrated
